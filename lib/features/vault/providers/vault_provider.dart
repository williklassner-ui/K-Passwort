import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/data/models/vault_group.dart';
import 'package:k_passwort/data/repositories/vault_repository.dart';
import 'package:k_passwort/data/repositories/vault_repository_impl.dart';

/// Incremented after every vault mutation so all downstream providers re-run.
final vaultRevisionProvider = StateProvider<int>((ref) => 0);

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return VaultRepositoryImpl();
});

final vaultProvider = Provider<VaultRepository>((ref) {
  ref.watch(vaultRevisionProvider); // re-run on any mutation
  return ref.watch(vaultRepositoryProvider);
});

final entriesProvider = Provider<List<VaultEntry>>((ref) {
  ref.watch(vaultRevisionProvider);
  return ref.watch(vaultRepositoryProvider).entries;
});

final groupsProvider = Provider<List<VaultGroup>>((ref) {
  ref.watch(vaultRevisionProvider);
  return ref.watch(vaultRepositoryProvider).groups;
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredEntriesProvider = Provider<List<VaultEntry>>((ref) {
  ref.watch(vaultRevisionProvider);
  final query = ref.watch(searchQueryProvider);
  return ref.watch(vaultRepositoryProvider).search(query);
});

final selectedGroupProvider = StateProvider<String?>((ref) => null);

final groupFilteredEntriesProvider = Provider<List<VaultEntry>>((ref) {
  final entries = ref.watch(filteredEntriesProvider);
  final groupId = ref.watch(selectedGroupProvider);
  if (groupId == null) return entries;
  return entries.where((e) => e.groupId == groupId).toList();
});

final entryByIdProvider = Provider.family<VaultEntry?, String>((ref, id) {
  ref.watch(vaultRevisionProvider);
  return ref.watch(vaultRepositoryProvider).findById(id);
});
