// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logs_table_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LogFilterDtoImpl _$$LogFilterDtoImplFromJson(Map<String, dynamic> json) =>
    _$LogFilterDtoImpl(
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      methodIds: (json['methodIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      includeTagIds: (json['includeTagIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludeTagIds: (json['excludeTagIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      minMoodScore: (json['minMoodScore'] as num?)?.toInt(),
      maxMoodScore: (json['maxMoodScore'] as num?)?.toInt(),
      minPhysicalScore: (json['minPhysicalScore'] as num?)?.toInt(),
      maxPhysicalScore: (json['maxPhysicalScore'] as num?)?.toInt(),
      minDurationMs: (json['minDurationMs'] as num?)?.toInt(),
      maxDurationMs: (json['maxDurationMs'] as num?)?.toInt(),
      searchText: json['searchText'] as String?,
    );

Map<String, dynamic> _$$LogFilterDtoImplToJson(_$LogFilterDtoImpl instance) =>
    <String, dynamic>{
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'methodIds': instance.methodIds,
      'includeTagIds': instance.includeTagIds,
      'excludeTagIds': instance.excludeTagIds,
      'minMoodScore': instance.minMoodScore,
      'maxMoodScore': instance.maxMoodScore,
      'minPhysicalScore': instance.minPhysicalScore,
      'maxPhysicalScore': instance.maxPhysicalScore,
      'minDurationMs': instance.minDurationMs,
      'maxDurationMs': instance.maxDurationMs,
      'searchText': instance.searchText,
    };

_$LogSortDtoImpl _$$LogSortDtoImplFromJson(Map<String, dynamic> json) =>
    _$LogSortDtoImpl(
      field: json['field'] as String,
      order: json['order'] as String,
    );

Map<String, dynamic> _$$LogSortDtoImplToJson(_$LogSortDtoImpl instance) =>
    <String, dynamic>{
      'field': instance.field,
      'order': instance.order,
    };
