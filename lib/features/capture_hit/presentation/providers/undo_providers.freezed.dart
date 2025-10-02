// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'undo_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UndoState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(SmokeLog undoableLog, int remainingSeconds)
        pendingUndo,
    required TResult Function(SmokeLog targetLog) undoing,
    required TResult Function(SmokeLog undoneLog) undoCompleted,
    required TResult Function(String message) undoFailed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult? Function(SmokeLog targetLog)? undoing,
    TResult? Function(SmokeLog undoneLog)? undoCompleted,
    TResult? Function(String message)? undoFailed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult Function(SmokeLog targetLog)? undoing,
    TResult Function(SmokeLog undoneLog)? undoCompleted,
    TResult Function(String message)? undoFailed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UndoIdleState value) idle,
    required TResult Function(UndoPendingState value) pendingUndo,
    required TResult Function(UndoInProgressState value) undoing,
    required TResult Function(UndoCompletedState value) undoCompleted,
    required TResult Function(UndoFailedState value) undoFailed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UndoIdleState value)? idle,
    TResult? Function(UndoPendingState value)? pendingUndo,
    TResult? Function(UndoInProgressState value)? undoing,
    TResult? Function(UndoCompletedState value)? undoCompleted,
    TResult? Function(UndoFailedState value)? undoFailed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UndoIdleState value)? idle,
    TResult Function(UndoPendingState value)? pendingUndo,
    TResult Function(UndoInProgressState value)? undoing,
    TResult Function(UndoCompletedState value)? undoCompleted,
    TResult Function(UndoFailedState value)? undoFailed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UndoStateCopyWith<$Res> {
  factory $UndoStateCopyWith(UndoState value, $Res Function(UndoState) then) =
      _$UndoStateCopyWithImpl<$Res, UndoState>;
}

