// Spec Header:
// Accessibility Configuration Entity
// Represents user accessibility preferences and system capabilities.
// Assumption: This tracks accessibility-related system settings and user preferences.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'accessibility_config.freezed.dart';

@freezed
class AccessibilityConfig with _$AccessibilityConfig {
  const AccessibilityConfig._();

  const factory AccessibilityConfig({
    required String userId,
    required DateTime createdAt,
    DateTime? updatedAt,

    // System accessibility features
    @Default(false) bool isScreenReaderEnabled,
    @Default(false) bool isBoldTextEnabled,
    @Default(false) bool isReduceMotionEnabled,
    @Default(false) bool isHighContrastEnabled,
    @Default(1.0) double textScaleFactor,

    // User preferences
    @Default(true) bool enableHapticFeedback,
    @Default(true) bool enableSemanticLabels,
    @Default(48.0) double minTapTargetSize,

    // Focus and navigation preferences
    @Default(true) bool enableFocusIndicators,
    @Default(true) bool enableCustomFocusOrder,
  }) = _AccessibilityConfig;

  // Business logic methods
  bool get isAccessibilityModeEnabled =>
      isScreenReaderEnabled ||
      isBoldTextEnabled ||
      isHighContrastEnabled ||
      textScaleFactor > 1.15;

  bool get shouldReduceAnimations => isReduceMotionEnabled;

  bool get requiresLargerTapTargets =>
      textScaleFactor > 1.0 || isScreenReaderEnabled;

  double get effectiveMinTapTarget =>
      requiresLargerTapTargets ? minTapTargetSize * 1.2 : minTapTargetSize;

  bool get needsHighContrast => isHighContrastEnabled;

  bool get shouldShowSemanticLabels =>
      enableSemanticLabels || isScreenReaderEnabled;
}
