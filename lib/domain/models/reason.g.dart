// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reason.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reason _$ReasonFromJson(Map<String, dynamic> json) => Reason(
  id: json['id'] as String,
  accountId: json['accountId'] as String?,
  name: json['name'] as String,
  enabled: json['enabled'] as bool,
  orderIndex: (json['orderIndex'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReasonToJson(Reason instance) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'name': instance.name,
  'enabled': instance.enabled,
  'orderIndex': instance.orderIndex,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$ReasonImpl _$$ReasonImplFromJson(Map<String, dynamic> json) => _$ReasonImpl(
  id: json['id'] as String,
  accountId: json['accountId'] as String?,
  name: json['name'] as String,
  enabled: json['enabled'] as bool,
  orderIndex: (json['orderIndex'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ReasonImplToJson(_$ReasonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'name': instance.name,
      'enabled': instance.enabled,
      'orderIndex': instance.orderIndex,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
