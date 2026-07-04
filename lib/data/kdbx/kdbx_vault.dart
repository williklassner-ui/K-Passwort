import 'dart:convert';
import 'dart:typed_data';
import 'package:argon2_ffi_flutter/argon2_ffi_flutter.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:kdbx/kdbx.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/data/models/vault_group.dart';
import 'package:k_passwort/security/crypto/secure_key.dart';

/// Wrapper around the kdbx package — provides KDBX read/write.
class KdbxVault {
  KdbxVault._(this._file);

  final KdbxFile _file;
  // Pure-Dart fallback format — used for encode()/create() and as safety net
  // when native Argon2 fails. open() prefers Argon2FfiFlutter (native C,
  // ~10-50× faster) which runs safely in a background isolate via compute().
  static final _format = KdbxFormat();

  static Future<KdbxVault> create({
    required String masterPassword,
    Uint8List? keyFileBytes,
  }) async {
    final credentials = _buildCredentials(masterPassword, keyFileBytes);
    final file = _format.create(
      credentials,
      'K-Passwort Vault',
      generator: 'K-Passwort',
    );
    return KdbxVault._(file);
  }

  static Future<KdbxVault> open({
    required Uint8List data,
    required String masterPassword,
    Uint8List? keyFileBytes,
  }) async {
    final args = (data, masterPassword, keyFileBytes);
    final file = await _runOffMainIsolate(_openInIsolate, args);
    return KdbxVault._(file);
  }

  static Future<KdbxVault> openWithKey({
    required Uint8List data,
    required SecureKey masterKey,
  }) async {
    final credentials = Credentials(ProtectedValue.fromBinary(masterKey.bytes));
    final file = await _format.read(data, credentials);
    return KdbxVault._(file);
  }

  /// Parses+decrypts a KDBX file. Runs the file's own (Argon2id/AES) KDF —
  /// the slow, CPU-bound step. Tries native Argon2 (Argon2FfiFlutter, ~10–50×
  /// faster than pure Dart) first; falls back to the pure-Dart implementation
  /// if the native library cannot be loaded on this device.
  /// Always runs inside a background isolate via compute() — no ANR risk.
  static Future<KdbxFile> _openInIsolate((Uint8List, String, Uint8List?) args) async {
    final (data, masterPassword, keyFileBytes) = args;
    final credentials = _buildCredentials(masterPassword, keyFileBytes);
    try {
      final nativeFormat = KdbxFormat(argon2: Argon2FfiFlutter());
      return await nativeFormat.read(data, credentials);
    } catch (_) {
      return _format.read(data, credentials);
    }
  }

  Future<Uint8List> encode() async {
    return _runOffMainIsolate(_encodeInIsolate, _file);
  }

  /// Serializes+encrypts the vault (XML build, gzip, AES). Slow for vaults
  /// with large attachments.
  static Future<Uint8List> _encodeInIsolate(KdbxFile file) async {
    late Uint8List output;
    await _format.save(file, (bytes) async {
      output = bytes;
    });
    return output;
  }

  /// Runs [fn] with [arg] in a background isolate via [compute] so the slow
  /// KDF/serialization work doesn't block the UI thread (and doesn't trip
  /// Android's ANR watchdog). Some `kdbx` package types may not be safely
  /// transferable across isolates — if the isolate hand-off itself fails,
  /// fall back to running synchronously on the calling isolate rather than
  /// crashing the open/save operation.
  static Future<R> _runOffMainIsolate<Q, R>(
    Future<R> Function(Q) fn,
    Q arg,
  ) async {
    try {
      return await compute(fn, arg);
    } catch (_) {
      return fn(arg);
    }
  }

  /// Uuid of the recycle-bin group, if one exists yet (only created lazily
  /// on first delete via [getRecycleBinOrCreate]).
  String? get _recycleBinId => _file.recycleBin?.uuid.uuid;

  List<VaultEntry> get entries {
    final binId = _recycleBinId;
    return _file.body.rootGroup
        .getAllEntries()
        .where((e) => binId == null || e.parent?.uuid.uuid != binId)
        .map(_mapEntry)
        .toList();
  }

