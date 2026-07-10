import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/features/vault/presentation/widgets/entry_icon_preview.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';

class EntryCard extends ConsumerWidget {
  const EntryCard({
    super.key,
    required this.entry,
    required this.index,
    this.selectionMode = false,
    this.selected = false,
    this.animate = true,
  });

  final VaultEntry entry;
  final int index;
  final bool selectionMode;
  final bool selected;
  // Whether to run the entrance animation — only true the first time a
  // tile is built, so scrolling it back into view doesn't re-animate it.
  final bool animate;

  Future<void> _copySecure(BuildContext context, String text, String label) async {
    const channel = MethodChannel(CryptoConstants.clipboardChannel);
    await channel.invokeMethod('copySecure', {
      'text': text,
      'clearAfterMs': CryptoConstants.clipboardClearDelayMs,
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$label kopiert — wird in 30s geleert'),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(entry.title, style: AppTypography.titleSmall),
            ),
            if (entry.username.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: const Text('Benutzername kopieren'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _copySecure(context, entry.username, 'Benutzername');
                },
              ),
            if (entry.password.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.key_rounded),
                title: const Text('Passwort kopieren'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _copySecure(context, entry.password, 'Passwort');
                },
              ),
            if (entry.url.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.open_in_new_rounded),
                title: const Text('URL öffnen'),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final uri = Uri.tryParse(entry.url);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                  }
                },
              ),
            ListTile(
              leading: Icon(
                entry.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: entry.isFavorite ? KPasswortColors.warning : null,
              ),
              title: Text(entry.isFavorite ? 'Favorit entfernen' : 'Als Favorit'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await ref
                    .read(vaultRepositoryProvider)
                    .updateEntry(entry.copyWith(isFavorite: !entry.isFavorite));
                ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Bearbeiten'),
              onTap: () {
                Navigator.pop(sheetCtx);
                context.push('/vault/entry/${Uri.encodeComponent(entry.id)}/edit');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: KPasswortColors.error),
              title: const Text('Löschen',
                  style: TextStyle(color: KPasswortColors.error)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('Eintrag löschen?'),
                    content: Text(
                        '"${entry.title}" wird in den Papierkorb verschoben und kann dort wiederhergestellt werden.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        child: const Text('Abbrechen'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: KPasswortColors.error),
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        child: const Text('Löschen'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(vaultRepositoryProvider).deleteEntry(entry.id);
                  ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (selectionMode) {
            _toggleSelection(ref);
          } else {
            context.push('/vault/entry/${Uri.encodeComponent(entry.id)}');
          }
        },
        onLongPress: () {
          if (selectionMode) return;
          ref.read(selectionModeProvider.notifier).state = true;
          _toggleSelection(ref);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Favicon / type icon (or selection checkmark)
              if (selectionMode)
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : KPasswortColors.onSurfaceVariant,
                  size: 24,
                )
              else
                _EntryIcon(entry: entry),
              const SizedBox(width: 14),

              // Title + size
              Expanded(
                child: Hero(
                  tag: 'entry_title_${entry.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      entry.title,
                      style: AppTypography.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),

              if (entry.attachments.isNotEmpty) ...[
                Icon(Icons.attach_file_rounded,
                    color: KPasswortColors.onSurfaceVariant, size: 14),
                const SizedBox(width: 4),
              ],
              Text(
                entry.sizeLabel,
                style: AppTypography.bodySmall,
              ),

              if (!selectionMode)
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 18),
                  color: KPasswortColors.onSurfaceVariant,
                  onPressed: () => _showActions(context, ref),
                )
              else
                const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );

    if (!animate) return card;

    // Clamp the stagger so far-down items don't get multi-second delays
    // the first time they're scrolled into view.
    final delayIndex = index.clamp(0, 12);
    return card
        .animate(delay: (delayIndex * 30).ms)
        .fadeIn(duration: 250.ms, curve: Curves.easeOut)
        .slideY(begin: 0.05, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }

  void _toggleSelection(WidgetRef ref) {
    final notifier = ref.read(selectedEntryIdsProvider.notifier);
    final current = Set<String>.from(notifier.state);
    if (current.contains(entry.id)) {
      current.remove(entry.id);
    } else {
      current.add(entry.id);
    }
    notifier.state = current;
  }
}

class _EntryIcon extends StatelessWidget {
  const _EntryIcon({required this.entry});
  final VaultEntry entry;

  @override
  Widget build(BuildContext context) => EntryIconPreview(
        iconType: entry.iconType,
        iconCode: entry.iconCode,
        iconImageBase64: entry.iconImageBase64,
        webIconUrl: entry.iconUrl,
        entryUrl: entry.url,
        entryType: entry.type,
      );
}
