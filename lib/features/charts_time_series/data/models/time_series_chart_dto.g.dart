// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_series_chart_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeSeriesChartDtoImpl _$$TimeSeriesChartDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$TimeSeriesChartDtoImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      aggregation: json['aggregation'] as String,
      metric: json['metric'] as String,
      smoothing: json['smoothing'] as String,
      dataPoints: (json['dataPoints'] as List<dynamic>)
          .map((e) => ChartDataPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      smoothingWindow: (json['smoothingWindow'] as num?)?.toInt(),
      visibleTags: (json['visibleTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TimeSeriesChartDtoImplToJson(
        _$TimeSeriesChartDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'title': instance.title,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'aggregation': instance.aggregation,
      'metric': instance.metric,
      'smoothing': instance.smoothing,
      'dataPoints': instance.dataPoints,
      'smoothingWindow': instance.smoothingWindow,
      'visibleTags': instance.visibleTags,
      'createdAt': instance.createdAt.toIso8601String(),
    };
