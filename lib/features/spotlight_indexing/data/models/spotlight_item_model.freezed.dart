// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spotlight_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpotlightItemModel _$SpotlightItemModelFromJson(Map<String, dynamic> json) {
  return _SpotlightItemModel.fromJson(json);
}

/// @nodoc
mixin _$SpotlightItemModel {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'type')
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'title')
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'keywords')
  List<String>? get keywords => throw _privateConstructorUsedError;
  @JsonKey(name: 'deep_link')
  String get deepLink => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  String get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'content_id')
  String get contentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this SpotlightItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpotlightItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpotlightItemModelCopyWith<SpotlightItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpotlightItemModelCopyWith<$Res> {
  factory $SpotlightItemModelCopyWith(
          SpotlightItemModel value, $Res Function(SpotlightItemModel) then) =
      _$SpotlightItemModelCopyWithImpl<$Res, SpotlightItemModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'type') String type,
      @JsonKey(name: 'title') String title,
      @JsonKey(name: 'description') String? description,
      @JsonKey(name: 'keywords') List<String>? keywords,
      @JsonKey(name: 'deep_link') String deepLink,
      @JsonKey(name: 'account_id') String accountId,
      @JsonKey(name: 'content_id') String contentId,
      @JsonKey(name: 'last_updated') DateTime lastUpdated,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class _$SpotlightItemModelCopyWithImpl<$Res, $Val extends SpotlightItemModel>
    implements $SpotlightItemModelCopyWith<$Res> {
  _$SpotlightItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpotlightItemModel
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
              as String,
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
abstract class _$$SpotlightItemModelImplCopyWith<$Res>
    implements $SpotlightItemModelCopyWith<$Res> {
  factory _$$SpotlightItemModelImplCopyWith(_$SpotlightItemModelImpl value,
          $Res Function(_$SpotlightItemModelImpl) then) =
      __$$SpotlightItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'type') String type,
      @JsonKey(name: 'title') String title,
      @JsonKey(name: 'description') String? description,
      @JsonKey(name: 'keywords') List<String>? keywords,
      @JsonKey(name: 'deep_link') String deepLink,
      @JsonKey(name: 'account_id') String accountId,
      @JsonKey(name: 'content_id') String contentId,
      @JsonKey(name: 'last_updated') DateTime lastUpdated,
      @JsonKey(name: 'is_active') bool isActive});
}

/// @nodoc
class __$$SpotlightItemModelImplCopyWithImpl<$Res>
    extends _$SpotlightItemModelCopyWithImpl<$Res, _$SpotlightItemModelImpl>
    implements _$$SpotlightItemModelImplCopyWith<$Res> {
  __$$SpotlightItemModelImplCopyWithImpl(_$SpotlightItemModelImpl _value,
      $Res Function(_$SpotlightItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpotlightItemModel
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
    return _then(_$SpotlightItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
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
@JsonSerializable()
class _$SpotlightItemModelImpl extends _SpotlightItemModel {
  const _$SpotlightItemModelImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'type') required this.type,
      @JsonKey(name: 'title') required this.title,
      @JsonKey(name: 'description') this.description,
      @JsonKey(name: 'keywords') final List<String>? keywords,
      @JsonKey(name: 'deep_link') required this.deepLink,
      @JsonKey(name: 'account_id') required this.accountId,
      @JsonKey(name: 'content_id') required this.contentId,
      @JsonKey(name: 'last_updated') required this.lastUpdated,
      @JsonKey(name: 'is_active') this.isActive = true})
      : _keywords = keywords,
        super._();

  factory _$SpotlightItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpotlightItemModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'type')
  final String type;
  @override
  @JsonKey(name: 'title')
  final String title;
  @override
  @JsonKey(name: 'description')
  final String? description;
  final List<String>? _keywords;
  @override
  @JsonKey(name: 'keywords')
  List<String>? get keywords {
    final value = _keywords;
    if (value == null) return null;
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'deep_link')
  final String deepLink;
  @override
  @JsonKey(name: 'account_id')
  final String accountId;
  @override
  @JsonKey(name: 'content_id')
  final String contentId;
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;

  @override
  String toString() {
    return 'SpotlightItemModel(id: $id, type: $type, title: $title, description: $description, keywords: $keywords, deepLink: $deepLink, accountId: $accountId, contentId: $contentId, lastUpdated: $lastUpdated, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpotlightItemModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of SpotlightItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpotlightItemModelImplCopyWith<_$SpotlightItemModelImpl> get copyWith =>
      __$$SpotlightItemModelImplCopyWithImpl<_$SpotlightItemModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpotlightItemModelImplToJson(
      this,
    );
  }
}

abstract class _SpotlightItemModel extends SpotlightItemModel {
  const factory _SpotlightItemModel(
          {@JsonKey(name: 'id') required final String id,
          @JsonKey(name: 'type') required final String type,
          @JsonKey(name: 'title') required final String title,
          @JsonKey(name: 'description') final String? description,
          @JsonKey(name: 'keywords') final List<String>? keywords,
          @JsonKey(name: 'deep_link') required final String deepLink,
          @JsonKey(name: 'account_id') required final String accountId,
          @JsonKey(name: 'content_id') required final String contentId,
          @JsonKey(name: 'last_updated') required final DateTime lastUpdated,
          @JsonKey(name: 'is_active') final bool isActive}) =
      _$SpotlightItemModelImpl;
  const _SpotlightItemModel._() : super._();

  factory _SpotlightItemModel.fromJson(Map<String, dynamic> json) =
      _$SpotlightItemModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'type')
  String get type;
  @override
  @JsonKey(name: 'title')
  String get title;
  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'keywords')
  List<String>? get keywords;
  @override
  @JsonKey(name: 'deep_link')
  String get deepLink;
  @override
  @JsonKey(name: 'account_id')
  String get accountId;
  @override
  @JsonKey(name: 'content_id')
  String get contentId;
  @override
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;

  /// Create a copy of SpotlightItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpotlightItemModelImplCopyWith<_$SpotlightItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
