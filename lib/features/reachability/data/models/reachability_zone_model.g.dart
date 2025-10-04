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
      bounds: const _RectJsonConverter()
          .fromJson(json['bounds'] as Map<String, dynamic>),
      level: json['level'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$$ReachabilityZoneModelImplToJson(
        _$ReachabilityZoneModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bounds': const _RectJsonConverter().toJson(instance.bounds),
      'level': instance.level,
      'description': instance.description,
    };
