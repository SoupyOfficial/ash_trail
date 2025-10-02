// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppFailure {
  String? get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? message, Object? cause, StackTrace? stackTrace)
        unexpected,
    required TResult Function(String? message, int? statusCode) network,
    required TResult Function(String? message) cache,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String? message, String? resourceId) notFound,
    required TResult Function(String? message) conflict,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult? Function(String? message, int? statusCode)? network,
    TResult? Function(String? message)? cache,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String? message, String? resourceId)? notFound,
    TResult? Function(String? message)? conflict,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult Function(String? message, int? statusCode)? network,
    TResult Function(String? message)? cache,
    TResult Function(String message, String? field)? validation,
    TResult Function(String? message, String? resourceId)? notFound,
    TResult Function(String? message)? conflict,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Unexpected value) unexpected,
    required TResult Function(_Network value) network,
    required TResult Function(_Cache value) cache,
    required TResult Function(_Validation value) validation,
    required TResult Function(_NotFound value) notFound,
    required TResult Function(_Conflict value) conflict,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Unexpected value)? unexpected,
    TResult? Function(_Network value)? network,
    TResult? Function(_Cache value)? cache,
    TResult? Function(_Validation value)? validation,
    TResult? Function(_NotFound value)? notFound,
    TResult? Function(_Conflict value)? conflict,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Unexpected value)? unexpected,
    TResult Function(_Network value)? network,
    TResult Function(_Cache value)? cache,
    TResult Function(_Validation value)? validation,
    TResult Function(_NotFound value)? notFound,
    TResult Function(_Conflict value)? conflict,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppFailureCopyWith<AppFailure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppFailureCopyWith<$Res> {
  factory $AppFailureCopyWith(
          AppFailure value, $Res Function(AppFailure) then) =
      _$AppFailureCopyWithImpl<$Res, AppFailure>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AppFailureCopyWithImpl<$Res, $Val extends AppFailure>
    implements $AppFailureCopyWith<$Res> {
  _$AppFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message!
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnexpectedImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$UnexpectedImplCopyWith(
          _$UnexpectedImpl value, $Res Function(_$UnexpectedImpl) then) =
      __$$UnexpectedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, Object? cause, StackTrace? stackTrace});
}

/// @nodoc
class __$$UnexpectedImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$UnexpectedImpl>
    implements _$$UnexpectedImplCopyWith<$Res> {
  __$$UnexpectedImplCopyWithImpl(
      _$UnexpectedImpl _value, $Res Function(_$UnexpectedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? cause = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(_$UnexpectedImpl(
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      cause: freezed == cause ? _value.cause : cause,
      stackTrace: freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

/// @nodoc

class _$UnexpectedImpl extends _Unexpected {
  const _$UnexpectedImpl({this.message, this.cause, this.stackTrace})
      : super._();

  @override
  final String? message;
  @override
  final Object? cause;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'AppFailure.unexpected(message: $message, cause: $cause, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnexpectedImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.cause, cause) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message,
      const DeepCollectionEquality().hash(cause), stackTrace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnexpectedImplCopyWith<_$UnexpectedImpl> get copyWith =>
      __$$UnexpectedImplCopyWithImpl<_$UnexpectedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? message, Object? cause, StackTrace? stackTrace)
        unexpected,
    required TResult Function(String? message, int? statusCode) network,
    required TResult Function(String? message) cache,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String? message, String? resourceId) notFound,
    required TResult Function(String? message) conflict,
  }) {
    return unexpected(message, cause, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult? Function(String? message, int? statusCode)? network,
    TResult? Function(String? message)? cache,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String? message, String? resourceId)? notFound,
    TResult? Function(String? message)? conflict,
  }) {
    return unexpected?.call(message, cause, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult Function(String? message, int? statusCode)? network,
    TResult Function(String? message)? cache,
    TResult Function(String message, String? field)? validation,
    TResult Function(String? message, String? resourceId)? notFound,
    TResult Function(String? message)? conflict,
    required TResult orElse(),
  }) {
    if (unexpected != null) {
      return unexpected(message, cause, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Unexpected value) unexpected,
    required TResult Function(_Network value) network,
    required TResult Function(_Cache value) cache,
    required TResult Function(_Validation value) validation,
    required TResult Function(_NotFound value) notFound,
    required TResult Function(_Conflict value) conflict,
  }) {
    return unexpected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Unexpected value)? unexpected,
    TResult? Function(_Network value)? network,
    TResult? Function(_Cache value)? cache,
    TResult? Function(_Validation value)? validation,
    TResult? Function(_NotFound value)? notFound,
    TResult? Function(_Conflict value)? conflict,
  }) {
    return unexpected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Unexpected value)? unexpected,
    TResult Function(_Network value)? network,
    TResult Function(_Cache value)? cache,
    TResult Function(_Validation value)? validation,
    TResult Function(_NotFound value)? notFound,
    TResult Function(_Conflict value)? conflict,
    required TResult orElse(),
  }) {
    if (unexpected != null) {
      return unexpected(this);
    }
    return orElse();
  }
}

