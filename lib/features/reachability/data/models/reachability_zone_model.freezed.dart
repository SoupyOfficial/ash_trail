// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reachability_zone_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReachabilityZoneModel _$ReachabilityZoneModelFromJson(
    Map<String, dynamic> json) {
  return _ReachabilityZoneModel.fromJson(json);
}

/// @nodoc
mixin _$ReachabilityZoneModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @_RectJsonConverter()
  Rect get bounds => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReachabilityZoneModelCopyWith<ReachabilityZoneModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReachabilityZoneModelCopyWith<$Res> {
  factory $ReachabilityZoneModelCopyWith(ReachabilityZoneModel value,
          $Res Function(ReachabilityZoneModel) then) =
      _$ReachabilityZoneModelCopyWithImpl<$Res, ReachabilityZoneModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      @_RectJsonConverter() Rect bounds,
      String level,
      String description});
}

/// @nodoc
class _$ReachabilityZoneModelCopyWithImpl<$Res,
        $Val extends ReachabilityZoneModel>
    implements $ReachabilityZoneModelCopyWith<$Res> {
  _$ReachabilityZoneModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? bounds = null,
    Object? level = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      bounds: null == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReachabilityZoneModelImplCopyWith<$Res>
    implements $ReachabilityZoneModelCopyWith<$Res> {
  factory _$$ReachabilityZoneModelImplCopyWith(
          _$ReachabilityZoneModelImpl value,
          $Res Function(_$ReachabilityZoneModelImpl) then) =
      __$$ReachabilityZoneModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @_RectJsonConverter() Rect bounds,
      String level,
      String description});
}

/// @nodoc
class __$$ReachabilityZoneModelImplCopyWithImpl<$Res>
    extends _$ReachabilityZoneModelCopyWithImpl<$Res,
        _$ReachabilityZoneModelImpl>
    implements _$$ReachabilityZoneModelImplCopyWith<$Res> {
  __$$ReachabilityZoneModelImplCopyWithImpl(_$ReachabilityZoneModelImpl _value,
      $Res Function(_$ReachabilityZoneModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? bounds = null,
    Object? level = null,
    Object? description = null,
  }) {
    return _then(_$ReachabilityZoneModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      bounds: null == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReachabilityZoneModelImpl extends _ReachabilityZoneModel {
  const _$ReachabilityZoneModelImpl(
      {required this.id,
      required this.name,
      @_RectJsonConverter() required this.bounds,
      required this.level,
      required this.description})
      : super._();

  factory _$ReachabilityZoneModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReachabilityZoneModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @_RectJsonConverter()
  final Rect bounds;
  @override
  final String level;
  @override
  final String description;

  @override
  String toString() {
    return 'ReachabilityZoneModel(id: $id, name: $name, bounds: $bounds, level: $level, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReachabilityZoneModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.bounds, bounds) || other.bounds == bounds) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, bounds, level, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReachabilityZoneModelImplCopyWith<_$ReachabilityZoneModelImpl>
      get copyWith => __$$ReachabilityZoneModelImplCopyWithImpl<
          _$ReachabilityZoneModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReachabilityZoneModelImplToJson(
      this,
    );
  }
}

abstract class _ReachabilityZoneModel extends ReachabilityZoneModel {
  const factory _ReachabilityZoneModel(
      {required final String id,
      required final String name,
      @_RectJsonConverter() required final Rect bounds,
      required final String level,
      required final String description}) = _$ReachabilityZoneModelImpl;
  const _ReachabilityZoneModel._() : super._();

  factory _ReachabilityZoneModel.fromJson(Map<String, dynamic> json) =
      _$ReachabilityZoneModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @_RectJsonConverter()
  Rect get bounds;
  @override
  String get level;
  @override
  String get description;
  @override
  @JsonKey(ignore: true)
  _$$ReachabilityZoneModelImplCopyWith<_$ReachabilityZoneModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
