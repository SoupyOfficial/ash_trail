// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportItem _$ImportItemFromJson(Map<String, dynamic> json) => ImportItem(
  id: json['id'] as String,
  batchId: json['batchId'] as String,
  status: json['status'] as String,
  raw: json['raw'] as Map<String, dynamic>,
  error: json['error'] as String?,
);

Map<String, dynamic> _$ImportItemToJson(ImportItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'batchId': instance.batchId,
      'status': instance.status,
      'raw': instance.raw,
      'error': instance.error,
    };

_$ImportItemImpl _$$ImportItemImplFromJson(Map<String, dynamic> json) =>
    _$ImportItemImpl(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      status: json['status'] as String,
      raw: json['raw'] as Map<String, dynamic>,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$ImportItemImplToJson(_$ImportItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'batchId': instance.batchId,
      'status': instance.status,
      'raw': instance.raw,
      'error': instance.error,
    };