abstract class _Unexpected extends AppFailure {
  const factory _Unexpected(
      {final String? message,
      final Object? cause,
      final StackTrace? stackTrace}) = _$UnexpectedImpl;
  const _Unexpected._() : super._();

  @override
  String? get message;
  Object? get cause;
  StackTrace? get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$UnexpectedImplCopyWith<_$UnexpectedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NetworkImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$NetworkImplCopyWith(
          _$NetworkImpl value, $Res Function(_$NetworkImpl) then) =
      __$$NetworkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, int? statusCode});
}

/// @nodoc
class __$$NetworkImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$NetworkImpl>
    implements _$$NetworkImplCopyWith<$Res> {
  __$$NetworkImplCopyWithImpl(
      _$NetworkImpl _value, $Res Function(_$NetworkImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? statusCode = freezed,
  }) {
    return _then(_$NetworkImpl(
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$NetworkImpl extends _Network {
  const _$NetworkImpl({this.message, this.statusCode}) : super._();

  @override
  final String? message;
  @override
  final int? statusCode;

  @override
  String toString() {
    return 'AppFailure.network(message: $message, statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkImplCopyWith<_$NetworkImpl> get copyWith =>
      __$$NetworkImplCopyWithImpl<_$NetworkImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? message, Object? cause, StackTrace? stackTrace)
        unexpected,
    required TResult Function(String? message, int? statusCode) network,
    required TResult Function(String? message) cache,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String? message, String? resourceId) notFound,
    required TResult Function(String? message) conflict,
  }) {
    return network(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult? Function(String? message, int? statusCode)? network,
    TResult? Function(String? message)? cache,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String? message, String? resourceId)? notFound,
    TResult? Function(String? message)? conflict,
  }) {
    return network?.call(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult Function(String? message, int? statusCode)? network,
    TResult Function(String? message)? cache,
    TResult Function(String message, String? field)? validation,
    TResult Function(String? message, String? resourceId)? notFound,
    TResult Function(String? message)? conflict,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, statusCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Unexpected value) unexpected,
    required TResult Function(_Network value) network,
    required TResult Function(_Cache value) cache,
    required TResult Function(_Validation value) validation,
    required TResult Function(_NotFound value) notFound,
    required TResult Function(_Conflict value) conflict,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Unexpected value)? unexpected,
    TResult? Function(_Network value)? network,
    TResult? Function(_Cache value)? cache,
    TResult? Function(_Validation value)? validation,
    TResult? Function(_NotFound value)? notFound,
    TResult? Function(_Conflict value)? conflict,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Unexpected value)? unexpected,
    TResult Function(_Network value)? network,
    TResult Function(_Cache value)? cache,
    TResult Function(_Validation value)? validation,
    TResult Function(_NotFound value)? notFound,
    TResult Function(_Conflict value)? conflict,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class _Network extends AppFailure {
  const factory _Network({final String? message, final int? statusCode}) =
      _$NetworkImpl;
  const _Network._() : super._();

  @override
  String? get message;
  int? get statusCode;
  @override
  @JsonKey(ignore: true)
  _$$NetworkImplCopyWith<_$NetworkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheImplCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory _$$CacheImplCopyWith(
          _$CacheImpl value, $Res Function(_$CacheImpl) then) =
      __$$CacheImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$CacheImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$CacheImpl>
    implements _$$CacheImplCopyWith<$Res> {
  __$$CacheImplCopyWithImpl(
      _$CacheImpl _value, $Res Function(_$CacheImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$CacheImpl(
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CacheImpl extends _Cache {
  const _$CacheImpl({this.message}) : super._();

  @override
  final String? message;

  @override
  String toString() {
    return 'AppFailure.cache(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheImplCopyWith<_$CacheImpl> get copyWith =>
      __$$CacheImplCopyWithImpl<_$CacheImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? message, Object? cause, StackTrace? stackTrace)
        unexpected,
    required TResult Function(String? message, int? statusCode) network,
    required TResult Function(String? message) cache,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String? message, String? resourceId) notFound,
    required TResult Function(String? message) conflict,
  }) {
    return cache(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult? Function(String? message, int? statusCode)? network,
    TResult? Function(String? message)? cache,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String? message, String? resourceId)? notFound,
    TResult? Function(String? message)? conflict,
  }) {
    return cache?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult Function(String? message, int? statusCode)? network,
    TResult Function(String? message)? cache,
    TResult Function(String message, String? field)? validation,
    TResult Function(String? message, String? resourceId)? notFound,
    TResult Function(String? message)? conflict,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Unexpected value) unexpected,
    required TResult Function(_Network value) network,
    required TResult Function(_Cache value) cache,
    required TResult Function(_Validation value) validation,
    required TResult Function(_NotFound value) notFound,
    required TResult Function(_Conflict value) conflict,
  }) {
    return cache(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Unexpected value)? unexpected,
    TResult? Function(_Network value)? network,
    TResult? Function(_Cache value)? cache,
    TResult? Function(_Validation value)? validation,
    TResult? Function(_NotFound value)? notFound,
    TResult? Function(_Conflict value)? conflict,
  }) {
    return cache?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Unexpected value)? unexpected,
    TResult Function(_Network value)? network,
    TResult Function(_Cache value)? cache,
    TResult Function(_Validation value)? validation,
    TResult Function(_NotFound value)? notFound,
    TResult Function(_Conflict value)? conflict,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(this);
    }
    return orElse();
  }
}