  List<VaultGroup> get groups {
    final binId = _recycleBinId;
    return _file.body.rootGroup.groups
        .where((g) => g.uuid.uuid != binId)
        .map(_mapGroup)
        .toList();
  }

  /// Entries currently in the recycle bin ("Papierkorb"), including ones
  /// inside a deleted (sub)group.
  List<VaultEntry> get trashedEntries {
    final bin = _file.recycleBin;
    if (bin == null) return [];
    return bin.getAllEntries().map(_mapEntry).toList();
  }

  void addEntry(VaultEntry entry) {
    final target = _groupOrRoot(entry.groupId);
    final kdbxEntry = KdbxEntry.create(_file, target);
    _updateKdbxEntry(kdbxEntry, entry);
    target.addEntry(kdbxEntry);
  }

  void updateEntry(VaultEntry entry) {
    final kdbxEntry = _findEntry(entry.id);
    if (kdbxEntry == null) return;
    _updateKdbxEntry(kdbxEntry, entry);
    // Move the entry into the group matching its label (or back to root).
    final target = _groupOrRoot(entry.groupId);
    if (kdbxEntry.parent?.uuid.uuid != target.uuid.uuid) {
      _file.move(kdbxEntry, target);
    }
  }

  /// Resolves a group id to its KDBX group, falling back to the root group.
  KdbxGroup _groupOrRoot(String? groupId) {
    if (groupId == null) return _file.body.rootGroup;
    return _findGroup(groupId) ?? _file.body.rootGroup;
  }

  /// Moves the entry into the recycle bin rather than deleting it outright
  /// — recoverable via [restoreEntry] until purged or permanently deleted.
  void deleteEntry(String id) {
    final kdbxEntry = _findEntry(id);
    if (kdbxEntry != null) {
      _file.move(kdbxEntry, _file.getRecycleBinOrCreate());
    }
  }

  /// Moves a trashed entry back into the root group.
  void restoreEntry(String id) {
    final kdbxEntry = _findEntry(id);
    if (kdbxEntry != null) {
      _file.move(kdbxEntry, _file.body.rootGroup);
    }
  }

  /// Permanently removes a trashed entry — cannot be undone.
  void permanentlyDeleteEntry(String id) {
    final kdbxEntry = _findEntry(id);
    if (kdbxEntry != null) {
      kdbxEntry.parent?.entries.remove(kdbxEntry);
    }
  }

  /// Permanently removes trashed entries whose last-modification (i.e.
  /// deletion) time is older than [retentionDays] days.
  void purgeExpiredTrash(int retentionDays) {
    final bin = _file.recycleBin;
    if (bin == null) return;
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final expired = bin.getAllEntries().where((e) {
      final modified = e.times.lastModificationTime.get();
      return modified != null && modified.isBefore(cutoff);
    }).toList();
    for (final e in expired) {
      e.parent?.entries.remove(e);
    }
  }

  void addGroup(String name, {String? parentId}) {
    final parent = parentId != null ? _findGroup(parentId) : _file.body.rootGroup;
    if (parent != null) {
      // Use the file API so the group is actually attached to its parent.
      // KdbxGroup.create() alone leaves the group orphaned (never in
      // rootGroup.groups), so created categories never appeared.
      _file.createGroup(parent: parent, name: name);
    }
  }

  void updateGroup(VaultGroup group) {
    final kdbxGroup = _findGroup(group.id);
    if (kdbxGroup == null) return;
    kdbxGroup.name.set(group.name);
  }

  /// Moves the group (and its contents) into the recycle bin rather than
  /// deleting it outright.
  void deleteGroup(String id) {
    final kdbxGroup = _findGroup(id);
    if (kdbxGroup == null) return;
    _file.move(kdbxGroup, _file.getRecycleBinOrCreate());
  }

  KdbxEntry? _findEntry(String uuid) {
    return _file.body.rootGroup
        .getAllEntries()
        .where((e) => e.uuid.uuid == uuid)
        .firstOrNull;
  }

