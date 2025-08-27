// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartView _$ChartViewFromJson(Map<String, dynamic> json) => ChartView(
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  title: json['title'] as String,
  range: json['range'] as String,
  customStart:
      json['customStart'] == null
          ? null
          : DateTime.parse(json['customStart'] as String),
  customEnd:
      json['customEnd'] == null
          ? null
          : DateTime.parse(json['customEnd'] as String),
  groupBy: json['groupBy'] as String,
  metric: json['metric'] as String,
  smoothing: json['smoothing'] as String,
  smoothingWindow: (json['smoothingWindow'] as num?)?.toInt(),
  visibleTags:
      (json['visibleTags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ChartViewToJson(ChartView instance) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'title': instance.title,
  'range': instance.range,
  'customStart': instance.customStart?.toIso8601String(),
  'customEnd': instance.customEnd?.toIso8601String(),
  'groupBy': instance.groupBy,
  'metric': instance.metric,
  'smoothing': instance.smoothing,
  'smoothingWindow': instance.smoothingWindow,
  'visibleTags': instance.visibleTags,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$ChartViewImpl _$$ChartViewImplFromJson(Map<String, dynamic> json) =>
    _$ChartViewImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      title: json['title'] as String,
      range: json['range'] as String,
      customStart:
          json['customStart'] == null
              ? null
              : DateTime.parse(json['customStart'] as String),
      customEnd:
          json['customEnd'] == null
              ? null
              : DateTime.parse(json['customEnd'] as String),
      groupBy: json['groupBy'] as String,
      metric: json['metric'] as String,
      smoothing: json['smoothing'] as String,
      smoothingWindow: (json['smoothingWindow'] as num?)?.toInt(),
      visibleTags:
          (json['visibleTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ChartViewImplToJson(_$ChartViewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'title': instance.title,
      'range': instance.range,
      'customStart': instance.customStart?.toIso8601String(),
      'customEnd': instance.customEnd?.toIso8601String(),
      'groupBy': instance.groupBy,
      'metric': instance.metric,
      'smoothing': instance.smoothing,
      'smoothingWindow': instance.smoothingWindow,
      'visibleTags': instance.visibleTags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
