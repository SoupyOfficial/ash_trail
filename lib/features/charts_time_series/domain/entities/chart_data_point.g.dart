// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_data_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChartDataPointImpl _$$ChartDataPointImplFromJson(Map<String, dynamic> json) =>
    _$ChartDataPointImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      totalDurationMs: (json['totalDurationMs'] as num).toInt(),
      averageMoodScore: (json['averageMoodScore'] as num?)?.toDouble(),
      averagePhysicalScore: (json['averagePhysicalScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ChartDataPointImplToJson(
        _$ChartDataPointImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'value': instance.value,
      'count': instance.count,
      'totalDurationMs': instance.totalDurationMs,
      'averageMoodScore': instance.averageMoodScore,
      'averagePhysicalScore': instance.averagePhysicalScore,
    };
