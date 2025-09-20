// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smoke_log_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmokeLogDtoImpl _$$SmokeLogDtoImplFromJson(Map<String, dynamic> json) =>
    _$SmokeLogDtoImpl(
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
      isDeleted: json['isDeleted'] as bool? ?? false,
      isPendingSync: json['isPendingSync'] as bool? ?? false,
    );

Map<String, dynamic> _$$SmokeLogDtoImplToJson(_$SmokeLogDtoImpl instance) =>
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
      'isDeleted': instance.isDeleted,
      'isPendingSync': instance.isPendingSync,
    };
