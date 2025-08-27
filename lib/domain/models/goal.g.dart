// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Goal _$GoalFromJson(Map<String, dynamic> json) => Goal(
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  type: json['type'] as String,
  target: (json['target'] as num).toInt(),
  window: json['window'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate:
      json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
  active: json['active'] as bool,
  progress: (json['progress'] as num?)?.toInt(),
  achievedAt:
      json['achievedAt'] == null
          ? null
          : DateTime.parse(json['achievedAt'] as String),
);

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'type': instance.type,
  'target': instance.target,
  'window': instance.window,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'active': instance.active,
  'progress': instance.progress,
  'achievedAt': instance.achievedAt?.toIso8601String(),
};

_$GoalImpl _$$GoalImplFromJson(Map<String, dynamic> json) => _$GoalImpl(
  id: json['id'] as String,
  accountId: json['accountId'] as String,
  type: json['type'] as String,
  target: (json['target'] as num).toInt(),
  window: json['window'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate:
      json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
  active: json['active'] as bool,
  progress: (json['progress'] as num?)?.toInt(),
  achievedAt:
      json['achievedAt'] == null
          ? null
          : DateTime.parse(json['achievedAt'] as String),
);

Map<String, dynamic> _$$GoalImplToJson(_$GoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'type': instance.type,
      'target': instance.target,
      'window': instance.window,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'active': instance.active,
      'progress': instance.progress,
      'achievedAt': instance.achievedAt?.toIso8601String(),
    };
