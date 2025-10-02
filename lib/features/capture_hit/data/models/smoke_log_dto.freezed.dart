// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smoke_log_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SmokeLogDto _$SmokeLogDtoFromJson(Map<String, dynamic> json) {
  return _SmokeLogDto.fromJson(json);
}

/// @nodoc
mixin _$SmokeLogDto {
  String get id => throw _privateConstructorUsedError;
  String get accountId => throw _privateConstructorUsedError;
  DateTime get ts => throw _privateConstructorUsedError;
  int get durationMs => throw _privateConstructorUsedError;
  String? get methodId => throw _privateConstructorUsedError;
  int? get potency => throw _privateConstructorUsedError;
  int get moodScore => throw _privateConstructorUsedError;
  int get physicalScore => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get deviceLocalId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;
  bool get isPendingSync => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SmokeLogDtoCopyWith<SmokeLogDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmokeLogDtoCopyWith<$Res> {
  factory $SmokeLogDtoCopyWith(
          SmokeLogDto value, $Res Function(SmokeLogDto) then) =
      _$SmokeLogDtoCopyWithImpl<$Res, SmokeLogDto>;
  @useResult
  $Res call(
      {String id,
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
      bool isDeleted,
      bool isPendingSync});
}

/// @nodoc
class _$SmokeLogDtoCopyWithImpl<$Res, $Val extends SmokeLogDto>
    implements $SmokeLogDtoCopyWith<$Res> {
  _$SmokeLogDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    Object? isDeleted = null,
    Object? isPendingSync = null,
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
      ts: null == ts
          ? _value.ts
          : ts // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      methodId: freezed == methodId
          ? _value.methodId
          : methodId // ignore: cast_nullable_to_non_nullable
              as String?,
      potency: freezed == potency
          ? _value.potency
          : potency // ignore: cast_nullable_to_non_nullable
              as int?,
      moodScore: null == moodScore
          ? _value.moodScore
          : moodScore // ignore: cast_nullable_to_non_nullable
              as int,
      physicalScore: null == physicalScore
          ? _value.physicalScore
          : physicalScore // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceLocalId: freezed == deviceLocalId
          ? _value.deviceLocalId
          : deviceLocalId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isPendingSync: null == isPendingSync
          ? _value.isPendingSync
          : isPendingSync // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SmokeLogDtoImplCopyWith<$Res>
    implements $SmokeLogDtoCopyWith<$Res> {
  factory _$$SmokeLogDtoImplCopyWith(
          _$SmokeLogDtoImpl value, $Res Function(_$SmokeLogDtoImpl) then) =
      __$$SmokeLogDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
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
      bool isDeleted,
      bool isPendingSync});
}

/// @nodoc
class __$$SmokeLogDtoImplCopyWithImpl<$Res>
    extends _$SmokeLogDtoCopyWithImpl<$Res, _$SmokeLogDtoImpl>
    implements _$$SmokeLogDtoImplCopyWith<$Res> {
  __$$SmokeLogDtoImplCopyWithImpl(
      _$SmokeLogDtoImpl _value, $Res Function(_$SmokeLogDtoImpl) _then)
      : super(_value, _then);

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
    Object? isDeleted = null,
    Object? isPendingSync = null,
  }) {
    return _then(_$SmokeLogDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      ts: null == ts
          ? _value.ts
          : ts // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      methodId: freezed == methodId
          ? _value.methodId
          : methodId // ignore: cast_nullable_to_non_nullable
              as String?,
      potency: freezed == potency
          ? _value.potency
          : potency // ignore: cast_nullable_to_non_nullable
              as int?,
      moodScore: null == moodScore
          ? _value.moodScore
          : moodScore // ignore: cast_nullable_to_non_nullable
              as int,
      physicalScore: null == physicalScore
          ? _value.physicalScore
          : physicalScore // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceLocalId: freezed == deviceLocalId
          ? _value.deviceLocalId
          : deviceLocalId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isPendingSync: null == isPendingSync
          ? _value.isPendingSync
          : isPendingSync // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SmokeLogDtoImpl implements _SmokeLogDto {
  const _$SmokeLogDtoImpl(
      {required this.id,
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
      this.isDeleted = false,
      this.isPendingSync = false});

  factory _$SmokeLogDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmokeLogDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
  @override
  final DateTime ts;
  @override
  final int durationMs;
  @override
  final String? methodId;
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
  @JsonKey()
  final bool isDeleted;
  @override
  @JsonKey()
  final bool isPendingSync;

  @override
  String toString() {
    return 'SmokeLogDto(id: $id, accountId: $accountId, ts: $ts, durationMs: $durationMs, methodId: $methodId, potency: $potency, moodScore: $moodScore, physicalScore: $physicalScore, notes: $notes, deviceLocalId: $deviceLocalId, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, isPendingSync: $isPendingSync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmokeLogDtoImpl &&
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
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.isPendingSync, isPendingSync) ||
                other.isPendingSync == isPendingSync));
  }

  @JsonKey(ignore: true)
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
      isDeleted,
      isPendingSync);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SmokeLogDtoImplCopyWith<_$SmokeLogDtoImpl> get copyWith =>
      __$$SmokeLogDtoImplCopyWithImpl<_$SmokeLogDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmokeLogDtoImplToJson(
      this,
    );
  }
}

abstract class _SmokeLogDto implements SmokeLogDto {
  const factory _SmokeLogDto(
      {required final String id,
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
      final bool isDeleted,
      final bool isPendingSync}) = _$SmokeLogDtoImpl;

  factory _SmokeLogDto.fromJson(Map<String, dynamic> json) =
      _$SmokeLogDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId;
  @override
  DateTime get ts;
  @override
  int get durationMs;
  @override
  String? get methodId;
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
  @override
  bool get isDeleted;
  @override
  bool get isPendingSync;
  @override
  @JsonKey(ignore: true)
  _$$SmokeLogDtoImplCopyWith<_$SmokeLogDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
