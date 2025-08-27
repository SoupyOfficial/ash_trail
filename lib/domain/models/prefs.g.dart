// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrefsImpl _$$PrefsImplFromJson(Map<String, dynamic> json) => _$PrefsImpl(
      accountId: json['accountId'] as String,
      defaultRange: json['defaultRange'] as String,
      unit: json['unit'] as String,
      analyticsOptIn: json['analyticsOptIn'] as bool,
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
      preferredTheme: json['preferredTheme'] as String,
      accentColor: json['accentColor'] as String?,
    );

Map<String, dynamic> _$$PrefsImplToJson(_$PrefsImpl instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'defaultRange': instance.defaultRange,
      'unit': instance.unit,
      'analyticsOptIn': instance.analyticsOptIn,
      'reminderTimes':
          instance.reminderTimes?.map((e) => e.toIso8601String()).toList(),
      'preferredTheme': instance.preferredTheme,
      'accentColor': instance.accentColor,
    };
