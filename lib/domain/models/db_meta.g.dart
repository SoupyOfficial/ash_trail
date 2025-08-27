// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DbMeta _$DbMetaFromJson(Map<String, dynamic> json) => DbMeta(
  id: json['id'] as String,
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  migratedAt: DateTime.parse(json['migratedAt'] as String),
);

Map<String, dynamic> _$DbMetaToJson(DbMeta instance) => <String, dynamic>{
  'id': instance.id,
  'schemaVersion': instance.schemaVersion,
  'migratedAt': instance.migratedAt.toIso8601String(),
};

_$DbMetaImpl _$$DbMetaImplFromJson(Map<String, dynamic> json) => _$DbMetaImpl(
  id: json['id'] as String,
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  migratedAt: DateTime.parse(json['migratedAt'] as String),
);

Map<String, dynamic> _$$DbMetaImplToJson(_$DbMetaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schemaVersion': instance.schemaVersion,
      'migratedAt': instance.migratedAt.toIso8601String(),
    };