/// @nodoc
class _$UndoStateCopyWithImpl<$Res, $Val extends UndoState>
    implements $UndoStateCopyWith<$Res> {
  _$UndoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$UndoIdleStateImplCopyWith<$Res> {
  factory _$$UndoIdleStateImplCopyWith(
          _$UndoIdleStateImpl value, $Res Function(_$UndoIdleStateImpl) then) =
      __$$UndoIdleStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UndoIdleStateImplCopyWithImpl<$Res>
    extends _$UndoStateCopyWithImpl<$Res, _$UndoIdleStateImpl>
    implements _$$UndoIdleStateImplCopyWith<$Res> {
  __$$UndoIdleStateImplCopyWithImpl(
      _$UndoIdleStateImpl _value, $Res Function(_$UndoIdleStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$UndoIdleStateImpl implements UndoIdleState {
  const _$UndoIdleStateImpl();

  @override
  String toString() {
    return 'UndoState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UndoIdleStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(SmokeLog undoableLog, int remainingSeconds)
        pendingUndo,
    required TResult Function(SmokeLog targetLog) undoing,
    required TResult Function(SmokeLog undoneLog) undoCompleted,
    required TResult Function(String message) undoFailed,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult? Function(SmokeLog targetLog)? undoing,
    TResult? Function(SmokeLog undoneLog)? undoCompleted,
    TResult? Function(String message)? undoFailed,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult Function(SmokeLog targetLog)? undoing,
    TResult Function(SmokeLog undoneLog)? undoCompleted,
    TResult Function(String message)? undoFailed,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UndoIdleState value) idle,
    required TResult Function(UndoPendingState value) pendingUndo,
    required TResult Function(UndoInProgressState value) undoing,
    required TResult Function(UndoCompletedState value) undoCompleted,
    required TResult Function(UndoFailedState value) undoFailed,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UndoIdleState value)? idle,
    TResult? Function(UndoPendingState value)? pendingUndo,
    TResult? Function(UndoInProgressState value)? undoing,
    TResult? Function(UndoCompletedState value)? undoCompleted,
    TResult? Function(UndoFailedState value)? undoFailed,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UndoIdleState value)? idle,
    TResult Function(UndoPendingState value)? pendingUndo,
    TResult Function(UndoInProgressState value)? undoing,
    TResult Function(UndoCompletedState value)? undoCompleted,
    TResult Function(UndoFailedState value)? undoFailed,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class UndoIdleState implements UndoState {
  const factory UndoIdleState() = _$UndoIdleStateImpl;
}

/// @nodoc
abstract class _$$UndoPendingStateImplCopyWith<$Res> {
  factory _$$UndoPendingStateImplCopyWith(_$UndoPendingStateImpl value,
          $Res Function(_$UndoPendingStateImpl) then) =
      __$$UndoPendingStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SmokeLog undoableLog, int remainingSeconds});

  $SmokeLogCopyWith<$Res> get undoableLog;
}

/// @nodoc
class __$$UndoPendingStateImplCopyWithImpl<$Res>
    extends _$UndoStateCopyWithImpl<$Res, _$UndoPendingStateImpl>
    implements _$$UndoPendingStateImplCopyWith<$Res> {
  __$$UndoPendingStateImplCopyWithImpl(_$UndoPendingStateImpl _value,
      $Res Function(_$UndoPendingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? undoableLog = null,
    Object? remainingSeconds = null,
  }) {
    return _then(_$UndoPendingStateImpl(
      undoableLog: null == undoableLog
          ? _value.undoableLog
          : undoableLog // ignore: cast_nullable_to_non_nullable
              as SmokeLog,
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $SmokeLogCopyWith<$Res> get undoableLog {
    return $SmokeLogCopyWith<$Res>(_value.undoableLog, (value) {
      return _then(_value.copyWith(undoableLog: value));
    });
  }
}

/// @nodoc

class _$UndoPendingStateImpl implements UndoPendingState {
  const _$UndoPendingStateImpl(
      {required this.undoableLog, required this.remainingSeconds});

  @override
  final SmokeLog undoableLog;
  @override
  final int remainingSeconds;

  @override
  String toString() {
    return 'UndoState.pendingUndo(undoableLog: $undoableLog, remainingSeconds: $remainingSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UndoPendingStateImpl &&
            (identical(other.undoableLog, undoableLog) ||
                other.undoableLog == undoableLog) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, undoableLog, remainingSeconds);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UndoPendingStateImplCopyWith<_$UndoPendingStateImpl> get copyWith =>
      __$$UndoPendingStateImplCopyWithImpl<_$UndoPendingStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(SmokeLog undoableLog, int remainingSeconds)
        pendingUndo,
    required TResult Function(SmokeLog targetLog) undoing,
    required TResult Function(SmokeLog undoneLog) undoCompleted,
    required TResult Function(String message) undoFailed,
  }) {
    return pendingUndo(undoableLog, remainingSeconds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult? Function(SmokeLog targetLog)? undoing,
    TResult? Function(SmokeLog undoneLog)? undoCompleted,
    TResult? Function(String message)? undoFailed,
  }) {
    return pendingUndo?.call(undoableLog, remainingSeconds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult Function(SmokeLog targetLog)? undoing,
    TResult Function(SmokeLog undoneLog)? undoCompleted,
    TResult Function(String message)? undoFailed,
    required TResult orElse(),
  }) {
    if (pendingUndo != null) {
      return pendingUndo(undoableLog, remainingSeconds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UndoIdleState value) idle,
    required TResult Function(UndoPendingState value) pendingUndo,
    required TResult Function(UndoInProgressState value) undoing,
    required TResult Function(UndoCompletedState value) undoCompleted,
    required TResult Function(UndoFailedState value) undoFailed,
  }) {
    return pendingUndo(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UndoIdleState value)? idle,
    TResult? Function(UndoPendingState value)? pendingUndo,
    TResult? Function(UndoInProgressState value)? undoing,
    TResult? Function(UndoCompletedState value)? undoCompleted,
    TResult? Function(UndoFailedState value)? undoFailed,
  }) {
    return pendingUndo?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UndoIdleState value)? idle,
    TResult Function(UndoPendingState value)? pendingUndo,
    TResult Function(UndoInProgressState value)? undoing,
    TResult Function(UndoCompletedState value)? undoCompleted,
    TResult Function(UndoFailedState value)? undoFailed,
    required TResult orElse(),
  }) {
    if (pendingUndo != null) {
      return pendingUndo(this);
    }
    return orElse();
  }
}

