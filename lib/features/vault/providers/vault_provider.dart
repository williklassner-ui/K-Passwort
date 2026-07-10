import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/data/models/vault_group.dart';
import 'package:k_passwort/data/repositories/vault_repository.dart';
import 'package:k_passwort/data/repositories/vault_repository_impl.dart';
import 'package:k_passwort/features/vault/providers/vault_list_provider.dart';

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

/// Entries currently in the recycle bin ("Papierkorb").
final trashedEntriesProvider = Provider<List<VaultEntry>>((ref) {
  ref.watch(vaultRevisionProvider);
  return ref.watch(vaultRepositoryProvider).trashedEntries;
});

final searchQueryProvider = StateProvider<String>((ref) => '');

enum SortOrder { titleAZ, titleZA, newestFirst, oldestFirst, byType, bySize }

final sortOrderProvider = StateProvider<SortOrder>((_) => SortOrder.titleAZ);

final filteredEntriesProvider = Provider<List<VaultEntry>>((ref) {
  ref.watch(vaultRevisionProvider);
  final query = ref.watch(searchQueryProvider);
  final sort = ref.watch(sortOrderProvider);
  final entries = ref.watch(vaultRepositoryProvider).search(query);
  return _sortEntries(entries, sort);
});

List<VaultEntry> _sortEntries(List<VaultEntry> entries, SortOrder order) {
  final sorted = [...entries];
  switch (order) {
    case SortOrder.titleAZ:
      sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    case SortOrder.titleZA:
      sorted.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    case SortOrder.newestFirst:
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case SortOrder.oldestFirst:
      sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    case SortOrder.byType:
      sorted.sort((a, b) => a.type.index.compareTo(b.type.index));
    case SortOrder.bySize:
      sorted.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
  }
  return sorted;
}

final selectedGroupProvider = StateProvider<String?>((ref) => null);

final groupFilteredEntriesProvider = Provider<List<VaultEntry>>((ref) {
  final entries = ref.watch(filteredEntriesProvider);
  final groupId = ref.watch(selectedGroupProvider);
  if (groupId == null) return entries;
  return entries.where((e) => e.groupId == groupId).toList();
});

final selectedTagsProvider = StateProvider<Set<String>>((_) => {});

final tagFilteredEntriesProvider = Provider<List<VaultEntry>>((ref) {
  final selectedTags = ref.watch(selectedTagsProvider);
  final entries = ref.watch(groupFilteredEntriesProvider);
  if (selectedTags.isEmpty) return entries;
  return entries.where((e) => e.tags.any((t) => selectedTags.contains(t.name))).toList();
});

final favoritesOnlyProvider = StateProvider<bool>((ref) => false);

final favoritesFilteredEntriesProvider = Provider<List<VaultEntry>>((ref) {
  final entries = ref.watch(tagFilteredEntriesProvider);
  final favoritesOnly = ref.watch(favoritesOnlyProvider);
  if (!favoritesOnly) return entries;
  return entries.where((e) => e.isFavorite).toList();
});

final allTagsProvider = Provider<List<Tag>>((ref) {
  ref.watch(vaultRevisionProvider);
  final entries = ref.watch(entriesProvider);
  final seen = <String>{};
  final result = <Tag>[];
  for (final entry in entries) {
    for (final tag in entry.tags) {
      if (seen.add(tag.name)) result.add(tag);
    }
  }
  return result;
});

final entryByIdProvider = Provider.family<VaultEntry?, String>((ref, id) {
  ref.watch(vaultRevisionProvider);
  return ref.watch(vaultRepositoryProvider).findById(id);
});

/// Currently open vault URI (set when vault is opened).
final currentVaultUriProvider = StateProvider<String?>((ref) => null);

/// Display name of the currently open vault.
final currentVaultNameProvider = Provider<String>((ref) {
  final uri = ref.watch(currentVaultUriProvider);
  if (uri == null) return '';
  final vaults = ref.watch(vaultListProvider);
  return vaults.firstWhere((v) => v.uri == uri, orElse: () => VaultDescriptor(name: '', uri: uri, lastOpened: DateTime.now())).name;
});

/// Whether the vault home screen is in multi-select mode.
final selectionModeProvider = StateProvider<bool>((ref) => false);

/// IDs of entries currently selected in multi-select mode.
final selectedEntryIdsProvider = StateProvider<Set<String>>((ref) => {});
