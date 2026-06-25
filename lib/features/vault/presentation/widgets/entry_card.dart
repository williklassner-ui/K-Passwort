import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.entry, required this.index});

  final VaultEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/vault/entry/${Uri.encodeComponent(entry.id)}'),
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
