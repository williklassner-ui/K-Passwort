// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vault_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Tag _$TagFromJson(Map<String, dynamic> json) {
  return _Tag.fromJson(json);
}

/// @nodoc
mixin _$Tag {
  String get name => throw _privateConstructorUsedError;
  int get iconCode => throw _privateConstructorUsedError;

  /// Serializes this Tag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagCopyWith<Tag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagCopyWith<$Res> {
  factory $TagCopyWith(Tag value, $Res Function(Tag) then) =
      _$TagCopyWithImpl<$Res, Tag>;
  @useResult
  $Res call({String name, int iconCode});
}

/// @nodoc
class _$TagCopyWithImpl<$Res, $Val extends Tag>
    implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? iconCode = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconCode: null == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TagImplCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$$TagImplCopyWith(_$TagImpl value, $Res Function(_$TagImpl) then) =
      __$$TagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int iconCode});
}

/// @nodoc
class __$$TagImplCopyWithImpl<$Res>
    extends _$TagCopyWithImpl<$Res, _$TagImpl>
    implements _$$TagImplCopyWith<$Res> {
  __$$TagImplCopyWithImpl(_$TagImpl _value, $Res Function(_$TagImpl) _then)
      : super(_value, _then);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? iconCode = null,
  }) {
    return _then(_$TagImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconCode: null == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TagImpl implements _Tag {
  const _$TagImpl({required this.name, this.iconCode = 0});

  factory _$TagImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final int iconCode;

  @override
  String toString() {
    return 'Tag(name: $name, iconCode: $iconCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconCode, iconCode) || other.iconCode == iconCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, iconCode);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      __$$TagImplCopyWithImpl<_$TagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagImplToJson(
      this,
    );
  }
}

abstract class _Tag implements Tag {
  const factory _Tag({required final String name, final int iconCode}) =
      _$TagImpl;

  factory _Tag.fromJson(Map<String, dynamic> json) = _$TagImpl.fromJson;

  @override
  String get name;
  @override
  int get iconCode;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VaultEntry _$VaultEntryFromJson(Map<String, dynamic> json) {
  return _VaultEntry.fromJson(json);
}

/// @nodoc
mixin _$VaultEntry {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  EntryType get type => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  List<CustomField> get customFields => throw _privateConstructorUsedError;
  List<VaultAttachment> get attachments => throw _privateConstructorUsedError;
  String? get totpSecret => throw _privateConstructorUsedError;
  String? get iconUrl => throw _privateConstructorUsedError;
  String? get groupId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  List<Tag> get tags => throw _privateConstructorUsedError;

  /// Serializes this VaultEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VaultEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VaultEntryCopyWith<VaultEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VaultEntryCopyWith<$Res> {
  factory $VaultEntryCopyWith(
          VaultEntry value, $Res Function(VaultEntry) then) =
      _$VaultEntryCopyWithImpl<$Res, VaultEntry>;
  @useResult
  $Res call(
      {String id,
      String title,
      EntryType type,
      String username,
      String password,
      String url,
      String notes,
      List<CustomField> customFields,
      List<VaultAttachment> attachments,
      String? totpSecret,
      String? iconUrl,
      String? groupId,
      DateTime createdAt,
      DateTime updatedAt,
      bool isFavorite,
      List<Tag> tags});
}

/// @nodoc
class _$VaultEntryCopyWithImpl<$Res, $Val extends VaultEntry>
    implements $VaultEntryCopyWith<$Res> {
  _$VaultEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VaultEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? username = null,
    Object? password = null,
    Object? url = null,
    Object? notes = null,
    Object? customFields = null,
    Object? attachments = null,
    Object? totpSecret = freezed,
    Object? iconUrl = freezed,
    Object? groupId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isFavorite = null,
    Object? tags = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EntryType,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      customFields: null == customFields
          ? _value.customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as List<CustomField>,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<VaultAttachment>,
      totpSecret: freezed == totpSecret
          ? _value.totpSecret
          : totpSecret // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VaultEntryImplCopyWith<$Res>
    implements $VaultEntryCopyWith<$Res> {
  factory _$$VaultEntryImplCopyWith(
          _$VaultEntryImpl value, $Res Function(_$VaultEntryImpl) then) =
      __$$VaultEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      EntryType type,
      String username,
      String password,
      String url,
      String notes,
      List<CustomField> customFields,
      List<VaultAttachment> attachments,
      String? totpSecret,
      String? iconUrl,
      String? groupId,
      DateTime createdAt,
      DateTime updatedAt,
      bool isFavorite,
      List<Tag> tags});
}

/// @nodoc
class __$$VaultEntryImplCopyWithImpl<$Res>
    extends _$VaultEntryCopyWithImpl<$Res, _$VaultEntryImpl>
    implements _$$VaultEntryImplCopyWith<$Res> {
  __$$VaultEntryImplCopyWithImpl(
      _$VaultEntryImpl _value, $Res Function(_$VaultEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of VaultEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? type = null,
    Object? username = null,
    Object? password = null,
    Object? url = null,
    Object? notes = null,
    Object? customFields = null,
    Object? attachments = null,
    Object? totpSecret = freezed,
    Object? iconUrl = freezed,
    Object? groupId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isFavorite = null,
    Object? tags = null,
  }) {
    return _then(_$VaultEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EntryType,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      customFields: null == customFields
          ? _value._customFields
          : customFields // ignore: cast_nullable_to_non_nullable
              as List<CustomField>,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<VaultAttachment>,
      totpSecret: freezed == totpSecret
          ? _value.totpSecret
          : totpSecret // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VaultEntryImpl implements _VaultEntry {
  const _$VaultEntryImpl(
      {required this.id,
      required this.title,
      required this.type,
      this.username = '',
      this.password = '',
      this.url = '',
      this.notes = '',
      final List<CustomField> customFields = const [],
      final List<VaultAttachment> attachments = const [],
      this.totpSecret,
      this.iconUrl,
      this.groupId,
      required this.createdAt,
      required this.updatedAt,
      this.isFavorite = false,
      final List<Tag> tags = const []})
      : _customFields = customFields,
        _attachments = attachments,
        _tags = tags;

  factory _$VaultEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$VaultEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final EntryType type;
  @override
  @JsonKey()
  final String username;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final String url;
  @override
  @JsonKey()
  final String notes;
  final List<CustomField> _customFields;
  @override
  @JsonKey()
  List<CustomField> get customFields {
    if (_customFields is EqualUnmodifiableListView) return _customFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customFields);
  }

  final List<VaultAttachment> _attachments;
  @override
  @JsonKey()
  List<VaultAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  final String? totpSecret;
  @override
  final String? iconUrl;
  @override
  final String? groupId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool isFavorite;
  final List<Tag> _tags;
  @override
  @JsonKey()
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'VaultEntry(id: $id, title: $title, type: $type, username: $username, password: $password, url: $url, notes: $notes, customFields: $customFields, attachments: $attachments, totpSecret: $totpSecret, iconUrl: $iconUrl, groupId: $groupId, createdAt: $createdAt, updatedAt: $updatedAt, isFavorite: $isFavorite, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VaultEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality()
                .equals(other._customFields, _customFields) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.totpSecret, totpSecret) ||
                other.totpSecret == totpSecret) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      type,
      username,
      password,
      url,
      notes,
      const DeepCollectionEquality().hash(_customFields),
      const DeepCollectionEquality().hash(_attachments),
      totpSecret,
      iconUrl,
      groupId,
      createdAt,
      updatedAt,
      isFavorite,
      const DeepCollectionEquality().hash(_tags));

  /// Create a copy of VaultEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VaultEntryImplCopyWith<_$VaultEntryImpl> get copyWith =>
      __$$VaultEntryImplCopyWithImpl<_$VaultEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VaultEntryImplToJson(
      this,
    );
  }
}

