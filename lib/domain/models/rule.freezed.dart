// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Rule _$RuleFromJson(Map<String, dynamic> json) {
  return _Rule.fromJson(json);
}

/// @nodoc
mixin _$Rule {
  String get id => throw _privateConstructorUsedError;
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  String get name => throw _privateConstructorUsedError;
  Map<String, dynamic> get condition => throw _privateConstructorUsedError;
  String get action =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  bool get enabled => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RuleCopyWith<Rule> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RuleCopyWith<$Res> {
  factory $RuleCopyWith(Rule value, $Res Function(Rule) then) =
      _$RuleCopyWithImpl<$Res, Rule>;
  @useResult
  $Res call(
      {String id,
      String accountId,
      String name,
      Map<String, dynamic> condition,
      String action,
      bool enabled,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$RuleCopyWithImpl<$Res, $Val extends Rule>
    implements $RuleCopyWith<$Res> {
  _$RuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? name = null,
    Object? condition = null,
    Object? action = null,
    Object? enabled = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$RuleImplCopyWith<$Res> implements $RuleCopyWith<$Res> {
  factory _$$RuleImplCopyWith(
          _$RuleImpl value, $Res Function(_$RuleImpl) then) =
      __$$RuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String accountId,
      String name,
      Map<String, dynamic> condition,
      String action,
      bool enabled,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$RuleImplCopyWithImpl<$Res>
    extends _$RuleCopyWithImpl<$Res, _$RuleImpl>
    implements _$$RuleImplCopyWith<$Res> {
  __$$RuleImplCopyWithImpl(_$RuleImpl _value, $Res Function(_$RuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? name = null,
    Object? condition = null,
    Object? action = null,
    Object? enabled = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$RuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value._condition
          : condition // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$RuleImpl implements _Rule {
  const _$RuleImpl(
      {required this.id,
      required this.accountId,
      required this.name,
      required final Map<String, dynamic> condition,
      required this.action,
      required this.enabled,
      required this.createdAt,
      required this.updatedAt})
      : _condition = condition;

  factory _$RuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RuleImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
// TODO: FK to Account
  @override
  final String name;
  final Map<String, dynamic> _condition;
  @override
  Map<String, dynamic> get condition {
    if (_condition is EqualUnmodifiableMapView) return _condition;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_condition);
  }

  @override
  final String action;
// TODO: constrain to enum values
  @override
  final bool enabled;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Rule(id: $id, accountId: $accountId, name: $name, condition: $condition, action: $action, enabled: $enabled, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._condition, _condition) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      accountId,
      name,
      const DeepCollectionEquality().hash(_condition),
      action,
      enabled,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RuleImplCopyWith<_$RuleImpl> get copyWith =>
      __$$RuleImplCopyWithImpl<_$RuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RuleImplToJson(
      this,
    );
  }
}

abstract class _Rule implements Rule {
  const factory _Rule(
      {required final String id,
      required final String accountId,
      required final String name,
      required final Map<String, dynamic> condition,
      required final String action,
      required final bool enabled,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$RuleImpl;

  factory _Rule.fromJson(Map<String, dynamic> json) = _$RuleImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId;
  @override // TODO: FK to Account
  String get name;
  @override
  Map<String, dynamic> get condition;
  @override
  String get action;
  @override // TODO: constrain to enum values
  bool get enabled;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RuleImplCopyWith<_$RuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
