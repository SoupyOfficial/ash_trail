// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiveActivityModelImpl _$$LiveActivityModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LiveActivityModelImpl(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      status: json['status'] as String,
      cancelReason: json['cancelReason'] as String?,
    );

Map<String, dynamic> _$$LiveActivityModelImplToJson(
        _$LiveActivityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'status': instance.status,
      'cancelReason': instance.cancelReason,
    };