  KdbxGroup? _findGroup(String uuid) {
    return _file.body.rootGroup.groups
        .where((g) => g.uuid.uuid == uuid)
        .firstOrNull;
  }

  static final _notesKey = KdbxKey('Notes');
  static final _cfKeysKey = KdbxKey('__kpa_cf_keys');
  static final _cfMetaKey = KdbxKey('__kpa_cf_meta');
  static final _attCountKey = KdbxKey('__kpa_att_count');
  static final _tagsKey = KdbxKey('__kpa_tags');
  static final _favoriteKey = KdbxKey('__kpa_favorite');
  static final _typeKey = KdbxKey('__kpa_type');
  static const _attPrefix = '__kpa_att_';

  VaultEntry _mapEntry(KdbxEntry e) {
    // Custom field metadata (type, iconCode) stored as JSON map keyed by field name
    final cfMetaRaw = e.getString(_cfMetaKey)?.getText();
    Map<String, dynamic> cfMeta = {};
    if (cfMetaRaw != null && cfMetaRaw.isNotEmpty) {
      try {
        cfMeta = jsonDecode(cfMetaRaw) as Map<String, dynamic>;
      } catch (_) {}
    }

    // Custom fields: read via manifest key
    final cfKeysRaw = e.getString(_cfKeysKey)?.getText() ?? '';
    final customFields = <CustomField>[];
    if (cfKeysRaw.isNotEmpty) {
      for (final key in cfKeysRaw.split('\n').where((s) => s.isNotEmpty)) {
        final kdbxKey = KdbxKey(key);
        final sv = e.getString(kdbxKey);
        if (sv != null) {
          final meta = cfMeta[key] as Map<String, dynamic>?;
          final fieldType = meta != null
              ? CustomFieldType.values
                      .where((t) => t.name == meta['t'])
                      .firstOrNull ??
                  CustomFieldType.text
              : CustomFieldType.text;
          final iconCode = meta?['ic'] as int?;
          customFields.add(CustomField(
            key: key,
            value: sv.getText() ?? '',
            isProtected: sv is ProtectedValue,
            type: fieldType,
            iconCode: iconCode,
          ));
        }
      }
    }

    // Attachments: read via count key
    final attCountStr = e.getString(_attCountKey)?.getText() ?? '0';
    final attCount = int.tryParse(attCountStr) ?? 0;
    final attachments = <VaultAttachment>[];
    for (var i = 0; i < attCount; i++) {
      final sv = e.getString(KdbxKey('$_attPrefix$i'));
      if (sv == null) continue;
      try {
        final map = jsonDecode(sv.getText() ?? '') as Map<String, dynamic>;
        final bytes = base64Decode(map['d'] as String);
        attachments.add(VaultAttachment(
          name: map['n'] as String? ?? 'attachment',
          mimeType: map['m'] as String? ?? 'application/octet-stream',
          bytes: bytes.toList(),
        ));
      } catch (_) {}
    }

    // Tags
    final tagsJson = e.getString(_tagsKey)?.getText();
    final tags = <Tag>[];
    if (tagsJson != null && tagsJson.isNotEmpty) {
      try {
        final list = jsonDecode(tagsJson) as List;
        for (final item in list) {
          final m = item as Map<String, dynamic>;
          tags.add(Tag(
            name: m['n'] as String? ?? '',
            iconCode: m['ic'] as int? ?? 0,
          ));
        }
      } catch (_) {}
    }

    // isFavorite
    final favStr = e.getString(_favoriteKey)?.getText();
    final isFavorite = favStr == 'true';

    // EntryType
    final typeStr = e.getString(_typeKey)?.getText();
    final entryType = typeStr != null
        ? EntryType.values.where((t) => t.name == typeStr).firstOrNull ??
            EntryType.login
        : EntryType.login;

    return VaultEntry(
      id: e.uuid.uuid,
      title: e.getString(KdbxKeyCommon.TITLE)?.getText() ?? '',
      type: entryType,
      username: e.getString(KdbxKeyCommon.USER_NAME)?.getText() ?? '',
      password: e.getString(KdbxKeyCommon.PASSWORD)?.getText() ?? '',
      url: e.getString(KdbxKeyCommon.URL)?.getText() ?? '',
      notes: e.getString(_notesKey)?.getText() ?? '',
      customFields: customFields,
      attachments: attachments,
      createdAt: e.times.creationTime.get() ?? DateTime.now(),
      updatedAt: e.times.lastModificationTime.get() ?? DateTime.now(),
      groupId: e.parent?.uuid.uuid,
      tags: tags,
      isFavorite: isFavorite,
    );
  }

