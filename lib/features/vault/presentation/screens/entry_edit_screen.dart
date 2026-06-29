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

// --- Unified row type hierarchy ---

sealed class _FieldRow {}

class _StdFieldRow extends _FieldRow {
  final _StdFieldKind kind;
  _StdFieldRow(this.kind);
}

class _CustomFieldRow extends _FieldRow {
  final _CfRow cf;
  _CustomFieldRow(this.cf);
}

enum _StdFieldKind { title, username, password, url, notes }

// --- Custom field data holder ---

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

// ─────────────────────────────────────────────────────────────────────────────

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

  // All rows in display order: std rows first, custom rows appended
  final List<_FieldRow> _allRows = [
    _StdFieldRow(_StdFieldKind.title),
    _StdFieldRow(_StdFieldKind.username),
    _StdFieldRow(_StdFieldKind.password),
    _StdFieldRow(_StdFieldKind.url),
    _StdFieldRow(_StdFieldKind.notes),
  ];

  EntryType _type = EntryType.login;
  String? _groupId;
  bool _saving = false;
  List<VaultAttachment> _attachments = [];
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
      _allRows.add(_CustomFieldRow(_CfRow(
        key: cf.key,
        value: cf.value,
        isProtected: cf.isProtected,
        type: cf.type,
        iconCode: cf.iconCode,
      )));
    }
  }

  List<_CustomFieldRow> get _customRows =>
      _allRows.whereType<_CustomFieldRow>().toList();

  bool _isDirty() {
    final orig = _original;
    if (orig == null) {
      return _titleCtrl.text.isNotEmpty ||
          _userCtrl.text.isNotEmpty ||
          _passCtrl.text.isNotEmpty ||
          _urlCtrl.text.isNotEmpty ||
          _notesCtrl.text.isNotEmpty ||
          _attachments.isNotEmpty ||
          _customRows.isNotEmpty;
    }
    if (_titleCtrl.text != orig.title) return true;
    if (_userCtrl.text != orig.username) return true;
    if (_passCtrl.text != orig.password) return true;
    if (_urlCtrl.text != orig.url) return true;
    if (_notesCtrl.text != orig.notes) return true;
    if (_attachments.length != orig.attachments.length) return true;
    if (_customRows.length != orig.customFields.length) return true;
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

  Future<void> _editTag(int index) async {
    final accent = Theme.of(context).colorScheme.primary;
    final current = _tags[index];
    String name = current.name;
    int iconCode = current.iconCode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Tag bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  controller: TextEditingController(text: name),
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
                              ? accent.withOpacity(0.2)
                              : KPasswortColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: accent) : null,
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
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && name.isNotEmpty) {
      setState(() => _tags[index] = Tag(name: name, iconCode: iconCode));
    }
  }

  Future<void> _createNewLabel() async {
    final nameCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neues Label'),
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
      final repo = ref.read(vaultRepositoryProvider);
      final labelName = nameCtrl.text.trim();
      await repo.addGroup(VaultGroup(id: const Uuid().v4(), name: labelName));
      // The real KDBX group ID is auto-assigned; find it by name
      final newGroup = repo.groups.lastWhere(
        (g) => g.name == labelName,
        orElse: () => VaultGroup(id: '', name: labelName),
      );
      ref.read(vaultRevisionProvider.notifier).update((n) => n + 1);
      if (mounted && newGroup.id.isNotEmpty) {
        setState(() => _groupId = newGroup.id);
      }
    }
  }

  Future<void> _addTag() async {
    final accent = Theme.of(context).colorScheme.primary;
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
                              ? accent.withOpacity(0.2)
                              : KPasswortColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: accent)
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
    for (final row in _allRows.whereType<_CustomFieldRow>()) {
      row.cf.dispose();
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
      final customFields = _allRows
          .whereType<_CustomFieldRow>()
          .map((r) => r.cf)
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
    final accent = Theme.of(context).colorScheme.primary;
    final validGroupId = groups.any((g) => g.id == _groupId) ? _groupId : null;
    // AppBar is taller than kToolbarHeight because of the filled "Speichern"
    // button, so add extra clearance to keep the type selector visible.
    final topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 24;

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
              onPressed: _saving ? null : _handleBack,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Abbrechen'),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Speichern'),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            topPadding,
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

              // Label dropdown — always visible
              DropdownButtonFormField<String?>(
                value: validGroupId,
                decoration: const InputDecoration(labelText: 'Label'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Keine')),
                  ...groups.map((g) =>
                      DropdownMenuItem(value: g.id, child: Text(g.name))),
                  DropdownMenuItem(
                    value: '__new__',
                    child: Row(children: const [
                      Icon(Icons.add_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Neues Label erstellen...'),
                    ]),
                  ),
                ],
                onChanged: (v) async {
                  if (v == '__new__') {
                    await _createNewLabel();
                    return;
                  }
                  setState(() => _groupId = v);
                },
              ).animate(delay: 50.ms).fadeIn(),
              const SizedBox(height: 14),

              // Unified draggable list of all fields
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _allRows.length,
                onReorder: (oldIdx, newIdx) {
                  setState(() {
                    if (newIdx > oldIdx) newIdx--;
                    _allRows.insert(newIdx, _allRows.removeAt(oldIdx));
                  });
                },
                itemBuilder: (ctx, i) => _buildRowItem(ctx, i, accent),
              ),

              TextButton.icon(
                onPressed: () async {
                  final type = await _pickFieldType();
                  if (type != null) {
                    setState(() => _allRows.add(_CustomFieldRow(_CfRow(
                          type: type,
                          isProtected: type == CustomFieldType.password,
                        ))));
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
                  color: accent,
                  letterSpacing: 1.2,
                ),
              ).animate(delay: 355.ms).fadeIn(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._tags.asMap().entries.map((e) => InputChip(
                        avatar: e.value.iconCode != 0
                            ? Icon(
                                IconData(e.value.iconCode,
                                    fontFamily: 'MaterialIcons'),
                                size: 14,
                              )
                            : null,
                        label: Text(e.value.name),
                        onPressed: () => _editTag(e.key),
                        onDeleted: () =>
                            setState(() => _tags.removeAt(e.key)),
                      )),
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 14),
                    label: const Text('Hinzufügen'),
                    onPressed: _addTag,
                  ),
                ],
              ).animate(delay: 360.ms).fadeIn(),

              // Attachments section
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'ANHÄNGE',
                  style: AppTypography.labelSmall.copyWith(
                    color: accent,
                    letterSpacing: 1.2,
                  ),
                ).animate(delay: 365.ms).fadeIn(),
                const SizedBox(height: 8),
                ..._attachments.asMap().entries.map((e) {
                  final att = e.value;
                  final idx = e.key;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: KPasswortColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: KPasswortColors.outline, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file_rounded,
                            size: 16, color: accent),
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
                          onPressed: () =>
                              setState(() => _attachments.removeAt(idx)),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowItem(BuildContext context, int index, Color accent) {
    final row = _allRows[index];

    if (row is _StdFieldRow) {
      final bool isPassword = row.kind == _StdFieldKind.password;
      final Widget inner = _buildStdContent(context, row.kind, accent);
      final ctrl = _ctrlForKind(row.kind);

      return Padding(
        key: ValueKey('std_${row.kind.name}'),
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: isPassword
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Expanded(child: inner),
            if (ctrl != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                color: KPasswortColors.onSurfaceVariant,
                tooltip: 'Leeren',
                onPressed: () => setState(() => ctrl.clear()),
              ),
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: EdgeInsets.only(
                    left: 4, top: isPassword ? 16 : 0),
                child: const Icon(Icons.drag_handle_rounded,
                    size: 18, color: KPasswortColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    } else if (row is _CustomFieldRow) {
      return _CfTile(
        key: ValueKey(row.cf),
        index: index,
        row: row.cf,
        onRemove: () => setState(() => _allRows.removeAt(index)),
        onChanged: () => setState(() {}),
        onGeneratorRequested: (pw) =>
            setState(() => row.cf.valCtrl.text = pw),
      );
    }

    return SizedBox.shrink(key: ValueKey('empty_$index'));
  }

  TextEditingController? _ctrlForKind(_StdFieldKind kind) => switch (kind) {
        _StdFieldKind.title => _titleCtrl,
        _StdFieldKind.username => _userCtrl,
        _StdFieldKind.password => _passCtrl,
        _StdFieldKind.url => _urlCtrl,
        _StdFieldKind.notes => _notesCtrl,
      };

  Widget _buildStdContent(
      BuildContext context, _StdFieldKind kind, Color accent) {
    switch (kind) {
      case _StdFieldKind.title:
        return _plainTextField(_titleCtrl, 'Titel',
            Icons.label_outline_rounded);
      case _StdFieldKind.username:
        return _plainTextField(_userCtrl, 'Benutzername',
            Icons.person_outline_rounded);
      case _StdFieldKind.password:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  ),
                ),
                const SizedBox(width: 8),
                _GeneratorButton(
                  onUse: (pw) => setState(() => _passCtrl.text = pw),
                ),
              ],
            ),
            const SizedBox(height: 8),
            PasswordStrengthIndicator(password: _passCtrl.text),
          ],
        );
      case _StdFieldKind.url:
        return _plainTextField(_urlCtrl, 'URL', Icons.link_rounded);
      case _StdFieldKind.notes:
        return _plainTextField(_notesCtrl, 'Notizen', Icons.notes_rounded,
            maxLines: 4);
    }
  }

  Widget _plainTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GeneratorButton extends ConsumerWidget {
  const _GeneratorButton({required this.onUse});
  final void Function(String) onUse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).colorScheme.primary;
    return IconButton(
      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
      tooltip: 'Generator',
      color: accent,
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
    final accent = Theme.of(context).colorScheme.primary;

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KPasswortColors.surface,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: accent.withOpacity(0.3)),
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
                    onPressed: () => ref
                        .read(generatorConfigProvider.notifier)
                        .update(config),
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
                (v) => ref.read(generatorConfigProvider.notifier).update(
                    config.copyWith(useUppercase: v))),
            _SheetSwitchTile('Kleinbuchstaben (a-z)', config.useLowercase,
                (v) => ref.read(generatorConfigProvider.notifier).update(
                    config.copyWith(useLowercase: v))),
            _SheetSwitchTile('Zahlen (0-9)', config.useNumbers,
                (v) => ref.read(generatorConfigProvider.notifier).update(
                    config.copyWith(useNumbers: v))),
            _SheetSwitchTile('Sonderzeichen (!@#...)', config.useSymbols,
                (v) => ref.read(generatorConfigProvider.notifier).update(
                    config.copyWith(useSymbols: v))),
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
    required this.index,
    required this.row,
    required this.onRemove,
    required this.onChanged,
    required this.onGeneratorRequested,
  });

  final int index;
  final _CfRow row;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final void Function(String) onGeneratorRequested;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
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
              Expanded(
                child: TextField(
                  controller: row.keyCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Feldname', isDense: true),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: KPasswortColors.error,
                onPressed: onRemove,
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.drag_handle_rounded,
                      size: 18, color: KPasswortColors.onSurfaceVariant),
                ),
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
                  decoration:
                      const InputDecoration(labelText: 'Wert', isDense: true),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 4),
              if (isPasswordType)
                IconButton(
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  color: accent,
                  tooltip: 'Generator',
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) =>
                        _GeneratorSheet(onUse: onGeneratorRequested),
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
              color: isSelected
                  ? type.color
                  : KPasswortColors.onSurfaceVariant,
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
