// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reason.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Reason _$ReasonFromJson(Map<String, dynamic> json) {
  return _Reason.fromJson(json);
}

/// @nodoc
mixin _$Reason {
  String get id => throw _privateConstructorUsedError;
  String? get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  String get name => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;
  int get orderIndex => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReasonCopyWith<Reason> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReasonCopyWith<$Res> {
  factory $ReasonCopyWith(Reason value, $Res Function(Reason) then) =
      _$ReasonCopyWithImpl<$Res, Reason>;
  @useResult
  $Res call(
      {String id,
      String? accountId,
      String name,
      bool enabled,
      int orderIndex,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$ReasonCopyWithImpl<$Res, $Val extends Reason>
    implements $ReasonCopyWith<$Res> {
  _$ReasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = freezed,
    Object? name = null,
    Object? enabled = null,
    Object? orderIndex = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      orderIndex: null == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$ReasonImplCopyWith<$Res> implements $ReasonCopyWith<$Res> {
  factory _$$ReasonImplCopyWith(
          _$ReasonImpl value, $Res Function(_$ReasonImpl) then) =
      __$$ReasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? accountId,
      String name,
      bool enabled,
      int orderIndex,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$ReasonImplCopyWithImpl<$Res>
    extends _$ReasonCopyWithImpl<$Res, _$ReasonImpl>
    implements _$$ReasonImplCopyWith<$Res> {
  __$$ReasonImplCopyWithImpl(
      _$ReasonImpl _value, $Res Function(_$ReasonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = freezed,
    Object? name = null,
    Object? enabled = null,
    Object? orderIndex = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ReasonImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      orderIndex: null == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$ReasonImpl implements _Reason {
  const _$ReasonImpl(
      {required this.id,
      this.accountId,
      required this.name,
      required this.enabled,
      required this.orderIndex,
      required this.createdAt,
      required this.updatedAt});

  factory _$ReasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReasonImplFromJson(json);

  @override
  final String id;
  @override
  final String? accountId;
// TODO: FK to Account
  @override
  final String name;
  @override
  final bool enabled;
  @override
  final int orderIndex;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Reason(id: $id, accountId: $accountId, name: $name, enabled: $enabled, orderIndex: $orderIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReasonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, accountId, name, enabled,
      orderIndex, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReasonImplCopyWith<_$ReasonImpl> get copyWith =>
      __$$ReasonImplCopyWithImpl<_$ReasonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReasonImplToJson(
      this,
    );
  }
}

abstract class _Reason implements Reason {
  const factory _Reason(
      {required final String id,
      final String? accountId,
      required final String name,
      required final bool enabled,
      required final int orderIndex,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$ReasonImpl;

  factory _Reason.fromJson(Map<String, dynamic> json) = _$ReasonImpl.fromJson;

  @override
  String get id;
  @override
  String? get accountId;
  @override // TODO: FK to Account
  String get name;
  @override
  bool get enabled;
  @override
  int get orderIndex;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$ReasonImplCopyWith<_$ReasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
