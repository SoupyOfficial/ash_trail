// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smoke_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SmokeLog _$SmokeLogFromJson(Map<String, dynamic> json) {
  return _SmokeLog.fromJson(json);
}

/// @nodoc
mixin _$SmokeLog {
  String get id => throw _privateConstructorUsedError;
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  DateTime get ts => throw _privateConstructorUsedError;
  int get durationMs => throw _privateConstructorUsedError;
  String? get methodId =>
      throw _privateConstructorUsedError; // TODO: FK to Method
  int? get potency => throw _privateConstructorUsedError;
  int get moodScore => throw _privateConstructorUsedError;
  int get physicalScore => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get deviceLocalId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SmokeLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmokeLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmokeLogCopyWith<SmokeLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmokeLogCopyWith<$Res> {
  factory $SmokeLogCopyWith(SmokeLog value, $Res Function(SmokeLog) then) =
      _$SmokeLogCopyWithImpl<$Res, SmokeLog>;
  @useResult
  $Res call({
    String id,
    String accountId,
    DateTime ts,
    int durationMs,
    String? methodId,
    int? potency,
    int moodScore,
    int physicalScore,
    String? notes,
    String? deviceLocalId,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SmokeLogCopyWithImpl<$Res, $Val extends SmokeLog>
    implements $SmokeLogCopyWith<$Res> {
  _$SmokeLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmokeLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? ts = null,
    Object? durationMs = null,
    Object? methodId = freezed,
    Object? potency = freezed,
    Object? moodScore = null,
    Object? physicalScore = null,
    Object? notes = freezed,
    Object? deviceLocalId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            accountId:
                null == accountId
                    ? _value.accountId
                    : accountId // ignore: cast_nullable_to_non_nullable
                        as String,
            ts:
                null == ts
                    ? _value.ts
                    : ts // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            durationMs:
                null == durationMs
                    ? _value.durationMs
                    : durationMs // ignore: cast_nullable_to_non_nullable
                        as int,
            methodId:
                freezed == methodId
                    ? _value.methodId
                    : methodId // ignore: cast_nullable_to_non_nullable
                        as String?,
            potency:
                freezed == potency
                    ? _value.potency
                    : potency // ignore: cast_nullable_to_non_nullable
                        as int?,
            moodScore:
                null == moodScore
                    ? _value.moodScore
                    : moodScore // ignore: cast_nullable_to_non_nullable
                        as int,
            physicalScore:
                null == physicalScore
                    ? _value.physicalScore
                    : physicalScore // ignore: cast_nullable_to_non_nullable
                        as int,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
            deviceLocalId:
                freezed == deviceLocalId
                    ? _value.deviceLocalId
                    : deviceLocalId // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SmokeLogImplCopyWith<$Res>
    implements $SmokeLogCopyWith<$Res> {
  factory _$$SmokeLogImplCopyWith(
    _$SmokeLogImpl value,
    $Res Function(_$SmokeLogImpl) then,
  ) = __$$SmokeLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String accountId,
    DateTime ts,
    int durationMs,
    String? methodId,
    int? potency,
    int moodScore,
    int physicalScore,
    String? notes,
    String? deviceLocalId,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SmokeLogImplCopyWithImpl<$Res>
    extends _$SmokeLogCopyWithImpl<$Res, _$SmokeLogImpl>
    implements _$$SmokeLogImplCopyWith<$Res> {
  __$$SmokeLogImplCopyWithImpl(
    _$SmokeLogImpl _value,
    $Res Function(_$SmokeLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SmokeLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? ts = null,
    Object? durationMs = null,
    Object? methodId = freezed,
    Object? potency = freezed,
    Object? moodScore = null,
    Object? physicalScore = null,
    Object? notes = freezed,
    Object? deviceLocalId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SmokeLogImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        accountId:
            null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                    as String,
        ts:
            null == ts
                ? _value.ts
                : ts // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        durationMs:
            null == durationMs
                ? _value.durationMs
                : durationMs // ignore: cast_nullable_to_non_nullable
                    as int,
        methodId:
            freezed == methodId
                ? _value.methodId
                : methodId // ignore: cast_nullable_to_non_nullable
                    as String?,
        potency:
            freezed == potency
                ? _value.potency
                : potency // ignore: cast_nullable_to_non_nullable
                    as int?,
        moodScore:
            null == moodScore
                ? _value.moodScore
                : moodScore // ignore: cast_nullable_to_non_nullable
                    as int,
        physicalScore:
            null == physicalScore
                ? _value.physicalScore
                : physicalScore // ignore: cast_nullable_to_non_nullable
                    as int,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
        deviceLocalId:
            freezed == deviceLocalId
                ? _value.deviceLocalId
                : deviceLocalId // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SmokeLogImpl implements _SmokeLog {
  const _$SmokeLogImpl({
    required this.id,
    required this.accountId,
    required this.ts,
    required this.durationMs,
    this.methodId,
    this.potency,
    required this.moodScore,
    required this.physicalScore,
    this.notes,
    this.deviceLocalId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$SmokeLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmokeLogImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
  // TODO: FK to Account
  @override
  final DateTime ts;
  @override
  final int durationMs;
  @override
  final String? methodId;
  // TODO: FK to Method
  @override
  final int? potency;
  @override
  final int moodScore;
  @override
  final int physicalScore;
  @override
  final String? notes;
  @override
  final String? deviceLocalId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SmokeLog(id: $id, accountId: $accountId, ts: $ts, durationMs: $durationMs, methodId: $methodId, potency: $potency, moodScore: $moodScore, physicalScore: $physicalScore, notes: $notes, deviceLocalId: $deviceLocalId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmokeLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.ts, ts) || other.ts == ts) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.methodId, methodId) ||
                other.methodId == methodId) &&
            (identical(other.potency, potency) || other.potency == potency) &&
            (identical(other.moodScore, moodScore) ||
                other.moodScore == moodScore) &&
            (identical(other.physicalScore, physicalScore) ||
                other.physicalScore == physicalScore) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.deviceLocalId, deviceLocalId) ||
                other.deviceLocalId == deviceLocalId) &&
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
    ts,
    durationMs,
    methodId,
    potency,
    moodScore,
    physicalScore,
    notes,
    deviceLocalId,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SmokeLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmokeLogImplCopyWith<_$SmokeLogImpl> get copyWith =>
      __$$SmokeLogImplCopyWithImpl<_$SmokeLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmokeLogImplToJson(this);
  }
}

abstract class _SmokeLog implements SmokeLog {
  const factory _SmokeLog({
    required final String id,
    required final String accountId,
    required final DateTime ts,
    required final int durationMs,
    final String? methodId,
    final int? potency,
    required final int moodScore,
    required final int physicalScore,
    final String? notes,
    final String? deviceLocalId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SmokeLogImpl;

  factory _SmokeLog.fromJson(Map<String, dynamic> json) =
      _$SmokeLogImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId; // TODO: FK to Account
  @override
  DateTime get ts;
  @override
  int get durationMs;
  @override
  String? get methodId; // TODO: FK to Method
  @override
  int? get potency;
  @override
  int get moodScore;
  @override
  int get physicalScore;
  @override
  String? get notes;
  @override
  String? get deviceLocalId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SmokeLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmokeLogImplCopyWith<_$SmokeLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
