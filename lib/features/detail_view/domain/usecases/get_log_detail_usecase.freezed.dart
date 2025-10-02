// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_log_detail_usecase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GetLogDetailParams {
  String get logId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GetLogDetailParamsCopyWith<GetLogDetailParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetLogDetailParamsCopyWith<$Res> {
  factory $GetLogDetailParamsCopyWith(
          GetLogDetailParams value, $Res Function(GetLogDetailParams) then) =
      _$GetLogDetailParamsCopyWithImpl<$Res, GetLogDetailParams>;
  @useResult
  $Res call({String logId});
}

/// @nodoc
class _$GetLogDetailParamsCopyWithImpl<$Res, $Val extends GetLogDetailParams>
    implements $GetLogDetailParamsCopyWith<$Res> {
  _$GetLogDetailParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
abstract class _$$GetLogDetailParamsImplCopyWith<$Res>
    implements $GetLogDetailParamsCopyWith<$Res> {
  factory _$$GetLogDetailParamsImplCopyWith(_$GetLogDetailParamsImpl value,
          $Res Function(_$GetLogDetailParamsImpl) then) =
      __$$GetLogDetailParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String logId});
}

/// @nodoc
class __$$GetLogDetailParamsImplCopyWithImpl<$Res>
    extends _$GetLogDetailParamsCopyWithImpl<$Res, _$GetLogDetailParamsImpl>
    implements _$$GetLogDetailParamsImplCopyWith<$Res> {
  __$$GetLogDetailParamsImplCopyWithImpl(_$GetLogDetailParamsImpl _value,
      $Res Function(_$GetLogDetailParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logId = null,
  }) {
    return _then(_$GetLogDetailParamsImpl(
      logId: null == logId
          ? _value.logId
          : logId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetLogDetailParamsImpl implements _GetLogDetailParams {
  const _$GetLogDetailParamsImpl({required this.logId});

  @override
  final String logId;

  @override
  String toString() {
    return 'GetLogDetailParams(logId: $logId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetLogDetailParamsImpl &&
            (identical(other.logId, logId) || other.logId == logId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, logId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetLogDetailParamsImplCopyWith<_$GetLogDetailParamsImpl> get copyWith =>
      __$$GetLogDetailParamsImplCopyWithImpl<_$GetLogDetailParamsImpl>(
          this, _$identity);
}

abstract class _GetLogDetailParams implements GetLogDetailParams {
  const factory _GetLogDetailParams({required final String logId}) =
      _$GetLogDetailParamsImpl;

  @override
  String get logId;
  @override
  @JsonKey(ignore: true)
  _$$GetLogDetailParamsImplCopyWith<_$GetLogDetailParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
