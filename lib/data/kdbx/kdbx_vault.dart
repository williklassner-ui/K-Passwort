import 'dart:convert';
import 'dart:typed_data';
import 'package:kdbx/kdbx.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/data/models/vault_group.dart';
import 'package:k_passwort/security/crypto/secure_key.dart';

/// Wrapper around the kdbx package — provides KDBX read/write.
class KdbxVault {
  KdbxVault._(this._file);

  final KdbxFile _file;
  static final _format = KdbxFormat();

  /// Create a new empty KDBX vault.
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

  /// Open an existing KDBX file from bytes.
  static Future<KdbxVault> open({
    required Uint8List data,
    required String masterPassword,
    Uint8List? keyFileBytes,
  }) async {
    final credentials = _buildCredentials(masterPassword, keyFileBytes);
    final file = await _format.read(data, credentials);
    return KdbxVault._(file);
  }

  /// Open using a pre-derived SecureKey (biometric unlock).
  static Future<KdbxVault> openWithKey({
    required Uint8List data,
    required SecureKey masterKey,
  }) async {
    final credentials = Credentials(ProtectedValue.fromBinary(masterKey.bytes));
    final file = await _format.read(data, credentials);
    return KdbxVault._(file);
  }

  /// Serialize the vault to bytes for saving.
  /// kdbx 2.4.2 save() uses a writer callback; the KdbxFile holds credentials.
  Future<Uint8List> encode() async {
    late Uint8List output;
    await _format.save(_file, (bytes) async {
      output = bytes;
    });
    return output;
  }

  List<VaultEntry> get entries {
    return _file.body.rootGroup.getAllEntries().map(_mapEntry).toList();
  }

  List<VaultGroup> get groups {
    return _file.body.rootGroup.groups.map(_mapGroup).toList();
  }

  void addEntry(VaultEntry entry) {
    final kdbxEntry = KdbxEntry.create(_file, _file.body.rootGroup);
    _updateKdbxEntry(kdbxEntry, entry);
    _file.body.rootGroup.addEntry(kdbxEntry);
  }

  void updateEntry(VaultEntry entry) {
    final kdbxEntry = _findEntry(entry.id);
    if (kdbxEntry != null) _updateKdbxEntry(kdbxEntry, entry);
  }

  void deleteEntry(String id) {
    final kdbxEntry = _findEntry(id);
    if (kdbxEntry != null) {
      kdbxEntry.parent?.entries.remove(kdbxEntry);
    }
  }

  void addGroup(String name, {String? parentId}) {
    final parent = parentId != null ? _findGroup(parentId) : _file.body.rootGroup;
    if (parent != null) {
      KdbxGroup.create(ctx: _file.ctx, parent: parent, name: name);
    }
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
  static final _attCountKey = KdbxKey('__kpa_att_count');
  static const _attPrefix = '__kpa_att_';

  VaultEntry _mapEntry(KdbxEntry e) {
    // Custom fields: read via manifest key
    final cfKeysRaw = e.getString(_cfKeysKey)?.getText() ?? '';
    final customFields = <CustomField>[];
    if (cfKeysRaw.isNotEmpty) {
      for (final key in cfKeysRaw.split('\n').where((s) => s.isNotEmpty)) {
        final kdbxKey = KdbxKey(key);
        final sv = e.getString(kdbxKey);
        if (sv != null) {
          customFields.add(CustomField(
            key: key,
            value: sv.getText() ?? '',
            isProtected: sv is ProtectedValue,
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

    return VaultEntry(
      id: e.uuid.uuid,
      title: e.getString(KdbxKeyCommon.TITLE)?.getText() ?? '',
      type: EntryType.login,
      username: e.getString(KdbxKeyCommon.USER_NAME)?.getText() ?? '',
      password: e.getString(KdbxKeyCommon.PASSWORD)?.getText() ?? '',
      url: e.getString(KdbxKeyCommon.URL)?.getText() ?? '',
      notes: e.getString(_notesKey)?.getText() ?? '',
      customFields: customFields,
      attachments: attachments,
      createdAt: e.times.creationTime.get() ?? DateTime.now(),
      updatedAt: e.times.lastModificationTime.get() ?? DateTime.now(),
      groupId: e.parent?.uuid.uuid,
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

    // Remove all existing custom fields and attachments before re-writing
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
    // Write manifest so _mapEntry can locate these fields on read-back
    entry.setString(
      _cfKeysKey,
      PlainValue(data.customFields.map((f) => f.key).join('\n')),
    );

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
