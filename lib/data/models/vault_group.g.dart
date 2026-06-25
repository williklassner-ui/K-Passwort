// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VaultGroupImpl _$$VaultGroupImplFromJson(Map<String, dynamic> json) =>
    _$VaultGroupImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      iconCode: (json['iconCode'] as num?)?.toInt() ?? 0,
      entryIds: (json['entryIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      subgroupIds: (json['subgroupIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$$VaultGroupImplToJson(_$VaultGroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentId': instance.parentId,
      'iconCode': instance.iconCode,
      'entryIds': instance.entryIds,
      'subgroupIds': instance.subgroupIds,
    };