abstract class UndoPendingState implements UndoState {
  const factory UndoPendingState(
      {required final SmokeLog undoableLog,
      required final int remainingSeconds}) = _$UndoPendingStateImpl;

  SmokeLog get undoableLog;
  int get remainingSeconds;
  @JsonKey(ignore: true)
  _$$UndoPendingStateImplCopyWith<_$UndoPendingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UndoInProgressStateImplCopyWith<$Res> {
  factory _$$UndoInProgressStateImplCopyWith(_$UndoInProgressStateImpl value,
          $Res Function(_$UndoInProgressStateImpl) then) =
      __$$UndoInProgressStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SmokeLog targetLog});

  $SmokeLogCopyWith<$Res> get targetLog;
}

/// @nodoc
class __$$UndoInProgressStateImplCopyWithImpl<$Res>
    extends _$UndoStateCopyWithImpl<$Res, _$UndoInProgressStateImpl>
    implements _$$UndoInProgressStateImplCopyWith<$Res> {
  __$$UndoInProgressStateImplCopyWithImpl(_$UndoInProgressStateImpl _value,
      $Res Function(_$UndoInProgressStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetLog = null,
  }) {
    return _then(_$UndoInProgressStateImpl(
      targetLog: null == targetLog
          ? _value.targetLog
          : targetLog // ignore: cast_nullable_to_non_nullable
              as SmokeLog,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $SmokeLogCopyWith<$Res> get targetLog {
    return $SmokeLogCopyWith<$Res>(_value.targetLog, (value) {
      return _then(_value.copyWith(targetLog: value));
    });
  }
}

/// @nodoc

class _$UndoInProgressStateImpl implements UndoInProgressState {
  const _$UndoInProgressStateImpl({required this.targetLog});

  @override
  final SmokeLog targetLog;

  @override
  String toString() {
    return 'UndoState.undoing(targetLog: $targetLog)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UndoInProgressStateImpl &&
            (identical(other.targetLog, targetLog) ||
                other.targetLog == targetLog));
  }

  @override
  int get hashCode => Object.hash(runtimeType, targetLog);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UndoInProgressStateImplCopyWith<_$UndoInProgressStateImpl> get copyWith =>
      __$$UndoInProgressStateImplCopyWithImpl<_$UndoInProgressStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(SmokeLog undoableLog, int remainingSeconds)
        pendingUndo,
    required TResult Function(SmokeLog targetLog) undoing,
    required TResult Function(SmokeLog undoneLog) undoCompleted,
    required TResult Function(String message) undoFailed,
  }) {
    return undoing(targetLog);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult? Function(SmokeLog targetLog)? undoing,
    TResult? Function(SmokeLog undoneLog)? undoCompleted,
    TResult? Function(String message)? undoFailed,
  }) {
    return undoing?.call(targetLog);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult Function(SmokeLog targetLog)? undoing,
    TResult Function(SmokeLog undoneLog)? undoCompleted,
    TResult Function(String message)? undoFailed,
    required TResult orElse(),
  }) {
    if (undoing != null) {
      return undoing(targetLog);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UndoIdleState value) idle,
    required TResult Function(UndoPendingState value) pendingUndo,
    required TResult Function(UndoInProgressState value) undoing,
    required TResult Function(UndoCompletedState value) undoCompleted,
    required TResult Function(UndoFailedState value) undoFailed,
  }) {
    return undoing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UndoIdleState value)? idle,
    TResult? Function(UndoPendingState value)? pendingUndo,
    TResult? Function(UndoInProgressState value)? undoing,
    TResult? Function(UndoCompletedState value)? undoCompleted,
    TResult? Function(UndoFailedState value)? undoFailed,
  }) {
    return undoing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UndoIdleState value)? idle,
    TResult Function(UndoPendingState value)? pendingUndo,
    TResult Function(UndoInProgressState value)? undoing,
    TResult Function(UndoCompletedState value)? undoCompleted,
    TResult Function(UndoFailedState value)? undoFailed,
    required TResult orElse(),
  }) {
    if (undoing != null) {
      return undoing(this);
    }
    return orElse();
  }
}

