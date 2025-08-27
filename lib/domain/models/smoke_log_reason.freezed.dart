// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smoke_log_reason.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SmokeLogReason _$SmokeLogReasonFromJson(Map<String, dynamic> json) {
  return _SmokeLogReason.fromJson(json);
}

/// @nodoc
mixin _$SmokeLogReason {
  String get id => throw _privateConstructorUsedError;
  String get smokeLogId =>
      throw _privateConstructorUsedError; // TODO: FK to SmokeLog
  String get reasonId =>
      throw _privateConstructorUsedError; // TODO: FK to Reason
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  DateTime get ts => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SmokeLogReason to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmokeLogReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmokeLogReasonCopyWith<SmokeLogReason> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmokeLogReasonCopyWith<$Res> {
  factory $SmokeLogReasonCopyWith(
    SmokeLogReason value,
    $Res Function(SmokeLogReason) then,
  ) = _$SmokeLogReasonCopyWithImpl<$Res, SmokeLogReason>;
  @useResult
  $Res call({
    String id,
    String smokeLogId,
    String reasonId,
    String accountId,
    DateTime ts,
    DateTime createdAt,
  });
}

/// @nodoc
class _$SmokeLogReasonCopyWithImpl<$Res, $Val extends SmokeLogReason>
    implements $SmokeLogReasonCopyWith<$Res> {
  _$SmokeLogReasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmokeLogReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smokeLogId = null,
    Object? reasonId = null,
    Object? accountId = null,
    Object? ts = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            smokeLogId:
                null == smokeLogId
                    ? _value.smokeLogId
                    : smokeLogId // ignore: cast_nullable_to_non_nullable
                        as String,
            reasonId:
                null == reasonId
                    ? _value.reasonId
                    : reasonId // ignore: cast_nullable_to_non_nullable
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
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SmokeLogReasonImplCopyWith<$Res>
    implements $SmokeLogReasonCopyWith<$Res> {
  factory _$$SmokeLogReasonImplCopyWith(
    _$SmokeLogReasonImpl value,
    $Res Function(_$SmokeLogReasonImpl) then,
  ) = __$$SmokeLogReasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String smokeLogId,
    String reasonId,
    String accountId,
    DateTime ts,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$SmokeLogReasonImplCopyWithImpl<$Res>
    extends _$SmokeLogReasonCopyWithImpl<$Res, _$SmokeLogReasonImpl>
    implements _$$SmokeLogReasonImplCopyWith<$Res> {
  __$$SmokeLogReasonImplCopyWithImpl(
    _$SmokeLogReasonImpl _value,
    $Res Function(_$SmokeLogReasonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SmokeLogReason
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smokeLogId = null,
    Object? reasonId = null,
    Object? accountId = null,
    Object? ts = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SmokeLogReasonImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        smokeLogId:
            null == smokeLogId
                ? _value.smokeLogId
                : smokeLogId // ignore: cast_nullable_to_non_nullable
                    as String,
        reasonId:
            null == reasonId
                ? _value.reasonId
                : reasonId // ignore: cast_nullable_to_non_nullable
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
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SmokeLogReasonImpl implements _SmokeLogReason {
  const _$SmokeLogReasonImpl({
    required this.id,
    required this.smokeLogId,
    required this.reasonId,
    required this.accountId,
    required this.ts,
    required this.createdAt,
  });

  factory _$SmokeLogReasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmokeLogReasonImplFromJson(json);

  @override
  final String id;
  @override
  final String smokeLogId;
  // TODO: FK to SmokeLog
  @override
  final String reasonId;
  // TODO: FK to Reason
  @override
  final String accountId;
  // TODO: FK to Account
  @override
  final DateTime ts;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SmokeLogReason(id: $id, smokeLogId: $smokeLogId, reasonId: $reasonId, accountId: $accountId, ts: $ts, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmokeLogReasonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.smokeLogId, smokeLogId) ||
                other.smokeLogId == smokeLogId) &&
            (identical(other.reasonId, reasonId) ||
                other.reasonId == reasonId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.ts, ts) || other.ts == ts) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    smokeLogId,
    reasonId,
    accountId,
    ts,
    createdAt,
  );

  /// Create a copy of SmokeLogReason
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmokeLogReasonImplCopyWith<_$SmokeLogReasonImpl> get copyWith =>
      __$$SmokeLogReasonImplCopyWithImpl<_$SmokeLogReasonImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SmokeLogReasonImplToJson(this);
  }
}

abstract class _SmokeLogReason implements SmokeLogReason {
  const factory _SmokeLogReason({
    required final String id,
    required final String smokeLogId,
    required final String reasonId,
    required final String accountId,
    required final DateTime ts,
    required final DateTime createdAt,
  }) = _$SmokeLogReasonImpl;

  factory _SmokeLogReason.fromJson(Map<String, dynamic> json) =
      _$SmokeLogReasonImpl.fromJson;

  @override
  String get id;
  @override
  String get smokeLogId; // TODO: FK to SmokeLog
  @override
  String get reasonId; // TODO: FK to Reason
  @override
  String get accountId; // TODO: FK to Account
  @override
  DateTime get ts;
  @override
  DateTime get createdAt;

  /// Create a copy of SmokeLogReason
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmokeLogReasonImplCopyWith<_$SmokeLogReasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
