import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/data/models/vault_group.dart';
import 'package:k_passwort/features/vault/presentation/widgets/entry_card.dart';
import 'package:k_passwort/features/vault/providers/vault_list_provider.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';
import 'package:k_passwort/ui/widgets/saving_overlay.dart';
import 'package:uuid/uuid.dart';

class VaultShell extends ConsumerWidget {
  const VaultShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    int selectedIndex = 0;
    if (location.startsWith(Routes.generator)) selectedIndex = 1;
    if (location.startsWith(Routes.settings)) selectedIndex = 2;

    return BackButtonListener(
      onBackButtonPressed: () async {
        // Only intercept the hardware back button on the top-level tabs.
        // For pushed sub-routes (entry detail/edit) return false so go_router
        // and any inner PopScope (e.g. discard-changes prompt) handle the pop.
        final loc = GoRouterState.of(context).uri.path;
        final atTopLevel = loc == Routes.vault ||
            loc == Routes.generator ||
            loc == Routes.settings;
        if (!atTopLevel) return false;

        final exit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('App beenden?'),
            content: const Text('K-Passwort wirklich beenden?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Beenden'),
              ),
            ],
          ),
        );
        if (exit == true) SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go(Routes.vault);
              case 1:
                context.go(Routes.generator);
              case 2:
                context.go(Routes.settings);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield_rounded),
              label: 'Tresor',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_fix_high_outlined),
              selectedIcon: Icon(Icons.auto_fix_high_rounded),
              label: 'Generator',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Einstellungen',
            ),
          ],
        ),
      ),
    );
  }
}

class VaultHomeScreen extends ConsumerStatefulWidget {
  const VaultHomeScreen({super.key});

