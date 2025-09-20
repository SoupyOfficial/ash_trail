// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LogFilter {
// Date range filtering
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate =>
      throw _privateConstructorUsedError; // Method filtering
  List<String>? get methodIds =>
      throw _privateConstructorUsedError; // Tag filtering (using SmokeLogTag relationships)
  List<String>? get includeTagIds => throw _privateConstructorUsedError;
  List<String>? get excludeTagIds =>
      throw _privateConstructorUsedError; // Mood score filtering (1-10)
  int? get minMoodScore => throw _privateConstructorUsedError;
  int? get maxMoodScore =>
      throw _privateConstructorUsedError; // Physical score filtering (1-10)
  int? get minPhysicalScore => throw _privateConstructorUsedError;
  int? get maxPhysicalScore =>
      throw _privateConstructorUsedError; // Duration filtering (in milliseconds)
  int? get minDurationMs => throw _privateConstructorUsedError;
  int? get maxDurationMs =>
      throw _privateConstructorUsedError; // Text search in notes
  String? get searchText => throw _privateConstructorUsedError;

  /// Create a copy of LogFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogFilterCopyWith<LogFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogFilterCopyWith<$Res> {
  factory $LogFilterCopyWith(LogFilter value, $Res Function(LogFilter) then) =
      _$LogFilterCopyWithImpl<$Res, LogFilter>;
  @useResult
  $Res call(
      {DateTime? startDate,
      DateTime? endDate,
      List<String>? methodIds,
      List<String>? includeTagIds,
      List<String>? excludeTagIds,
      int? minMoodScore,
      int? maxMoodScore,
      int? minPhysicalScore,
      int? maxPhysicalScore,
      int? minDurationMs,
      int? maxDurationMs,
      String? searchText});
}

