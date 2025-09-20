// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_element_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UiElementModelImpl _$$UiElementModelImplFromJson(Map<String, dynamic> json) =>
    _$UiElementModelImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      type: json['type'] as String,
      isInteractive: json['isInteractive'] as bool,
      semanticLabel: json['semanticLabel'] as String?,
      hasAlternativeAccess: json['hasAlternativeAccess'] as bool?,
    );

Map<String, dynamic> _$$UiElementModelImplToJson(
        _$UiElementModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'left': instance.left,
      'top': instance.top,
      'width': instance.width,
      'height': instance.height,
      'type': instance.type,
      'isInteractive': instance.isInteractive,
      'semanticLabel': instance.semanticLabel,
      'hasAlternativeAccess': instance.hasAlternativeAccess,
    };