abstract class _Cache extends AppFailure {
  const factory _Cache({final String? message}) = _$CacheImpl;
  const _Cache._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$CacheImplCopyWith<_$CacheImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$ValidationImplCopyWith(
          _$ValidationImpl value, $Res Function(_$ValidationImpl) then) =
      __$$ValidationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? field});
}

/// @nodoc
class __$$ValidationImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$ValidationImpl>
    implements _$$ValidationImplCopyWith<$Res> {
  __$$ValidationImplCopyWithImpl(
      _$ValidationImpl _value, $Res Function(_$ValidationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? field = freezed,
  }) {
    return _then(_$ValidationImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      field: freezed == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ValidationImpl extends _Validation {
  const _$ValidationImpl({required this.message, this.field}) : super._();

  @override
  final String message;
  @override
  final String? field;

  @override
  String toString() {
    return 'AppFailure.validation(message: $message, field: $field)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.field, field) || other.field == field));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, field);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationImplCopyWith<_$ValidationImpl> get copyWith =>
      __$$ValidationImplCopyWithImpl<_$ValidationImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? message, Object? cause, StackTrace? stackTrace)
        unexpected,
    required TResult Function(String? message, int? statusCode) network,
    required TResult Function(String? message) cache,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String? message, String? resourceId) notFound,
    required TResult Function(String? message) conflict,
  }) {
    return validation(message, field);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult? Function(String? message, int? statusCode)? network,
    TResult? Function(String? message)? cache,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String? message, String? resourceId)? notFound,
    TResult? Function(String? message)? conflict,
  }) {
    return validation?.call(message, field);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult Function(String? message, int? statusCode)? network,
    TResult Function(String? message)? cache,
    TResult Function(String message, String? field)? validation,
    TResult Function(String? message, String? resourceId)? notFound,
    TResult Function(String? message)? conflict,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, field);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Unexpected value) unexpected,
    required TResult Function(_Network value) network,
    required TResult Function(_Cache value) cache,
    required TResult Function(_Validation value) validation,
    required TResult Function(_NotFound value) notFound,
    required TResult Function(_Conflict value) conflict,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Unexpected value)? unexpected,
    TResult? Function(_Network value)? network,
    TResult? Function(_Cache value)? cache,
    TResult? Function(_Validation value)? validation,
    TResult? Function(_NotFound value)? notFound,
    TResult? Function(_Conflict value)? conflict,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Unexpected value)? unexpected,
    TResult Function(_Network value)? network,
    TResult Function(_Cache value)? cache,
    TResult Function(_Validation value)? validation,
    TResult Function(_NotFound value)? notFound,
    TResult Function(_Conflict value)? conflict,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class _Validation extends AppFailure {
  const factory _Validation(
      {required final String message, final String? field}) = _$ValidationImpl;
  const _Validation._() : super._();

  @override
  String get message;
  String? get field;
  @override
  @JsonKey(ignore: true)
  _$$ValidationImplCopyWith<_$ValidationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$NotFoundImplCopyWith(
          _$NotFoundImpl value, $Res Function(_$NotFoundImpl) then) =
      __$$NotFoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message, String? resourceId});
}

