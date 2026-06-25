import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_passwort/core/constants/icon_constants.dart';
import 'package:k_passwort/core/constants/route_constants.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/data/models/vault_group.dart';
import 'package:k_passwort/data/storage/saf_storage.dart';
import 'package:k_passwort/features/generator/providers/generator_provider.dart';
import 'package:k_passwort/features/generator/domain/password_generator.dart';
import 'package:k_passwort/features/onboarding/presentation/widgets/password_strength_indicator.dart';
import 'package:k_passwort/features/vault/providers/vault_provider.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';
import 'package:k_passwort/ui/widgets/gradient_scaffold.dart';
import 'package:k_passwort/ui/widgets/secure_text_field.dart';
import 'package:uuid/uuid.dart';

class _CfRow {
  _CfRow({
    String key = '',
    String value = '',
    bool isProtected = false,
    CustomFieldType type = CustomFieldType.text,
    int? iconCode,
  })  : keyCtrl = TextEditingController(text: key),
        valCtrl = TextEditingController(text: value),
        isProtected = isProtected,
        type = type,
        iconCode = iconCode;

  final TextEditingController keyCtrl;
  final TextEditingController valCtrl;
  bool isProtected;
  CustomFieldType type;
  int? iconCode;

  CustomField toField() => CustomField(
        key: keyCtrl.text.trim(),
        value: valCtrl.text,
        isProtected: isProtected,
        type: type,
        iconCode: iconCode,
      );

  void dispose() {
    keyCtrl.dispose();
    valCtrl.dispose();
  }
}

class EntryEditScreen extends ConsumerStatefulWidget {
  const EntryEditScreen({super.key, required this.entryId});
  final String? entryId;

  @override
  ConsumerState<EntryEditScreen> createState() => _State();
}

