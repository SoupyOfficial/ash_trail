// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FilterPreset _$FilterPresetFromJson(Map<String, dynamic> json) {
  return _FilterPreset.fromJson(json);
}

/// @nodoc
mixin _$FilterPreset {
  String get id => throw _privateConstructorUsedError;
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  String get name => throw _privateConstructorUsedError;
  String get range =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  DateTime? get customStart => throw _privateConstructorUsedError;
  DateTime? get customEnd => throw _privateConstructorUsedError;
  List<String>? get includeTags => throw _privateConstructorUsedError;
  List<String>? get excludeTags => throw _privateConstructorUsedError;
  String get sort =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String? get query => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this FilterPreset to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FilterPresetCopyWith<FilterPreset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FilterPresetCopyWith<$Res> {
  factory $FilterPresetCopyWith(
          FilterPreset value, $Res Function(FilterPreset) then) =
      _$FilterPresetCopyWithImpl<$Res, FilterPreset>;
  @useResult
  $Res call(
      {String id,
      String accountId,
      String name,
      String range,
      DateTime? customStart,
      DateTime? customEnd,
      List<String>? includeTags,
      List<String>? excludeTags,
      String sort,
      String? query,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$FilterPresetCopyWithImpl<$Res, $Val extends FilterPreset>
    implements $FilterPresetCopyWith<$Res> {
  _$FilterPresetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? name = null,
    Object? range = null,
    Object? customStart = freezed,
    Object? customEnd = freezed,
    Object? includeTags = freezed,
    Object? excludeTags = freezed,
    Object? sort = null,
    Object? query = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      range: null == range
          ? _value.range
          : range // ignore: cast_nullable_to_non_nullable
              as String,
      customStart: freezed == customStart
          ? _value.customStart
          : customStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      customEnd: freezed == customEnd
          ? _value.customEnd
          : customEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      includeTags: freezed == includeTags
          ? _value.includeTags
          : includeTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      excludeTags: freezed == excludeTags
          ? _value.excludeTags
          : excludeTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as String,
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FilterPresetImplCopyWith<$Res>
    implements $FilterPresetCopyWith<$Res> {
  factory _$$FilterPresetImplCopyWith(
          _$FilterPresetImpl value, $Res Function(_$FilterPresetImpl) then) =
      __$$FilterPresetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String accountId,
      String name,
      String range,
      DateTime? customStart,
      DateTime? customEnd,
      List<String>? includeTags,
      List<String>? excludeTags,
      String sort,
      String? query,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$FilterPresetImplCopyWithImpl<$Res>
    extends _$FilterPresetCopyWithImpl<$Res, _$FilterPresetImpl>
    implements _$$FilterPresetImplCopyWith<$Res> {
  __$$FilterPresetImplCopyWithImpl(
      _$FilterPresetImpl _value, $Res Function(_$FilterPresetImpl) _then)
      : super(_value, _then);

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? name = null,
    Object? range = null,
    Object? customStart = freezed,
    Object? customEnd = freezed,
    Object? includeTags = freezed,
    Object? excludeTags = freezed,
    Object? sort = null,
    Object? query = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$FilterPresetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      range: null == range
          ? _value.range
          : range // ignore: cast_nullable_to_non_nullable
              as String,
      customStart: freezed == customStart
          ? _value.customStart
          : customStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      customEnd: freezed == customEnd
          ? _value.customEnd
          : customEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      includeTags: freezed == includeTags
          ? _value._includeTags
          : includeTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      excludeTags: freezed == excludeTags
          ? _value._excludeTags
          : excludeTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as String,
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FilterPresetImpl implements _FilterPreset {
  const _$FilterPresetImpl(
      {required this.id,
      required this.accountId,
      required this.name,
      required this.range,
      this.customStart,
      this.customEnd,
      final List<String>? includeTags,
      final List<String>? excludeTags,
      required this.sort,
      this.query,
      required this.createdAt,
      required this.updatedAt})
      : _includeTags = includeTags,
        _excludeTags = excludeTags;

  factory _$FilterPresetImpl.fromJson(Map<String, dynamic> json) =>
      _$$FilterPresetImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
// TODO: FK to Account
  @override
  final String name;
  @override
  final String range;
// TODO: constrain to enum values
  @override
  final DateTime? customStart;
  @override
  final DateTime? customEnd;
  final List<String>? _includeTags;
  @override
  List<String>? get includeTags {
    final value = _includeTags;
    if (value == null) return null;
    if (_includeTags is EqualUnmodifiableListView) return _includeTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _excludeTags;
  @override
  List<String>? get excludeTags {
    final value = _excludeTags;
    if (value == null) return null;
    if (_excludeTags is EqualUnmodifiableListView) return _excludeTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String sort;
// TODO: constrain to enum values
  @override
  final String? query;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'FilterPreset(id: $id, accountId: $accountId, name: $name, range: $range, customStart: $customStart, customEnd: $customEnd, includeTags: $includeTags, excludeTags: $excludeTags, sort: $sort, query: $query, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterPresetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.range, range) || other.range == range) &&
            (identical(other.customStart, customStart) ||
                other.customStart == customStart) &&
            (identical(other.customEnd, customEnd) ||
                other.customEnd == customEnd) &&
            const DeepCollectionEquality()
                .equals(other._includeTags, _includeTags) &&
            const DeepCollectionEquality()
                .equals(other._excludeTags, _excludeTags) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      accountId,
      name,
      range,
      customStart,
      customEnd,
      const DeepCollectionEquality().hash(_includeTags),
      const DeepCollectionEquality().hash(_excludeTags),
      sort,
      query,
      createdAt,
      updatedAt);

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterPresetImplCopyWith<_$FilterPresetImpl> get copyWith =>
      __$$FilterPresetImplCopyWithImpl<_$FilterPresetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FilterPresetImplToJson(
      this,
    );
  }
}

abstract class _FilterPreset implements FilterPreset {
  const factory _FilterPreset(
      {required final String id,
      required final String accountId,
      required final String name,
      required final String range,
      final DateTime? customStart,
      final DateTime? customEnd,
      final List<String>? includeTags,
      final List<String>? excludeTags,
      required final String sort,
      final String? query,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$FilterPresetImpl;

  factory _FilterPreset.fromJson(Map<String, dynamic> json) =
      _$FilterPresetImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId; // TODO: FK to Account
  @override
  String get name;
  @override
  String get range; // TODO: constrain to enum values
  @override
  DateTime? get customStart;
  @override
  DateTime? get customEnd;
  @override
  List<String>? get includeTags;
  @override
  List<String>? get excludeTags;
  @override
  String get sort; // TODO: constrain to enum values
  @override
  String? get query;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of FilterPreset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FilterPresetImplCopyWith<_$FilterPresetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
