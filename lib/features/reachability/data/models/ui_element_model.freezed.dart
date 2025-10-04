// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_element_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UiElementModel _$UiElementModelFromJson(Map<String, dynamic> json) {
  return _UiElementModel.fromJson(json);
}

/// @nodoc
mixin _$UiElementModel {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  @_RectJsonConverter()
  Rect get bounds => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  bool get isInteractive => throw _privateConstructorUsedError;
  String? get semanticLabel => throw _privateConstructorUsedError;
  bool? get hasAccessibilityLabel => throw _privateConstructorUsedError;
  bool? get hasAlternativeAccess => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UiElementModelCopyWith<UiElementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UiElementModelCopyWith<$Res> {
  factory $UiElementModelCopyWith(
          UiElementModel value, $Res Function(UiElementModel) then) =
      _$UiElementModelCopyWithImpl<$Res, UiElementModel>;
  @useResult
  $Res call(
      {String id,
      String label,
      @_RectJsonConverter() Rect bounds,
      String type,
      bool isInteractive,
      String? semanticLabel,
      bool? hasAccessibilityLabel,
      bool? hasAlternativeAccess});
}

/// @nodoc
class _$UiElementModelCopyWithImpl<$Res, $Val extends UiElementModel>
    implements $UiElementModelCopyWith<$Res> {
  _$UiElementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? bounds = null,
    Object? type = null,
    Object? isInteractive = null,
    Object? semanticLabel = freezed,
    Object? hasAccessibilityLabel = freezed,
    Object? hasAlternativeAccess = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      bounds: null == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isInteractive: null == isInteractive
          ? _value.isInteractive
          : isInteractive // ignore: cast_nullable_to_non_nullable
              as bool,
      semanticLabel: freezed == semanticLabel
          ? _value.semanticLabel
          : semanticLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      hasAccessibilityLabel: freezed == hasAccessibilityLabel
          ? _value.hasAccessibilityLabel
          : hasAccessibilityLabel // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasAlternativeAccess: freezed == hasAlternativeAccess
          ? _value.hasAlternativeAccess
          : hasAlternativeAccess // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UiElementModelImplCopyWith<$Res>
    implements $UiElementModelCopyWith<$Res> {
  factory _$$UiElementModelImplCopyWith(_$UiElementModelImpl value,
          $Res Function(_$UiElementModelImpl) then) =
      __$$UiElementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      @_RectJsonConverter() Rect bounds,
      String type,
      bool isInteractive,
      String? semanticLabel,
      bool? hasAccessibilityLabel,
      bool? hasAlternativeAccess});
}

/// @nodoc
class __$$UiElementModelImplCopyWithImpl<$Res>
    extends _$UiElementModelCopyWithImpl<$Res, _$UiElementModelImpl>
    implements _$$UiElementModelImplCopyWith<$Res> {
  __$$UiElementModelImplCopyWithImpl(
      _$UiElementModelImpl _value, $Res Function(_$UiElementModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? bounds = null,
    Object? type = null,
    Object? isInteractive = null,
    Object? semanticLabel = freezed,
    Object? hasAccessibilityLabel = freezed,
    Object? hasAlternativeAccess = freezed,
  }) {
    return _then(_$UiElementModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      bounds: null == bounds
          ? _value.bounds
          : bounds // ignore: cast_nullable_to_non_nullable
              as Rect,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isInteractive: null == isInteractive
          ? _value.isInteractive
          : isInteractive // ignore: cast_nullable_to_non_nullable
              as bool,
      semanticLabel: freezed == semanticLabel
          ? _value.semanticLabel
          : semanticLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      hasAccessibilityLabel: freezed == hasAccessibilityLabel
          ? _value.hasAccessibilityLabel
          : hasAccessibilityLabel // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasAlternativeAccess: freezed == hasAlternativeAccess
          ? _value.hasAlternativeAccess
          : hasAlternativeAccess // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UiElementModelImpl extends _UiElementModel {
  const _$UiElementModelImpl(
      {required this.id,
      required this.label,
      @_RectJsonConverter() required this.bounds,
      required this.type,
      required this.isInteractive,
      this.semanticLabel,
      this.hasAccessibilityLabel,
      this.hasAlternativeAccess})
      : super._();

  factory _$UiElementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UiElementModelImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  @_RectJsonConverter()
  final Rect bounds;
  @override
  final String type;
  @override
  final bool isInteractive;
  @override
  final String? semanticLabel;
  @override
  final bool? hasAccessibilityLabel;
  @override
  final bool? hasAlternativeAccess;

  @override
  String toString() {
    return 'UiElementModel(id: $id, label: $label, bounds: $bounds, type: $type, isInteractive: $isInteractive, semanticLabel: $semanticLabel, hasAccessibilityLabel: $hasAccessibilityLabel, hasAlternativeAccess: $hasAlternativeAccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UiElementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.bounds, bounds) || other.bounds == bounds) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isInteractive, isInteractive) ||
                other.isInteractive == isInteractive) &&
            (identical(other.semanticLabel, semanticLabel) ||
                other.semanticLabel == semanticLabel) &&
            (identical(other.hasAccessibilityLabel, hasAccessibilityLabel) ||
                other.hasAccessibilityLabel == hasAccessibilityLabel) &&
            (identical(other.hasAlternativeAccess, hasAlternativeAccess) ||
                other.hasAlternativeAccess == hasAlternativeAccess));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      label,
      bounds,
      type,
      isInteractive,
      semanticLabel,
      hasAccessibilityLabel,
      hasAlternativeAccess);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UiElementModelImplCopyWith<_$UiElementModelImpl> get copyWith =>
      __$$UiElementModelImplCopyWithImpl<_$UiElementModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UiElementModelImplToJson(
      this,
    );
  }
}

abstract class _UiElementModel extends UiElementModel {
  const factory _UiElementModel(
      {required final String id,
      required final String label,
      @_RectJsonConverter() required final Rect bounds,
      required final String type,
      required final bool isInteractive,
      final String? semanticLabel,
      final bool? hasAccessibilityLabel,
      final bool? hasAlternativeAccess}) = _$UiElementModelImpl;
  const _UiElementModel._() : super._();

  factory _UiElementModel.fromJson(Map<String, dynamic> json) =
      _$UiElementModelImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  @_RectJsonConverter()
  Rect get bounds;
  @override
  String get type;
  @override
  bool get isInteractive;
  @override
  String? get semanticLabel;
  @override
  bool? get hasAccessibilityLabel;
  @override
  bool? get hasAlternativeAccess;
  @override
  @JsonKey(ignore: true)
  _$$UiElementModelImplCopyWith<_$UiElementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
