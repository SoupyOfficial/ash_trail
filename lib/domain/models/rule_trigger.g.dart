// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_trigger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleTrigger _$RuleTriggerFromJson(Map<String, dynamic> json) => RuleTrigger(
  id: json['id'] as String,
  ruleId: json['ruleId'] as String,
  triggeredAt: DateTime.parse(json['triggeredAt'] as String),
  context: json['context'] as Map<String, dynamic>,
);

Map<String, dynamic> _$RuleTriggerToJson(RuleTrigger instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ruleId': instance.ruleId,
      'triggeredAt': instance.triggeredAt.toIso8601String(),
      'context': instance.context,
    };

_$RuleTriggerImpl _$$RuleTriggerImplFromJson(Map<String, dynamic> json) =>
    _$RuleTriggerImpl(
      id: json['id'] as String,
      ruleId: json['ruleId'] as String,
      triggeredAt: DateTime.parse(json['triggeredAt'] as String),
      context: json['context'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$RuleTriggerImplToJson(_$RuleTriggerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ruleId': instance.ruleId,
      'triggeredAt': instance.triggeredAt.toIso8601String(),
      'context': instance.context,
    };