/// @nodoc
class __$$NotFoundImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$NotFoundImpl>
    implements _$$NotFoundImplCopyWith<$Res> {
  __$$NotFoundImplCopyWithImpl(
      _$NotFoundImpl _value, $Res Function(_$NotFoundImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
    Object? resourceId = freezed,
  }) {
    return _then(_$NotFoundImpl(
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      resourceId: freezed == resourceId
          ? _value.resourceId
          : resourceId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$NotFoundImpl extends _NotFound {
  const _$NotFoundImpl({this.message, this.resourceId}) : super._();

  @override
  final String? message;
  @override
  final String? resourceId;

  @override
  String toString() {
    return 'AppFailure.notFound(message: $message, resourceId: $resourceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.resourceId, resourceId) ||
                other.resourceId == resourceId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, resourceId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundImplCopyWith<_$NotFoundImpl> get copyWith =>
      __$$NotFoundImplCopyWithImpl<_$NotFoundImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? message, Object? cause, StackTrace? stackTrace)
        unexpected,
    required TResult Function(String? message, int? statusCode) network,
    required TResult Function(String? message) cache,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String? message, String? resourceId) notFound,
    required TResult Function(String? message) conflict,
  }) {
    return notFound(message, resourceId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult? Function(String? message, int? statusCode)? network,
    TResult? Function(String? message)? cache,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String? message, String? resourceId)? notFound,
    TResult? Function(String? message)? conflict,
  }) {
    return notFound?.call(message, resourceId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult Function(String? message, int? statusCode)? network,
    TResult Function(String? message)? cache,
    TResult Function(String message, String? field)? validation,
    TResult Function(String? message, String? resourceId)? notFound,
    TResult Function(String? message)? conflict,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message, resourceId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Unexpected value) unexpected,
    required TResult Function(_Network value) network,
    required TResult Function(_Cache value) cache,
    required TResult Function(_Validation value) validation,
    required TResult Function(_NotFound value) notFound,
    required TResult Function(_Conflict value) conflict,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Unexpected value)? unexpected,
    TResult? Function(_Network value)? network,
    TResult? Function(_Cache value)? cache,
    TResult? Function(_Validation value)? validation,
    TResult? Function(_NotFound value)? notFound,
    TResult? Function(_Conflict value)? conflict,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Unexpected value)? unexpected,
    TResult Function(_Network value)? network,
    TResult Function(_Cache value)? cache,
    TResult Function(_Validation value)? validation,
    TResult Function(_NotFound value)? notFound,
    TResult Function(_Conflict value)? conflict,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class _NotFound extends AppFailure {
  const factory _NotFound({final String? message, final String? resourceId}) =
      _$NotFoundImpl;
  const _NotFound._() : super._();

  @override
  String? get message;
  String? get resourceId;
  @override
  @JsonKey(ignore: true)
  _$$NotFoundImplCopyWith<_$NotFoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConflictImplCopyWith<$Res>
    implements $AppFailureCopyWith<$Res> {
  factory _$$ConflictImplCopyWith(
          _$ConflictImpl value, $Res Function(_$ConflictImpl) then) =
      __$$ConflictImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? message});
}

