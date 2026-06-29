import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:k_passwort/core/constants/crypto_constants.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';

class EntryCard extends ConsumerWidget {
  const EntryCard({super.key, required this.entry, required this.index});

  final VaultEntry entry;
  final int index;

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
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                context.go('/vault/entry/${Uri.encodeComponent(entry.id)}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: KPasswortColors.error),
              title: const Text('Löschen',
                  style: TextStyle(color: KPasswortColors.error)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('Eintrag löschen?'),
                    content: Text('"${entry.title}" wird dauerhaft gelöscht.'),
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
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/vault/entry/${Uri.encodeComponent(entry.id)}'),
        onLongPress: () => _showActions(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Favicon / type icon
              Hero(
                tag: 'entry_icon_${entry.id}',
                child: _EntryIcon(entry: entry),
              ),
              const SizedBox(width: 14),

              // Title + username
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'entry_title_${entry.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          entry.title,
                          style: AppTypography.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (entry.username.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.username,
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Favorite indicator
              if (entry.isFavorite)
                const Icon(Icons.star_rounded, color: KPasswortColors.warning, size: 16),

              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: KPasswortColors.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 30).ms)
        .fadeIn(duration: 250.ms, curve: Curves.easeOut)
        .slideY(begin: 0.05, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}

class _EntryIcon extends StatelessWidget {
  const _EntryIcon({required this.entry});
  final VaultEntry entry;

  @override
  Widget build(BuildContext context) {
    // Try favicon from URL
    final faviconUrl = _getFaviconUrl(entry.url);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: entry.type.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: faviconUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: faviconUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _TypeIcon(entry: entry),
                placeholder: (_, __) => _TypeIcon(entry: entry),
              ),
            )
          : _TypeIcon(entry: entry),
    );
  }

  String? _getFaviconUrl(String url) {
    if (url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) return null;
      return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=64';
    } catch (_) {
      return null;
    }
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.entry});
  final VaultEntry entry;

  @override
  Widget build(BuildContext context) {
    return Icon(entry.type.icon, color: entry.type.color, size: 22);
  }
}
