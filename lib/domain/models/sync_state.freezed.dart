// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SyncState _$SyncStateFromJson(Map<String, dynamic> json) {
  return _SyncState.fromJson(json);
}

/// @nodoc
mixin _$SyncState {
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  DateTime? get lastPulledAt => throw _privateConstructorUsedError;
  DateTime? get lastPushedAt => throw _privateConstructorUsedError;
  String? get remoteVersion => throw _privateConstructorUsedError;
  String? get tombstoneWatermark => throw _privateConstructorUsedError;
  DateTime? get backoffUntil => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SyncStateCopyWith<SyncState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncStateCopyWith<$Res> {
  factory $SyncStateCopyWith(SyncState value, $Res Function(SyncState) then) =
      _$SyncStateCopyWithImpl<$Res, SyncState>;
  @useResult
  $Res call(
      {String accountId,
      DateTime? lastPulledAt,
      DateTime? lastPushedAt,
      String? remoteVersion,
      String? tombstoneWatermark,
      DateTime? backoffUntil});
}

/// @nodoc
class _$SyncStateCopyWithImpl<$Res, $Val extends SyncState>
    implements $SyncStateCopyWith<$Res> {
  _$SyncStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? lastPulledAt = freezed,
    Object? lastPushedAt = freezed,
    Object? remoteVersion = freezed,
    Object? tombstoneWatermark = freezed,
    Object? backoffUntil = freezed,
  }) {
    return _then(_value.copyWith(
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      lastPulledAt: freezed == lastPulledAt
          ? _value.lastPulledAt
          : lastPulledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPushedAt: freezed == lastPushedAt
          ? _value.lastPushedAt
          : lastPushedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      remoteVersion: freezed == remoteVersion
          ? _value.remoteVersion
          : remoteVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      tombstoneWatermark: freezed == tombstoneWatermark
          ? _value.tombstoneWatermark
          : tombstoneWatermark // ignore: cast_nullable_to_non_nullable
              as String?,
      backoffUntil: freezed == backoffUntil
          ? _value.backoffUntil
          : backoffUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncStateImplCopyWith<$Res>
    implements $SyncStateCopyWith<$Res> {
  factory _$$SyncStateImplCopyWith(
          _$SyncStateImpl value, $Res Function(_$SyncStateImpl) then) =
      __$$SyncStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String accountId,
      DateTime? lastPulledAt,
      DateTime? lastPushedAt,
      String? remoteVersion,
      String? tombstoneWatermark,
      DateTime? backoffUntil});
}

/// @nodoc
class __$$SyncStateImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$SyncStateImpl>
    implements _$$SyncStateImplCopyWith<$Res> {
  __$$SyncStateImplCopyWithImpl(
      _$SyncStateImpl _value, $Res Function(_$SyncStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? lastPulledAt = freezed,
    Object? lastPushedAt = freezed,
    Object? remoteVersion = freezed,
    Object? tombstoneWatermark = freezed,
    Object? backoffUntil = freezed,
  }) {
    return _then(_$SyncStateImpl(
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      lastPulledAt: freezed == lastPulledAt
          ? _value.lastPulledAt
          : lastPulledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPushedAt: freezed == lastPushedAt
          ? _value.lastPushedAt
          : lastPushedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      remoteVersion: freezed == remoteVersion
          ? _value.remoteVersion
          : remoteVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      tombstoneWatermark: freezed == tombstoneWatermark
          ? _value.tombstoneWatermark
          : tombstoneWatermark // ignore: cast_nullable_to_non_nullable
              as String?,
      backoffUntil: freezed == backoffUntil
          ? _value.backoffUntil
          : backoffUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncStateImpl implements _SyncState {
  const _$SyncStateImpl(
      {required this.accountId,
      this.lastPulledAt,
      this.lastPushedAt,
      this.remoteVersion,
      this.tombstoneWatermark,
      this.backoffUntil});

  factory _$SyncStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncStateImplFromJson(json);

  @override
  final String accountId;
// TODO: FK to Account
  @override
  final DateTime? lastPulledAt;
  @override
  final DateTime? lastPushedAt;
  @override
  final String? remoteVersion;
  @override
  final String? tombstoneWatermark;
  @override
  final DateTime? backoffUntil;

  @override
  String toString() {
    return 'SyncState(accountId: $accountId, lastPulledAt: $lastPulledAt, lastPushedAt: $lastPushedAt, remoteVersion: $remoteVersion, tombstoneWatermark: $tombstoneWatermark, backoffUntil: $backoffUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncStateImpl &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.lastPulledAt, lastPulledAt) ||
                other.lastPulledAt == lastPulledAt) &&
            (identical(other.lastPushedAt, lastPushedAt) ||
                other.lastPushedAt == lastPushedAt) &&
            (identical(other.remoteVersion, remoteVersion) ||
                other.remoteVersion == remoteVersion) &&
            (identical(other.tombstoneWatermark, tombstoneWatermark) ||
                other.tombstoneWatermark == tombstoneWatermark) &&
            (identical(other.backoffUntil, backoffUntil) ||
                other.backoffUntil == backoffUntil));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, accountId, lastPulledAt,
      lastPushedAt, remoteVersion, tombstoneWatermark, backoffUntil);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncStateImplCopyWith<_$SyncStateImpl> get copyWith =>
      __$$SyncStateImplCopyWithImpl<_$SyncStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncStateImplToJson(
      this,
    );
  }
}

abstract class _SyncState implements SyncState {
  const factory _SyncState(
      {required final String accountId,
      final DateTime? lastPulledAt,
      final DateTime? lastPushedAt,
      final String? remoteVersion,
      final String? tombstoneWatermark,
      final DateTime? backoffUntil}) = _$SyncStateImpl;

  factory _SyncState.fromJson(Map<String, dynamic> json) =
      _$SyncStateImpl.fromJson;

  @override
  String get accountId;
  @override // TODO: FK to Account
  DateTime? get lastPulledAt;
  @override
  DateTime? get lastPushedAt;
  @override
  String? get remoteVersion;
  @override
  String? get tombstoneWatermark;
  @override
  DateTime? get backoffUntil;
  @override
  @JsonKey(ignore: true)
  _$$SyncStateImplCopyWith<_$SyncStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
