import 'dart:typed_data';
import 'package:kdbx/kdbx.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/data/models/vault_group.dart';
import 'package:k_passwort/security/crypto/secure_key.dart';

/// Wrapper around the kdbx package — provides KDBX 4.x read/write.
class KdbxVault {
  KdbxVault._(this._file);

  final KdbxFile _file;
  static final _format = KdbxFormat();

  /// Create a new empty KDBX 4 vault.
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
    final file = await _format.decode(data, credentials);
    return KdbxVault._(file);
  }

  /// Open using a pre-derived SecureKey (biometric unlock).
  static Future<KdbxVault> openWithKey({
    required Uint8List data,
    required SecureKey masterKey,
  }) async {
    // Use kdbx raw key credentials
    final credentials = Credentials(ProtectedValue.fromBinary(masterKey.bytes));
    final file = await _format.decode(data, credentials);
    return KdbxVault._(file);
  }

  /// Serialize the vault to bytes for saving.
  Future<Uint8List> encode() => _format.encode(_file);

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
      _file.body.rootGroup.remove(kdbxEntry);
    }
  }

  void addGroup(String name, {String? parentId}) {
    final parent = parentId != null ? _findGroup(parentId) : _file.body.rootGroup;
    if (parent != null) {
      KdbxGroup.create(file: _file, parent: parent, name: name);
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

  VaultEntry _mapEntry(KdbxEntry e) {
    return VaultEntry(
      id: e.uuid.uuid,
      title: e.getString(KdbxKeyCommon.TITLE)?.getText() ?? '',
      type: EntryType.login,
      username: e.getString(KdbxKeyCommon.USER_NAME)?.getText() ?? '',
      password: e.getString(KdbxKeyCommon.PASSWORD)?.getText() ?? '',
      url: e.getString(KdbxKeyCommon.URL)?.getText() ?? '',
      notes: e.getString(KdbxKeyCommon.NOTES)?.getText() ?? '',
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
    entry.setString(KdbxKeyCommon.NOTES, PlainValue(data.notes));

    for (final field in data.customFields) {
      final kdbxKey = KdbxKey(field.key);
      entry.setString(
        kdbxKey,
        field.isProtected
            ? ProtectedValue.fromString(field.value)
            : PlainValue(field.value),
      );
    }
  }

  static Credentials _buildCredentials(String password, Uint8List? keyFileBytes) {
    if (keyFileBytes != null) {
      return Credentials.composite(
        ProtectedValue.fromString(password),
        KeyFileCredentials(keyFileBytes),
      );
    }
    return Credentials(ProtectedValue.fromString(password));
  }
}