/// @nodoc
class __$$ConflictImplCopyWithImpl<$Res>
    extends _$AppFailureCopyWithImpl<$Res, _$ConflictImpl>
    implements _$$ConflictImplCopyWith<$Res> {
  __$$ConflictImplCopyWithImpl(
      _$ConflictImpl _value, $Res Function(_$ConflictImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = freezed,
  }) {
    return _then(_$ConflictImpl(
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ConflictImpl extends _Conflict {
  const _$ConflictImpl({this.message}) : super._();

  @override
  final String? message;

  @override
  String toString() {
    return 'AppFailure.conflict(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConflictImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConflictImplCopyWith<_$ConflictImpl> get copyWith =>
      __$$ConflictImplCopyWithImpl<_$ConflictImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? message, Object? cause, StackTrace? stackTrace)
        unexpected,
    required TResult Function(String? message, int? statusCode) network,
    required TResult Function(String? message) cache,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String? message, String? resourceId) notFound,
    required TResult Function(String? message) conflict,
  }) {
    return conflict(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult? Function(String? message, int? statusCode)? network,
    TResult? Function(String? message)? cache,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String? message, String? resourceId)? notFound,
    TResult? Function(String? message)? conflict,
  }) {
    return conflict?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message, Object? cause, StackTrace? stackTrace)?
        unexpected,
    TResult Function(String? message, int? statusCode)? network,
    TResult Function(String? message)? cache,
    TResult Function(String message, String? field)? validation,
    TResult Function(String? message, String? resourceId)? notFound,
    TResult Function(String? message)? conflict,
    required TResult orElse(),
  }) {
    if (conflict != null) {
      return conflict(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Unexpected value) unexpected,
    required TResult Function(_Network value) network,
    required TResult Function(_Cache value) cache,
    required TResult Function(_Validation value) validation,
    required TResult Function(_NotFound value) notFound,
    required TResult Function(_Conflict value) conflict,
  }) {
    return conflict(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Unexpected value)? unexpected,
    TResult? Function(_Network value)? network,
    TResult? Function(_Cache value)? cache,
    TResult? Function(_Validation value)? validation,
    TResult? Function(_NotFound value)? notFound,
    TResult? Function(_Conflict value)? conflict,
  }) {
    return conflict?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Unexpected value)? unexpected,
    TResult Function(_Network value)? network,
    TResult Function(_Cache value)? cache,
    TResult Function(_Validation value)? validation,
    TResult Function(_NotFound value)? notFound,
    TResult Function(_Conflict value)? conflict,
    required TResult orElse(),
  }) {
    if (conflict != null) {
      return conflict(this);
    }
    return orElse();
  }
}

abstract class _Conflict extends AppFailure {
  const factory _Conflict({final String? message}) = _$ConflictImpl;
  const _Conflict._() : super._();

  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$ConflictImplCopyWith<_$ConflictImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
