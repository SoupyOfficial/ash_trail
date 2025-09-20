// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reachability_audit_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReachabilityAuditReportModelImpl _$$ReachabilityAuditReportModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ReachabilityAuditReportModelImpl(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      screenName: json['screenName'] as String,
      screenWidth: (json['screenWidth'] as num).toDouble(),
      screenHeight: (json['screenHeight'] as num).toDouble(),
      elements: (json['elements'] as List<dynamic>)
          .map((e) => UiElementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      zones: (json['zones'] as List<dynamic>)
          .map((e) => ReachabilityZoneModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary:
          AuditSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) =>
              AuditRecommendationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ReachabilityAuditReportModelImplToJson(
        _$ReachabilityAuditReportModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'screenName': instance.screenName,
      'screenWidth': instance.screenWidth,
      'screenHeight': instance.screenHeight,
      'elements': instance.elements,
      'zones': instance.zones,
      'summary': instance.summary,
      'recommendations': instance.recommendations,
    };
