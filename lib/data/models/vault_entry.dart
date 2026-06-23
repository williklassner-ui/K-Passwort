import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vault_entry.freezed.dart';
part 'vault_entry.g.dart';

enum EntryType { login, card, note, identity, sshKey, wifi, custom }

@freezed
class VaultEntry with _$VaultEntry {
  const factory VaultEntry({
    required String id,
    required String title,
    required EntryType type,
    @Default('') String username,
    @Default('') String password,
    @Default('') String url,
    @Default('') String notes,
    @Default([]) List<CustomField> customFields,
    String? totpSecret,
    String? iconUrl,
    String? groupId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isFavorite,
    @Default([]) List<String> tags,
  }) = _VaultEntry;

  factory VaultEntry.fromJson(Map<String, dynamic> json) =>
      _$VaultEntryFromJson(json);

  factory VaultEntry.empty() => VaultEntry(
        id: '',
        title: '',
        type: EntryType.login,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
}

@freezed
class CustomField with _$CustomField {
  const factory CustomField({
    required String key,
    required String value,
    @Default(false) bool isProtected,
  }) = _CustomField;

  factory CustomField.fromJson(Map<String, dynamic> json) =>
      _$CustomFieldFromJson(json);
}

extension VaultEntryColor on EntryType {
  Color get color {
    switch (this) {
      case EntryType.login:
        return const Color(0xFF0A84FF);
      case EntryType.card:
        return const Color(0xFFFF9F0A);
      case EntryType.note:
        return const Color(0xFF32D74B);
      case EntryType.identity:
        return const Color(0xFFBF5AF2);
      case EntryType.sshKey:
        return const Color(0xFFFF453A);
      case EntryType.wifi:
        return const Color(0xFF64D2FF);
      case EntryType.custom:
        return const Color(0xFF8E8E93);
    }
  }

  IconData get icon {
    switch (this) {
      case EntryType.login:
        return Icons.lock_outline_rounded;
      case EntryType.card:
        return Icons.credit_card_rounded;
      case EntryType.note:
        return Icons.sticky_note_2_outlined;
      case EntryType.identity:
        return Icons.person_outline_rounded;
      case EntryType.sshKey:
        return Icons.terminal_rounded;
      case EntryType.wifi:
        return Icons.wifi_rounded;
      case EntryType.custom:
        return Icons.category_outlined;
    }
  }
}
