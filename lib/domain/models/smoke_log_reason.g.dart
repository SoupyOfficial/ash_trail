// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smoke_log_reason.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmokeLogReasonImpl _$$SmokeLogReasonImplFromJson(Map<String, dynamic> json) =>
    _$SmokeLogReasonImpl(
      id: json['id'] as String,
      smokeLogId: json['smokeLogId'] as String,
      reasonId: json['reasonId'] as String,
      accountId: json['accountId'] as String,
      ts: DateTime.parse(json['ts'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SmokeLogReasonImplToJson(
        _$SmokeLogReasonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'smokeLogId': instance.smokeLogId,
      'reasonId': instance.reasonId,
      'accountId': instance.accountId,
      'ts': instance.ts.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
