// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reachability_zone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReachabilityZoneModelImpl _$$ReachabilityZoneModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ReachabilityZoneModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      level: json['level'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$ReachabilityZoneModelImplToJson(
        _$ReachabilityZoneModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'left': instance.left,
      'top': instance.top,
      'width': instance.width,
      'height': instance.height,
      'level': instance.level,
      'description': instance.description,
    };