abstract class _VaultEntry implements VaultEntry {
  const factory _VaultEntry(
      {required final String id,
      required final String title,
      required final EntryType type,
      final String username,
      final String password,
      final String url,
      final String notes,
      final List<CustomField> customFields,
      final List<VaultAttachment> attachments,
      final String? totpSecret,
      final String? iconUrl,
      final String? groupId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final bool isFavorite,
      final List<Tag> tags}) = _$VaultEntryImpl;

  factory _VaultEntry.fromJson(Map<String, dynamic> json) =
      _$VaultEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  EntryType get type;
  @override
  String get username;
  @override
  String get password;
  @override
  String get url;
  @override
  String get notes;
  @override
  List<CustomField> get customFields;
  @override
  List<VaultAttachment> get attachments;
  @override
  String? get totpSecret;
  @override
  String? get iconUrl;
  @override
  String? get groupId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isFavorite;
  @override
  List<Tag> get tags;

  /// Create a copy of VaultEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VaultEntryImplCopyWith<_$VaultEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomField _$CustomFieldFromJson(Map<String, dynamic> json) {
  return _CustomField.fromJson(json);
}

/// @nodoc
mixin _$CustomField {
  String get key => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  bool get isProtected => throw _privateConstructorUsedError;
  CustomFieldType get type => throw _privateConstructorUsedError;
  int? get iconCode => throw _privateConstructorUsedError;

  /// Serializes this CustomField to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomFieldCopyWith<CustomField> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomFieldCopyWith<$Res> {
  factory $CustomFieldCopyWith(
          CustomField value, $Res Function(CustomField) then) =
      _$CustomFieldCopyWithImpl<$Res, CustomField>;
  @useResult
  $Res call(
      {String key,
      String value,
      bool isProtected,
      CustomFieldType type,
      int? iconCode});
}

