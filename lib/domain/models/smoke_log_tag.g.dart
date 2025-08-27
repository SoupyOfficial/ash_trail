// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smoke_log_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmokeLogTag _$SmokeLogTagFromJson(Map<String, dynamic> json) => SmokeLogTag(
  id: json['id'] as String,
  smokeLogId: json['smokeLogId'] as String,
  tagId: json['tagId'] as String,
  accountId: json['accountId'] as String,
  ts: DateTime.parse(json['ts'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SmokeLogTagToJson(SmokeLogTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'smokeLogId': instance.smokeLogId,
      'tagId': instance.tagId,
      'accountId': instance.accountId,
      'ts': instance.ts.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$SmokeLogTagImpl _$$SmokeLogTagImplFromJson(Map<String, dynamic> json) =>
    _$SmokeLogTagImpl(
      id: json['id'] as String,
      smokeLogId: json['smokeLogId'] as String,
      tagId: json['tagId'] as String,
      accountId: json['accountId'] as String,
      ts: DateTime.parse(json['ts'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SmokeLogTagImplToJson(_$SmokeLogTagImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'smokeLogId': instance.smokeLogId,
      'tagId': instance.tagId,
      'accountId': instance.accountId,
      'ts': instance.ts.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
