// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Method _$MethodFromJson(Map<String, dynamic> json) => Method(
  id: json['id'] as String,
  accountId: json['accountId'] as String?,
  name: json['name'] as String,
  category: json['category'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MethodToJson(Method instance) => <String, dynamic>{
  'id': instance.id,
  'accountId': instance.accountId,
  'name': instance.name,
  'category': instance.category,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$MethodImpl _$$MethodImplFromJson(Map<String, dynamic> json) => _$MethodImpl(
  id: json['id'] as String,
  accountId: json['accountId'] as String?,
  name: json['name'] as String,
  category: json['category'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$MethodImplToJson(_$MethodImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'name': instance.name,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
