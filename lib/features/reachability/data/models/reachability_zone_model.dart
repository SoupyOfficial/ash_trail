// Data model for reachability zone persistence
// Maps between domain ReachabilityZone and storage format

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/painting.dart';
import '../../domain/entities/reachability_zone.dart';

part 'reachability_zone_model.freezed.dart';
part 'reachability_zone_model.g.dart';

@freezed
class ReachabilityZoneModel with _$ReachabilityZoneModel {
  const factory ReachabilityZoneModel({
    required String id,
    required String name,
    @_RectJsonConverter() required Rect bounds,
    required String level,
    required String description,
  }) = _ReachabilityZoneModel;

  const ReachabilityZoneModel._();

  factory ReachabilityZoneModel.fromJson(Map<String, dynamic> json) =>
      _$ReachabilityZoneModelFromJson(json);

  ReachabilityZone toEntity() => ReachabilityZone(
        id: id,
        name: name,
        bounds: bounds,
        level: _levelFromString(level),
        description: description,
      );

  factory ReachabilityZoneModel.fromEntity(ReachabilityZone entity) =>
      ReachabilityZoneModel(
        id: entity.id,
        name: entity.name,
        bounds: entity.bounds,
        level: _levelToString(entity.level),
        description: entity.description,
      );
}

class _RectJsonConverter extends JsonConverter<Rect, Map<String, dynamic>> {
  const _RectJsonConverter();

  @override
  Rect fromJson(Map<String, dynamic> json) => Rect.fromLTWH(
        (json['left'] as num).toDouble(),
        (json['top'] as num).toDouble(),
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
      );

  @override
  Map<String, dynamic> toJson(Rect rect) => <String, dynamic>{
        'left': rect.left,
        'top': rect.top,
        'width': rect.width,
        'height': rect.height,
      };
}

ReachabilityLevel _levelFromString(String level) => switch (level) {
      'easy' => ReachabilityLevel.easy,
      'moderate' => ReachabilityLevel.moderate,
      'difficult' => ReachabilityLevel.difficult,
      'unreachable' => ReachabilityLevel.unreachable,
      _ => ReachabilityLevel.easy,
    };

String _levelToString(ReachabilityLevel level) => switch (level) {
      ReachabilityLevel.easy => 'easy',
      ReachabilityLevel.moderate => 'moderate',
      ReachabilityLevel.difficult => 'difficult',
      ReachabilityLevel.unreachable => 'unreachable',
    };
