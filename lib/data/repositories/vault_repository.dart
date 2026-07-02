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

  /// Moves entry [id] into the recycle bin ("Papierkorb") rather than
  /// deleting it outright — it stays recoverable via [restoreEntry] until
  /// permanently removed (manually or by [purgeExpiredTrash]).
  Future<void> deleteEntry(String id);

  Future<void> addGroup(VaultGroup group);
  Future<void> updateGroup(VaultGroup group);

  /// Moves group [id] (and its contents) into the recycle bin.
  Future<void> deleteGroup(String id);

  /// Entries currently in the recycle bin, across any deleted groups too.
  List<VaultEntry> get trashedEntries;

  /// Moves a trashed entry back into the root group.
  Future<void> restoreEntry(String id);

  /// Permanently removes a trashed entry — cannot be undone.
  Future<void> permanentlyDeleteEntry(String id);

  /// Permanently removes trashed entries older than [retentionDays] days
  /// (based on their deletion/last-modification time). No-op if nothing has
  /// expired.
  Future<void> purgeExpiredTrash(int retentionDays);

  VaultEntry? findById(String id);
  List<VaultEntry> search(String query);

  /// Creates a new optimized (fast native Argon2id) vault at [newUri],
  /// copies all current groups and entries into it, writes it, and switches
  /// the active vault to the new file.
  Future<void> migrateToNewVault({
    required String newUri,
    required String masterPassword,
  });

  /// Move or copy [entryIds] from the currently open vault into the vault at
  /// [targetUri]. Opens the target as a separate vault instance, appends the
  /// entries, and writes it back — the currently open vault stays active.
  /// If [move] is true, the entries are also deleted from the source vault.
  Future<void> transferEntriesToVault({
    required List<String> entryIds,
    required String targetUri,
    required String targetMasterPassword,
    required bool move,
  });
}
