// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_recommendation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuditRecommendationModel _$AuditRecommendationModelFromJson(
    Map<String, dynamic> json) {
  return _AuditRecommendationModel.fromJson(json);
}

/// @nodoc
mixin _$AuditRecommendationModel {
  String get elementId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  String? get suggestedFix => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuditRecommendationModelCopyWith<AuditRecommendationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditRecommendationModelCopyWith<$Res> {
  factory $AuditRecommendationModelCopyWith(AuditRecommendationModel value,
          $Res Function(AuditRecommendationModel) then) =
      _$AuditRecommendationModelCopyWithImpl<$Res, AuditRecommendationModel>;
  @useResult
  $Res call(
      {String elementId,
      String type,
      String description,
      int priority,
      String? suggestedFix});
}

/// @nodoc
class _$AuditRecommendationModelCopyWithImpl<$Res,
        $Val extends AuditRecommendationModel>
    implements $AuditRecommendationModelCopyWith<$Res> {
  _$AuditRecommendationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? elementId = null,
    Object? type = null,
    Object? description = null,
    Object? priority = null,
    Object? suggestedFix = freezed,
  }) {
    return _then(_value.copyWith(
      elementId: null == elementId
          ? _value.elementId
          : elementId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      suggestedFix: freezed == suggestedFix
          ? _value.suggestedFix
          : suggestedFix // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuditRecommendationModelImplCopyWith<$Res>
    implements $AuditRecommendationModelCopyWith<$Res> {
  factory _$$AuditRecommendationModelImplCopyWith(
          _$AuditRecommendationModelImpl value,
          $Res Function(_$AuditRecommendationModelImpl) then) =
      __$$AuditRecommendationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String elementId,
      String type,
      String description,
      int priority,
      String? suggestedFix});
}

/// @nodoc
class __$$AuditRecommendationModelImplCopyWithImpl<$Res>
    extends _$AuditRecommendationModelCopyWithImpl<$Res,
        _$AuditRecommendationModelImpl>
    implements _$$AuditRecommendationModelImplCopyWith<$Res> {
  __$$AuditRecommendationModelImplCopyWithImpl(
      _$AuditRecommendationModelImpl _value,
      $Res Function(_$AuditRecommendationModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? elementId = null,
    Object? type = null,
    Object? description = null,
    Object? priority = null,
    Object? suggestedFix = freezed,
  }) {
    return _then(_$AuditRecommendationModelImpl(
      elementId: null == elementId
          ? _value.elementId
          : elementId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      suggestedFix: freezed == suggestedFix
          ? _value.suggestedFix
          : suggestedFix // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditRecommendationModelImpl extends _AuditRecommendationModel {
  const _$AuditRecommendationModelImpl(
      {required this.elementId,
      required this.type,
      required this.description,
      required this.priority,
      this.suggestedFix})
      : super._();

  factory _$AuditRecommendationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditRecommendationModelImplFromJson(json);

  @override
  final String elementId;
  @override
  final String type;
  @override
  final String description;
  @override
  final int priority;
  @override
  final String? suggestedFix;

  @override
  String toString() {
    return 'AuditRecommendationModel(elementId: $elementId, type: $type, description: $description, priority: $priority, suggestedFix: $suggestedFix)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditRecommendationModelImpl &&
            (identical(other.elementId, elementId) ||
                other.elementId == elementId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.suggestedFix, suggestedFix) ||
                other.suggestedFix == suggestedFix));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, elementId, type, description, priority, suggestedFix);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditRecommendationModelImplCopyWith<_$AuditRecommendationModelImpl>
      get copyWith => __$$AuditRecommendationModelImplCopyWithImpl<
          _$AuditRecommendationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditRecommendationModelImplToJson(
      this,
    );
  }
}

abstract class _AuditRecommendationModel extends AuditRecommendationModel {
  const factory _AuditRecommendationModel(
      {required final String elementId,
      required final String type,
      required final String description,
      required final int priority,
      final String? suggestedFix}) = _$AuditRecommendationModelImpl;
  const _AuditRecommendationModel._() : super._();

  factory _AuditRecommendationModel.fromJson(Map<String, dynamic> json) =
      _$AuditRecommendationModelImpl.fromJson;

  @override
  String get elementId;
  @override
  String get type;
  @override
  String get description;
  @override
  int get priority;
  @override
  String? get suggestedFix;
  @override
  @JsonKey(ignore: true)
  _$$AuditRecommendationModelImplCopyWith<_$AuditRecommendationModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
