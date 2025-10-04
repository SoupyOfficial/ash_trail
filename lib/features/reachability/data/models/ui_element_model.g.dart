// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_element_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UiElementModelImpl _$$UiElementModelImplFromJson(Map<String, dynamic> json) =>
    _$UiElementModelImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      bounds: const _RectJsonConverter()
          .fromJson(json['bounds'] as Map<String, dynamic>),
      type: json['type'] as String,
      isInteractive: json['isInteractive'] as bool,
      semanticLabel: json['semanticLabel'] as String?,
      hasAccessibilityLabel: json['hasAccessibilityLabel'] as bool?,
      hasAlternativeAccess: json['hasAlternativeAccess'] as bool?,
    );

Map<String, dynamic> _$$UiElementModelImplToJson(
        _$UiElementModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'bounds': const _RectJsonConverter().toJson(instance.bounds),
      'type': instance.type,
      'isInteractive': instance.isInteractive,
      'semanticLabel': instance.semanticLabel,
      'hasAccessibilityLabel': instance.hasAccessibilityLabel,
      'hasAlternativeAccess': instance.hasAlternativeAccess,
    };
