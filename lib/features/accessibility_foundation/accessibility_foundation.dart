// Spec Header:
// Accessibility Foundation Feature Integration
// Exports all accessibility foundation components for use throughout the app.
// Assumption: This is the main entry point for accessibility functionality.

import 'package:flutter/material.dart';
import 'presentation/services/accessibility_service.dart';

// Core services
export 'presentation/services/accessibility_service.dart';

// Semantic wrapper widgets
export 'presentation/widgets/semantic_wrappers.dart';

// Providers (when build_runner generates the files)
// export 'presentation/providers/accessibility_providers.dart';

/// A utility mixin to provide accessibility helpers to widgets
mixin AccessibilityMixin {
  /// Check if accessibility mode is active based on MediaQuery
  bool isAccessibilityModeActive(BuildContext context) {
    final capabilities = AccessibilityService.fromMediaQuery(context);
    return capabilities.isAccessibilityModeActive;
  }

  /// Get effective minimum tap target size
  double getEffectiveMinTapTarget(BuildContext context,
      {double baseSize = 48.0}) {
    return AccessibilityService.getEffectiveMinTapTarget(context,
        baseSize: baseSize);
  }

  /// Check if screen reader is active
  bool isScreenReaderActive(BuildContext context) {
    return AccessibilityService.isScreenReaderActive(context);
  }

  /// Check if animations should be reduced
  bool shouldReduceMotion(BuildContext context) {
    return AccessibilityService.shouldReduceMotion(context);
  }
}

/// Extension on BuildContext for easy accessibility checks
extension AccessibilityContext on BuildContext {
  /// Get accessibility capabilities for this context
  AccessibilityCapabilities get accessibilityCapabilities =>
      AccessibilityService.fromMediaQuery(this);

  /// Check if accessibility mode is active
  bool get isAccessibilityModeActive =>
      AccessibilityService.fromMediaQuery(this).isAccessibilityModeActive;

  /// Check if screen reader is active
  bool get isScreenReaderActive =>
      AccessibilityService.isScreenReaderActive(this);

  /// Check if animations should be reduced
  bool get shouldReduceMotion => AccessibilityService.shouldReduceMotion(this);

  /// Get effective minimum tap target size
  double effectiveMinTapTarget({double baseSize = 48.0}) =>
      AccessibilityService.getEffectiveMinTapTarget(this, baseSize: baseSize);

  /// Check if larger tap targets are needed
  bool get needsLargerTapTargets =>
      AccessibilityService.fromMediaQuery(this).needsLargerTapTargets;

  /// Check if high contrast is needed
  bool get needsHighContrast =>
      AccessibilityService.fromMediaQuery(this).needsHighContrast;
}
