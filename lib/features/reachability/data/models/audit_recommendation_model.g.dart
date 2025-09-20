// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditRecommendationModelImpl _$$AuditRecommendationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AuditRecommendationModelImpl(
      elementId: json['elementId'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      priority: (json['priority'] as num).toInt(),
      suggestedFix: json['suggestedFix'] as String?,
    );

Map<String, dynamic> _$$AuditRecommendationModelImplToJson(
        _$AuditRecommendationModelImpl instance) =>
    <String, dynamic>{
      'elementId': instance.elementId,
      'type': instance.type,
      'description': instance.description,
      'priority': instance.priority,
      'suggestedFix': instance.suggestedFix,
    };
