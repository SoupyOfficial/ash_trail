// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FilterPresetImpl _$$FilterPresetImplFromJson(Map<String, dynamic> json) =>
    _$FilterPresetImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      name: json['name'] as String,
      range: json['range'] as String,
      customStart: json['customStart'] == null
          ? null
          : DateTime.parse(json['customStart'] as String),
      customEnd: json['customEnd'] == null
          ? null
          : DateTime.parse(json['customEnd'] as String),
      includeTags: (json['includeTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludeTags: (json['excludeTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sort: json['sort'] as String,
      query: json['query'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$FilterPresetImplToJson(_$FilterPresetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'name': instance.name,
      'range': instance.range,
      'customStart': instance.customStart?.toIso8601String(),
      'customEnd': instance.customEnd?.toIso8601String(),
      'includeTags': instance.includeTags,
      'excludeTags': instance.excludeTags,
      'sort': instance.sort,
      'query': instance.query,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
