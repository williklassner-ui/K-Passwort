import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/features/vault/presentation/widgets/entry_card.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';

class VaultShell extends ConsumerWidget {
  const VaultShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    int selectedIndex = 0;
    if (location.startsWith(Routes.generator)) selectedIndex = 1;
    if (location.startsWith(Routes.settings)) selectedIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go(Routes.vault);
            case 1: context.go(Routes.generator);
            case 2: context.go(Routes.settings);
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(groupFilteredEntriesProvider);

    return GradientScaffold(
      appBar: AppBar(
        title: _searching
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
            : const Text('Tresor'),
        actions: [
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
            onPressed: () {}, // Sort options
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(Routes.entryNew),
        child: const Icon(Icons.add_rounded),
      ),
      body: entries.isEmpty
          ? _EmptyState(isSearching: _searching)
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return EntryCard(entry: entry, index: index);
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
          ).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'Keine Einträge gefunden' : 'Tresor ist leer',
            style: AppTypography.titleMedium.copyWith(color: KPasswortColors.onSurfaceVariant),
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
