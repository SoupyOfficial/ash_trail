// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncStateImpl _$$SyncStateImplFromJson(Map<String, dynamic> json) =>
    _$SyncStateImpl(
      accountId: json['accountId'] as String,
      lastPulledAt: json['lastPulledAt'] == null
          ? null
          : DateTime.parse(json['lastPulledAt'] as String),
      lastPushedAt: json['lastPushedAt'] == null
          ? null
          : DateTime.parse(json['lastPushedAt'] as String),
      remoteVersion: json['remoteVersion'] as String?,
      tombstoneWatermark: json['tombstoneWatermark'] as String?,
      backoffUntil: json['backoffUntil'] == null
          ? null
          : DateTime.parse(json['backoffUntil'] as String),
    );

Map<String, dynamic> _$$SyncStateImplToJson(_$SyncStateImpl instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'lastPulledAt': instance.lastPulledAt?.toIso8601String(),
      'lastPushedAt': instance.lastPushedAt?.toIso8601String(),
      'remoteVersion': instance.remoteVersion,
      'tombstoneWatermark': instance.tombstoneWatermark,
      'backoffUntil': instance.backoffUntil?.toIso8601String(),
    };
