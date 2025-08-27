// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_daily.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StatsDaily _$StatsDailyFromJson(Map<String, dynamic> json) {
  return _StatsDaily.fromJson(json);
}

/// @nodoc
mixin _$StatsDaily {
  String get id => throw _privateConstructorUsedError;
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  DateTime get date => throw _privateConstructorUsedError;
  int get hitCount => throw _privateConstructorUsedError;
  int get totalDurationMs => throw _privateConstructorUsedError;
  int get avgDurationMs => throw _privateConstructorUsedError;

  /// Serializes this StatsDaily to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatsDaily
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatsDailyCopyWith<StatsDaily> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsDailyCopyWith<$Res> {
  factory $StatsDailyCopyWith(
          StatsDaily value, $Res Function(StatsDaily) then) =
      _$StatsDailyCopyWithImpl<$Res, StatsDaily>;
  @useResult
  $Res call(
      {String id,
      String accountId,
      DateTime date,
      int hitCount,
      int totalDurationMs,
      int avgDurationMs});
}

/// @nodoc
class _$StatsDailyCopyWithImpl<$Res, $Val extends StatsDaily>
    implements $StatsDailyCopyWith<$Res> {
  _$StatsDailyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatsDaily
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? date = null,
    Object? hitCount = null,
    Object? totalDurationMs = null,
    Object? avgDurationMs = null,
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
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hitCount: null == hitCount
          ? _value.hitCount
          : hitCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMs: null == totalDurationMs
          ? _value.totalDurationMs
          : totalDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      avgDurationMs: null == avgDurationMs
          ? _value.avgDurationMs
          : avgDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatsDailyImplCopyWith<$Res>
    implements $StatsDailyCopyWith<$Res> {
  factory _$$StatsDailyImplCopyWith(
          _$StatsDailyImpl value, $Res Function(_$StatsDailyImpl) then) =
      __$$StatsDailyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String accountId,
      DateTime date,
      int hitCount,
      int totalDurationMs,
      int avgDurationMs});
}

/// @nodoc
class __$$StatsDailyImplCopyWithImpl<$Res>
    extends _$StatsDailyCopyWithImpl<$Res, _$StatsDailyImpl>
    implements _$$StatsDailyImplCopyWith<$Res> {
  __$$StatsDailyImplCopyWithImpl(
      _$StatsDailyImpl _value, $Res Function(_$StatsDailyImpl) _then)
      : super(_value, _then);

  /// Create a copy of StatsDaily
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? date = null,
    Object? hitCount = null,
    Object? totalDurationMs = null,
    Object? avgDurationMs = null,
  }) {
    return _then(_$StatsDailyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hitCount: null == hitCount
          ? _value.hitCount
          : hitCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMs: null == totalDurationMs
          ? _value.totalDurationMs
          : totalDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
      avgDurationMs: null == avgDurationMs
          ? _value.avgDurationMs
          : avgDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsDailyImpl implements _StatsDaily {
  const _$StatsDailyImpl(
      {required this.id,
      required this.accountId,
      required this.date,
      required this.hitCount,
      required this.totalDurationMs,
      required this.avgDurationMs});

  factory _$StatsDailyImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsDailyImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
// TODO: FK to Account
  @override
  final DateTime date;
  @override
  final int hitCount;
  @override
  final int totalDurationMs;
  @override
  final int avgDurationMs;

  @override
  String toString() {
    return 'StatsDaily(id: $id, accountId: $accountId, date: $date, hitCount: $hitCount, totalDurationMs: $totalDurationMs, avgDurationMs: $avgDurationMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsDailyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.hitCount, hitCount) ||
                other.hitCount == hitCount) &&
            (identical(other.totalDurationMs, totalDurationMs) ||
                other.totalDurationMs == totalDurationMs) &&
            (identical(other.avgDurationMs, avgDurationMs) ||
                other.avgDurationMs == avgDurationMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, accountId, date, hitCount,
      totalDurationMs, avgDurationMs);

  /// Create a copy of StatsDaily
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsDailyImplCopyWith<_$StatsDailyImpl> get copyWith =>
      __$$StatsDailyImplCopyWithImpl<_$StatsDailyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsDailyImplToJson(
      this,
    );
  }
}

abstract class _StatsDaily implements StatsDaily {
  const factory _StatsDaily(
      {required final String id,
      required final String accountId,
      required final DateTime date,
      required final int hitCount,
      required final int totalDurationMs,
      required final int avgDurationMs}) = _$StatsDailyImpl;

  factory _StatsDaily.fromJson(Map<String, dynamic> json) =
      _$StatsDailyImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId; // TODO: FK to Account
  @override
  DateTime get date;
  @override
  int get hitCount;
  @override
  int get totalDurationMs;
  @override
  int get avgDurationMs;

  /// Create a copy of StatsDaily
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatsDailyImplCopyWith<_$StatsDailyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
