// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refresh_log_detail_usecase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RefreshLogDetailParams {
  String get logId => throw _privateConstructorUsedError;

  /// Create a copy of RefreshLogDetailParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RefreshLogDetailParamsCopyWith<RefreshLogDetailParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefreshLogDetailParamsCopyWith<$Res> {
  factory $RefreshLogDetailParamsCopyWith(RefreshLogDetailParams value,
          $Res Function(RefreshLogDetailParams) then) =
      _$RefreshLogDetailParamsCopyWithImpl<$Res, RefreshLogDetailParams>;
  @useResult
  $Res call({String logId});
}

/// @nodoc
class _$RefreshLogDetailParamsCopyWithImpl<$Res,
        $Val extends RefreshLogDetailParams>
    implements $RefreshLogDetailParamsCopyWith<$Res> {
  _$RefreshLogDetailParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RefreshLogDetailParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
  }) {
    return _then(_value.copyWith(
      logId: null == logId
          ? _value.logId
          : logId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefreshLogDetailParamsImplCopyWith<$Res>
    implements $RefreshLogDetailParamsCopyWith<$Res> {
  factory _$$RefreshLogDetailParamsImplCopyWith(
          _$RefreshLogDetailParamsImpl value,
          $Res Function(_$RefreshLogDetailParamsImpl) then) =
      __$$RefreshLogDetailParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String logId});
}

/// @nodoc
class __$$RefreshLogDetailParamsImplCopyWithImpl<$Res>
    extends _$RefreshLogDetailParamsCopyWithImpl<$Res,
        _$RefreshLogDetailParamsImpl>
    implements _$$RefreshLogDetailParamsImplCopyWith<$Res> {
  __$$RefreshLogDetailParamsImplCopyWithImpl(
      _$RefreshLogDetailParamsImpl _value,
      $Res Function(_$RefreshLogDetailParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RefreshLogDetailParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
  }) {
    return _then(_$RefreshLogDetailParamsImpl(
      logId: null == logId
          ? _value.logId
          : logId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RefreshLogDetailParamsImpl implements _RefreshLogDetailParams {
  const _$RefreshLogDetailParamsImpl({required this.logId});

  @override
  final String logId;

  @override
  String toString() {
    return 'RefreshLogDetailParams(logId: $logId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshLogDetailParamsImpl &&
            (identical(other.logId, logId) || other.logId == logId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, logId);

  /// Create a copy of RefreshLogDetailParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefreshLogDetailParamsImplCopyWith<_$RefreshLogDetailParamsImpl>
      get copyWith => __$$RefreshLogDetailParamsImplCopyWithImpl<
          _$RefreshLogDetailParamsImpl>(this, _$identity);
}

abstract class _RefreshLogDetailParams implements RefreshLogDetailParams {
  const factory _RefreshLogDetailParams({required final String logId}) =
      _$RefreshLogDetailParamsImpl;

  @override
  String get logId;

  /// Create a copy of RefreshLogDetailParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefreshLogDetailParamsImplCopyWith<_$RefreshLogDetailParamsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