/// @nodoc
class _$CustomFieldCopyWithImpl<$Res, $Val extends CustomField>
    implements $CustomFieldCopyWith<$Res> {
  _$CustomFieldCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = null,
    Object? isProtected = null,
    Object? type = null,
    Object? iconCode = freezed,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      isProtected: null == isProtected
          ? _value.isProtected
          : isProtected // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CustomFieldType,
      iconCode: freezed == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomFieldImplCopyWith<$Res>
    implements $CustomFieldCopyWith<$Res> {
  factory _$$CustomFieldImplCopyWith(
          _$CustomFieldImpl value, $Res Function(_$CustomFieldImpl) then) =
      __$$CustomFieldImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key,
      String value,
      bool isProtected,
      CustomFieldType type,
      int? iconCode});
}

/// @nodoc
class __$$CustomFieldImplCopyWithImpl<$Res>
    extends _$CustomFieldCopyWithImpl<$Res, _$CustomFieldImpl>
    implements _$$CustomFieldImplCopyWith<$Res> {
  __$$CustomFieldImplCopyWithImpl(
      _$CustomFieldImpl _value, $Res Function(_$CustomFieldImpl) _then)
      : super(_value, _then);

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? value = null,
    Object? isProtected = null,
    Object? type = null,
    Object? iconCode = freezed,
  }) {
    return _then(_$CustomFieldImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      isProtected: null == isProtected
          ? _value.isProtected
          : isProtected // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CustomFieldType,
      iconCode: freezed == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomFieldImpl implements _CustomField {
  const _$CustomFieldImpl(
      {required this.key,
      required this.value,
      this.isProtected = false,
      this.type = CustomFieldType.text,
      this.iconCode});

  factory _$CustomFieldImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomFieldImplFromJson(json);

  @override
  final String key;
  @override
  final String value;
  @override
  @JsonKey()
  final bool isProtected;
  @override
  @JsonKey()
  final CustomFieldType type;
  @override
  final int? iconCode;

  @override
  String toString() {
    return 'CustomField(key: $key, value: $value, isProtected: $isProtected, type: $type, iconCode: $iconCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomFieldImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.iconCode, iconCode) ||
                other.iconCode == iconCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, key, value, isProtected, type, iconCode);

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomFieldImplCopyWith<_$CustomFieldImpl> get copyWith =>
      __$$CustomFieldImplCopyWithImpl<_$CustomFieldImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomFieldImplToJson(
      this,
    );
  }
}

abstract class _CustomField implements CustomField {
  const factory _CustomField(
      {required final String key,
      required final String value,
      final bool isProtected,
      final CustomFieldType type,
      final int? iconCode}) = _$CustomFieldImpl;

  factory _CustomField.fromJson(Map<String, dynamic> json) =
      _$CustomFieldImpl.fromJson;

  @override
  String get key;
  @override
  String get value;
  @override
  bool get isProtected;
  @override
  CustomFieldType get type;
  @override
  int? get iconCode;

  /// Create a copy of CustomField
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomFieldImplCopyWith<_$CustomFieldImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VaultAttachment _$VaultAttachmentFromJson(Map<String, dynamic> json) {
  return _VaultAttachment.fromJson(json);
}

/// @nodoc
mixin _$VaultAttachment {
  String get name => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  List<int> get bytes => throw _privateConstructorUsedError;

  /// Serializes this VaultAttachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VaultAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VaultAttachmentCopyWith<VaultAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VaultAttachmentCopyWith<$Res> {
  factory $VaultAttachmentCopyWith(
          VaultAttachment value, $Res Function(VaultAttachment) then) =
      _$VaultAttachmentCopyWithImpl<$Res, VaultAttachment>;
  @useResult
  $Res call({String name, String mimeType, List<int> bytes});
}

/// @nodoc
class _$VaultAttachmentCopyWithImpl<$Res, $Val extends VaultAttachment>
    implements $VaultAttachmentCopyWith<$Res> {
  _$VaultAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VaultAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? mimeType = null,
    Object? bytes = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      bytes: null == bytes
          ? _value.bytes
          : bytes // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VaultAttachmentImplCopyWith<$Res>
    implements $VaultAttachmentCopyWith<$Res> {
  factory _$$VaultAttachmentImplCopyWith(_$VaultAttachmentImpl value,
          $Res Function(_$VaultAttachmentImpl) then) =
      __$$VaultAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String mimeType, List<int> bytes});
}

/// @nodoc
class __$$VaultAttachmentImplCopyWithImpl<$Res>
    extends _$VaultAttachmentCopyWithImpl<$Res, _$VaultAttachmentImpl>
    implements _$$VaultAttachmentImplCopyWith<$Res> {
  __$$VaultAttachmentImplCopyWithImpl(
      _$VaultAttachmentImpl _value, $Res Function(_$VaultAttachmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of VaultAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? mimeType = null,
    Object? bytes = null,
  }) {
    return _then(_$VaultAttachmentImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      bytes: null == bytes
          ? _value._bytes
          : bytes // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VaultAttachmentImpl implements _VaultAttachment {
  const _$VaultAttachmentImpl(
      {required this.name,
      this.mimeType = 'application/octet-stream',
      required final List<int> bytes})
      : _bytes = bytes;

  factory _$VaultAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$VaultAttachmentImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final String mimeType;
  final List<int> _bytes;
  @override
  List<int> get bytes {
    if (_bytes is EqualUnmodifiableListView) return _bytes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bytes);
  }

  @override
  String toString() {
    return 'VaultAttachment(name: $name, mimeType: $mimeType, bytes: $bytes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VaultAttachmentImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            const DeepCollectionEquality().equals(other._bytes, _bytes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, mimeType,
      const DeepCollectionEquality().hash(_bytes));

  /// Create a copy of VaultAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VaultAttachmentImplCopyWith<_$VaultAttachmentImpl> get copyWith =>
      __$$VaultAttachmentImplCopyWithImpl<_$VaultAttachmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VaultAttachmentImplToJson(
      this,
    );
  }
}

abstract class _VaultAttachment implements VaultAttachment {
  const factory _VaultAttachment(
      {required final String name,
      final String mimeType,
      required final List<int> bytes}) = _$VaultAttachmentImpl;

  factory _VaultAttachment.fromJson(Map<String, dynamic> json) =
      _$VaultAttachmentImpl.fromJson;

  @override
  String get name;
  @override
  String get mimeType;
  @override
  List<int> get bytes;

  /// Create a copy of VaultAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VaultAttachmentImplCopyWith<_$VaultAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
