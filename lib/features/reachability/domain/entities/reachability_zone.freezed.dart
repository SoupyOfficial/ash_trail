// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reachability_zone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReachabilityZone {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Rect get bounds => throw _privateConstructorUsedError;
  ReachabilityLevel get level => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ReachabilityZoneCopyWith<ReachabilityZone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReachabilityZoneCopyWith<$Res> {
  factory $ReachabilityZoneCopyWith(
          ReachabilityZone value, $Res Function(ReachabilityZone) then) =
      _$ReachabilityZoneCopyWithImpl<$Res, ReachabilityZone>;
  @useResult
  $Res call(
      {String id,
      String name,
      Rect bounds,
      ReachabilityLevel level,
      String description});
}

/// @nodoc
class _$ReachabilityZoneCopyWithImpl<$Res, $Val extends ReachabilityZone>
    implements $ReachabilityZoneCopyWith<$Res> {
  _$ReachabilityZoneCopyWithImpl(this._value, this._then);

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
              as ReachabilityLevel,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReachabilityZoneImplCopyWith<$Res>
    implements $ReachabilityZoneCopyWith<$Res> {
  factory _$$ReachabilityZoneImplCopyWith(_$ReachabilityZoneImpl value,
          $Res Function(_$ReachabilityZoneImpl) then) =
      __$$ReachabilityZoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      Rect bounds,
      ReachabilityLevel level,
      String description});
}

/// @nodoc
class __$$ReachabilityZoneImplCopyWithImpl<$Res>
    extends _$ReachabilityZoneCopyWithImpl<$Res, _$ReachabilityZoneImpl>
    implements _$$ReachabilityZoneImplCopyWith<$Res> {
  __$$ReachabilityZoneImplCopyWithImpl(_$ReachabilityZoneImpl _value,
      $Res Function(_$ReachabilityZoneImpl) _then)
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
    return _then(_$ReachabilityZoneImpl(
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
              as ReachabilityLevel,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ReachabilityZoneImpl extends _ReachabilityZone {
  const _$ReachabilityZoneImpl(
      {required this.id,
      required this.name,
      required this.bounds,
      required this.level,
      required this.description})
      : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final Rect bounds;
  @override
  final ReachabilityLevel level;
  @override
  final String description;

  @override
  String toString() {
    return 'ReachabilityZone(id: $id, name: $name, bounds: $bounds, level: $level, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReachabilityZoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.bounds, bounds) || other.bounds == bounds) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, bounds, level, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReachabilityZoneImplCopyWith<_$ReachabilityZoneImpl> get copyWith =>
      __$$ReachabilityZoneImplCopyWithImpl<_$ReachabilityZoneImpl>(
          this, _$identity);
}

abstract class _ReachabilityZone extends ReachabilityZone {
  const factory _ReachabilityZone(
      {required final String id,
      required final String name,
      required final Rect bounds,
      required final ReachabilityLevel level,
      required final String description}) = _$ReachabilityZoneImpl;
  const _ReachabilityZone._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  Rect get bounds;
  @override
  ReachabilityLevel get level;
  @override
  String get description;
  @override
  @JsonKey(ignore: true)
  _$$ReachabilityZoneImplCopyWith<_$ReachabilityZoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
