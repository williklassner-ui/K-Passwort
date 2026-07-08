import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:k_passwort/data/models/vault_entry.dart';

/// Renders an entry's thumbnail, honoring the user's chosen [iconType]:
/// custom image > custom Material icon > web-fetched thumbnail > automatic
/// favicon derived from [entryUrl] > a type-based fallback icon.
///
/// Takes plain scalar fields (rather than a [VaultEntry]) so the edit screen
/// can preview unsaved, in-progress selections live.
class EntryIconPreview extends StatelessWidget {
  const EntryIconPreview({
    super.key,
    required this.iconType,
    this.iconCode,
    this.iconImageBase64,
    this.webIconUrl,
    required this.entryUrl,
    required this.entryType,
    this.size = 44,
  });

  final EntryIconType iconType;
  final int? iconCode;
  final String? iconImageBase64;
  final String? webIconUrl;
  final String entryUrl;
  final EntryType entryType;
  final double size;

  static String? _faviconUrlFor(String url) {
    if (url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) return null;
      return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=64';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Icon(entryType.icon, color: entryType.color, size: size * 0.5);

    if (iconType == EntryIconType.image && iconImageBase64 != null) {
      try {
        content = Image.memory(
          base64Decode(iconImageBase64!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => content,
        );
      } catch (_) {}
    } else if (iconType == EntryIconType.materialIcon && iconCode != null) {
      content = Icon(
        IconData(iconCode!, fontFamily: 'MaterialIcons'),
        color: entryType.color,
        size: size * 0.5,
      );
    } else if (iconType == EntryIconType.webThumbnail && webIconUrl != null) {
      content = CachedNetworkImage(
        imageUrl: webIconUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Icon(entryType.icon, color: entryType.color, size: size * 0.5),
        placeholder: (_, __) => Icon(entryType.icon, color: entryType.color, size: size * 0.5),
      );
    } else {
      final faviconUrl = _faviconUrlFor(entryUrl);
      if (faviconUrl != null) {
        content = CachedNetworkImage(
          imageUrl: faviconUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Icon(entryType.icon, color: entryType.color, size: size * 0.5),
          placeholder: (_, __) => Icon(entryType.icon, color: entryType.color, size: size * 0.5),
        );
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: entryType.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size > 50 ? 16 : 12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size > 50 ? 16 : 12),
        child: content,
      ),
    );
  }
}
