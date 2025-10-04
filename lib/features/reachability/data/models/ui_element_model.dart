// Data model for UI element persistence
// Maps between domain UiElement and storage format

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/painting.dart';
import '../../domain/entities/ui_element.dart';

part 'ui_element_model.freezed.dart';
part 'ui_element_model.g.dart';

@freezed
class UiElementModel with _$UiElementModel {
  const factory UiElementModel({
    required String id,
    required String label,
    @_RectJsonConverter() required Rect bounds,
    required String type,
    required bool isInteractive,
    String? semanticLabel,
    bool? hasAccessibilityLabel,
    bool? hasAlternativeAccess,
  }) = _UiElementModel;

  const UiElementModel._();

  factory UiElementModel.fromJson(Map<String, dynamic> json) =>
      _$UiElementModelFromJson(json);

  UiElement toEntity() => UiElement(
        id: id,
        label: label,
        bounds: bounds,
        type: _typeFromString(type),
        isInteractive: isInteractive,
        semanticLabel: semanticLabel,
        hasAccessibilityLabel: hasAccessibilityLabel,
        hasAlternativeAccess: hasAlternativeAccess,
      );

  factory UiElementModel.fromEntity(UiElement entity) => UiElementModel(
        id: entity.id,
        label: entity.label,
        bounds: entity.bounds,
        type: _typeToString(entity.type),
        isInteractive: entity.isInteractive,
        semanticLabel: entity.semanticLabel,
        hasAccessibilityLabel: entity.hasAccessibilityLabel,
        hasAlternativeAccess: entity.hasAlternativeAccess,
      );
}

class _RectJsonConverter extends JsonConverter<Rect, Map<String, dynamic>> {
  const _RectJsonConverter();

  @override
  Rect fromJson(Map<String, dynamic> json) => Rect.fromLTWH(
        (json['left'] as num).toDouble(),
        (json['top'] as num).toDouble(),
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
      );

  @override
  Map<String, dynamic> toJson(Rect rect) => <String, dynamic>{
        'left': rect.left,
        'top': rect.top,
        'width': rect.width,
        'height': rect.height,
      };
}

UiElementType _typeFromString(String type) => switch (type) {
      'button' => UiElementType.button,
      'text_field' => UiElementType.textField,
      'slider' => UiElementType.slider,
      'toggle' => UiElementType.toggle,
      'navigation_item' => UiElementType.navigationItem,
      'action_button' => UiElementType.actionButton,
      'list_item' => UiElementType.listItem,
      'card' => UiElementType.card,
      _ => UiElementType.other,
    };

String _typeToString(UiElementType type) => switch (type) {
      UiElementType.button => 'button',
      UiElementType.textField => 'text_field',
      UiElementType.slider => 'slider',
      UiElementType.toggle => 'toggle',
      UiElementType.navigationItem => 'navigation_item',
      UiElementType.actionButton => 'action_button',
      UiElementType.listItem => 'list_item',
      UiElementType.card => 'card',
      UiElementType.other => 'other',
    };
