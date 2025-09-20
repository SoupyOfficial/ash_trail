// Data model for audit recommendation persistence
// Maps between domain AuditRecommendation and storage format

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/reachability_audit_report.dart';

part 'audit_recommendation_model.freezed.dart';
part 'audit_recommendation_model.g.dart';

@freezed
class AuditRecommendationModel with _$AuditRecommendationModel {
  const factory AuditRecommendationModel({
    required String elementId,
    required String type,
    required String description,
    required int priority,
    String? suggestedFix,
  }) = _AuditRecommendationModel;

  const AuditRecommendationModel._();

  factory AuditRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$AuditRecommendationModelFromJson(json);

  AuditRecommendation toEntity() => AuditRecommendation(
        elementId: elementId,
        type: _typeFromString(type),
        description: description,
        priority: priority,
        suggestedFix: suggestedFix,
      );

  factory AuditRecommendationModel.fromEntity(AuditRecommendation entity) =>
      AuditRecommendationModel(
        elementId: entity.elementId,
        type: _typeToString(entity.type),
        description: entity.description,
        priority: entity.priority,
        suggestedFix: entity.suggestedFix,
      );
}

RecommendationType _typeFromString(String type) => switch (type) {
      'move_to_easy_reach' => RecommendationType.moveToEasyReach,
      'increase_touch_target' => RecommendationType.increaseTouchTarget,
      'add_accessibility_label' => RecommendationType.addAccessibilityLabel,
      'add_alternative_access' => RecommendationType.addAlternativeAccess,
      'improve_contrast' => RecommendationType.improveContrast,
      _ => RecommendationType.moveToEasyReach,
    };

String _typeToString(RecommendationType type) => switch (type) {
      RecommendationType.moveToEasyReach => 'move_to_easy_reach',
      RecommendationType.increaseTouchTarget => 'increase_touch_target',
      RecommendationType.addAccessibilityLabel => 'add_accessibility_label',
      RecommendationType.addAlternativeAccess => 'add_alternative_access',
      RecommendationType.improveContrast => 'improve_contrast',
    };
