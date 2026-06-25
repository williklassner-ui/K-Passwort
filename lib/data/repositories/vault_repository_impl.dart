import 'dart:typed_data';
import 'package:k_passwort/core/errors/failures.dart';
import 'package:k_passwort/data/kdbx/kdbx_vault.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/data/models/vault_group.dart';
import 'package:k_passwort/data/repositories/vault_repository.dart';
import 'package:k_passwort/data/storage/saf_storage.dart';

class VaultRepositoryImpl implements VaultRepository {
  KdbxVault? _vault;
  String? _currentUri;

  @override
  bool get isOpen => _vault != null;

  @override
  List<VaultEntry> get entries => _vault?.entries ?? [];

  @override
  List<VaultGroup> get groups => _vault?.groups ?? [];

  @override
  Future<void> create({
    required String vaultUri,
    required String masterPassword,
    Uint8List? keyFileBytes,
  }) async {
    _vault = await KdbxVault.create(
      masterPassword: masterPassword,
      keyFileBytes: keyFileBytes,
    );
    _currentUri = vaultUri;
    await save();
  }

  @override
  Future<void> open({
    required String vaultUri,
    required String masterPassword,
    Uint8List? keyFileBytes,
  }) async {
    final bytes = await SafStorage.readFile(vaultUri);
    if (bytes == null) throw const VaultNotFoundFailure();

    try {
      _vault = await KdbxVault.open(
        data: bytes,
        masterPassword: masterPassword,
        keyFileBytes: keyFileBytes,
      );
      _currentUri = vaultUri;
    } catch (e) {
      if (e.toString().contains('Invalid credentials')) {
        throw const WrongPasswordFailure();
      }
      throw CorruptedVaultFailure();
    }
  }

  @override
  void close() {
    _vault = null;
    _currentUri = null;
  }

  @override
  Future<void> save() async {
    if (_vault == null || _currentUri == null) return;
    final bytes = await _vault!.encode();
    final ok = await SafStorage.writeFile(_currentUri!, bytes);
    if (!ok) throw const StorageFailure('Vault konnte nicht gespeichert werden');
  }

  @override
  Future<void> addEntry(VaultEntry entry) async {
    _vault!.addEntry(entry);
    await save();
  }

  @override
  Future<void> updateEntry(VaultEntry entry) async {
    _vault!.updateEntry(entry);
    await save();
  }

  @override
  Future<void> deleteEntry(String id) async {
    _vault!.deleteEntry(id);
    await save();
  }

  @override
  Future<void> addGroup(VaultGroup group) async {
    _vault!.addGroup(group.name, parentId: group.parentId);
    await save();
  }

  @override
  Future<void> updateGroup(VaultGroup group) async {
    _vault!.updateGroup(group);
    await save();
  }

  @override
  Future<void> deleteGroup(String id) async {
    _vault!.deleteGroup(id);
    await save();
  }

  @override
  VaultEntry? findById(String id) {
    return entries.where((e) => e.id == id).firstOrNull;
  }

  @override
  List<VaultEntry> search(String query) {
    if (query.isEmpty) return entries;
    final q = query.toLowerCase();
    return entries
        .where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.username.toLowerCase().contains(q) ||
            e.url.toLowerCase().contains(q) ||
            e.notes.toLowerCase().contains(q))
        .toList();
  }
}