class _State extends ConsumerState<EntryEditScreen> {
  final _titleCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  EntryType _type = EntryType.login;
  String? _groupId;
  bool _saving = false;
  List<VaultAttachment> _attachments = [];
  final List<_CfRow> _customFields = [];
  final List<Tag> _tags = [];
  VaultEntry? _original;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      final entry = ref.read(entryByIdProvider(widget.entryId!));
      if (entry != null) {
        _original = entry;
        _populate(entry);
      }
    }
  }

  void _populate(VaultEntry e) {
    _titleCtrl.text = e.title;
    _userCtrl.text = e.username;
    _passCtrl.text = e.password;
    _urlCtrl.text = e.url;
    _notesCtrl.text = e.notes;
    _type = e.type;
    _groupId = e.groupId;
    _attachments = List.from(e.attachments);
    _tags.addAll(e.tags);
    for (final cf in e.customFields) {
      _customFields.add(_CfRow(
        key: cf.key,
        value: cf.value,
        isProtected: cf.isProtected,
        type: cf.type,
        iconCode: cf.iconCode,
      ));
    }
  }

  bool _isDirty() {
    final orig = _original;
    if (orig == null) {
      return _titleCtrl.text.isNotEmpty ||
          _userCtrl.text.isNotEmpty ||
          _passCtrl.text.isNotEmpty ||
          _urlCtrl.text.isNotEmpty ||
          _notesCtrl.text.isNotEmpty ||
          _attachments.isNotEmpty ||
          _customFields.isNotEmpty;
    }
    if (_titleCtrl.text != orig.title) return true;
    if (_userCtrl.text != orig.username) return true;
    if (_passCtrl.text != orig.password) return true;
    if (_urlCtrl.text != orig.url) return true;
    if (_notesCtrl.text != orig.notes) return true;
    if (_attachments.length != orig.attachments.length) return true;
    if (_customFields.length != orig.customFields.length) return true;
    return false;
  }

  Future<bool> _confirmDiscard() => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Änderungen verwerfen?'),
          content: const Text('Nicht gespeicherte Änderungen gehen verloren.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Behalten'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Verwerfen'),
            ),
          ],
        ),
      ).then((v) => v ?? false);

  Future<void> _handleBack() async {
    if (!_isDirty()) {
      if (mounted) context.pop();
      return;
    }
    final confirmed = await _confirmDiscard();
    if (confirmed && mounted) context.pop();
  }

  Future<void> _pickAttachment() async {
    final att = await SafStorage.pickAnyFile();
    if (att != null && mounted) {
      setState(() => _attachments.add(att));
    }
  }

  Future<void> _renameAttachment(int index) async {
    final att = _attachments[index];
    final controller = TextEditingController(text: att.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Umbenennen'),
        content: TextField(
          controller: controller,
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true && controller.text.isNotEmpty) {
      setState(() {
        _attachments[index] = att.copyWith(name: controller.text);
      });
    }
  }

  Future<void> _addTag() async {
    String name = '';
    int iconCode = AppIcons.tagIcons.first.codePoint;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Neuer Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (v) => name = v,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppIcons.tagIcons.map((icon) {
                    final isSelected = iconCode == icon.codePoint;
                    return GestureDetector(
                      onTap: () => setDlgState(() => iconCode = icon.codePoint),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? KPasswortColors.primary.withOpacity(0.2)
                              : KPasswortColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: KPasswortColors.primary)
                              : null,
                        ),
                        child: Icon(icon, size: 18),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hinzufügen'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && name.isNotEmpty) {
      setState(() => _tags.add(Tag(name: name, iconCode: iconCode)));
    }
  }

  Future<CustomFieldType?> _pickFieldType() => showDialog<CustomFieldType>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Feldtyp wählen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: CustomFieldType.values
                .map((type) => ListTile(
                      leading: Icon(_fieldTypeIcon(type)),
                      title: Text(_fieldTypeLabel(type)),
                      onTap: () => Navigator.pop(ctx, type),
                    ))
                .toList(),
          ),
        ),
      );

  IconData _fieldTypeIcon(CustomFieldType type) => switch (type) {
        CustomFieldType.text => Icons.text_fields_rounded,
        CustomFieldType.password => Icons.lock_rounded,
        CustomFieldType.number => Icons.numbers_rounded,
        CustomFieldType.email => Icons.email_rounded,
        CustomFieldType.url => Icons.link_rounded,
        CustomFieldType.username => Icons.person_rounded,
        CustomFieldType.date => Icons.calendar_today_rounded,
      };

  String _fieldTypeLabel(CustomFieldType type) => switch (type) {
        CustomFieldType.text => 'Text',
        CustomFieldType.password => 'Passwort',
        CustomFieldType.number => 'Zahl',
        CustomFieldType.email => 'E-Mail',
        CustomFieldType.url => 'URL',
        CustomFieldType.username => 'Benutzername',
        CustomFieldType.date => 'Datum',
      };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _urlCtrl.dispose();
    _notesCtrl.dispose();
    for (final cf in _customFields) {
      cf.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titel ist erforderlich')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = ref.read(vaultRepositoryProvider);
      final now = DateTime.now();
      final customFields = _customFields
          .where((cf) => cf.keyCtrl.text.trim().isNotEmpty)
          .map((cf) => cf.toField())
          .toList();

      if (widget.entryId == null) {
        final entry = VaultEntry(
          id: const Uuid().v4(),
          title: _titleCtrl.text.trim(),
          type: _type,
          username: _userCtrl.text.trim(),
          password: _passCtrl.text,
          url: _urlCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          customFields: customFields,
          attachments: _attachments,
          tags: _tags,
          groupId: _groupId,
          createdAt: now,
          updatedAt: now,
        );
        await repo.addEntry(entry);
      } else {
        final existing = repo.findById(widget.entryId!);
        if (existing != null) {
          final updated = existing.copyWith(
            title: _titleCtrl.text.trim(),
            type: _type,
            username: _userCtrl.text.trim(),
            password: _passCtrl.text,
            url: _urlCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
            customFields: customFields,
            attachments: _attachments,
            tags: _tags,
            groupId: _groupId,
            updatedAt: now,
          );
          await repo.updateEntry(updated);
        }
      }

      ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);

      if (mounted) {
        context.go(widget.entryId != null
            ? '/vault/entry/${Uri.encodeComponent(widget.entryId!)}'
            : Routes.vault);
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.entryId == null;
    final groups = ref.watch(groupsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: GradientScaffold(
        appBar: AppBar(
          title: Text(isNew ? 'Neuer Eintrag' : 'Bearbeiten'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _handleBack,
          ),
          actions: [
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: KPasswortColors.primary),
                    )
                  : const Text('Speichern'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            80,
            20,
            MediaQuery.of(context).viewInsets.bottom + 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeSelector(
                selected: _type,
                onChanged: (t) => setState(() => _type = t),
              ).animate().fadeIn(),

              const SizedBox(height: 16),

              // Category/Group selector
              if (groups.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  value: _groupId,
                  decoration: const InputDecoration(labelText: 'Kategorie'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Keine')),
                    ...groups.map((g) =>
                        DropdownMenuItem(value: g.id, child: Text(g.name))),
                  ],
                  onChanged: (v) => setState(() => _groupId = v),
                ).animate(delay: 50.ms).fadeIn(),
                const SizedBox(height: 14),
              ],

              _field(_titleCtrl, 'Titel', Icons.label_outline_rounded, delay: 100),
              _field(_userCtrl, 'Benutzername', Icons.person_outline_rounded, delay: 150),
              _secureField(delay: 200),
              _field(_urlCtrl, 'URL', Icons.link_rounded, delay: 250),
              _field(_notesCtrl, 'Notizen', Icons.notes_rounded, delay: 300, maxLines: 4),

              // Custom fields
              if (_customFields.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'EIGENE FELDER',
                  style: AppTypography.labelSmall.copyWith(
                    color: KPasswortColors.primary,
                    letterSpacing: 1.2,
                  ),
                ).animate(delay: 320.ms).fadeIn(),
                const SizedBox(height: 8),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _customFields.length,
                  onReorder: (oldIdx, newIdx) {
                    setState(() {
                      if (newIdx > oldIdx) newIdx--;
                      _customFields.insert(newIdx, _customFields.removeAt(oldIdx));
                    });
                  },
                  itemBuilder: (_, i) => _CfTile(
                    key: ValueKey(_customFields[i]),
                    row: _customFields[i],
                    onRemove: () => setState(() => _customFields.removeAt(i)),
                    onChanged: () => setState(() {}),
                    onGeneratorRequested: (pw) =>
                        setState(() => _customFields[i].valCtrl.text = pw),
                  ),
                ),
              ],

              TextButton.icon(
                onPressed: () async {
                  final type = await _pickFieldType();
                  if (type != null) {
                    setState(() => _customFields.add(_CfRow(
                          type: type,
                          isProtected: type == CustomFieldType.password,
                        )));
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Eigenes Feld hinzufügen'),
              ).animate(delay: 350.ms).fadeIn(),

              // Tags section
              const SizedBox(height: 8),
              Text(
                'TAGS',
                style: AppTypography.labelSmall.copyWith(
                  color: KPasswortColors.primary,
                  letterSpacing: 1.2,
                ),
              ).animate(delay: 355.ms).fadeIn(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._tags.asMap().entries.map((e) => Chip(
                        avatar: e.value.iconCode != 0
                            ? Icon(
                                IconData(e.value.iconCode,
                                    fontFamily: 'MaterialIcons'),
                                size: 14,
                              )
                            : null,
                        label: Text(e.value.name),
                        onDeleted: () => setState(() => _tags.removeAt(e.key)),
                      )),
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 14),
                    label: const Text('Hinzufügen'),
                    onPressed: _addTag,
                  ),
                ],
              ).animate(delay: 360.ms).fadeIn(),

              // Attachments
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'ANHÄNGE',
                  style: AppTypography.labelSmall.copyWith(
                    color: KPasswortColors.primary,
                    letterSpacing: 1.2,
                  ),
                ).animate(delay: 365.ms).fadeIn(),
                const SizedBox(height: 8),
                ..._attachments.asMap().entries.map((e) {
                  final att = e.value;
                  final idx = e.key;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: KPasswortColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: KPasswortColors.outline, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file_rounded,
                            size: 16, color: KPasswortColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${att.name} (${att.sizeLabel})',
                            style: AppTypography.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          onPressed: () => _renameAttachment(idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          color: KPasswortColors.error,
                          onPressed: () => setState(() => _attachments.removeAt(idx)),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              TextButton.icon(
                onPressed: _pickAttachment,
                icon: const Icon(Icons.attach_file_rounded, size: 18),
                label: const Text('Anhang hinzufügen'),
              ).animate(delay: 380.ms).fadeIn(),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(isNew ? 'Eintrag erstellen' : 'Änderungen speichern'),
                ),
              ).animate(delay: 400.ms).fadeIn(),
            ],
          ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SecureTextField(
                  controller: _passCtrl,
                  label: 'Passwort',
                  isPassword: true,
                  isMonospace: true,
                  onChanged: (_) => setState(() {}),
                ).animate(delay: delay.ms).fadeIn().slideY(begin: 0.06),
              ),
              const SizedBox(width: 8),
              _GeneratorButton(
                onUse: (pw) => setState(() {
                  _passCtrl.text = pw;
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PasswordStrengthIndicator(password: _passCtrl.text),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _GeneratorButton extends ConsumerWidget {
  const _GeneratorButton({required this.onUse});
  final void Function(String) onUse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
      tooltip: 'Generator',
      color: KPasswortColors.primary,
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => _GeneratorSheet(onUse: onUse),
      ),
    );
  }
}

