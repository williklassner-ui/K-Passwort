import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/features/onboarding/presentation/widgets/password_strength_indicator.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';
import 'package:k_passwort/ui/widgets/secure_text_field.dart';
import 'package:uuid/uuid.dart';

class EntryEditScreen extends ConsumerStatefulWidget {
  const EntryEditScreen({super.key, required this.entryId});
  final String? entryId;

  @override
  ConsumerState<EntryEditScreen> createState() => _State();
}

class _State extends ConsumerState<EntryEditScreen> {
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  EntryType _selectedType = EntryType.login;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      final entry = ref.read(entryByIdProvider(widget.entryId!));
      if (entry != null) _populate(entry);
    }
  }

  void _populate(VaultEntry entry) {
    _titleController.text = entry.title;
    _usernameController.text = entry.username;
    _passwordController.text = entry.password;
    _urlController.text = entry.url;
    _notesController.text = entry.notes;
    _selectedType = entry.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titel ist erforderlich')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = ref.read(vaultRepositoryProvider);
      final now = DateTime.now();

      if (widget.entryId == null) {
        final entry = VaultEntry(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          type: _selectedType,
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          url: _urlController.text.trim(),
          notes: _notesController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await repo.addEntry(entry);
      } else {
        final existing = repo.findById(widget.entryId!);
        if (existing != null) {
          final updated = existing.copyWith(
            title: _titleController.text.trim(),
            type: _selectedType,
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            url: _urlController.text.trim(),
            notes: _notesController.text.trim(),
            updatedAt: now,
          );
          await repo.updateEntry(updated);
        }
      }

      ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);

      if (mounted) {
        context.go(widget.entryId != null
            ? '/vault/entry/${widget.entryId}'
            : Routes.vault);
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.entryId == null;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Neuer Eintrag' : 'Bearbeiten'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 16, width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: KPasswortColors.primary))
                : const Text('Speichern'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            _TypeSelector(
              selected: _selectedType,
              onChanged: (t) => setState(() => _selectedType = t),
            ).animate().fadeIn(),

            const SizedBox(height: 20),

            _field(_titleController, 'Titel', Icons.label_outline_rounded,
                delay: 100),
            _field(_usernameController, 'Benutzername', Icons.person_outline_rounded,
                delay: 150),
            _secureField(delay: 200),
            _field(_urlController, 'URL', Icons.link_rounded, delay: 250),
            _field(_notesController, 'Notizen', Icons.notes_rounded,
                delay: 300, maxLines: 4),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(isNew ? 'Eintrag erstellen' : 'Änderungen speichern'),
              ),
            ).animate(delay: 350.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int delay = 0,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
      ).animate(delay: delay.ms).fadeIn().slideY(begin: 0.06),
    );
  }

  Widget _secureField({int delay = 0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SecureTextField(
            controller: _passwordController,
            label: 'Passwort',
            isPassword: true,
            isMonospace: true,
            onChanged: (_) => setState(() {}),
          ).animate(delay: delay.ms).fadeIn().slideY(begin: 0.06),
          const SizedBox(height: 8),
          PasswordStrengthIndicator(password: _passwordController.text),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onChanged});

  final EntryType selected;
  final ValueChanged<EntryType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: EntryType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final type = EntryType.values[i];
          final isSelected = type == selected;
          return FilterChip(
            label: Text(type.name),
            avatar: Icon(type.icon, size: 14),
            selected: isSelected,
            onSelected: (_) => onChanged(type),
            selectedColor: type.color.withOpacity(0.2),
            checkmarkColor: type.color,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isSelected ? type.color : KPasswortColors.onSurfaceVariant,
            ),
            side: BorderSide(
              color: isSelected ? type.color : KPasswortColors.outline,
            ),
          );
        },
      ),
    );
  }
}
