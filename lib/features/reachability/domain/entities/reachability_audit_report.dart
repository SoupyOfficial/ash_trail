// Reachability audit report containing analysis results and recommendations
// Generated after performing ergonomics analysis on UI elements

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/painting.dart';
import 'reachability_zone.dart';
import 'ui_element.dart';

part 'reachability_audit_report.freezed.dart';

@freezed
class ReachabilityAuditReport with _$ReachabilityAuditReport {
  const ReachabilityAuditReport._();

  const factory ReachabilityAuditReport({
    required String id,
    required DateTime timestamp,
    required String screenName,
    required Size screenSize,
    required List<UiElement> elements,
    required List<ReachabilityZone> zones,
    required AuditSummary summary,
    List<AuditRecommendation>? recommendations,
  }) = _ReachabilityAuditReport;

  /// Get all interactive elements that are outside easy reach
  List<UiElement> get problemElements {
    return elements
        .where((element) => 
            element.isInteractive && 
            element.getReachabilityLevel(zones) != ReachabilityLevel.easy)
        .toList();
  }

  /// Get elements with touch target size issues
  List<UiElement> get touchTargetIssues {
    return elements
        .where((element) => !element.meetsTouchTargetSize)
        .toList();
  }

  /// Get elements with accessibility issues
  List<UiElement> get accessibilityIssues {
    return elements
        .where((element) => element.needsAccessibilityImprovement)
        .toList();
  }

  /// Overall compliance score (0.0 to 1.0)
  double get complianceScore {
    if (elements.isEmpty) return 1.0;
    
    final interactiveElements = elements.where((e) => e.isInteractive).toList();
    if (interactiveElements.isEmpty) return 1.0;
    
    final compliantElements = interactiveElements
        .where((e) => 
            e.getReachabilityLevel(zones) == ReachabilityLevel.easy &&
            e.meetsTouchTargetSize &&
            !e.needsAccessibilityImprovement)
        .length;
        
    return compliantElements / interactiveElements.length;
  }

  /// Whether audit passes minimum requirements
  bool get passesAudit => complianceScore >= 0.6; // 60% compliance threshold
}

@freezed
class AuditSummary with _$AuditSummary {
  const factory AuditSummary({
    required int totalElements,
    required int interactiveElements,
    required int elementsInEasyReach,
    required int elementsWithIssues,
    required double avgTouchTargetSize,
    required int accessibilityIssues,
  }) = _AuditSummary;
}

@freezed
class AuditRecommendation with _$AuditRecommendation {
  const factory AuditRecommendation({
    required String elementId,
    required RecommendationType type,
    required String description,
    required int priority,
    String? suggestedFix,
  }) = _AuditRecommendation;
}

enum RecommendationType {
  moveToEasyReach,
  increaseTouchTarget,
  addAccessibilityLabel,
  addAlternativeAccess,
  improveContrast,
}

extension RecommendationTypeX on RecommendationType {
  String get displayName => switch (this) {
    RecommendationType.moveToEasyReach => 'Move to Easy Reach Zone',
    RecommendationType.increaseTouchTarget => 'Increase Touch Target Size',
    RecommendationType.addAccessibilityLabel => 'Add Accessibility Label',
    RecommendationType.addAlternativeAccess => 'Add Alternative Access',
    RecommendationType.improveContrast => 'Improve Color Contrast',
  };

  int get defaultPriority => switch (this) {
    RecommendationType.moveToEasyReach => 1, // Highest
    RecommendationType.increaseTouchTarget => 2,
    RecommendationType.addAccessibilityLabel => 2,
    RecommendationType.addAlternativeAccess => 3,
    RecommendationType.improveContrast => 3,
  };
}