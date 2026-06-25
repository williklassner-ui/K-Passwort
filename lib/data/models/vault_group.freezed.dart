// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vault_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VaultGroup _$VaultGroupFromJson(Map<String, dynamic> json) {
  return _VaultGroup.fromJson(json);
}

/// @nodoc
mixin _$VaultGroup {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  int get iconCode => throw _privateConstructorUsedError;
  List<String> get entryIds => throw _privateConstructorUsedError;
  List<String> get subgroupIds => throw _privateConstructorUsedError;

  /// Serializes this VaultGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VaultGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VaultGroupCopyWith<VaultGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VaultGroupCopyWith<$Res> {
  factory $VaultGroupCopyWith(
          VaultGroup value, $Res Function(VaultGroup) then) =
      _$VaultGroupCopyWithImpl<$Res, VaultGroup>;
  @useResult
  $Res call({
    String id,
    String name,
    String? parentId,
    int iconCode,
    List<String> entryIds,
    List<String> subgroupIds,
  });
}

/// @nodoc
class _$VaultGroupCopyWithImpl<$Res, $Val extends VaultGroup>
    implements $VaultGroupCopyWith<$Res> {
  _$VaultGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VaultGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? parentId = freezed,
    Object? iconCode = null,
    Object? entryIds = null,
    Object? subgroupIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      iconCode: null == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as int,
      entryIds: null == entryIds
          ? _value.entryIds
          : entryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      subgroupIds: null == subgroupIds
          ? _value.subgroupIds
          : subgroupIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VaultGroupImplCopyWith<$Res>
    implements $VaultGroupCopyWith<$Res> {
  factory _$$VaultGroupImplCopyWith(
          _$VaultGroupImpl value, $Res Function(_$VaultGroupImpl) then) =
      __$$VaultGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? parentId,
    int iconCode,
    List<String> entryIds,
    List<String> subgroupIds,
  });
}

/// @nodoc
class __$$VaultGroupImplCopyWithImpl<$Res>
    extends _$VaultGroupCopyWithImpl<$Res, _$VaultGroupImpl>
    implements _$$VaultGroupImplCopyWith<$Res> {
  __$$VaultGroupImplCopyWithImpl(
      _$VaultGroupImpl _value, $Res Function(_$VaultGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of VaultGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? parentId = freezed,
    Object? iconCode = null,
    Object? entryIds = null,
    Object? subgroupIds = null,
  }) {
    return _then(_$VaultGroupImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      iconCode: null == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as int,
      entryIds: null == entryIds
          ? _value._entryIds
          : entryIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      subgroupIds: null == subgroupIds
          ? _value._subgroupIds
          : subgroupIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VaultGroupImpl implements _VaultGroup {
  const _$VaultGroupImpl({
    required this.id,
    required this.name,
    this.parentId,
    this.iconCode = 0,
    final List<String> entryIds = const [],
    final List<String> subgroupIds = const [],
  })  : _entryIds = entryIds,
        _subgroupIds = subgroupIds;

  factory _$VaultGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$VaultGroupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? parentId;
  @override
  @JsonKey()
  final int iconCode;
  final List<String> _entryIds;
  @override
  @JsonKey()
  List<String> get entryIds {
    if (_entryIds is EqualUnmodifiableListView) return _entryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entryIds);
  }

  final List<String> _subgroupIds;
  @override
  @JsonKey()
  List<String> get subgroupIds {
    if (_subgroupIds is EqualUnmodifiableListView) return _subgroupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subgroupIds);
  }

  @override
  String toString() {
    return 'VaultGroup(id: $id, name: $name, parentId: $parentId, iconCode: $iconCode, entryIds: $entryIds, subgroupIds: $subgroupIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VaultGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.iconCode, iconCode) ||
                other.iconCode == iconCode) &&
            const DeepCollectionEquality()
                .equals(other._entryIds, _entryIds) &&
            const DeepCollectionEquality()
                .equals(other._subgroupIds, _subgroupIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      parentId,
      iconCode,
      const DeepCollectionEquality().hash(_entryIds),
      const DeepCollectionEquality().hash(_subgroupIds));

  /// Create a copy of VaultGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VaultGroupImplCopyWith<_$VaultGroupImpl> get copyWith =>
      __$$VaultGroupImplCopyWithImpl<_$VaultGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VaultGroupImplToJson(
      this,
    );
  }
}

abstract class _VaultGroup implements VaultGroup {
  const factory _VaultGroup({
    required final String id,
    required final String name,
    final String? parentId,
    final int iconCode,
    final List<String> entryIds,
    final List<String> subgroupIds,
  }) = _$VaultGroupImpl;

  factory _VaultGroup.fromJson(Map<String, dynamic> json) =
      _$VaultGroupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get parentId;
  @override
  int get iconCode;
  @override
  List<String> get entryIds;
  @override
  List<String> get subgroupIds;

  /// Create a copy of VaultGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VaultGroupImplCopyWith<_$VaultGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
