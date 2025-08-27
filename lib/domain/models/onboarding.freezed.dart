// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Onboarding _$OnboardingFromJson(Map<String, dynamic> json) {
  return _Onboarding.fromJson(json);
}

/// @nodoc
mixin _$Onboarding {
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  List<String> get stepsCompleted =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Onboarding to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Onboarding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingCopyWith<Onboarding> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingCopyWith<$Res> {
  factory $OnboardingCopyWith(
    Onboarding value,
    $Res Function(Onboarding) then,
  ) = _$OnboardingCopyWithImpl<$Res, Onboarding>;
  @useResult
  $Res call({
    String accountId,
    List<String> stepsCompleted,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$OnboardingCopyWithImpl<$Res, $Val extends Onboarding>
    implements $OnboardingCopyWith<$Res> {
  _$OnboardingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Onboarding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? stepsCompleted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            accountId:
                null == accountId
                    ? _value.accountId
                    : accountId // ignore: cast_nullable_to_non_nullable
                        as String,
            stepsCompleted:
                null == stepsCompleted
                    ? _value.stepsCompleted
                    : stepsCompleted // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnboardingImplCopyWith<$Res>
    implements $OnboardingCopyWith<$Res> {
  factory _$$OnboardingImplCopyWith(
    _$OnboardingImpl value,
    $Res Function(_$OnboardingImpl) then,
  ) = __$$OnboardingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String accountId,
    List<String> stepsCompleted,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$OnboardingImplCopyWithImpl<$Res>
    extends _$OnboardingCopyWithImpl<$Res, _$OnboardingImpl>
    implements _$$OnboardingImplCopyWith<$Res> {
  __$$OnboardingImplCopyWithImpl(
    _$OnboardingImpl _value,
    $Res Function(_$OnboardingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Onboarding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? stepsCompleted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$OnboardingImpl(
        accountId:
            null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                    as String,
        stepsCompleted:
            null == stepsCompleted
                ? _value._stepsCompleted
                : stepsCompleted // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$OnboardingImpl implements _Onboarding {
  const _$OnboardingImpl({
    required this.accountId,
    required final List<String> stepsCompleted,
    required this.createdAt,
    required this.updatedAt,
  }) : _stepsCompleted = stepsCompleted;

  factory _$OnboardingImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnboardingImplFromJson(json);

  @override
  final String accountId;
  // TODO: FK to Account
  final List<String> _stepsCompleted;
  // TODO: FK to Account
  @override
  List<String> get stepsCompleted {
    if (_stepsCompleted is EqualUnmodifiableListView) return _stepsCompleted;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stepsCompleted);
  }

  // TODO: constrain to enum values
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Onboarding(accountId: $accountId, stepsCompleted: $stepsCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingImpl &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            const DeepCollectionEquality().equals(
              other._stepsCompleted,
              _stepsCompleted,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    accountId,
    const DeepCollectionEquality().hash(_stepsCompleted),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Onboarding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingImplCopyWith<_$OnboardingImpl> get copyWith =>
      __$$OnboardingImplCopyWithImpl<_$OnboardingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OnboardingImplToJson(this);
  }
}

abstract class _Onboarding implements Onboarding {
  const factory _Onboarding({
    required final String accountId,
    required final List<String> stepsCompleted,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$OnboardingImpl;

  factory _Onboarding.fromJson(Map<String, dynamic> json) =
      _$OnboardingImpl.fromJson;

  @override
  String get accountId; // TODO: FK to Account
  @override
  List<String> get stepsCompleted; // TODO: constrain to enum values
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Onboarding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingImplCopyWith<_$OnboardingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
