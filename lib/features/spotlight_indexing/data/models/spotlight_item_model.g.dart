// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotlight_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpotlightItemModelImpl _$$SpotlightItemModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpotlightItemModelImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      deepLink: json['deep_link'] as String,
      accountId: json['account_id'] as String,
      contentId: json['content_id'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$SpotlightItemModelImplToJson(
        _$SpotlightItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'keywords': instance.keywords,
      'deep_link': instance.deepLink,
      'account_id': instance.accountId,
      'content_id': instance.contentId,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'is_active': instance.isActive,
    };
