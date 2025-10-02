// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_progress_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GoalProgressView {
  Goal get goal => throw _privateConstructorUsedError;
  double get progressPercentage => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  String get displayText => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GoalProgressViewCopyWith<GoalProgressView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalProgressViewCopyWith<$Res> {
  factory $GoalProgressViewCopyWith(
          GoalProgressView value, $Res Function(GoalProgressView) then) =
      _$GoalProgressViewCopyWithImpl<$Res, GoalProgressView>;
  @useResult
  $Res call(
      {Goal goal,
      double progressPercentage,
      bool isCompleted,
      String displayText});

  $GoalCopyWith<$Res> get goal;
}

/// @nodoc
class _$GoalProgressViewCopyWithImpl<$Res, $Val extends GoalProgressView>
    implements $GoalProgressViewCopyWith<$Res> {
  _$GoalProgressViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = null,
    Object? progressPercentage = null,
    Object? isCompleted = null,
    Object? displayText = null,
  }) {
    return _then(_value.copyWith(
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as Goal,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      displayText: null == displayText
          ? _value.displayText
          : displayText // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GoalCopyWith<$Res> get goal {
    return $GoalCopyWith<$Res>(_value.goal, (value) {
      return _then(_value.copyWith(goal: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GoalProgressViewImplCopyWith<$Res>
    implements $GoalProgressViewCopyWith<$Res> {
  factory _$$GoalProgressViewImplCopyWith(_$GoalProgressViewImpl value,
          $Res Function(_$GoalProgressViewImpl) then) =
      __$$GoalProgressViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Goal goal,
      double progressPercentage,
      bool isCompleted,
      String displayText});

  @override
  $GoalCopyWith<$Res> get goal;
}

/// @nodoc
class __$$GoalProgressViewImplCopyWithImpl<$Res>
    extends _$GoalProgressViewCopyWithImpl<$Res, _$GoalProgressViewImpl>
    implements _$$GoalProgressViewImplCopyWith<$Res> {
  __$$GoalProgressViewImplCopyWithImpl(_$GoalProgressViewImpl _value,
      $Res Function(_$GoalProgressViewImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goal = null,
    Object? progressPercentage = null,
    Object? isCompleted = null,
    Object? displayText = null,
  }) {
    return _then(_$GoalProgressViewImpl(
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as Goal,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      displayText: null == displayText
          ? _value.displayText
          : displayText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GoalProgressViewImpl extends _GoalProgressView {
  const _$GoalProgressViewImpl(
      {required this.goal,
      required this.progressPercentage,
      required this.isCompleted,
      required this.displayText})
      : super._();

  @override
  final Goal goal;
  @override
  final double progressPercentage;
  @override
  final bool isCompleted;
  @override
  final String displayText;

  @override
  String toString() {
    return 'GoalProgressView(goal: $goal, progressPercentage: $progressPercentage, isCompleted: $isCompleted, displayText: $displayText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalProgressViewImpl &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.displayText, displayText) ||
                other.displayText == displayText));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, goal, progressPercentage, isCompleted, displayText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalProgressViewImplCopyWith<_$GoalProgressViewImpl> get copyWith =>
      __$$GoalProgressViewImplCopyWithImpl<_$GoalProgressViewImpl>(
          this, _$identity);
}

abstract class _GoalProgressView extends GoalProgressView {
  const factory _GoalProgressView(
      {required final Goal goal,
      required final double progressPercentage,
      required final bool isCompleted,
      required final String displayText}) = _$GoalProgressViewImpl;
  const _GoalProgressView._() : super._();

  @override
  Goal get goal;
  @override
  double get progressPercentage;
  @override
  bool get isCompleted;
  @override
  String get displayText;
  @override
  @JsonKey(ignore: true)
  _$$GoalProgressViewImplCopyWith<_$GoalProgressViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
