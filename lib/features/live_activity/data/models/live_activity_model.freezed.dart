// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_activity_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LiveActivityModel _$LiveActivityModelFromJson(Map<String, dynamic> json) {
  return _LiveActivityModel.fromJson(json);
}

/// @nodoc
mixin _$LiveActivityModel {
  String get id => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get cancelReason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LiveActivityModelCopyWith<LiveActivityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveActivityModelCopyWith<$Res> {
  factory $LiveActivityModelCopyWith(
          LiveActivityModel value, $Res Function(LiveActivityModel) then) =
      _$LiveActivityModelCopyWithImpl<$Res, LiveActivityModel>;
  @useResult
  $Res call(
      {String id,
      DateTime startedAt,
      DateTime? endedAt,
      String status,
      String? cancelReason});
}

/// @nodoc
class _$LiveActivityModelCopyWithImpl<$Res, $Val extends LiveActivityModel>
    implements $LiveActivityModelCopyWith<$Res> {
  _$LiveActivityModelCopyWithImpl(this._value, this._then);

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
              as String,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LiveActivityModelImplCopyWith<$Res>
    implements $LiveActivityModelCopyWith<$Res> {
  factory _$$LiveActivityModelImplCopyWith(_$LiveActivityModelImpl value,
          $Res Function(_$LiveActivityModelImpl) then) =
      __$$LiveActivityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime startedAt,
      DateTime? endedAt,
      String status,
      String? cancelReason});
}

/// @nodoc
class __$$LiveActivityModelImplCopyWithImpl<$Res>
    extends _$LiveActivityModelCopyWithImpl<$Res, _$LiveActivityModelImpl>
    implements _$$LiveActivityModelImplCopyWith<$Res> {
  __$$LiveActivityModelImplCopyWithImpl(_$LiveActivityModelImpl _value,
      $Res Function(_$LiveActivityModelImpl) _then)
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
    return _then(_$LiveActivityModelImpl(
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
              as String,
      cancelReason: freezed == cancelReason
          ? _value.cancelReason
          : cancelReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LiveActivityModelImpl extends _LiveActivityModel {
  const _$LiveActivityModelImpl(
      {required this.id,
      required this.startedAt,
      this.endedAt,
      required this.status,
      this.cancelReason})
      : super._();

  factory _$LiveActivityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiveActivityModelImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final String status;
  @override
  final String? cancelReason;

  @override
  String toString() {
    return 'LiveActivityModel(id: $id, startedAt: $startedAt, endedAt: $endedAt, status: $status, cancelReason: $cancelReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveActivityModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cancelReason, cancelReason) ||
                other.cancelReason == cancelReason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, startedAt, endedAt, status, cancelReason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveActivityModelImplCopyWith<_$LiveActivityModelImpl> get copyWith =>
      __$$LiveActivityModelImplCopyWithImpl<_$LiveActivityModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveActivityModelImplToJson(
      this,
    );
  }
}

abstract class _LiveActivityModel extends LiveActivityModel {
  const factory _LiveActivityModel(
      {required final String id,
      required final DateTime startedAt,
      final DateTime? endedAt,
      required final String status,
      final String? cancelReason}) = _$LiveActivityModelImpl;
  const _LiveActivityModel._() : super._();

  factory _LiveActivityModel.fromJson(Map<String, dynamic> json) =
      _$LiveActivityModelImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  String get status;
  @override
  String? get cancelReason;
  @override
  @JsonKey(ignore: true)
  _$$LiveActivityModelImplCopyWith<_$LiveActivityModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
