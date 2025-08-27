// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_op.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SyncOp _$SyncOpFromJson(Map<String, dynamic> json) {
  return _SyncOp.fromJson(json);
}

/// @nodoc
mixin _$SyncOp {
  String get id => throw _privateConstructorUsedError;
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  String get entity =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String get op =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String get recordId => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  int get attempts => throw _privateConstructorUsedError;
  String? get lastError => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SyncOp to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncOp
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncOpCopyWith<SyncOp> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncOpCopyWith<$Res> {
  factory $SyncOpCopyWith(SyncOp value, $Res Function(SyncOp) then) =
      _$SyncOpCopyWithImpl<$Res, SyncOp>;
  @useResult
  $Res call({
    String id,
    String accountId,
    String entity,
    String op,
    String recordId,
    Map<String, dynamic> payload,
    String status,
    int attempts,
    String? lastError,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SyncOpCopyWithImpl<$Res, $Val extends SyncOp>
    implements $SyncOpCopyWith<$Res> {
  _$SyncOpCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncOp
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? entity = null,
    Object? op = null,
    Object? recordId = null,
    Object? payload = null,
    Object? status = null,
    Object? attempts = null,
    Object? lastError = freezed,
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
            entity:
                null == entity
                    ? _value.entity
                    : entity // ignore: cast_nullable_to_non_nullable
                        as String,
            op:
                null == op
                    ? _value.op
                    : op // ignore: cast_nullable_to_non_nullable
                        as String,
            recordId:
                null == recordId
                    ? _value.recordId
                    : recordId // ignore: cast_nullable_to_non_nullable
                        as String,
            payload:
                null == payload
                    ? _value.payload
                    : payload // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            attempts:
                null == attempts
                    ? _value.attempts
                    : attempts // ignore: cast_nullable_to_non_nullable
                        as int,
            lastError:
                freezed == lastError
                    ? _value.lastError
                    : lastError // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SyncOpImplCopyWith<$Res> implements $SyncOpCopyWith<$Res> {
  factory _$$SyncOpImplCopyWith(
    _$SyncOpImpl value,
    $Res Function(_$SyncOpImpl) then,
  ) = __$$SyncOpImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String accountId,
    String entity,
    String op,
    String recordId,
    Map<String, dynamic> payload,
    String status,
    int attempts,
    String? lastError,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SyncOpImplCopyWithImpl<$Res>
    extends _$SyncOpCopyWithImpl<$Res, _$SyncOpImpl>
    implements _$$SyncOpImplCopyWith<$Res> {
  __$$SyncOpImplCopyWithImpl(
    _$SyncOpImpl _value,
    $Res Function(_$SyncOpImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncOp
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? entity = null,
    Object? op = null,
    Object? recordId = null,
    Object? payload = null,
    Object? status = null,
    Object? attempts = null,
    Object? lastError = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SyncOpImpl(
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
        entity:
            null == entity
                ? _value.entity
                : entity // ignore: cast_nullable_to_non_nullable
                    as String,
        op:
            null == op
                ? _value.op
                : op // ignore: cast_nullable_to_non_nullable
                    as String,
        recordId:
            null == recordId
                ? _value.recordId
                : recordId // ignore: cast_nullable_to_non_nullable
                    as String,
        payload:
            null == payload
                ? _value._payload
                : payload // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        attempts:
            null == attempts
                ? _value.attempts
                : attempts // ignore: cast_nullable_to_non_nullable
                    as int,
        lastError:
            freezed == lastError
                ? _value.lastError
                : lastError // ignore: cast_nullable_to_non_nullable
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
class _$SyncOpImpl implements _SyncOp {
  const _$SyncOpImpl({
    required this.id,
    required this.accountId,
    required this.entity,
    required this.op,
    required this.recordId,
    required final Map<String, dynamic> payload,
    required this.status,
    required this.attempts,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  }) : _payload = payload;

  factory _$SyncOpImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncOpImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
  // TODO: FK to Account
  @override
  final String entity;
  // TODO: constrain to enum values
  @override
  final String op;
  // TODO: constrain to enum values
  @override
  final String recordId;
  final Map<String, dynamic> _payload;
  @override
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  final String status;
  // TODO: constrain to enum values
  @override
  final int attempts;
  @override
  final String? lastError;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SyncOp(id: $id, accountId: $accountId, entity: $entity, op: $op, recordId: $recordId, payload: $payload, status: $status, attempts: $attempts, lastError: $lastError, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncOpImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.entity, entity) || other.entity == entity) &&
            (identical(other.op, op) || other.op == op) &&
            (identical(other.recordId, recordId) ||
                other.recordId == recordId) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.lastError, lastError) ||
                other.lastError == lastError) &&
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
    entity,
    op,
    recordId,
    const DeepCollectionEquality().hash(_payload),
    status,
    attempts,
    lastError,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SyncOp
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncOpImplCopyWith<_$SyncOpImpl> get copyWith =>
      __$$SyncOpImplCopyWithImpl<_$SyncOpImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncOpImplToJson(this);
  }
}

abstract class _SyncOp implements SyncOp {
  const factory _SyncOp({
    required final String id,
    required final String accountId,
    required final String entity,
    required final String op,
    required final String recordId,
    required final Map<String, dynamic> payload,
    required final String status,
    required final int attempts,
    final String? lastError,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SyncOpImpl;

  factory _SyncOp.fromJson(Map<String, dynamic> json) = _$SyncOpImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId; // TODO: FK to Account
  @override
  String get entity; // TODO: constrain to enum values
  @override
  String get op; // TODO: constrain to enum values
  @override
  String get recordId;
  @override
  Map<String, dynamic> get payload;
  @override
  String get status; // TODO: constrain to enum values
  @override
  int get attempts;
  @override
  String? get lastError;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SyncOp
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncOpImplCopyWith<_$SyncOpImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
