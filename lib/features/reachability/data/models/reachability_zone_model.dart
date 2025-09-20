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
    required double left,
    required double top,
    required double width,
    required double height,
    required String level,
    required String description,
  }) = _ReachabilityZoneModel;

  const ReachabilityZoneModel._();

  factory ReachabilityZoneModel.fromJson(Map<String, dynamic> json) =>
      _$ReachabilityZoneModelFromJson(json);

  ReachabilityZone toEntity() => ReachabilityZone(
        id: id,
        name: name,
        bounds: Rect.fromLTWH(left, top, width, height),
        level: _levelFromString(level),
        description: description,
      );

  factory ReachabilityZoneModel.fromEntity(ReachabilityZone entity) =>
      ReachabilityZoneModel(
        id: entity.id,
        name: entity.name,
        left: entity.bounds.left,
        top: entity.bounds.top,
        width: entity.bounds.width,
        height: entity.bounds.height,
        level: _levelToString(entity.level),
        description: entity.description,
      );
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
