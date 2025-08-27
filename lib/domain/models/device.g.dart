// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  id: json['id'] as String,
  platform: json['platform'] as String,
  appVersion: json['appVersion'] as String,
  osVersion: json['osVersion'] as String?,
  model: json['model'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'id': instance.id,
  'platform': instance.platform,
  'appVersion': instance.appVersion,
  'osVersion': instance.osVersion,
  'model': instance.model,
  'createdAt': instance.createdAt.toIso8601String(),
};

_$DeviceImpl _$$DeviceImplFromJson(Map<String, dynamic> json) => _$DeviceImpl(
  id: json['id'] as String,
  platform: json['platform'] as String,
  appVersion: json['appVersion'] as String,
  osVersion: json['osVersion'] as String?,
  model: json['model'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$DeviceImplToJson(_$DeviceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': instance.platform,
      'appVersion': instance.appVersion,
      'osVersion': instance.osVersion,
      'model': instance.model,
      'createdAt': instance.createdAt.toIso8601String(),
    };
