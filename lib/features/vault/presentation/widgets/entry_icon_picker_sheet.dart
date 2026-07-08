import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k_passwort/core/constants/icon_constants.dart';
import 'package:k_passwort/data/models/vault_entry.dart';
import 'package:k_passwort/ui/theme/color_scheme.dart';
import 'package:k_passwort/ui/theme/typography.dart';

/// Result of [showEntryIconPickerSheet] — exactly one source is set,
/// matching [type].
class EntryIconPickResult {
  const EntryIconPickResult.materialIcon(int code)
      : type = EntryIconType.materialIcon,
        iconCode = code,
        imageBase64 = null,
        url = null;

  const EntryIconPickResult.image(String base64)
      : type = EntryIconType.image,
        iconCode = null,
        imageBase64 = base64,
        url = null;

  const EntryIconPickResult.web(String webUrl)
      : type = EntryIconType.webThumbnail,
        iconCode = null,
        imageBase64 = null,
        url = webUrl;

  const EntryIconPickResult.auto()
      : type = EntryIconType.auto,
        iconCode = null,
        imageBase64 = null,
        url = null;

  final EntryIconType type;
  final int? iconCode;
  final String? imageBase64;
  final String? url;
}

Future<EntryIconPickResult?> showEntryIconPickerSheet(
  BuildContext context, {
  required String urlHint,
}) {
  return showModalBottomSheet<EntryIconPickResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _IconPickerSheet(urlHint: urlHint),
  );
}

enum _IconPickTab { icon, image, web }

class _IconPickerSheet extends StatefulWidget {
  const _IconPickerSheet({required this.urlHint});
  final String urlHint;

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  _IconPickTab _tab = _IconPickTab.icon;
  late final TextEditingController _domainCtrl;
  List<String> _webCandidates = [];
  String? _selectedWebUrl;
  bool _loadingImage = false;

  @override
  void initState() {
    super.initState();
    _domainCtrl = TextEditingController(text: _hostFrom(widget.urlHint));
    if (_domainCtrl.text.isNotEmpty) _buildWebCandidates();
  }

  @override
  void dispose() {
    _domainCtrl.dispose();
    super.dispose();
  }

  String _hostFrom(String url) {
    if (url.isEmpty) return '';
    try {
      final uri = Uri.parse(url.contains('://') ? url : 'https://$url');
      return uri.host;
    } catch (_) {
      return '';
    }
  }

  void _buildWebCandidates() {
    final domain = _domainCtrl.text.trim();
    setState(() {
      _selectedWebUrl = null;
      _webCandidates = domain.isEmpty
          ? []
          : [
              'https://www.google.com/s2/favicons?domain=$domain&sz=128',
              'https://icons.duckduckgo.com/ip3/$domain.ico',
              'https://logo.clearbit.com/$domain',
            ];
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _loadingImage = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (file == null || !mounted) {
        setState(() => _loadingImage = false);
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      Navigator.pop(context, EntryIconPickResult.image(base64Encode(bytes)));
    } catch (_) {
      if (mounted) setState(() => _loadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Icon auswählen', style: AppTypography.titleSmall),
            const SizedBox(height: 16),
            SegmentedButton<_IconPickTab>(
              segments: const [
                ButtonSegment(
                  value: _IconPickTab.icon,
                  label: Text('Icon'),
                  icon: Icon(Icons.emoji_symbols_outlined, size: 16),
                ),
                ButtonSegment(
                  value: _IconPickTab.image,
                  label: Text('Bild'),
                  icon: Icon(Icons.image_outlined, size: 16),
                ),
                ButtonSegment(
                  value: _IconPickTab.web,
                  label: Text('Web-Suche'),
                  icon: Icon(Icons.travel_explore_outlined, size: 16),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
            const SizedBox(height: 20),
            switch (_tab) {
              _IconPickTab.icon => _buildIconGrid(accent),
              _IconPickTab.image => _buildImageOptions(),
              _IconPickTab.web => _buildWebSearch(accent),
            },
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, const EntryIconPickResult.auto()),
              child: const Text('Zurücksetzen (automatisch)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconGrid(Color accent) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppIcons.tagIcons.map((icon) {
        return GestureDetector(
          onTap: () => Navigator.pop(
            context,
            EntryIconPickResult.materialIcon(icon.codePoint),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KPasswortColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageOptions() {
    if (_loadingImage) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.photo_camera_rounded),
          title: const Text('Kamera'),
          onTap: () => _pickImage(ImageSource.camera),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_rounded),
          title: const Text('Galerie'),
          onTap: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildWebSearch(Color accent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _domainCtrl,
          decoration: InputDecoration(
            labelText: 'Domain (z. B. github.com)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: _buildWebCandidates,
            ),
          ),
          onSubmitted: (_) => _buildWebCandidates(),
        ),
        if (_webCandidates.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _webCandidates.map((candidateUrl) {
              final isSelected = _selectedWebUrl == candidateUrl;
              return GestureDetector(
                onTap: () => setState(() => _selectedWebUrl = candidateUrl),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: KPasswortColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: accent, width: 2) : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: candidateUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: KPasswortColors.onSurfaceVariant,
                      ),
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedWebUrl == null
                  ? null
                  : () => Navigator.pop(context, EntryIconPickResult.web(_selectedWebUrl!)),
              child: const Text('Übernehmen'),
            ),
          ),
        ],
      ],
    );
  }
}