abstract class UndoInProgressState implements UndoState {
  const factory UndoInProgressState({required final SmokeLog targetLog}) =
      _$UndoInProgressStateImpl;

  SmokeLog get targetLog;
  @JsonKey(ignore: true)
  _$$UndoInProgressStateImplCopyWith<_$UndoInProgressStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UndoCompletedStateImplCopyWith<$Res> {
  factory _$$UndoCompletedStateImplCopyWith(_$UndoCompletedStateImpl value,
          $Res Function(_$UndoCompletedStateImpl) then) =
      __$$UndoCompletedStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SmokeLog undoneLog});

  $SmokeLogCopyWith<$Res> get undoneLog;
}

/// @nodoc
class __$$UndoCompletedStateImplCopyWithImpl<$Res>
    extends _$UndoStateCopyWithImpl<$Res, _$UndoCompletedStateImpl>
    implements _$$UndoCompletedStateImplCopyWith<$Res> {
  __$$UndoCompletedStateImplCopyWithImpl(_$UndoCompletedStateImpl _value,
      $Res Function(_$UndoCompletedStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? undoneLog = null,
  }) {
    return _then(_$UndoCompletedStateImpl(
      undoneLog: null == undoneLog
          ? _value.undoneLog
          : undoneLog // ignore: cast_nullable_to_non_nullable
              as SmokeLog,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $SmokeLogCopyWith<$Res> get undoneLog {
    return $SmokeLogCopyWith<$Res>(_value.undoneLog, (value) {
      return _then(_value.copyWith(undoneLog: value));
    });
  }
}

/// @nodoc

class _$UndoCompletedStateImpl implements UndoCompletedState {
  const _$UndoCompletedStateImpl({required this.undoneLog});

  @override
  final SmokeLog undoneLog;

  @override
  String toString() {
    return 'UndoState.undoCompleted(undoneLog: $undoneLog)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UndoCompletedStateImpl &&
            (identical(other.undoneLog, undoneLog) ||
                other.undoneLog == undoneLog));
  }

  @override
  int get hashCode => Object.hash(runtimeType, undoneLog);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UndoCompletedStateImplCopyWith<_$UndoCompletedStateImpl> get copyWith =>
      __$$UndoCompletedStateImplCopyWithImpl<_$UndoCompletedStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(SmokeLog undoableLog, int remainingSeconds)
        pendingUndo,
    required TResult Function(SmokeLog targetLog) undoing,
    required TResult Function(SmokeLog undoneLog) undoCompleted,
    required TResult Function(String message) undoFailed,
  }) {
    return undoCompleted(undoneLog);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult? Function(SmokeLog targetLog)? undoing,
    TResult? Function(SmokeLog undoneLog)? undoCompleted,
    TResult? Function(String message)? undoFailed,
  }) {
    return undoCompleted?.call(undoneLog);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult Function(SmokeLog targetLog)? undoing,
    TResult Function(SmokeLog undoneLog)? undoCompleted,
    TResult Function(String message)? undoFailed,
    required TResult orElse(),
  }) {
    if (undoCompleted != null) {
      return undoCompleted(undoneLog);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UndoIdleState value) idle,
    required TResult Function(UndoPendingState value) pendingUndo,
    required TResult Function(UndoInProgressState value) undoing,
    required TResult Function(UndoCompletedState value) undoCompleted,
    required TResult Function(UndoFailedState value) undoFailed,
  }) {
    return undoCompleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UndoIdleState value)? idle,
    TResult? Function(UndoPendingState value)? pendingUndo,
    TResult? Function(UndoInProgressState value)? undoing,
    TResult? Function(UndoCompletedState value)? undoCompleted,
    TResult? Function(UndoFailedState value)? undoFailed,
  }) {
    return undoCompleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UndoIdleState value)? idle,
    TResult Function(UndoPendingState value)? pendingUndo,
    TResult Function(UndoInProgressState value)? undoing,
    TResult Function(UndoCompletedState value)? undoCompleted,
    TResult Function(UndoFailedState value)? undoFailed,
    required TResult orElse(),
  }) {
    if (undoCompleted != null) {
      return undoCompleted(this);
    }
    return orElse();
  }
}

