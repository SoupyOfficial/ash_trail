// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siri_shortcuts_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SiriShortcutsModelImpl _$$SiriShortcutsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SiriShortcutsModelImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastDonatedAt: json['last_donated_at'] == null
          ? null
          : DateTime.parse(json['last_donated_at'] as String),
      invocationCount: (json['invocation_count'] as num?)?.toInt() ?? 0,
      isDonated: json['is_donated'] as bool? ?? false,
      customPhrase: json['custom_phrase'] as String?,
      lastInvokedAt: json['last_invoked_at'] == null
          ? null
          : DateTime.parse(json['last_invoked_at'] as String),
    );

Map<String, dynamic> _$$SiriShortcutsModelImplToJson(
        _$SiriShortcutsModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'created_at': instance.createdAt.toIso8601String(),
      'last_donated_at': instance.lastDonatedAt?.toIso8601String(),
      'invocation_count': instance.invocationCount,
      'is_donated': instance.isDonated,
      'custom_phrase': instance.customPhrase,
      'last_invoked_at': instance.lastInvokedAt?.toIso8601String(),
    };
