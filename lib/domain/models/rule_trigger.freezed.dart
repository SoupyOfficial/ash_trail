// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rule_trigger.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RuleTrigger _$RuleTriggerFromJson(Map<String, dynamic> json) {
  return _RuleTrigger.fromJson(json);
}

/// @nodoc
mixin _$RuleTrigger {
  String get id => throw _privateConstructorUsedError;
  String get ruleId => throw _privateConstructorUsedError; // TODO: FK to Rule
  DateTime get triggeredAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get context => throw _privateConstructorUsedError;

  /// Serializes this RuleTrigger to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RuleTriggerCopyWith<RuleTrigger> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleTriggerCopyWith<$Res> {
  factory $RuleTriggerCopyWith(
          RuleTrigger value, $Res Function(RuleTrigger) then) =
      _$RuleTriggerCopyWithImpl<$Res, RuleTrigger>;
  @useResult
  $Res call(
      {String id,
      String ruleId,
      DateTime triggeredAt,
      Map<String, dynamic> context});
}

/// @nodoc
class _$RuleTriggerCopyWithImpl<$Res, $Val extends RuleTrigger>
    implements $RuleTriggerCopyWith<$Res> {
  _$RuleTriggerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ruleId = null,
    Object? triggeredAt = null,
    Object? context = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ruleId: null == ruleId
          ? _value.ruleId
          : ruleId // ignore: cast_nullable_to_non_nullable
              as String,
      triggeredAt: null == triggeredAt
          ? _value.triggeredAt
          : triggeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RuleTriggerImplCopyWith<$Res>
    implements $RuleTriggerCopyWith<$Res> {
  factory _$$RuleTriggerImplCopyWith(
          _$RuleTriggerImpl value, $Res Function(_$RuleTriggerImpl) then) =
      __$$RuleTriggerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String ruleId,
      DateTime triggeredAt,
      Map<String, dynamic> context});
}

/// @nodoc
class __$$RuleTriggerImplCopyWithImpl<$Res>
    extends _$RuleTriggerCopyWithImpl<$Res, _$RuleTriggerImpl>
    implements _$$RuleTriggerImplCopyWith<$Res> {
  __$$RuleTriggerImplCopyWithImpl(
      _$RuleTriggerImpl _value, $Res Function(_$RuleTriggerImpl) _then)
      : super(_value, _then);

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ruleId = null,
    Object? triggeredAt = null,
    Object? context = null,
  }) {
    return _then(_$RuleTriggerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ruleId: null == ruleId
          ? _value.ruleId
          : ruleId // ignore: cast_nullable_to_non_nullable
              as String,
      triggeredAt: null == triggeredAt
          ? _value.triggeredAt
          : triggeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      context: null == context
          ? _value._context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RuleTriggerImpl implements _RuleTrigger {
  const _$RuleTriggerImpl(
      {required this.id,
      required this.ruleId,
      required this.triggeredAt,
      required final Map<String, dynamic> context})
      : _context = context;

  factory _$RuleTriggerImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuleTriggerImplFromJson(json);

  @override
  final String id;
  @override
  final String ruleId;
// TODO: FK to Rule
  @override
  final DateTime triggeredAt;
  final Map<String, dynamic> _context;
  @override
  Map<String, dynamic> get context {
    if (_context is EqualUnmodifiableMapView) return _context;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_context);
  }

  @override
  String toString() {
    return 'RuleTrigger(id: $id, ruleId: $ruleId, triggeredAt: $triggeredAt, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleTriggerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ruleId, ruleId) || other.ruleId == ruleId) &&
            (identical(other.triggeredAt, triggeredAt) ||
                other.triggeredAt == triggeredAt) &&
            const DeepCollectionEquality().equals(other._context, _context));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, ruleId, triggeredAt,
      const DeepCollectionEquality().hash(_context));

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleTriggerImplCopyWith<_$RuleTriggerImpl> get copyWith =>
      __$$RuleTriggerImplCopyWithImpl<_$RuleTriggerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuleTriggerImplToJson(
      this,
    );
  }
}

abstract class _RuleTrigger implements RuleTrigger {
  const factory _RuleTrigger(
      {required final String id,
      required final String ruleId,
      required final DateTime triggeredAt,
      required final Map<String, dynamic> context}) = _$RuleTriggerImpl;

  factory _RuleTrigger.fromJson(Map<String, dynamic> json) =
      _$RuleTriggerImpl.fromJson;

  @override
  String get id;
  @override
  String get ruleId; // TODO: FK to Rule
  @override
  DateTime get triggeredAt;
  @override
  Map<String, dynamic> get context;

  /// Create a copy of RuleTrigger
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RuleTriggerImplCopyWith<_$RuleTriggerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
