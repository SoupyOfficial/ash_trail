// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WidgetDataModelImpl _$$WidgetDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WidgetDataModelImpl(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      size: json['size'] as String,
      tapAction: json['tap_action'] as String,
      todayHitCount: (json['today_hit_count'] as num).toInt(),
      currentStreak: (json['current_streak'] as num).toInt(),
      lastSyncAt: DateTime.parse(json['last_sync_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      showStreak: json['show_streak'] as bool?,
      showLastSync: json['show_last_sync'] as bool?,
    );

Map<String, dynamic> _$$WidgetDataModelImplToJson(
        _$WidgetDataModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'size': instance.size,
      'tap_action': instance.tapAction,
      'today_hit_count': instance.todayHitCount,
      'current_streak': instance.currentStreak,
      'last_sync_at': instance.lastSyncAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'show_streak': instance.showStreak,
      'show_last_sync': instance.showLastSync,
    };
