import 'dart:typed_data';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/data/models/vault_group.dart';

abstract class VaultRepository {
  /// Current loaded entries (decrypted in memory).
  List<VaultEntry> get entries;
  List<VaultGroup> get groups;

  bool get isOpen;

  /// Create a new vault at the given SAF URI.
  Future<void> create({
    required String vaultUri,
    required String masterPassword,
    Uint8List? keyFileBytes,
  });

  /// Open an existing vault from the given SAF URI.
  Future<void> open({
    required String vaultUri,
    required String masterPassword,
    Uint8List? keyFileBytes,
  });

  /// Close vault (does NOT zero master key — that's SessionManager's job).
  void close();

  /// Persist current state to the SAF URI.
  Future<void> save();

  Future<void> addEntry(VaultEntry entry);
  Future<void> updateEntry(VaultEntry entry);
  Future<void> deleteEntry(String id);

  VaultEntry? findById(String id);
  List<VaultEntry> search(String query);
}
