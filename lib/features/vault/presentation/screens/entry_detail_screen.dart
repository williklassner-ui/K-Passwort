import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:k_passwort/core/constants/crypto_constants.dart';

class EntryDetailScreen extends ConsumerStatefulWidget {
  const EntryDetailScreen({super.key, required this.entryId});
  final String entryId;

  @override
  ConsumerState<EntryDetailScreen> createState() => _State();
}

class _State extends ConsumerState<EntryDetailScreen> {
  bool _passwordRevealed = false;
  int? _clipboardCountdown;

  Future<void> _copySecure(String text, String label) async {
    const channel = MethodChannel(CryptoConstants.clipboardChannel);
    await channel.invokeMethod('copySecure', {
      'text': text,
      'clearAfterMs': CryptoConstants.clipboardClearDelayMs,
    });

    // Show countdown snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$label kopiert — wird in 30s geleert'),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(entryByIdProvider(widget.entryId));

    if (entry == null) {
      return const Scaffold(body: Center(child: Text('Eintrag nicht gefunden')));
    }

    return GradientScaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'entry_title_${entry.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(entry.title, style: AppTypography.titleLarge),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/vault/entry/${entry.id}/edit'),
          ),
          IconButton(
            icon: Icon(
              entry.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: entry.isFavorite ? KPasswortColors.warning : null,
            ),
            onPressed: () async {
              final updated = entry.copyWith(isFavorite: !entry.isFavorite);
              await ref.read(vaultRepositoryProvider).updateEntry(updated);
              ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge
            _TypeBadge(type: entry.type),

            const SizedBox(height: 24),

            // Fields
            if (entry.username.isNotEmpty)
              _FieldRow(
                label: 'Benutzername',
                value: entry.username,
                icon: Icons.person_outline_rounded,
                onCopy: () => _copySecure(entry.username, 'Benutzername'),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.05),

            if (entry.password.isNotEmpty)
              _PasswordRow(
                password: entry.password,
                revealed: _passwordRevealed,
                onToggleReveal: () => setState(() => _passwordRevealed = !_passwordRevealed),
                onCopy: () => _copySecure(entry.password, 'Passwort'),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.05),

            if (entry.url.isNotEmpty)
              _FieldRow(
                label: 'URL',
                value: entry.url,
                icon: Icons.link_rounded,
                onCopy: () => _copySecure(entry.url, 'URL'),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.05),

            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              _NotesSection(notes: entry.notes)
                  .animate(delay: 250.ms).fadeIn().slideY(begin: 0.05),
            ],

            if (entry.customFields.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...entry.customFields.asMap().entries.map((e) =>
                _FieldRow(
                  label: e.value.key,
                  value: e.value.isProtected ? '••••••••' : e.value.value,
                  icon: Icons.tune_rounded,
                  onCopy: () => _copySecure(e.value.value, e.value.key),
                ).animate(delay: (280 + e.key * 50).ms).fadeIn().slideY(begin: 0.05)
              ),
            ],

            const SizedBox(height: 32),

            // Metadata
            _MetaRow('Erstellt', _formatDate(entry.createdAt)),
            _MetaRow('Geändert', _formatDate(entry.updatedAt)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final EntryType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: type.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 14, color: type.color),
          const SizedBox(width: 6),
          Text(type.name, style: AppTypography.labelSmall.copyWith(color: type.color)),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onCopy,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: KPasswortColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KPasswortColors.outline, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: KPasswortColors.primary, size: 20),
        title: Text(label, style: AppTypography.labelSmall),
        subtitle: Text(value, style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded, size: 18),
          color: KPasswortColors.onSurfaceVariant,
          onPressed: onCopy,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}

class _PasswordRow extends StatelessWidget {
  const _PasswordRow({
    required this.password,
    required this.revealed,
    required this.onToggleReveal,
    required this.onCopy,
  });

  final String password;
  final bool revealed;
  final VoidCallback onToggleReveal;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: KPasswortColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KPasswortColors.outline, width: 0.5),
      ),
      child: ListTile(
        leading: const Icon(Icons.lock_outline_rounded, color: KPasswortColors.primary, size: 20),
        title: const Text('Passwort', style: AppTypography.labelSmall),
        subtitle: ExcludeSemantics(
          child: Text(
            revealed ? password : '•' * password.length.clamp(8, 24),
            style: revealed
                ? AppTypography.passwordMedium
                : AppTypography.bodyMedium.copyWith(letterSpacing: 2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
              ),
              color: KPasswortColors.onSurfaceVariant,
              onPressed: onToggleReveal,
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              color: KPasswortColors.onSurfaceVariant,
              onPressed: onCopy,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KPasswortColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KPasswortColors.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notizen', style: AppTypography.labelSmall),
          const SizedBox(height: 8),
          Text(notes, style: AppTypography.bodyMedium.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: AppTypography.bodySmall),
          Text(value, style: AppTypography.bodySmall.copyWith(color: KPasswortColors.onBackground)),
        ],
      ),
    );
  }
}
