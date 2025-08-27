// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smoke_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmokeLog _$SmokeLogFromJson(Map<String, dynamic> json) => SmokeLog(
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  ts: DateTime.parse(json['ts'] as String),
  durationMs: (json['durationMs'] as num).toInt(),
  methodId: json['methodId'] as String?,
  potency: (json['potency'] as num?)?.toInt(),
  moodScore: (json['moodScore'] as num).toInt(),
  physicalScore: (json['physicalScore'] as num).toInt(),
  notes: json['notes'] as String?,
  deviceLocalId: json['deviceLocalId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SmokeLogToJson(SmokeLog instance) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'ts': instance.ts.toIso8601String(),
  'durationMs': instance.durationMs,
  'methodId': instance.methodId,
  'potency': instance.potency,
  'moodScore': instance.moodScore,
  'physicalScore': instance.physicalScore,
  'notes': instance.notes,
  'deviceLocalId': instance.deviceLocalId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$SmokeLogImpl _$$SmokeLogImplFromJson(Map<String, dynamic> json) =>
    _$SmokeLogImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      ts: DateTime.parse(json['ts'] as String),
      durationMs: (json['durationMs'] as num).toInt(),
      methodId: json['methodId'] as String?,
      potency: (json['potency'] as num?)?.toInt(),
      moodScore: (json['moodScore'] as num).toInt(),
      physicalScore: (json['physicalScore'] as num).toInt(),
      notes: json['notes'] as String?,
      deviceLocalId: json['deviceLocalId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SmokeLogImplToJson(_$SmokeLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'ts': instance.ts.toIso8601String(),
      'durationMs': instance.durationMs,
      'methodId': instance.methodId,
      'potency': instance.potency,
      'moodScore': instance.moodScore,
      'physicalScore': instance.physicalScore,
      'notes': instance.notes,
      'deviceLocalId': instance.deviceLocalId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