  VaultGroup _mapGroup(KdbxGroup g) {
    return VaultGroup(
      id: g.uuid.uuid,
      name: g.name.get() ?? '',
      parentId: g.parent?.uuid.uuid,
      entryIds: g.entries.map((e) => e.uuid.uuid).toList(),
      subgroupIds: g.groups.map((sg) => sg.uuid.uuid).toList(),
    );
  }

  void _updateKdbxEntry(KdbxEntry entry, VaultEntry data) {
    entry.setString(KdbxKeyCommon.TITLE, PlainValue(data.title));
    entry.setString(KdbxKeyCommon.USER_NAME, PlainValue(data.username));
    entry.setString(KdbxKeyCommon.PASSWORD, ProtectedValue.fromString(data.password));
    entry.setString(KdbxKeyCommon.URL, PlainValue(data.url));
    entry.setString(_notesKey, PlainValue(data.notes));

    // Remove all existing custom/meta fields before re-writing
    final keysToRemove = entry.stringEntries
        .map((kv) => kv.key)
        .where((k) =>
            k.key != KdbxKeyCommon.TITLE.key &&
            k.key != KdbxKeyCommon.USER_NAME.key &&
            k.key != KdbxKeyCommon.PASSWORD.key &&
            k.key != KdbxKeyCommon.URL.key &&
            k.key != 'Notes')
        .toList();
    for (final k in keysToRemove) {
      entry.setString(k, null);
    }

    for (final field in data.customFields) {
      final kdbxKey = KdbxKey(field.key);
      entry.setString(
        kdbxKey,
        field.isProtected
            ? ProtectedValue.fromString(field.value)
            : PlainValue(field.value),
      );
    }
    // Manifest of custom field keys
    entry.setString(
      _cfKeysKey,
      PlainValue(data.customFields.map((f) => f.key).join('\n')),
    );

    // Custom field metadata (type + iconCode)
    if (data.customFields.isNotEmpty) {
      final meta = <String, dynamic>{};
      for (final field in data.customFields) {
        meta[field.key] = {'t': field.type.name, 'ic': field.iconCode};
      }
      entry.setString(_cfMetaKey, PlainValue(jsonEncode(meta)));
    } else {
      entry.setString(_cfMetaKey, PlainValue(''));
    }

    for (var i = 0; i < data.attachments.length; i++) {
      final att = data.attachments[i];
      final json = jsonEncode({
        'n': att.name,
        'm': att.mimeType,
        'd': base64Encode(Uint8List.fromList(att.bytes)),
      });
      entry.setString(KdbxKey('$_attPrefix$i'), ProtectedValue.fromString(json));
    }
    entry.setString(_attCountKey, PlainValue(data.attachments.length.toString()));

    // Tags
    if (data.tags.isNotEmpty) {
      final tagsJson = jsonEncode(
        data.tags.map((t) => {'n': t.name, 'ic': t.iconCode}).toList(),
      );
      entry.setString(_tagsKey, PlainValue(tagsJson));
    } else {
      entry.setString(_tagsKey, PlainValue(''));
    }

    // isFavorite + EntryType
    entry.setString(_favoriteKey, PlainValue(data.isFavorite.toString()));
    entry.setString(_typeKey, PlainValue(data.type.name));
  }

  static Credentials _buildCredentials(String password, Uint8List? keyFileBytes) {
    if (keyFileBytes != null) {
      return Credentials.composite(
        ProtectedValue.fromString(password),
        keyFileBytes,
      );
    }
    return Credentials(ProtectedValue.fromString(password));
  }
}
