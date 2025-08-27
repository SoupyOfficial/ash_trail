// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_identity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthIdentity _$AuthIdentityFromJson(Map<String, dynamic> json) {
  return _AuthIdentity.fromJson(json);
}

/// @nodoc
mixin _$AuthIdentity {
  String get id => throw _privateConstructorUsedError;
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  String get provider =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String get providerUid => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AuthIdentity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthIdentity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthIdentityCopyWith<AuthIdentity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthIdentityCopyWith<$Res> {
  factory $AuthIdentityCopyWith(
          AuthIdentity value, $Res Function(AuthIdentity) then) =
      _$AuthIdentityCopyWithImpl<$Res, AuthIdentity>;
  @useResult
  $Res call(
      {String id,
      String accountId,
      String provider,
      String providerUid,
      String? email,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$AuthIdentityCopyWithImpl<$Res, $Val extends AuthIdentity>
    implements $AuthIdentityCopyWith<$Res> {
  _$AuthIdentityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthIdentity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? provider = null,
    Object? providerUid = null,
    Object? email = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      providerUid: null == providerUid
          ? _value.providerUid
          : providerUid // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthIdentityImplCopyWith<$Res>
    implements $AuthIdentityCopyWith<$Res> {
  factory _$$AuthIdentityImplCopyWith(
          _$AuthIdentityImpl value, $Res Function(_$AuthIdentityImpl) then) =
      __$$AuthIdentityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String accountId,
      String provider,
      String providerUid,
      String? email,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$AuthIdentityImplCopyWithImpl<$Res>
    extends _$AuthIdentityCopyWithImpl<$Res, _$AuthIdentityImpl>
    implements _$$AuthIdentityImplCopyWith<$Res> {
  __$$AuthIdentityImplCopyWithImpl(
      _$AuthIdentityImpl _value, $Res Function(_$AuthIdentityImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthIdentity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? provider = null,
    Object? providerUid = null,
    Object? email = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$AuthIdentityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      providerUid: null == providerUid
          ? _value.providerUid
          : providerUid // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthIdentityImpl implements _AuthIdentity {
  const _$AuthIdentityImpl(
      {required this.id,
      required this.accountId,
      required this.provider,
      required this.providerUid,
      this.email,
      required this.createdAt,
      required this.updatedAt});

  factory _$AuthIdentityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthIdentityImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
// TODO: FK to Account
  @override
  final String provider;
// TODO: constrain to enum values
  @override
  final String providerUid;
  @override
  final String? email;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'AuthIdentity(id: $id, accountId: $accountId, provider: $provider, providerUid: $providerUid, email: $email, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthIdentityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.providerUid, providerUid) ||
                other.providerUid == providerUid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, accountId, provider,
      providerUid, email, createdAt, updatedAt);

  /// Create a copy of AuthIdentity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthIdentityImplCopyWith<_$AuthIdentityImpl> get copyWith =>
      __$$AuthIdentityImplCopyWithImpl<_$AuthIdentityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthIdentityImplToJson(
      this,
    );
  }
}

abstract class _AuthIdentity implements AuthIdentity {
  const factory _AuthIdentity(
      {required final String id,
      required final String accountId,
      required final String provider,
      required final String providerUid,
      final String? email,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$AuthIdentityImpl;

  factory _AuthIdentity.fromJson(Map<String, dynamic> json) =
      _$AuthIdentityImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId; // TODO: FK to Account
  @override
  String get provider; // TODO: constrain to enum values
  @override
  String get providerUid;
  @override
  String? get email;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of AuthIdentity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthIdentityImplCopyWith<_$AuthIdentityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
