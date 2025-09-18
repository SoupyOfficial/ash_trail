// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spotlight_item_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SpotlightItemEntity {
  /// Unique identifier for this spotlight item
  String get id => throw _privateConstructorUsedError;

  /// The type of content being indexed
  SpotlightItemType get type => throw _privateConstructorUsedError;

  /// Display title for the spotlight result
  String get title => throw _privateConstructorUsedError;

  /// Description text shown in spotlight results
  String? get description => throw _privateConstructorUsedError;

  /// Keywords for improving searchability
  List<String>? get keywords => throw _privateConstructorUsedError;

  /// Deep link URL for navigation when item is selected
  String get deepLink => throw _privateConstructorUsedError;

  /// Account ID this item belongs to
  String get accountId => throw _privateConstructorUsedError;

  /// Original content ID (tag name, chart view id, etc.)
  String get contentId => throw _privateConstructorUsedError;

  /// When this item was created/last updated
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Whether this item should be indexed
  bool get isActive => throw _privateConstructorUsedError;

  /// Create a copy of SpotlightItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpotlightItemEntityCopyWith<SpotlightItemEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpotlightItemEntityCopyWith<$Res> {
  factory $SpotlightItemEntityCopyWith(
          SpotlightItemEntity value, $Res Function(SpotlightItemEntity) then) =
      _$SpotlightItemEntityCopyWithImpl<$Res, SpotlightItemEntity>;
  @useResult
  $Res call(
      {String id,
      SpotlightItemType type,
      String title,
      String? description,
      List<String>? keywords,
      String deepLink,
      String accountId,
      String contentId,
      DateTime lastUpdated,
      bool isActive});
}

/// @nodoc
class _$SpotlightItemEntityCopyWithImpl<$Res, $Val extends SpotlightItemEntity>
    implements $SpotlightItemEntityCopyWith<$Res> {
  _$SpotlightItemEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpotlightItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? description = freezed,
    Object? keywords = freezed,
    Object? deepLink = null,
    Object? accountId = null,
    Object? contentId = null,
    Object? lastUpdated = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SpotlightItemType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      keywords: freezed == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      deepLink: null == deepLink
          ? _value.deepLink
          : deepLink // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpotlightItemEntityImplCopyWith<$Res>
    implements $SpotlightItemEntityCopyWith<$Res> {
  factory _$$SpotlightItemEntityImplCopyWith(_$SpotlightItemEntityImpl value,
          $Res Function(_$SpotlightItemEntityImpl) then) =
      __$$SpotlightItemEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SpotlightItemType type,
      String title,
      String? description,
      List<String>? keywords,
      String deepLink,
      String accountId,
      String contentId,
      DateTime lastUpdated,
      bool isActive});
}

/// @nodoc
class __$$SpotlightItemEntityImplCopyWithImpl<$Res>
    extends _$SpotlightItemEntityCopyWithImpl<$Res, _$SpotlightItemEntityImpl>
    implements _$$SpotlightItemEntityImplCopyWith<$Res> {
  __$$SpotlightItemEntityImplCopyWithImpl(_$SpotlightItemEntityImpl _value,
      $Res Function(_$SpotlightItemEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpotlightItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? description = freezed,
    Object? keywords = freezed,
    Object? deepLink = null,
    Object? accountId = null,
    Object? contentId = null,
    Object? lastUpdated = null,
    Object? isActive = null,
  }) {
    return _then(_$SpotlightItemEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SpotlightItemType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      keywords: freezed == keywords
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      deepLink: null == deepLink
          ? _value.deepLink
          : deepLink // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      contentId: null == contentId
          ? _value.contentId
          : contentId // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SpotlightItemEntityImpl extends _SpotlightItemEntity {
  const _$SpotlightItemEntityImpl(
      {required this.id,
      required this.type,
      required this.title,
      this.description,
      final List<String>? keywords,
      required this.deepLink,
      required this.accountId,
      required this.contentId,
      required this.lastUpdated,
      this.isActive = true})
      : _keywords = keywords,
        super._();

  /// Unique identifier for this spotlight item
  @override
  final String id;

  /// The type of content being indexed
  @override
  final SpotlightItemType type;

  /// Display title for the spotlight result
  @override
  final String title;

  /// Description text shown in spotlight results
  @override
  final String? description;

  /// Keywords for improving searchability
  final List<String>? _keywords;

  /// Keywords for improving searchability
  @override
  List<String>? get keywords {
    final value = _keywords;
    if (value == null) return null;
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Deep link URL for navigation when item is selected
  @override
  final String deepLink;

  /// Account ID this item belongs to
  @override
  final String accountId;

  /// Original content ID (tag name, chart view id, etc.)
  @override
  final String contentId;

  /// When this item was created/last updated
  @override
  final DateTime lastUpdated;

  /// Whether this item should be indexed
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'SpotlightItemEntity(id: $id, type: $type, title: $title, description: $description, keywords: $keywords, deepLink: $deepLink, accountId: $accountId, contentId: $contentId, lastUpdated: $lastUpdated, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpotlightItemEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            (identical(other.deepLink, deepLink) ||
                other.deepLink == deepLink) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.contentId, contentId) ||
                other.contentId == contentId) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      title,
      description,
      const DeepCollectionEquality().hash(_keywords),
      deepLink,
      accountId,
      contentId,
      lastUpdated,
      isActive);

  /// Create a copy of SpotlightItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpotlightItemEntityImplCopyWith<_$SpotlightItemEntityImpl> get copyWith =>
      __$$SpotlightItemEntityImplCopyWithImpl<_$SpotlightItemEntityImpl>(
          this, _$identity);
}

abstract class _SpotlightItemEntity extends SpotlightItemEntity {
  const factory _SpotlightItemEntity(
      {required final String id,
      required final SpotlightItemType type,
      required final String title,
      final String? description,
      final List<String>? keywords,
      required final String deepLink,
      required final String accountId,
      required final String contentId,
      required final DateTime lastUpdated,
      final bool isActive}) = _$SpotlightItemEntityImpl;
  const _SpotlightItemEntity._() : super._();

  /// Unique identifier for this spotlight item
  @override
  String get id;

  /// The type of content being indexed
  @override
  SpotlightItemType get type;

  /// Display title for the spotlight result
  @override
  String get title;

  /// Description text shown in spotlight results
  @override
  String? get description;

  /// Keywords for improving searchability
  @override
  List<String>? get keywords;

  /// Deep link URL for navigation when item is selected
  @override
  String get deepLink;

  /// Account ID this item belongs to
  @override
  String get accountId;

  /// Original content ID (tag name, chart view id, etc.)
  @override
  String get contentId;

  /// When this item was created/last updated
  @override
  DateTime get lastUpdated;

  /// Whether this item should be indexed
  @override
  bool get isActive;

  /// Create a copy of SpotlightItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpotlightItemEntityImplCopyWith<_$SpotlightItemEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
