// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_op.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncOpImpl _$$SyncOpImplFromJson(Map<String, dynamic> json) => _$SyncOpImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      entity: json['entity'] as String,
      op: json['op'] as String,
      recordId: json['recordId'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      status: json['status'] as String,
      attempts: (json['attempts'] as num).toInt(),
      lastError: json['lastError'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SyncOpImplToJson(_$SyncOpImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'entity': instance.entity,
      'op': instance.op,
      'recordId': instance.recordId,
      'payload': instance.payload,
      'status': instance.status,
      'attempts': instance.attempts,
      'lastError': instance.lastError,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
