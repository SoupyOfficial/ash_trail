// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReminderImpl _$$ReminderImplFromJson(Map<String, dynamic> json) =>
    _$ReminderImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      time: DateTime.parse(json['time'] as String),
      days: (json['days'] as List<dynamic>).map((e) => e as String).toList(),
      enabled: json['enabled'] as bool,
      lastTriggeredAt:
          json['lastTriggeredAt'] == null
              ? null
              : DateTime.parse(json['lastTriggeredAt'] as String),
    );

Map<String, dynamic> _$$ReminderImplToJson(_$ReminderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'time': instance.time.toIso8601String(),
      'days': instance.days,
      'enabled': instance.enabled,
      'lastTriggeredAt': instance.lastTriggeredAt?.toIso8601String(),
    };