  @override
  ConsumerState<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends ConsumerState<VaultHomeScreen> {
  bool _searching = false;
  bool _savingGroup = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showNewGroupDialog() async {
    final nameCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neue Gruppe'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
    if (confirmed == true && nameCtrl.text.isNotEmpty && mounted) {
      setState(() => _savingGroup = true);
      final repo = ref.read(vaultRepositoryProvider);
      await repo.addGroup(VaultGroup(
        id: const Uuid().v4(),
        name: nameCtrl.text,
      ));
      ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
      if (mounted) setState(() => _savingGroup = false);
    }
  }

  Future<void> _showVaultSwitcher() async {
    final vaults = ref.read(vaultListProvider);
    final currentUri = ref.read(currentVaultUriProvider);
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Datenbank wechseln',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...vaults.map((v) => ListTile(
                  leading: Icon(
                    v.uri == currentUri
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    color: v.uri == currentUri
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(v.name),
                  onTap: v.uri == currentUri
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          final uri = Uri(
                            path: Routes.switchVault,
                            queryParameters: {'uri': v.uri, 'name': v.name},
                          );
                          context.go(uri.toString());
                        },
                )),
            ListTile(
              leading: const Icon(Icons.add_rounded),
              title: const Text('Neue Datenbank hinzufügen'),
              onTap: () {
                Navigator.pop(ctx);
                context.go(Routes.onboardingOpenVault);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _transferSelected({required bool move}) async {
    final selectedIds = ref.read(selectedEntryIdsProvider);
    if (selectedIds.isEmpty) return;
    final otherVaults = ref
        .read(vaultListProvider)
        .where((v) => v.uri != ref.read(currentVaultUriProvider))
        .toList();
    if (otherVaults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Füge zuerst eine weitere Datenbank hinzu'),
      ));
      return;
    }

    final target = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                move ? 'Verschieben nach…' : 'Kopieren nach…',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...otherVaults.map((v) => ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  title: Text(v.name),
                  onTap: () => Navigator.pop(ctx, v.uri),
                )),
          ],
        ),
      ),
    );
    if (target == null || !mounted) return;

    final pwCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Master-Passwort'),
        content: TextField(
          controller: pwCtrl,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Master-Passwort der Zieldatenbank'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(move ? 'Verschieben' : 'Kopieren'),
          ),
        ],
      ),
    );
    if (confirmed != true || pwCtrl.text.isEmpty || !mounted) return;

    setState(() => _savingGroup = true);
    try {
      await ref.read(vaultRepositoryProvider).transferEntriesToVault(
            entryIds: selectedIds.toList(),
            targetUri: target,
            targetMasterPassword: pwCtrl.text,
            move: move,
          );
      ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
      ref.read(selectionModeProvider.notifier).state = false;
      ref.read(selectedEntryIdsProvider.notifier).state = {};
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(move
              ? 'Einträge verschoben'
              : 'Einträge kopiert'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingGroup = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(tagFilteredEntriesProvider);
    final allTags = ref.watch(allTagsProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final groups = ref.watch(groupsProvider);
    final selectedGroup = ref.watch(selectedGroupProvider);
    final selectionMode = ref.watch(selectionModeProvider);
    final selectedIds = ref.watch(selectedEntryIdsProvider);
    final vaultName = ref.watch(currentVaultNameProvider);

    final hasFilters = allTags.isNotEmpty || groups.isNotEmpty;

    return Stack(
      children: [
        GradientScaffold(
      appBar: AppBar(
        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  ref.read(selectionModeProvider.notifier).state = false;
                  ref.read(selectedEntryIdsProvider.notifier).state = {};
                },
              )
            : null,
        title: selectionMode
            ? Text('${selectedIds.length} ausgewählt')
            : _searching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: AppTypography.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Suchen…',
                      border: InputBorder.none,
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: KPasswortColors.onSurfaceVariant,
                      ),
                    ),
                    onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
                  )
                : InkWell(
                    onTap: _showVaultSwitcher,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(vaultName.isEmpty ? 'Tresor' : vaultName),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more_rounded, size: 20),
                      ],
                    ),
                  ),
        actions: selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: 'Kopieren',
                  onPressed: () => _transferSelected(move: false),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz_rounded),
                  tooltip: 'Verschieben',
                  onPressed: () => _transferSelected(move: true),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(_searching ? Icons.close : Icons.search_rounded),
                  onPressed: () {
                    setState(() => _searching = !_searching);
                    if (!_searching) {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (ctx) => const _SortSheet(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.create_new_folder_outlined),
                  tooltip: 'Neue Gruppe',
                  onPressed: _showNewGroupDialog,
                ),
              ],
      ),
      floatingActionButton: selectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => context.go(Routes.entryNew),
              child: const Icon(Icons.add_rounded),
            ),
      body: entries.isEmpty && !hasFilters
          ? _EmptyState(isSearching: _searching)
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 100)),

                // Group filter chips
                if (groups.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: const Text('Alle'),
                              selected: selectedGroup == null,
                              onSelected: (_) =>
                                  ref.read(selectedGroupProvider.notifier).state = null,
                            ),
                          ),
                          ...groups.map((g) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(g.name),
                                  selected: selectedGroup == g.id,
                                  onSelected: (_) {
                                    ref.read(selectedGroupProvider.notifier).state =
                                        selectedGroup == g.id ? null : g.id;
                                  },
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),

                // Tag filter chips
                if (allTags.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: allTags.map((tag) {
                          final isSelected = selectedTags.contains(tag.name);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: tag.iconCode != 0
                                  ? Icon(
                                      IconData(tag.iconCode, fontFamily: 'MaterialIcons'),
                                      size: 14,
                                    )
                                  : null,
                              label: Text(tag.name),
                              selected: isSelected,
                              onSelected: (v) {
                                final notifier = ref.read(selectedTagsProvider.notifier);
                                final current =
                                    Set<String>.from(ref.read(selectedTagsProvider));
                                if (v) {
                                  current.add(tag.name);
                                } else {
                                  current.remove(tag.name);
                                }
                                notifier.state = current;
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                if (entries.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyState(isSearching: _searching),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return EntryCard(
                          entry: entry,
                          index: index,
                          selectionMode: selectionMode,
                          selected: selectedIds.contains(entry.id),
                        );
                      },
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
        ),
        if (_savingGroup) const SavingOverlay(),
      ],
    );
  }
}

class _SortSheet extends ConsumerWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sortOrderProvider);
    const options = [
      (SortOrder.titleAZ, 'A → Z'),
      (SortOrder.titleZA, 'Z → A'),
      (SortOrder.newestFirst, 'Neueste zuerst'),
      (SortOrder.oldestFirst, 'Älteste zuerst'),
      (SortOrder.byType, 'Nach Typ'),
      (SortOrder.bySize, 'Nach Größe'),
    ];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sortierung',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ...options.map((opt) => RadioListTile<SortOrder>(
                title: Text(opt.$2),
                value: opt.$1,
                groupValue: current,
                onChanged: (v) {
                  ref.read(sortOrderProvider.notifier).state = v!;
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching});
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.lock_outline_rounded,
            size: 64,
            color: KPasswortColors.onSurfaceVariant,
          ).animate().scale(
              begin: const Offset(0.5, 0.5),
              duration: 500.ms,
              curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'Keine Einträge gefunden' : 'Tresor ist leer',
            style: AppTypography.titleMedium
                .copyWith(color: KPasswortColors.onSurfaceVariant),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 8),
          if (!isSearching)
            Text(
              'Tippe auf + um einen Eintrag hinzuzufügen',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }
}
