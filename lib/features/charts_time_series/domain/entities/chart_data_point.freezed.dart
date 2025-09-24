// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chart_data_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChartDataPoint _$ChartDataPointFromJson(Map<String, dynamic> json) {
  return _ChartDataPoint.fromJson(json);
}

/// @nodoc
mixin _$ChartDataPoint {
  /// Timestamp for this data point
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Primary metric value (e.g., count, duration, average)
  double get value => throw _privateConstructorUsedError;

  /// Raw count of items in this time bucket
  int get count => throw _privateConstructorUsedError;

  /// Sum of durations in milliseconds
  int get totalDurationMs => throw _privateConstructorUsedError;

  /// Average mood score for this time period (0-10 scale)
  double? get averageMoodScore => throw _privateConstructorUsedError;

  /// Average physical score for this time period (0-10 scale)
  double? get averagePhysicalScore => throw _privateConstructorUsedError;

  /// Serializes this ChartDataPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChartDataPointCopyWith<ChartDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChartDataPointCopyWith<$Res> {
  factory $ChartDataPointCopyWith(
          ChartDataPoint value, $Res Function(ChartDataPoint) then) =
      _$ChartDataPointCopyWithImpl<$Res, ChartDataPoint>;
  @useResult
  $Res call(
      {DateTime timestamp,
      double value,
      int count,
      int totalDurationMs,
      double? averageMoodScore,
      double? averagePhysicalScore});
}

/// @nodoc
class _$ChartDataPointCopyWithImpl<$Res, $Val extends ChartDataPoint>
    implements $ChartDataPointCopyWith<$Res> {
  _$ChartDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? value = null,
    Object? count = null,
    Object? totalDurationMs = null,
    Object? averageMoodScore = freezed,
    Object? averagePhysicalScore = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMs: null == totalDurationMs
          ? _value.totalDurationMs
          : totalDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      averageMoodScore: freezed == averageMoodScore
          ? _value.averageMoodScore
          : averageMoodScore // ignore: cast_nullable_to_non_nullable
              as double?,
      averagePhysicalScore: freezed == averagePhysicalScore
          ? _value.averagePhysicalScore
          : averagePhysicalScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChartDataPointImplCopyWith<$Res>
    implements $ChartDataPointCopyWith<$Res> {
  factory _$$ChartDataPointImplCopyWith(_$ChartDataPointImpl value,
          $Res Function(_$ChartDataPointImpl) then) =
      __$$ChartDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime timestamp,
      double value,
      int count,
      int totalDurationMs,
      double? averageMoodScore,
      double? averagePhysicalScore});
}

/// @nodoc
class __$$ChartDataPointImplCopyWithImpl<$Res>
    extends _$ChartDataPointCopyWithImpl<$Res, _$ChartDataPointImpl>
    implements _$$ChartDataPointImplCopyWith<$Res> {
  __$$ChartDataPointImplCopyWithImpl(
      _$ChartDataPointImpl _value, $Res Function(_$ChartDataPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? value = null,
    Object? count = null,
    Object? totalDurationMs = null,
    Object? averageMoodScore = freezed,
    Object? averagePhysicalScore = freezed,
  }) {
    return _then(_$ChartDataPointImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMs: null == totalDurationMs
          ? _value.totalDurationMs
          : totalDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      averageMoodScore: freezed == averageMoodScore
          ? _value.averageMoodScore
          : averageMoodScore // ignore: cast_nullable_to_non_nullable
              as double?,
      averagePhysicalScore: freezed == averagePhysicalScore
          ? _value.averagePhysicalScore
          : averagePhysicalScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChartDataPointImpl extends _ChartDataPoint {
  const _$ChartDataPointImpl(
      {required this.timestamp,
      required this.value,
      required this.count,
      required this.totalDurationMs,
      this.averageMoodScore,
      this.averagePhysicalScore})
      : super._();

  factory _$ChartDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChartDataPointImplFromJson(json);

  /// Timestamp for this data point
  @override
  final DateTime timestamp;

  /// Primary metric value (e.g., count, duration, average)
  @override
  final double value;

  /// Raw count of items in this time bucket
  @override
  final int count;

  /// Sum of durations in milliseconds
  @override
  final int totalDurationMs;

  /// Average mood score for this time period (0-10 scale)
  @override
  final double? averageMoodScore;

  /// Average physical score for this time period (0-10 scale)
  @override
  final double? averagePhysicalScore;

  @override
  String toString() {
    return 'ChartDataPoint(timestamp: $timestamp, value: $value, count: $count, totalDurationMs: $totalDurationMs, averageMoodScore: $averageMoodScore, averagePhysicalScore: $averagePhysicalScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChartDataPointImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.totalDurationMs, totalDurationMs) ||
                other.totalDurationMs == totalDurationMs) &&
            (identical(other.averageMoodScore, averageMoodScore) ||
                other.averageMoodScore == averageMoodScore) &&
            (identical(other.averagePhysicalScore, averagePhysicalScore) ||
                other.averagePhysicalScore == averagePhysicalScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, value, count,
      totalDurationMs, averageMoodScore, averagePhysicalScore);

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChartDataPointImplCopyWith<_$ChartDataPointImpl> get copyWith =>
      __$$ChartDataPointImplCopyWithImpl<_$ChartDataPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChartDataPointImplToJson(
      this,
    );
  }
}

abstract class _ChartDataPoint extends ChartDataPoint {
  const factory _ChartDataPoint(
      {required final DateTime timestamp,
      required final double value,
      required final int count,
      required final int totalDurationMs,
      final double? averageMoodScore,
      final double? averagePhysicalScore}) = _$ChartDataPointImpl;
  const _ChartDataPoint._() : super._();

  factory _ChartDataPoint.fromJson(Map<String, dynamic> json) =
      _$ChartDataPointImpl.fromJson;

  /// Timestamp for this data point
  @override
  DateTime get timestamp;

  /// Primary metric value (e.g., count, duration, average)
  @override
  double get value;

  /// Raw count of items in this time bucket
  @override
  int get count;

  /// Sum of durations in milliseconds
  @override
  int get totalDurationMs;

  /// Average mood score for this time period (0-10 scale)
  @override
  double? get averageMoodScore;

  /// Average physical score for this time period (0-10 scale)
  @override
  double? get averagePhysicalScore;

  /// Create a copy of ChartDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChartDataPointImplCopyWith<_$ChartDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
