// Spec Header:
// Accessibility Service - Core Infrastructure
// Detects system accessibility capabilities and provides centralized configuration.
// Assumption: Integrates with Flutter's accessibility APIs and MediaQuery for system detection.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service for detecting and managing accessibility capabilities
class AccessibilityService {
  static const _platform = MethodChannel('ash_trail.dev/accessibility');

  /// Get current system accessibility settings
  static AccessibilityCapabilities fromMediaQuery(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Get text scale factor safely with multiple fallbacks
    double textScaleFactor = 1.0;
    try {
      final scaleValue = mediaQuery.textScaler.scale(1.0);
      if (scaleValue.isFinite && scaleValue > 0 && scaleValue < 10) {
        textScaleFactor = scaleValue;
      }
    } catch (e) {
      // Fallback to default if any error occurs
      textScaleFactor = 1.0;
    }

    return AccessibilityCapabilities(
      textScaleFactor: textScaleFactor,
      isScreenReaderEnabled: mediaQuery.accessibleNavigation,
      isHighContrastEnabled: mediaQuery.highContrast,
      isBoldTextEnabled: mediaQuery.boldText,
      isReduceMotionEnabled: mediaQuery.disableAnimations,
      platformBrightness: mediaQuery.platformBrightness,
      devicePixelRatio: mediaQuery.devicePixelRatio,
    );
  }

  /// Get platform-specific accessibility features
  static Future<Map<String, dynamic>> getPlatformAccessibilityFeatures() async {
    try {
      final Map<Object?, Object?> result =
          await _platform.invokeMethod('getAccessibilityFeatures');

      return Map<String, dynamic>.from(result);
    } on PlatformException {
      // Fallback for platforms without native implementation
      return <String, dynamic>{};
    }
  }

  /// Check if VoiceOver/TalkBack is enabled
  static bool isScreenReaderActive(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Get effective minimum tap target size based on accessibility needs
  static double getEffectiveMinTapTarget(BuildContext context,
      {double baseSize = 48.0}) {
    try {
      final capabilities = fromMediaQuery(context);

      // Guard against invalid values
      if (!baseSize.isFinite || baseSize <= 0) {
        baseSize = 48.0;
      }

      // Increase tap targets for accessibility needs
      if (capabilities.isScreenReaderEnabled ||
          capabilities.textScaleFactor > 1.15) {
        final multiplier = 1.2;
        final result = baseSize * multiplier;
        // Guard against infinite or invalid results
        return result.isFinite && result > 0 ? result : baseSize;
      }

      return baseSize;
    } catch (e) {
      // Safe fallback if MediaQuery access fails
      return baseSize.isFinite && baseSize > 0 ? baseSize : 48.0;
    }
  }

  /// Check if animations should be reduced
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Check if semantic announcements should be immediate (for errors/important info)
  static bool shouldAnnounceImmediately(
      {bool isError = false, bool isImportant = false}) {
    return isError || isImportant;
  }
}

/// Data class for accessibility capabilities
class AccessibilityCapabilities {
  final double textScaleFactor;
  final bool isScreenReaderEnabled;
  final bool isHighContrastEnabled;
  final bool isBoldTextEnabled;
  final bool isReduceMotionEnabled;
  final Brightness platformBrightness;
  final double devicePixelRatio;

  const AccessibilityCapabilities({
    required this.textScaleFactor,
    required this.isScreenReaderEnabled,
    required this.isHighContrastEnabled,
    required this.isBoldTextEnabled,
    required this.isReduceMotionEnabled,
    required this.platformBrightness,
    required this.devicePixelRatio,
  });

  /// Whether accessibility mode is considered active
  bool get isAccessibilityModeActive =>
      isScreenReaderEnabled ||
      textScaleFactor > 1.15 ||
      isHighContrastEnabled ||
      isBoldTextEnabled;

  /// Whether larger tap targets are needed
  bool get needsLargerTapTargets =>
      isScreenReaderEnabled || textScaleFactor > 1.0;

  /// Whether high contrast is needed
  bool get needsHighContrast => isHighContrastEnabled;

  /// Whether animations should be reduced
  bool get shouldReduceAnimations => isReduceMotionEnabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessibilityCapabilities &&
          runtimeType == other.runtimeType &&
          textScaleFactor == other.textScaleFactor &&
          isScreenReaderEnabled == other.isScreenReaderEnabled &&
          isHighContrastEnabled == other.isHighContrastEnabled &&
          isBoldTextEnabled == other.isBoldTextEnabled &&
          isReduceMotionEnabled == other.isReduceMotionEnabled &&
          platformBrightness == other.platformBrightness &&
          devicePixelRatio == other.devicePixelRatio;

  @override
  int get hashCode => Object.hash(
        textScaleFactor,
        isScreenReaderEnabled,
        isHighContrastEnabled,
        isBoldTextEnabled,
        isReduceMotionEnabled,
        platformBrightness,
        devicePixelRatio,
      );

  @override
  String toString() {
    return 'AccessibilityCapabilities('
        'textScaleFactor: $textScaleFactor, '
        'isScreenReaderEnabled: $isScreenReaderEnabled, '
        'isHighContrastEnabled: $isHighContrastEnabled, '
        'isBoldTextEnabled: $isBoldTextEnabled, '
        'isReduceMotionEnabled: $isReduceMotionEnabled, '
        'platformBrightness: $platformBrightness, '
        'devicePixelRatio: $devicePixelRatio)';
  }
}
