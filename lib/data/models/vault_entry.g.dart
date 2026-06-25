// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
      name: json['name'] as String,
      iconCode: (json['iconCode'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'iconCode': instance.iconCode,
    };

_$VaultEntryImpl _$$VaultEntryImplFromJson(Map<String, dynamic> json) =>
    _$VaultEntryImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      type: $enumDecode(_$EntryTypeEnumMap, json['type']),
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      url: json['url'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      customFields: (json['customFields'] as List<dynamic>?)
              ?.map((e) => CustomField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map(
                  (e) => VaultAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totpSecret: json['totpSecret'] as String?,
      iconUrl: json['iconUrl'] as String?,
      groupId: json['groupId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$$VaultEntryImplToJson(_$VaultEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': _$EntryTypeEnumMap[instance.type]!,
      'username': instance.username,
      'password': instance.password,
      'url': instance.url,
      'notes': instance.notes,
      'customFields': instance.customFields.map((e) => e.toJson()).toList(),
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'totpSecret': instance.totpSecret,
      'iconUrl': instance.iconUrl,
      'groupId': instance.groupId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'tags': instance.tags.map((e) => e.toJson()).toList(),
    };

const _$EntryTypeEnumMap = {
  EntryType.login: 'login',
  EntryType.card: 'card',
  EntryType.note: 'note',
  EntryType.identity: 'identity',
  EntryType.sshKey: 'sshKey',
  EntryType.wifi: 'wifi',
  EntryType.custom: 'custom',
};

_$CustomFieldImpl _$$CustomFieldImplFromJson(Map<String, dynamic> json) =>
    _$CustomFieldImpl(
      key: json['key'] as String,
      value: json['value'] as String,
      isProtected: json['isProtected'] as bool? ?? false,
      type: $enumDecodeNullable(_$CustomFieldTypeEnumMap, json['type']) ??
          CustomFieldType.text,
      iconCode: (json['iconCode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CustomFieldImplToJson(_$CustomFieldImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'isProtected': instance.isProtected,
      'type': _$CustomFieldTypeEnumMap[instance.type]!,
      'iconCode': instance.iconCode,
    };

const _$CustomFieldTypeEnumMap = {
  CustomFieldType.text: 'text',
  CustomFieldType.password: 'password',
  CustomFieldType.number: 'number',
  CustomFieldType.email: 'email',
  CustomFieldType.url: 'url',
  CustomFieldType.username: 'username',
  CustomFieldType.date: 'date',
};

_$VaultAttachmentImpl _$$VaultAttachmentImplFromJson(
        Map<String, dynamic> json) =>
    _$VaultAttachmentImpl(
      name: json['name'] as String,
      mimeType:
          json['mimeType'] as String? ?? 'application/octet-stream',
      bytes: (json['bytes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$$VaultAttachmentImplToJson(
        _$VaultAttachmentImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mimeType': instance.mimeType,
      'bytes': instance.bytes,
    };
