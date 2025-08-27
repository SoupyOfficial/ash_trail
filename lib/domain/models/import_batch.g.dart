// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_batch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImportBatchImpl _$$ImportBatchImplFromJson(Map<String, dynamic> json) =>
    _$ImportBatchImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      source: json['source'] as String,
      fileName: json['fileName'] as String?,
      countInserted: (json['countInserted'] as num).toInt(),
      countFailed: (json['countFailed'] as num).toInt(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      finishedAt: json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
      log: json['log'] as String?,
    );

Map<String, dynamic> _$$ImportBatchImplToJson(_$ImportBatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'source': instance.source,
      'fileName': instance.fileName,
      'countInserted': instance.countInserted,
      'countFailed': instance.countFailed,
      'startedAt': instance.startedAt.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
      'log': instance.log,
    };
