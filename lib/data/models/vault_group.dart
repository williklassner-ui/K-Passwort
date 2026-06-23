import 'package:freezed_annotation/freezed_annotation.dart';

part 'vault_group.freezed.dart';
part 'vault_group.g.dart';

@freezed
class VaultGroup with _$VaultGroup {
  const factory VaultGroup({
    required String id,
    required String name,
    String? parentId,
    @Default(0) int iconCode,
    @Default([]) List<String> entryIds,
    @Default([]) List<String> subgroupIds,
  }) = _VaultGroup;

  factory VaultGroup.fromJson(Map<String, dynamic> json) =>
      _$VaultGroupFromJson(json);
}
