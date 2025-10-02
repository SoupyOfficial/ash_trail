// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_activity_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LiveActivityEntity {
  String get id => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  LiveActivityStatus get status => throw _privateConstructorUsedError;
  String? get cancelReason => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LiveActivityEntityCopyWith<LiveActivityEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveActivityEntityCopyWith<$Res> {
  factory $LiveActivityEntityCopyWith(
          LiveActivityEntity value, $Res Function(LiveActivityEntity) then) =
      _$LiveActivityEntityCopyWithImpl<$Res, LiveActivityEntity>;
  @useResult
  $Res call(
      {String id,
      DateTime startedAt,
      DateTime? endedAt,
      LiveActivityStatus status,
      String? cancelReason});
}

/// @nodoc
class _$LiveActivityEntityCopyWithImpl<$Res, $Val extends LiveActivityEntity>
    implements $LiveActivityEntityCopyWith<$Res> {
  _$LiveActivityEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? status = null,
    Object? cancelReason = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as LiveActivityStatus,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LiveActivityEntityImplCopyWith<$Res>
    implements $LiveActivityEntityCopyWith<$Res> {
  factory _$$LiveActivityEntityImplCopyWith(_$LiveActivityEntityImpl value,
          $Res Function(_$LiveActivityEntityImpl) then) =
      __$$LiveActivityEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime startedAt,
      DateTime? endedAt,
      LiveActivityStatus status,
      String? cancelReason});
}

/// @nodoc
class __$$LiveActivityEntityImplCopyWithImpl<$Res>
    extends _$LiveActivityEntityCopyWithImpl<$Res, _$LiveActivityEntityImpl>
    implements _$$LiveActivityEntityImplCopyWith<$Res> {
  __$$LiveActivityEntityImplCopyWithImpl(_$LiveActivityEntityImpl _value,
      $Res Function(_$LiveActivityEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? status = null,
    Object? cancelReason = freezed,
  }) {
    return _then(_$LiveActivityEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as LiveActivityStatus,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LiveActivityEntityImpl extends _LiveActivityEntity {
  const _$LiveActivityEntityImpl(
      {required this.id,
      required this.startedAt,
      this.endedAt,
      required this.status,
      this.cancelReason})
      : super._();

  @override
  final String id;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final LiveActivityStatus status;
  @override
  final String? cancelReason;

  @override
  String toString() {
    return 'LiveActivityEntity(id: $id, startedAt: $startedAt, endedAt: $endedAt, status: $status, cancelReason: $cancelReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveActivityEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cancelReason, cancelReason) ||
                other.cancelReason == cancelReason));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, startedAt, endedAt, status, cancelReason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveActivityEntityImplCopyWith<_$LiveActivityEntityImpl> get copyWith =>
      __$$LiveActivityEntityImplCopyWithImpl<_$LiveActivityEntityImpl>(
          this, _$identity);
}

abstract class _LiveActivityEntity extends LiveActivityEntity {
  const factory _LiveActivityEntity(
      {required final String id,
      required final DateTime startedAt,
      final DateTime? endedAt,
      required final LiveActivityStatus status,
      final String? cancelReason}) = _$LiveActivityEntityImpl;
  const _LiveActivityEntity._() : super._();

  @override
  String get id;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  LiveActivityStatus get status;
  @override
  String? get cancelReason;
  @override
  @JsonKey(ignore: true)
  _$$LiveActivityEntityImplCopyWith<_$LiveActivityEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