abstract class UndoCompletedState implements UndoState {
  const factory UndoCompletedState({required final SmokeLog undoneLog}) =
      _$UndoCompletedStateImpl;

  SmokeLog get undoneLog;
  @JsonKey(ignore: true)
  _$$UndoCompletedStateImplCopyWith<_$UndoCompletedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UndoFailedStateImplCopyWith<$Res> {
  factory _$$UndoFailedStateImplCopyWith(_$UndoFailedStateImpl value,
          $Res Function(_$UndoFailedStateImpl) then) =
      __$$UndoFailedStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UndoFailedStateImplCopyWithImpl<$Res>
    extends _$UndoStateCopyWithImpl<$Res, _$UndoFailedStateImpl>
    implements _$$UndoFailedStateImplCopyWith<$Res> {
  __$$UndoFailedStateImplCopyWithImpl(
      _$UndoFailedStateImpl _value, $Res Function(_$UndoFailedStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UndoFailedStateImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UndoFailedStateImpl implements UndoFailedState {
  const _$UndoFailedStateImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'UndoState.undoFailed(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UndoFailedStateImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UndoFailedStateImplCopyWith<_$UndoFailedStateImpl> get copyWith =>
      __$$UndoFailedStateImplCopyWithImpl<_$UndoFailedStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(SmokeLog undoableLog, int remainingSeconds)
        pendingUndo,
    required TResult Function(SmokeLog targetLog) undoing,
    required TResult Function(SmokeLog undoneLog) undoCompleted,
    required TResult Function(String message) undoFailed,
  }) {
    return undoFailed(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult? Function(SmokeLog targetLog)? undoing,
    TResult? Function(SmokeLog undoneLog)? undoCompleted,
    TResult? Function(String message)? undoFailed,
  }) {
    return undoFailed?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(SmokeLog undoableLog, int remainingSeconds)? pendingUndo,
    TResult Function(SmokeLog targetLog)? undoing,
    TResult Function(SmokeLog undoneLog)? undoCompleted,
    TResult Function(String message)? undoFailed,
    required TResult orElse(),
  }) {
    if (undoFailed != null) {
      return undoFailed(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UndoIdleState value) idle,
    required TResult Function(UndoPendingState value) pendingUndo,
    required TResult Function(UndoInProgressState value) undoing,
    required TResult Function(UndoCompletedState value) undoCompleted,
    required TResult Function(UndoFailedState value) undoFailed,
  }) {
    return undoFailed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UndoIdleState value)? idle,
    TResult? Function(UndoPendingState value)? pendingUndo,
    TResult? Function(UndoInProgressState value)? undoing,
    TResult? Function(UndoCompletedState value)? undoCompleted,
    TResult? Function(UndoFailedState value)? undoFailed,
  }) {
    return undoFailed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UndoIdleState value)? idle,
    TResult Function(UndoPendingState value)? pendingUndo,
    TResult Function(UndoInProgressState value)? undoing,
    TResult Function(UndoCompletedState value)? undoCompleted,
    TResult Function(UndoFailedState value)? undoFailed,
    required TResult orElse(),
  }) {
    if (undoFailed != null) {
      return undoFailed(this);
    }
    return orElse();
  }
}

abstract class UndoFailedState implements UndoState {
  const factory UndoFailedState({required final String message}) =
      _$UndoFailedStateImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$UndoFailedStateImplCopyWith<_$UndoFailedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
