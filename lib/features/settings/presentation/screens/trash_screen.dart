import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  Future<void> _restore(BuildContext context, WidgetRef ref, VaultEntry entry) async {
    await ref.read(vaultRepositoryProvider).restoreEntry(entry.id);
    ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${entry.title}" wiederhergestellt')),
      );
    }
  }

  Future<void> _deleteForever(BuildContext context, WidgetRef ref, VaultEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Endgültig löschen?'),
        content: Text(
          '"${entry.title}" wird unwiderruflich gelöscht und kann nicht wiederhergestellt werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Löschen', style: TextStyle(color: KPasswortColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(vaultRepositoryProvider).permanentlyDeleteEntry(entry.id);
    ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashed = ref.watch(trashedEntriesProvider);

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Papierkorb'),
        leading: BackButton(onPressed: () => context.go(Routes.settings)),
      ),
      body: SafeArea(
        child: trashed.isEmpty
            ? Center(
                child: Text(
                  'Papierkorb ist leer',
                  style: AppTypography.bodyMedium
                      .copyWith(color: KPasswortColors.onSurfaceVariant),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: trashed.length,
                itemBuilder: (context, index) {
                  final entry = trashed[index];
                  return ListTile(
                    leading: const Icon(Icons.delete_outline_rounded),
                    title: Text(entry.title.isEmpty ? '(ohne Titel)' : entry.title,
                        style: AppTypography.bodyMedium),
                    subtitle: Text(
                      [
                        if (entry.username.isNotEmpty) entry.username,
                        if (entry.attachments.isNotEmpty)
                          '${entry.attachments.length} Anhang/Anhänge',
                      ].join(' · '),
                      style: AppTypography.bodySmall
                          .copyWith(color: KPasswortColors.onSurfaceVariant),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.restore_rounded),
                          tooltip: 'Wiederherstellen',
                          onPressed: () => _restore(context, ref, entry),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_forever_rounded, color: KPasswortColors.error),
                          tooltip: 'Endgültig löschen',
                          onPressed: () => _deleteForever(context, ref, entry),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
