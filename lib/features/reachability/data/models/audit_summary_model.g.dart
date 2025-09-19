// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditSummaryModelImpl _$$AuditSummaryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AuditSummaryModelImpl(
      totalElements: (json['totalElements'] as num).toInt(),
      interactiveElements: (json['interactiveElements'] as num).toInt(),
      elementsInEasyReach: (json['elementsInEasyReach'] as num).toInt(),
      elementsWithIssues: (json['elementsWithIssues'] as num).toInt(),
      avgTouchTargetSize: (json['avgTouchTargetSize'] as num).toDouble(),
      accessibilityIssues: (json['accessibilityIssues'] as num).toInt(),
    );

Map<String, dynamic> _$$AuditSummaryModelImplToJson(
        _$AuditSummaryModelImpl instance) =>
    <String, dynamic>{
      'totalElements': instance.totalElements,
      'interactiveElements': instance.interactiveElements,
      'elementsInEasyReach': instance.elementsInEasyReach,
      'elementsWithIssues': instance.elementsWithIssues,
      'avgTouchTargetSize': instance.avgTouchTargetSize,
      'accessibilityIssues': instance.accessibilityIssues,
    };
