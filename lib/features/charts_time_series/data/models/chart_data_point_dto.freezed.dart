// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chart_data_point_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChartDataPointDto _$ChartDataPointDtoFromJson(Map<String, dynamic> json) {
  return _ChartDataPointDto.fromJson(json);
}

/// @nodoc
mixin _$ChartDataPointDto {
  DateTime get timestamp => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  int get totalDurationMs => throw _privateConstructorUsedError;
  double? get averageMoodScore => throw _privateConstructorUsedError;
  double? get averagePhysicalScore => throw _privateConstructorUsedError;

  /// Serializes this ChartDataPointDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChartDataPointDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChartDataPointDtoCopyWith<ChartDataPointDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChartDataPointDtoCopyWith<$Res> {
  factory $ChartDataPointDtoCopyWith(
          ChartDataPointDto value, $Res Function(ChartDataPointDto) then) =
      _$ChartDataPointDtoCopyWithImpl<$Res, ChartDataPointDto>;
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
class _$ChartDataPointDtoCopyWithImpl<$Res, $Val extends ChartDataPointDto>
    implements $ChartDataPointDtoCopyWith<$Res> {
  _$ChartDataPointDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChartDataPointDto
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
abstract class _$$ChartDataPointDtoImplCopyWith<$Res>
    implements $ChartDataPointDtoCopyWith<$Res> {
  factory _$$ChartDataPointDtoImplCopyWith(_$ChartDataPointDtoImpl value,
          $Res Function(_$ChartDataPointDtoImpl) then) =
      __$$ChartDataPointDtoImplCopyWithImpl<$Res>;
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
class __$$ChartDataPointDtoImplCopyWithImpl<$Res>
    extends _$ChartDataPointDtoCopyWithImpl<$Res, _$ChartDataPointDtoImpl>
    implements _$$ChartDataPointDtoImplCopyWith<$Res> {
  __$$ChartDataPointDtoImplCopyWithImpl(_$ChartDataPointDtoImpl _value,
      $Res Function(_$ChartDataPointDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChartDataPointDto
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
    return _then(_$ChartDataPointDtoImpl(
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
class _$ChartDataPointDtoImpl implements _ChartDataPointDto {
  const _$ChartDataPointDtoImpl(
      {required this.timestamp,
      required this.value,
      required this.count,
      required this.totalDurationMs,
      this.averageMoodScore,
      this.averagePhysicalScore});

  factory _$ChartDataPointDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChartDataPointDtoImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final double value;
  @override
  final int count;
  @override
  final int totalDurationMs;
  @override
  final double? averageMoodScore;
  @override
  final double? averagePhysicalScore;

  @override
  String toString() {
    return 'ChartDataPointDto(timestamp: $timestamp, value: $value, count: $count, totalDurationMs: $totalDurationMs, averageMoodScore: $averageMoodScore, averagePhysicalScore: $averagePhysicalScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChartDataPointDtoImpl &&
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

  /// Create a copy of ChartDataPointDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChartDataPointDtoImplCopyWith<_$ChartDataPointDtoImpl> get copyWith =>
      __$$ChartDataPointDtoImplCopyWithImpl<_$ChartDataPointDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChartDataPointDtoImplToJson(
      this,
    );
  }
}

abstract class _ChartDataPointDto implements ChartDataPointDto {
  const factory _ChartDataPointDto(
      {required final DateTime timestamp,
      required final double value,
      required final int count,
      required final int totalDurationMs,
      final double? averageMoodScore,
      final double? averagePhysicalScore}) = _$ChartDataPointDtoImpl;

  factory _ChartDataPointDto.fromJson(Map<String, dynamic> json) =
      _$ChartDataPointDtoImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  double get value;
  @override
  int get count;
  @override
  int get totalDurationMs;
  @override
  double? get averageMoodScore;
  @override
  double? get averagePhysicalScore;

  /// Create a copy of ChartDataPointDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChartDataPointDtoImplCopyWith<_$ChartDataPointDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
