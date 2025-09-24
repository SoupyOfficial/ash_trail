// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_series_chart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeSeriesChartImpl _$$TimeSeriesChartImplFromJson(
        Map<String, dynamic> json) =>
    _$TimeSeriesChartImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      aggregation: $enumDecode(_$ChartAggregationEnumMap, json['aggregation']),
      metric: $enumDecode(_$ChartMetricEnumMap, json['metric']),
      smoothing: $enumDecode(_$ChartSmoothingEnumMap, json['smoothing']),
      dataPoints: (json['dataPoints'] as List<dynamic>)
          .map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      smoothingWindow: (json['smoothingWindow'] as num?)?.toInt(),
      visibleTags: (json['visibleTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TimeSeriesChartImplToJson(
        _$TimeSeriesChartImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'title': instance.title,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'aggregation': _$ChartAggregationEnumMap[instance.aggregation]!,
      'metric': _$ChartMetricEnumMap[instance.metric]!,
      'smoothing': _$ChartSmoothingEnumMap[instance.smoothing]!,
      'dataPoints': instance.dataPoints,
      'smoothingWindow': instance.smoothingWindow,
      'visibleTags': instance.visibleTags,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ChartAggregationEnumMap = {
  ChartAggregation.daily: 'daily',
  ChartAggregation.weekly: 'weekly',
  ChartAggregation.monthly: 'monthly',
};

const _$ChartMetricEnumMap = {
  ChartMetric.count: 'count',
  ChartMetric.duration: 'duration',
  ChartMetric.averageDuration: 'averageDuration',
  ChartMetric.moodScore: 'moodScore',
  ChartMetric.physicalScore: 'physicalScore',
};

const _$ChartSmoothingEnumMap = {
  ChartSmoothing.none: 'none',
  ChartSmoothing.movingAverage: 'movingAverage',
  ChartSmoothing.cumulative: 'cumulative',
};

_$ChartConfigImpl _$$ChartConfigImplFromJson(Map<String, dynamic> json) =>
    _$ChartConfigImpl(
      accountId: json['accountId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      aggregation: $enumDecode(_$ChartAggregationEnumMap, json['aggregation']),
      metric: $enumDecode(_$ChartMetricEnumMap, json['metric']),
      smoothing: $enumDecode(_$ChartSmoothingEnumMap, json['smoothing']),
      smoothingWindow: (json['smoothingWindow'] as num?)?.toInt() ?? 7,
      visibleTags: (json['visibleTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$ChartConfigImplToJson(_$ChartConfigImpl instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'aggregation': _$ChartAggregationEnumMap[instance.aggregation]!,
      'metric': _$ChartMetricEnumMap[instance.metric]!,
      'smoothing': _$ChartSmoothingEnumMap[instance.smoothing]!,
      'smoothingWindow': instance.smoothingWindow,
      'visibleTags': instance.visibleTags,
    };
