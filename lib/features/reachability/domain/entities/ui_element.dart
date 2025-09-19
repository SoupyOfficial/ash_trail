// UI element representation for reachability audit
// Tracks screen elements and their ergonomic accessibility

import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'reachability_zone.dart';

part 'ui_element.freezed.dart';

@freezed
class UiElement with _$UiElement {
  const UiElement._();

  const factory UiElement({
    required String id,
    required String label,
    required Rect bounds,
    required UiElementType type,
    required bool isInteractive,
    String? semanticLabel,
    bool? hasAlternativeAccess,
  }) = _UiElement;

  /// Check if element is within the easy reach zone
  bool isWithinEasyReach(List<ReachabilityZone> zones) {
    final easyZones = zones.where((z) => z.level == ReachabilityLevel.easy);
    return easyZones.any((zone) => zone.overlapsRect(bounds));
  }

  /// Get the best reachability level for this element
  ReachabilityLevel getReachabilityLevel(List<ReachabilityZone> zones) {
    final levels = zones
        .where((zone) => zone.overlapsRect(bounds))
        .map((zone) => zone.level)
        .toList();

    if (levels.isEmpty) return ReachabilityLevel.unreachable;

    // Return the most accessible level found
    if (levels.contains(ReachabilityLevel.easy)) return ReachabilityLevel.easy;
    if (levels.contains(ReachabilityLevel.moderate))
      return ReachabilityLevel.moderate;
    if (levels.contains(ReachabilityLevel.difficult))
      return ReachabilityLevel.difficult;
    return ReachabilityLevel.unreachable;
  }

  /// Calculate coverage percentage within easy reach zones
  double getEasyReachCoverage(List<ReachabilityZone> zones) {
    final easyZones = zones.where((z) => z.level == ReachabilityLevel.easy);
    if (easyZones.isEmpty) return 0.0;

    double maxCoverage = 0.0;
    for (final zone in easyZones) {
      final coverage = zone.coveragePercentage(bounds);
      if (coverage > maxCoverage) {
        maxCoverage = coverage;
      }
    }
    return maxCoverage;
  }

  /// Whether this element needs accessibility improvements
  bool get needsAccessibilityImprovement {
    if (!isInteractive) return false;
    return (semanticLabel == null || semanticLabel!.isEmpty) ||
        (hasAlternativeAccess != true);
  }

  /// Minimum touch target size (48dp)
  static const double minTouchTargetSize = 48.0;

  /// Whether touch target meets minimum size requirements
  bool get meetsTouchTargetSize {
    if (!isInteractive) return true;
    return bounds.width >= minTouchTargetSize &&
        bounds.height >= minTouchTargetSize;
  }
}

enum UiElementType {
  button,
  textField,
  slider,
  toggle,
  navigationItem,
  actionButton,
  listItem,
  card,
  other,
}

extension UiElementTypeX on UiElementType {
  String get displayName => switch (this) {
        UiElementType.button => 'Button',
        UiElementType.textField => 'Text Field',
        UiElementType.slider => 'Slider',
        UiElementType.toggle => 'Toggle',
        UiElementType.navigationItem => 'Navigation Item',
        UiElementType.actionButton => 'Action Button',
        UiElementType.listItem => 'List Item',
        UiElementType.card => 'Card',
        UiElementType.other => 'Other',
      };

  bool get isHighPriority => switch (this) {
        UiElementType.button => true,
        UiElementType.actionButton => true,
        UiElementType.navigationItem => true,
        UiElementType.textField => true,
        _ => false,
      };
}
