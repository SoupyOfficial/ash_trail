// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushToken _$PushTokenFromJson(Map<String, dynamic> json) => PushToken(
  id: json['id'] as String,
  deviceId: json['deviceId'] as String,
  platform: json['platform'] as String,
  token: json['token'] as String,
  active: json['active'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  revokedAt:
      json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt'] as String),
);

Map<String, dynamic> _$PushTokenToJson(PushToken instance) => <String, dynamic>{
  'id': instance.id,
  'deviceId': instance.deviceId,
  'platform': instance.platform,
  'token': instance.token,
  'active': instance.active,
  'createdAt': instance.createdAt.toIso8601String(),
  'revokedAt': instance.revokedAt?.toIso8601String(),
};

_$PushTokenImpl _$$PushTokenImplFromJson(Map<String, dynamic> json) =>
    _$PushTokenImpl(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      platform: json['platform'] as String,
      token: json['token'] as String,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      revokedAt:
          json['revokedAt'] == null
              ? null
              : DateTime.parse(json['revokedAt'] as String),
    );

Map<String, dynamic> _$$PushTokenImplToJson(_$PushTokenImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': instance.deviceId,
      'platform': instance.platform,
      'token': instance.token,
      'active': instance.active,
      'createdAt': instance.createdAt.toIso8601String(),
      'revokedAt': instance.revokedAt?.toIso8601String(),
    };
