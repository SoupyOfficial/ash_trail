// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'record_button_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RecordButtonState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(DateTime startTime, int currentDurationMs)
        recording,
    required TResult Function(int durationMs, String smokeLogId) completed,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(DateTime startTime, int currentDurationMs)? recording,
    TResult? Function(int durationMs, String smokeLogId)? completed,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(DateTime startTime, int currentDurationMs)? recording,
    TResult Function(int durationMs, String smokeLogId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RecordButtonIdleState value) idle,
    required TResult Function(RecordButtonRecordingState value) recording,
    required TResult Function(RecordButtonCompletedState value) completed,
    required TResult Function(RecordButtonErrorState value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RecordButtonIdleState value)? idle,
    TResult? Function(RecordButtonRecordingState value)? recording,
    TResult? Function(RecordButtonCompletedState value)? completed,
    TResult? Function(RecordButtonErrorState value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RecordButtonIdleState value)? idle,
    TResult Function(RecordButtonRecordingState value)? recording,
    TResult Function(RecordButtonCompletedState value)? completed,
    TResult Function(RecordButtonErrorState value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordButtonStateCopyWith<$Res> {
  factory $RecordButtonStateCopyWith(
          RecordButtonState value, $Res Function(RecordButtonState) then) =
      _$RecordButtonStateCopyWithImpl<$Res, RecordButtonState>;
}

/// @nodoc
class _$RecordButtonStateCopyWithImpl<$Res, $Val extends RecordButtonState>
    implements $RecordButtonStateCopyWith<$Res> {
  _$RecordButtonStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$RecordButtonIdleStateImplCopyWith<$Res> {
  factory _$$RecordButtonIdleStateImplCopyWith(
          _$RecordButtonIdleStateImpl value,
          $Res Function(_$RecordButtonIdleStateImpl) then) =
      __$$RecordButtonIdleStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RecordButtonIdleStateImplCopyWithImpl<$Res>
    extends _$RecordButtonStateCopyWithImpl<$Res, _$RecordButtonIdleStateImpl>
    implements _$$RecordButtonIdleStateImplCopyWith<$Res> {
  __$$RecordButtonIdleStateImplCopyWithImpl(_$RecordButtonIdleStateImpl _value,
      $Res Function(_$RecordButtonIdleStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RecordButtonIdleStateImpl implements RecordButtonIdleState {
  const _$RecordButtonIdleStateImpl();

  @override
  String toString() {
    return 'RecordButtonState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordButtonIdleStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(DateTime startTime, int currentDurationMs)
        recording,
    required TResult Function(int durationMs, String smokeLogId) completed,
    required TResult Function(String message) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(DateTime startTime, int currentDurationMs)? recording,
    TResult? Function(int durationMs, String smokeLogId)? completed,
    TResult? Function(String message)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(DateTime startTime, int currentDurationMs)? recording,
    TResult Function(int durationMs, String smokeLogId)? completed,
    TResult Function(String message)? error,
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
    required TResult Function(RecordButtonIdleState value) idle,
    required TResult Function(RecordButtonRecordingState value) recording,
    required TResult Function(RecordButtonCompletedState value) completed,
    required TResult Function(RecordButtonErrorState value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RecordButtonIdleState value)? idle,
    TResult? Function(RecordButtonRecordingState value)? recording,
    TResult? Function(RecordButtonCompletedState value)? completed,
    TResult? Function(RecordButtonErrorState value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RecordButtonIdleState value)? idle,
    TResult Function(RecordButtonRecordingState value)? recording,
    TResult Function(RecordButtonCompletedState value)? completed,
    TResult Function(RecordButtonErrorState value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class RecordButtonIdleState implements RecordButtonState {
  const factory RecordButtonIdleState() = _$RecordButtonIdleStateImpl;
}

/// @nodoc
abstract class _$$RecordButtonRecordingStateImplCopyWith<$Res> {
  factory _$$RecordButtonRecordingStateImplCopyWith(
          _$RecordButtonRecordingStateImpl value,
          $Res Function(_$RecordButtonRecordingStateImpl) then) =
      __$$RecordButtonRecordingStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DateTime startTime, int currentDurationMs});
}

/// @nodoc
class __$$RecordButtonRecordingStateImplCopyWithImpl<$Res>
    extends _$RecordButtonStateCopyWithImpl<$Res,
        _$RecordButtonRecordingStateImpl>
    implements _$$RecordButtonRecordingStateImplCopyWith<$Res> {
  __$$RecordButtonRecordingStateImplCopyWithImpl(
      _$RecordButtonRecordingStateImpl _value,
      $Res Function(_$RecordButtonRecordingStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? currentDurationMs = null,
  }) {
    return _then(_$RecordButtonRecordingStateImpl(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentDurationMs: null == currentDurationMs
          ? _value.currentDurationMs
          : currentDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$RecordButtonRecordingStateImpl implements RecordButtonRecordingState {
  const _$RecordButtonRecordingStateImpl(
      {required this.startTime, required this.currentDurationMs});

  @override
  final DateTime startTime;
  @override
  final int currentDurationMs;

  @override
  String toString() {
    return 'RecordButtonState.recording(startTime: $startTime, currentDurationMs: $currentDurationMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordButtonRecordingStateImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.currentDurationMs, currentDurationMs) ||
                other.currentDurationMs == currentDurationMs));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startTime, currentDurationMs);

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordButtonRecordingStateImplCopyWith<_$RecordButtonRecordingStateImpl>
      get copyWith => __$$RecordButtonRecordingStateImplCopyWithImpl<
          _$RecordButtonRecordingStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(DateTime startTime, int currentDurationMs)
        recording,
    required TResult Function(int durationMs, String smokeLogId) completed,
    required TResult Function(String message) error,
  }) {
    return recording(startTime, currentDurationMs);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(DateTime startTime, int currentDurationMs)? recording,
    TResult? Function(int durationMs, String smokeLogId)? completed,
    TResult? Function(String message)? error,
  }) {
    return recording?.call(startTime, currentDurationMs);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(DateTime startTime, int currentDurationMs)? recording,
    TResult Function(int durationMs, String smokeLogId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (recording != null) {
      return recording(startTime, currentDurationMs);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RecordButtonIdleState value) idle,
    required TResult Function(RecordButtonRecordingState value) recording,
    required TResult Function(RecordButtonCompletedState value) completed,
    required TResult Function(RecordButtonErrorState value) error,
  }) {
    return recording(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RecordButtonIdleState value)? idle,
    TResult? Function(RecordButtonRecordingState value)? recording,
    TResult? Function(RecordButtonCompletedState value)? completed,
    TResult? Function(RecordButtonErrorState value)? error,
  }) {
    return recording?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RecordButtonIdleState value)? idle,
    TResult Function(RecordButtonRecordingState value)? recording,
    TResult Function(RecordButtonCompletedState value)? completed,
    TResult Function(RecordButtonErrorState value)? error,
    required TResult orElse(),
  }) {
    if (recording != null) {
      return recording(this);
    }
    return orElse();
  }
}

abstract class RecordButtonRecordingState implements RecordButtonState {
  const factory RecordButtonRecordingState(
      {required final DateTime startTime,
      required final int currentDurationMs}) = _$RecordButtonRecordingStateImpl;

  DateTime get startTime;
  int get currentDurationMs;

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordButtonRecordingStateImplCopyWith<_$RecordButtonRecordingStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RecordButtonCompletedStateImplCopyWith<$Res> {
  factory _$$RecordButtonCompletedStateImplCopyWith(
          _$RecordButtonCompletedStateImpl value,
          $Res Function(_$RecordButtonCompletedStateImpl) then) =
      __$$RecordButtonCompletedStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int durationMs, String smokeLogId});
}

/// @nodoc
class __$$RecordButtonCompletedStateImplCopyWithImpl<$Res>
    extends _$RecordButtonStateCopyWithImpl<$Res,
        _$RecordButtonCompletedStateImpl>
    implements _$$RecordButtonCompletedStateImplCopyWith<$Res> {
  __$$RecordButtonCompletedStateImplCopyWithImpl(
      _$RecordButtonCompletedStateImpl _value,
      $Res Function(_$RecordButtonCompletedStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationMs = null,
    Object? smokeLogId = null,
  }) {
    return _then(_$RecordButtonCompletedStateImpl(
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      smokeLogId: null == smokeLogId
          ? _value.smokeLogId
          : smokeLogId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RecordButtonCompletedStateImpl implements RecordButtonCompletedState {
  const _$RecordButtonCompletedStateImpl(
      {required this.durationMs, required this.smokeLogId});

  @override
  final int durationMs;
  @override
  final String smokeLogId;

  @override
  String toString() {
    return 'RecordButtonState.completed(durationMs: $durationMs, smokeLogId: $smokeLogId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordButtonCompletedStateImpl &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.smokeLogId, smokeLogId) ||
                other.smokeLogId == smokeLogId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, durationMs, smokeLogId);

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordButtonCompletedStateImplCopyWith<_$RecordButtonCompletedStateImpl>
      get copyWith => __$$RecordButtonCompletedStateImplCopyWithImpl<
          _$RecordButtonCompletedStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(DateTime startTime, int currentDurationMs)
        recording,
    required TResult Function(int durationMs, String smokeLogId) completed,
    required TResult Function(String message) error,
  }) {
    return completed(durationMs, smokeLogId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(DateTime startTime, int currentDurationMs)? recording,
    TResult? Function(int durationMs, String smokeLogId)? completed,
    TResult? Function(String message)? error,
  }) {
    return completed?.call(durationMs, smokeLogId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(DateTime startTime, int currentDurationMs)? recording,
    TResult Function(int durationMs, String smokeLogId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(durationMs, smokeLogId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RecordButtonIdleState value) idle,
    required TResult Function(RecordButtonRecordingState value) recording,
    required TResult Function(RecordButtonCompletedState value) completed,
    required TResult Function(RecordButtonErrorState value) error,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RecordButtonIdleState value)? idle,
    TResult? Function(RecordButtonRecordingState value)? recording,
    TResult? Function(RecordButtonCompletedState value)? completed,
    TResult? Function(RecordButtonErrorState value)? error,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RecordButtonIdleState value)? idle,
    TResult Function(RecordButtonRecordingState value)? recording,
    TResult Function(RecordButtonCompletedState value)? completed,
    TResult Function(RecordButtonErrorState value)? error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class RecordButtonCompletedState implements RecordButtonState {
  const factory RecordButtonCompletedState(
      {required final int durationMs,
      required final String smokeLogId}) = _$RecordButtonCompletedStateImpl;

  int get durationMs;
  String get smokeLogId;

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordButtonCompletedStateImplCopyWith<_$RecordButtonCompletedStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RecordButtonErrorStateImplCopyWith<$Res> {
  factory _$$RecordButtonErrorStateImplCopyWith(
          _$RecordButtonErrorStateImpl value,
          $Res Function(_$RecordButtonErrorStateImpl) then) =
      __$$RecordButtonErrorStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$RecordButtonErrorStateImplCopyWithImpl<$Res>
    extends _$RecordButtonStateCopyWithImpl<$Res, _$RecordButtonErrorStateImpl>
    implements _$$RecordButtonErrorStateImplCopyWith<$Res> {
  __$$RecordButtonErrorStateImplCopyWithImpl(
      _$RecordButtonErrorStateImpl _value,
      $Res Function(_$RecordButtonErrorStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$RecordButtonErrorStateImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RecordButtonErrorStateImpl implements RecordButtonErrorState {
  const _$RecordButtonErrorStateImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'RecordButtonState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordButtonErrorStateImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordButtonErrorStateImplCopyWith<_$RecordButtonErrorStateImpl>
      get copyWith => __$$RecordButtonErrorStateImplCopyWithImpl<
          _$RecordButtonErrorStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(DateTime startTime, int currentDurationMs)
        recording,
    required TResult Function(int durationMs, String smokeLogId) completed,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(DateTime startTime, int currentDurationMs)? recording,
    TResult? Function(int durationMs, String smokeLogId)? completed,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(DateTime startTime, int currentDurationMs)? recording,
    TResult Function(int durationMs, String smokeLogId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RecordButtonIdleState value) idle,
    required TResult Function(RecordButtonRecordingState value) recording,
    required TResult Function(RecordButtonCompletedState value) completed,
    required TResult Function(RecordButtonErrorState value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RecordButtonIdleState value)? idle,
    TResult? Function(RecordButtonRecordingState value)? recording,
    TResult? Function(RecordButtonCompletedState value)? completed,
    TResult? Function(RecordButtonErrorState value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RecordButtonIdleState value)? idle,
    TResult Function(RecordButtonRecordingState value)? recording,
    TResult Function(RecordButtonCompletedState value)? completed,
    TResult Function(RecordButtonErrorState value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class RecordButtonErrorState implements RecordButtonState {
  const factory RecordButtonErrorState({required final String message}) =
      _$RecordButtonErrorStateImpl;

  String get message;

  /// Create a copy of RecordButtonState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordButtonErrorStateImplCopyWith<_$RecordButtonErrorStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
