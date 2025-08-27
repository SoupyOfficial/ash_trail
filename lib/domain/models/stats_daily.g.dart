// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_daily.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StatsDailyImpl _$$StatsDailyImplFromJson(Map<String, dynamic> json) =>
    _$StatsDailyImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      date: DateTime.parse(json['date'] as String),
      hitCount: (json['hitCount'] as num).toInt(),
      totalDurationMs: (json['totalDurationMs'] as num).toInt(),
      avgDurationMs: (json['avgDurationMs'] as num).toInt(),
    );

Map<String, dynamic> _$$StatsDailyImplToJson(_$StatsDailyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'date': instance.date.toIso8601String(),
      'hitCount': instance.hitCount,
      'totalDurationMs': instance.totalDurationMs,
      'avgDurationMs': instance.avgDurationMs,
    };
