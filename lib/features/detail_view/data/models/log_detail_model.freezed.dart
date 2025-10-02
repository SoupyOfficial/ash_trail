// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LogDetailModel _$LogDetailModelFromJson(Map<String, dynamic> json) {
  return _LogDetailModel.fromJson(json);
}

/// @nodoc
mixin _$LogDetailModel {
  SmokeLog get log => throw _privateConstructorUsedError;
  List<Tag> get tags => throw _privateConstructorUsedError;
  List<Reason> get reasons => throw _privateConstructorUsedError;
  Method? get method => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LogDetailModelCopyWith<LogDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogDetailModelCopyWith<$Res> {
  factory $LogDetailModelCopyWith(
          LogDetailModel value, $Res Function(LogDetailModel) then) =
      _$LogDetailModelCopyWithImpl<$Res, LogDetailModel>;
  @useResult
  $Res call(
      {SmokeLog log, List<Tag> tags, List<Reason> reasons, Method? method});

  $SmokeLogCopyWith<$Res> get log;
  $MethodCopyWith<$Res>? get method;
}

/// @nodoc
class _$LogDetailModelCopyWithImpl<$Res, $Val extends LogDetailModel>
    implements $LogDetailModelCopyWith<$Res> {
  _$LogDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? log = null,
    Object? tags = null,
    Object? reasons = null,
    Object? method = freezed,
  }) {
    return _then(_value.copyWith(
      log: null == log
          ? _value.log
          : log // ignore: cast_nullable_to_non_nullable
              as SmokeLog,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
      reasons: null == reasons
          ? _value.reasons
          : reasons // ignore: cast_nullable_to_non_nullable
              as List<Reason>,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as Method?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SmokeLogCopyWith<$Res> get log {
    return $SmokeLogCopyWith<$Res>(_value.log, (value) {
      return _then(_value.copyWith(log: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MethodCopyWith<$Res>? get method {
    if (_value.method == null) {
      return null;
    }

    return $MethodCopyWith<$Res>(_value.method!, (value) {
      return _then(_value.copyWith(method: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LogDetailModelImplCopyWith<$Res>
    implements $LogDetailModelCopyWith<$Res> {
  factory _$$LogDetailModelImplCopyWith(_$LogDetailModelImpl value,
          $Res Function(_$LogDetailModelImpl) then) =
      __$$LogDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SmokeLog log, List<Tag> tags, List<Reason> reasons, Method? method});

  @override
  $SmokeLogCopyWith<$Res> get log;
  @override
  $MethodCopyWith<$Res>? get method;
}

/// @nodoc
class __$$LogDetailModelImplCopyWithImpl<$Res>
    extends _$LogDetailModelCopyWithImpl<$Res, _$LogDetailModelImpl>
    implements _$$LogDetailModelImplCopyWith<$Res> {
  __$$LogDetailModelImplCopyWithImpl(
      _$LogDetailModelImpl _value, $Res Function(_$LogDetailModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? log = null,
    Object? tags = null,
    Object? reasons = null,
    Object? method = freezed,
  }) {
    return _then(_$LogDetailModelImpl(
      log: null == log
          ? _value.log
          : log // ignore: cast_nullable_to_non_nullable
              as SmokeLog,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<Tag>,
      reasons: null == reasons
          ? _value._reasons
          : reasons // ignore: cast_nullable_to_non_nullable
              as List<Reason>,
      method: freezed == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as Method?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogDetailModelImpl extends _LogDetailModel {
  const _$LogDetailModelImpl(
      {required this.log,
      final List<Tag> tags = const [],
      final List<Reason> reasons = const [],
      this.method})
      : _tags = tags,
        _reasons = reasons,
        super._();

  factory _$LogDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogDetailModelImplFromJson(json);

  @override
  final SmokeLog log;
  final List<Tag> _tags;
  @override
  @JsonKey()
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<Reason> _reasons;
  @override
  @JsonKey()
  List<Reason> get reasons {
    if (_reasons is EqualUnmodifiableListView) return _reasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reasons);
  }

  @override
  final Method? method;

  @override
  String toString() {
    return 'LogDetailModel(log: $log, tags: $tags, reasons: $reasons, method: $method)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogDetailModelImpl &&
            (identical(other.log, log) || other.log == log) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._reasons, _reasons) &&
            (identical(other.method, method) || other.method == method));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      log,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_reasons),
      method);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LogDetailModelImplCopyWith<_$LogDetailModelImpl> get copyWith =>
      __$$LogDetailModelImplCopyWithImpl<_$LogDetailModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogDetailModelImplToJson(
      this,
    );
  }
}

abstract class _LogDetailModel extends LogDetailModel {
  const factory _LogDetailModel(
      {required final SmokeLog log,
      final List<Tag> tags,
      final List<Reason> reasons,
      final Method? method}) = _$LogDetailModelImpl;
  const _LogDetailModel._() : super._();

  factory _LogDetailModel.fromJson(Map<String, dynamic> json) =
      _$LogDetailModelImpl.fromJson;

  @override
  SmokeLog get log;
  @override
  List<Tag> get tags;
  @override
  List<Reason> get reasons;
  @override
  Method? get method;
  @override
  @JsonKey(ignore: true)
  _$$LogDetailModelImplCopyWith<_$LogDetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
