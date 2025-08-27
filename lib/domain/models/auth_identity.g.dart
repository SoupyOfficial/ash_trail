// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthIdentityImpl _$$AuthIdentityImplFromJson(Map<String, dynamic> json) =>
    _$AuthIdentityImpl(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      provider: json['provider'] as String,
      providerUid: json['providerUid'] as String,
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AuthIdentityImplToJson(_$AuthIdentityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'provider': instance.provider,
      'providerUid': instance.providerUid,
      'email': instance.email,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
