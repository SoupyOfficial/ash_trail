// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LogDetailModelImpl _$$LogDetailModelImplFromJson(Map<String, dynamic> json) =>
    _$LogDetailModelImpl(
      log: SmokeLog.fromJson(json['log'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => Reason.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      method: json['method'] == null
          ? null
          : Method.fromJson(json['method'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LogDetailModelImplToJson(
        _$LogDetailModelImpl instance) =>
    <String, dynamic>{
      'log': instance.log,
      'tags': instance.tags,
      'reasons': instance.reasons,
      'method': instance.method,
    };