/// @nodoc
class _$LogFilterCopyWithImpl<$Res, $Val extends LogFilter>
    implements $LogFilterCopyWith<$Res> {
  _$LogFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? methodIds = freezed,
    Object? includeTagIds = freezed,
    Object? excludeTagIds = freezed,
    Object? minMoodScore = freezed,
    Object? maxMoodScore = freezed,
    Object? minPhysicalScore = freezed,
    Object? maxPhysicalScore = freezed,
    Object? minDurationMs = freezed,
    Object? maxDurationMs = freezed,
    Object? searchText = freezed,
  }) {
    return _then(_value.copyWith(
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      methodIds: freezed == methodIds
          ? _value.methodIds
          : methodIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      includeTagIds: freezed == includeTagIds
          ? _value.includeTagIds
          : includeTagIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      excludeTagIds: freezed == excludeTagIds
          ? _value.excludeTagIds
          : excludeTagIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      minMoodScore: freezed == minMoodScore
          ? _value.minMoodScore
          : minMoodScore // ignore: cast_nullable_to_non_nullable
              as int?,
      maxMoodScore: freezed == maxMoodScore
          ? _value.maxMoodScore
          : maxMoodScore // ignore: cast_nullable_to_non_nullable
              as int?,
      minPhysicalScore: freezed == minPhysicalScore
          ? _value.minPhysicalScore
          : minPhysicalScore // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPhysicalScore: freezed == maxPhysicalScore
          ? _value.maxPhysicalScore
          : maxPhysicalScore // ignore: cast_nullable_to_non_nullable
              as int?,
      minDurationMs: freezed == minDurationMs
          ? _value.minDurationMs
          : minDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      maxDurationMs: freezed == maxDurationMs
          ? _value.maxDurationMs
          : maxDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      searchText: freezed == searchText
          ? _value.searchText
          : searchText // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogFilterImplCopyWith<$Res>
    implements $LogFilterCopyWith<$Res> {
  factory _$$LogFilterImplCopyWith(
          _$LogFilterImpl value, $Res Function(_$LogFilterImpl) then) =
      __$$LogFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? startDate,
      DateTime? endDate,
      List<String>? methodIds,
      List<String>? includeTagIds,
      List<String>? excludeTagIds,
      int? minMoodScore,
      int? maxMoodScore,
      int? minPhysicalScore,
      int? maxPhysicalScore,
      int? minDurationMs,
      int? maxDurationMs,
      String? searchText});
}

/// @nodoc
class __$$LogFilterImplCopyWithImpl<$Res>
    extends _$LogFilterCopyWithImpl<$Res, _$LogFilterImpl>
    implements _$$LogFilterImplCopyWith<$Res> {
  __$$LogFilterImplCopyWithImpl(
      _$LogFilterImpl _value, $Res Function(_$LogFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? methodIds = freezed,
    Object? includeTagIds = freezed,
    Object? excludeTagIds = freezed,
    Object? minMoodScore = freezed,
    Object? maxMoodScore = freezed,
    Object? minPhysicalScore = freezed,
    Object? maxPhysicalScore = freezed,
    Object? minDurationMs = freezed,
    Object? maxDurationMs = freezed,
    Object? searchText = freezed,
  }) {
    return _then(_$LogFilterImpl(
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      methodIds: freezed == methodIds
          ? _value._methodIds
          : methodIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      includeTagIds: freezed == includeTagIds
          ? _value._includeTagIds
          : includeTagIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      excludeTagIds: freezed == excludeTagIds
          ? _value._excludeTagIds
          : excludeTagIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      minMoodScore: freezed == minMoodScore
          ? _value.minMoodScore
          : minMoodScore // ignore: cast_nullable_to_non_nullable
              as int?,
      maxMoodScore: freezed == maxMoodScore
          ? _value.maxMoodScore
          : maxMoodScore // ignore: cast_nullable_to_non_nullable
              as int?,
      minPhysicalScore: freezed == minPhysicalScore
          ? _value.minPhysicalScore
          : minPhysicalScore // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPhysicalScore: freezed == maxPhysicalScore
          ? _value.maxPhysicalScore
          : maxPhysicalScore // ignore: cast_nullable_to_non_nullable
              as int?,
      minDurationMs: freezed == minDurationMs
          ? _value.minDurationMs
          : minDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      maxDurationMs: freezed == maxDurationMs
          ? _value.maxDurationMs
          : maxDurationMs // ignore: cast_nullable_to_non_nullable
              as int?,
      searchText: freezed == searchText
          ? _value.searchText
          : searchText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LogFilterImpl extends _LogFilter {
  const _$LogFilterImpl(
      {this.startDate,
      this.endDate,
      final List<String>? methodIds,
      final List<String>? includeTagIds,
      final List<String>? excludeTagIds,
      this.minMoodScore,
      this.maxMoodScore,
      this.minPhysicalScore,
      this.maxPhysicalScore,
      this.minDurationMs,
      this.maxDurationMs,
      this.searchText})
      : _methodIds = methodIds,
        _includeTagIds = includeTagIds,
        _excludeTagIds = excludeTagIds,
        super._();

// Date range filtering
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
// Method filtering
  final List<String>? _methodIds;
// Method filtering
  @override
  List<String>? get methodIds {
    final value = _methodIds;
    if (value == null) return null;
    if (_methodIds is EqualUnmodifiableListView) return _methodIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// Tag filtering (using SmokeLogTag relationships)
  final List<String>? _includeTagIds;
// Tag filtering (using SmokeLogTag relationships)
  @override
  List<String>? get includeTagIds {
    final value = _includeTagIds;
    if (value == null) return null;
    if (_includeTagIds is EqualUnmodifiableListView) return _includeTagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _excludeTagIds;
  @override
  List<String>? get excludeTagIds {
    final value = _excludeTagIds;
    if (value == null) return null;
    if (_excludeTagIds is EqualUnmodifiableListView) return _excludeTagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// Mood score filtering (1-10)
  @override
  final int? minMoodScore;
  @override
  final int? maxMoodScore;
// Physical score filtering (1-10)
  @override
  final int? minPhysicalScore;
  @override
  final int? maxPhysicalScore;
// Duration filtering (in milliseconds)
  @override
  final int? minDurationMs;
  @override
  final int? maxDurationMs;
// Text search in notes
  @override
  final String? searchText;

  @override
  String toString() {
    return 'LogFilter(startDate: $startDate, endDate: $endDate, methodIds: $methodIds, includeTagIds: $includeTagIds, excludeTagIds: $excludeTagIds, minMoodScore: $minMoodScore, maxMoodScore: $maxMoodScore, minPhysicalScore: $minPhysicalScore, maxPhysicalScore: $maxPhysicalScore, minDurationMs: $minDurationMs, maxDurationMs: $maxDurationMs, searchText: $searchText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogFilterImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality()
                .equals(other._methodIds, _methodIds) &&
            const DeepCollectionEquality()
                .equals(other._includeTagIds, _includeTagIds) &&
            const DeepCollectionEquality()
                .equals(other._excludeTagIds, _excludeTagIds) &&
            (identical(other.minMoodScore, minMoodScore) ||
                other.minMoodScore == minMoodScore) &&
            (identical(other.maxMoodScore, maxMoodScore) ||
                other.maxMoodScore == maxMoodScore) &&
            (identical(other.minPhysicalScore, minPhysicalScore) ||
                other.minPhysicalScore == minPhysicalScore) &&
            (identical(other.maxPhysicalScore, maxPhysicalScore) ||
                other.maxPhysicalScore == maxPhysicalScore) &&
            (identical(other.minDurationMs, minDurationMs) ||
                other.minDurationMs == minDurationMs) &&
            (identical(other.maxDurationMs, maxDurationMs) ||
                other.maxDurationMs == maxDurationMs) &&
            (identical(other.searchText, searchText) ||
                other.searchText == searchText));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      startDate,
      endDate,
      const DeepCollectionEquality().hash(_methodIds),
      const DeepCollectionEquality().hash(_includeTagIds),
      const DeepCollectionEquality().hash(_excludeTagIds),
      minMoodScore,
      maxMoodScore,
      minPhysicalScore,
      maxPhysicalScore,
      minDurationMs,
      maxDurationMs,
      searchText);

  /// Create a copy of LogFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogFilterImplCopyWith<_$LogFilterImpl> get copyWith =>
      __$$LogFilterImplCopyWithImpl<_$LogFilterImpl>(this, _$identity);
}

abstract class _LogFilter extends LogFilter {
  const factory _LogFilter(
      {final DateTime? startDate,
      final DateTime? endDate,
      final List<String>? methodIds,
      final List<String>? includeTagIds,
      final List<String>? excludeTagIds,
      final int? minMoodScore,
      final int? maxMoodScore,
      final int? minPhysicalScore,
      final int? maxPhysicalScore,
      final int? minDurationMs,
      final int? maxDurationMs,
      final String? searchText}) = _$LogFilterImpl;
  const _LogFilter._() : super._();

// Date range filtering
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate; // Method filtering
  @override
  List<String>?
      get methodIds; // Tag filtering (using SmokeLogTag relationships)
  @override
  List<String>? get includeTagIds;
  @override
  List<String>? get excludeTagIds; // Mood score filtering (1-10)
  @override
  int? get minMoodScore;
  @override
  int? get maxMoodScore; // Physical score filtering (1-10)
  @override
  int? get minPhysicalScore;
  @override
  int? get maxPhysicalScore; // Duration filtering (in milliseconds)
  @override
  int? get minDurationMs;
  @override
  int? get maxDurationMs; // Text search in notes
  @override
  String? get searchText;

  /// Create a copy of LogFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogFilterImplCopyWith<_$LogFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
