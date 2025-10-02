// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UiElement {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  Rect get bounds => throw _privateConstructorUsedError;
  UiElementType get type => throw _privateConstructorUsedError;
  bool get isInteractive => throw _privateConstructorUsedError;
  String? get semanticLabel => throw _privateConstructorUsedError;
  bool? get hasAlternativeAccess => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UiElementCopyWith<UiElement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UiElementCopyWith<$Res> {
  factory $UiElementCopyWith(UiElement value, $Res Function(UiElement) then) =
      _$UiElementCopyWithImpl<$Res, UiElement>;
  @useResult
  $Res call(
      {String id,
      String label,
      Rect bounds,
      UiElementType type,
      bool isInteractive,
      String? semanticLabel,
      bool? hasAlternativeAccess});
}

/// @nodoc
class _$UiElementCopyWithImpl<$Res, $Val extends UiElement>
    implements $UiElementCopyWith<$Res> {
  _$UiElementCopyWithImpl(this._value, this._then);

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
              as UiElementType,
      isInteractive: null == isInteractive
          ? _value.isInteractive
          : isInteractive // ignore: cast_nullable_to_non_nullable
              as bool,
      semanticLabel: freezed == semanticLabel
          ? _value.semanticLabel
          : semanticLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      hasAlternativeAccess: freezed == hasAlternativeAccess
          ? _value.hasAlternativeAccess
          : hasAlternativeAccess // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UiElementImplCopyWith<$Res>
    implements $UiElementCopyWith<$Res> {
  factory _$$UiElementImplCopyWith(
          _$UiElementImpl value, $Res Function(_$UiElementImpl) then) =
      __$$UiElementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      Rect bounds,
      UiElementType type,
      bool isInteractive,
      String? semanticLabel,
      bool? hasAlternativeAccess});
}

/// @nodoc
class __$$UiElementImplCopyWithImpl<$Res>
    extends _$UiElementCopyWithImpl<$Res, _$UiElementImpl>
    implements _$$UiElementImplCopyWith<$Res> {
  __$$UiElementImplCopyWithImpl(
      _$UiElementImpl _value, $Res Function(_$UiElementImpl) _then)
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
    Object? hasAlternativeAccess = freezed,
  }) {
    return _then(_$UiElementImpl(
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
              as UiElementType,
      isInteractive: null == isInteractive
          ? _value.isInteractive
          : isInteractive // ignore: cast_nullable_to_non_nullable
              as bool,
      semanticLabel: freezed == semanticLabel
          ? _value.semanticLabel
          : semanticLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      hasAlternativeAccess: freezed == hasAlternativeAccess
          ? _value.hasAlternativeAccess
          : hasAlternativeAccess // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$UiElementImpl extends _UiElement {
  const _$UiElementImpl(
      {required this.id,
      required this.label,
      required this.bounds,
      required this.type,
      required this.isInteractive,
      this.semanticLabel,
      this.hasAlternativeAccess})
      : super._();

  @override
  final String id;
  @override
  final String label;
  @override
  final Rect bounds;
  @override
  final UiElementType type;
  @override
  final bool isInteractive;
  @override
  final String? semanticLabel;
  @override
  final bool? hasAlternativeAccess;

  @override
  String toString() {
    return 'UiElement(id: $id, label: $label, bounds: $bounds, type: $type, isInteractive: $isInteractive, semanticLabel: $semanticLabel, hasAlternativeAccess: $hasAlternativeAccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UiElementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.bounds, bounds) || other.bounds == bounds) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isInteractive, isInteractive) ||
                other.isInteractive == isInteractive) &&
            (identical(other.semanticLabel, semanticLabel) ||
                other.semanticLabel == semanticLabel) &&
            (identical(other.hasAlternativeAccess, hasAlternativeAccess) ||
                other.hasAlternativeAccess == hasAlternativeAccess));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, label, bounds, type,
      isInteractive, semanticLabel, hasAlternativeAccess);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UiElementImplCopyWith<_$UiElementImpl> get copyWith =>
      __$$UiElementImplCopyWithImpl<_$UiElementImpl>(this, _$identity);
}

abstract class _UiElement extends UiElement {
  const factory _UiElement(
      {required final String id,
      required final String label,
      required final Rect bounds,
      required final UiElementType type,
      required final bool isInteractive,
      final String? semanticLabel,
      final bool? hasAlternativeAccess}) = _$UiElementImpl;
  const _UiElement._() : super._();

  @override
  String get id;
  @override
  String get label;
  @override
  Rect get bounds;
  @override
  UiElementType get type;
  @override
  bool get isInteractive;
  @override
  String? get semanticLabel;
  @override
  bool? get hasAlternativeAccess;
  @override
  @JsonKey(ignore: true)
  _$$UiElementImplCopyWith<_$UiElementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
