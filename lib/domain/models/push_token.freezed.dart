// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PushToken _$PushTokenFromJson(Map<String, dynamic> json) {
  return _PushToken.fromJson(json);
}

/// @nodoc
mixin _$PushToken {
  String get id => throw _privateConstructorUsedError;
  String get deviceId =>
      throw _privateConstructorUsedError; // TODO: FK to Device
  String get platform =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String get token => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get revokedAt => throw _privateConstructorUsedError;

  /// Serializes this PushToken to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PushToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PushTokenCopyWith<PushToken> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PushTokenCopyWith<$Res> {
  factory $PushTokenCopyWith(PushToken value, $Res Function(PushToken) then) =
      _$PushTokenCopyWithImpl<$Res, PushToken>;
  @useResult
  $Res call(
      {String id,
      String deviceId,
      String platform,
      String token,
      bool active,
      DateTime createdAt,
      DateTime? revokedAt});
}

/// @nodoc
class _$PushTokenCopyWithImpl<$Res, $Val extends PushToken>
    implements $PushTokenCopyWith<$Res> {
  _$PushTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PushToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? platform = null,
    Object? token = null,
    Object? active = null,
    Object? createdAt = null,
    Object? revokedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      revokedAt: freezed == revokedAt
          ? _value.revokedAt
          : revokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PushTokenImplCopyWith<$Res>
    implements $PushTokenCopyWith<$Res> {
  factory _$$PushTokenImplCopyWith(
          _$PushTokenImpl value, $Res Function(_$PushTokenImpl) then) =
      __$$PushTokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deviceId,
      String platform,
      String token,
      bool active,
      DateTime createdAt,
      DateTime? revokedAt});
}

/// @nodoc
class __$$PushTokenImplCopyWithImpl<$Res>
    extends _$PushTokenCopyWithImpl<$Res, _$PushTokenImpl>
    implements _$$PushTokenImplCopyWith<$Res> {
  __$$PushTokenImplCopyWithImpl(
      _$PushTokenImpl _value, $Res Function(_$PushTokenImpl) _then)
      : super(_value, _then);

  /// Create a copy of PushToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceId = null,
    Object? platform = null,
    Object? token = null,
    Object? active = null,
    Object? createdAt = null,
    Object? revokedAt = freezed,
  }) {
    return _then(_$PushTokenImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      revokedAt: freezed == revokedAt
          ? _value.revokedAt
          : revokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PushTokenImpl implements _PushToken {
  const _$PushTokenImpl(
      {required this.id,
      required this.deviceId,
      required this.platform,
      required this.token,
      required this.active,
      required this.createdAt,
      this.revokedAt});

  factory _$PushTokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$PushTokenImplFromJson(json);

  @override
  final String id;
  @override
  final String deviceId;
// TODO: FK to Device
  @override
  final String platform;
// TODO: constrain to enum values
  @override
  final String token;
  @override
  final bool active;
  @override
  final DateTime createdAt;
  @override
  final DateTime? revokedAt;

  @override
  String toString() {
    return 'PushToken(id: $id, deviceId: $deviceId, platform: $platform, token: $token, active: $active, createdAt: $createdAt, revokedAt: $revokedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PushTokenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.revokedAt, revokedAt) ||
                other.revokedAt == revokedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, deviceId, platform, token, active, createdAt, revokedAt);

  /// Create a copy of PushToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PushTokenImplCopyWith<_$PushTokenImpl> get copyWith =>
      __$$PushTokenImplCopyWithImpl<_$PushTokenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PushTokenImplToJson(
      this,
    );
  }
}

abstract class _PushToken implements PushToken {
  const factory _PushToken(
      {required final String id,
      required final String deviceId,
      required final String platform,
      required final String token,
      required final bool active,
      required final DateTime createdAt,
      final DateTime? revokedAt}) = _$PushTokenImpl;

  factory _PushToken.fromJson(Map<String, dynamic> json) =
      _$PushTokenImpl.fromJson;

  @override
  String get id;
  @override
  String get deviceId; // TODO: FK to Device
  @override
  String get platform; // TODO: constrain to enum values
  @override
  String get token;
  @override
  bool get active;
  @override
  DateTime get createdAt;
  @override
  DateTime? get revokedAt;

  /// Create a copy of PushToken
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PushTokenImplCopyWith<_$PushTokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
