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
    required double left,
    required double top,
    required double width,
    required double height,
    required String type,
    required bool isInteractive,
    String? semanticLabel,
    bool? hasAlternativeAccess,
  }) = _UiElementModel;

  const UiElementModel._();

  factory UiElementModel.fromJson(Map<String, dynamic> json) =>
      _$UiElementModelFromJson(json);

  UiElement toEntity() => UiElement(
        id: id,
        label: label,
        bounds: Rect.fromLTWH(left, top, width, height),
        type: _typeFromString(type),
        isInteractive: isInteractive,
        semanticLabel: semanticLabel,
        hasAlternativeAccess: hasAlternativeAccess,
      );

  factory UiElementModel.fromEntity(UiElement entity) => UiElementModel(
        id: entity.id,
        label: entity.label,
        left: entity.bounds.left,
        top: entity.bounds.top,
        width: entity.bounds.width,
        height: entity.bounds.height,
        type: _typeToString(entity.type),
        isInteractive: entity.isInteractive,
        semanticLabel: entity.semanticLabel,
        hasAlternativeAccess: entity.hasAlternativeAccess,
      );
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