class _GeneratorSheet extends ConsumerWidget {
  const _GeneratorSheet({required this.onUse});
  final void Function(String) onUse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(generatorConfigProvider);
    final password = ref.watch(generatedPasswordProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => SingleChildScrollView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: KPasswortColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text('Passwort-Generator',
                  style: AppTypography.titleMedium),
            ),
            const SizedBox(height: 16),
            // Password display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KPasswortColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KPasswortColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  SelectableText(
                    password,
                    style: AppTypography.passwordLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () =>
                        ref.read(generatorConfigProvider.notifier).update(config),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Länge: ${config.length}', style: AppTypography.labelMedium),
            Slider(
              value: config.length.toDouble(),
              min: 8,
              max: 64,
              divisions: 56,
              onChanged: (v) => ref
                  .read(generatorConfigProvider.notifier)
                  .update(config.copyWith(length: v.toInt())),
            ),
            _SheetSwitchTile('Großbuchstaben (A-Z)', config.useUppercase,
                (v) => ref.read(generatorConfigProvider.notifier).update(config.copyWith(useUppercase: v))),
            _SheetSwitchTile('Kleinbuchstaben (a-z)', config.useLowercase,
                (v) => ref.read(generatorConfigProvider.notifier).update(config.copyWith(useLowercase: v))),
            _SheetSwitchTile('Zahlen (0-9)', config.useNumbers,
                (v) => ref.read(generatorConfigProvider.notifier).update(config.copyWith(useNumbers: v))),
            _SheetSwitchTile('Sonderzeichen (!@#...)', config.useSymbols,
                (v) => ref.read(generatorConfigProvider.notifier).update(config.copyWith(useSymbols: v))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Verwenden'),
                onPressed: () {
                  onUse(password);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSwitchTile extends StatelessWidget {
  const _SheetSwitchTile(this.label, this.value, this.onChanged);
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: AppTypography.bodyMedium),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

class _CfTile extends StatelessWidget {
  const _CfTile({
    super.key,
    required this.row,
    required this.onRemove,
    required this.onChanged,
    required this.onGeneratorRequested,
  });

  final _CfRow row;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final void Function(String) onGeneratorRequested;

  @override
  Widget build(BuildContext context) {
    final isPasswordType = row.type == CustomFieldType.password;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KPasswortColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KPasswortColors.outline, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.drag_handle_rounded,
                  size: 18, color: KPasswortColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.keyCtrl,
                  decoration: const InputDecoration(labelText: 'Feldname', isDense: true),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: KPasswortColors.error,
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.valCtrl,
                  obscureText: row.isProtected,
                  keyboardType: switch (row.type) {
                    CustomFieldType.number => TextInputType.number,
                    CustomFieldType.email => TextInputType.emailAddress,
                    CustomFieldType.url => TextInputType.url,
                    _ => TextInputType.text,
                  },
                  decoration: const InputDecoration(labelText: 'Wert', isDense: true),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 4),
              if (isPasswordType)
                IconButton(
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  color: KPasswortColors.primary,
                  tooltip: 'Generator',
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => _GeneratorSheet(onUse: onGeneratorRequested),
                  ),
                ),
              IconButton(
                icon: Icon(
                  row.isProtected
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                color: KPasswortColors.onSurfaceVariant,
                onPressed: () {
                  row.isProtected = !row.isProtected;
                  onChanged();
                },
              ),
            ],
          ),
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
