// Spec Header:
// Accessibility Foundation Providers
// Riverpod providers for accessibility capabilities and configuration management.
// Assumption: MediaQuery changes trigger rebuilds for dynamic accessibility updates.

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/accessibility_service.dart';

part 'accessibility_providers.g.dart';

/// Provider for current accessibility capabilities from system
@riverpod
AccessibilityCapabilities accessibilityCapabilities(
  AccessibilityCapabilitiesRef ref,
  BuildContext context,
) {
  // This will automatically rebuild when MediaQuery changes
  return AccessibilityService.fromMediaQuery(context);
}

/// Provider for effective minimum tap target size
@riverpod
double effectiveMinTapTarget(
  EffectiveMinTapTargetRef ref,
  BuildContext context, {
  double baseSize = 48.0,
}) {
  return AccessibilityService.getEffectiveMinTapTarget(context,
      baseSize: baseSize);
}

/// Provider to check if screen reader is active
@riverpod
bool isScreenReaderActive(
  IsScreenReaderActiveRef ref,
  BuildContext context,
) {
  return AccessibilityService.isScreenReaderActive(context);
}

/// Provider to check if motion should be reduced
@riverpod
bool shouldReduceMotion(
  ShouldReduceMotionRef ref,
  BuildContext context,
) {
  return AccessibilityService.shouldReduceMotion(context);
}

/// Provider for platform accessibility features
@riverpod
Future<Map<String, dynamic>> platformAccessibilityFeatures(
  PlatformAccessibilityFeaturesRef ref,
) async {
  return AccessibilityService.getPlatformAccessibilityFeatures();
}

/// Utility provider to check if semantic announcements should be immediate
@riverpod
bool shouldAnnounceImmediately(
  ShouldAnnounceImmediatelyRef ref, {
  bool isError = false,
  bool isImportant = false,
}) {
  return AccessibilityService.shouldAnnounceImmediately(
    isError: isError,
    isImportant: isImportant,
  );
}

/// Provider for accessibility mode detection
@riverpod
bool isAccessibilityModeActive(
  IsAccessibilityModeActiveRef ref,
  BuildContext context,
) {
  final capabilities = ref.watch(accessibilityCapabilitiesProvider(context));
  return capabilities.isAccessibilityModeActive;
}

/// Provider for checking if larger tap targets are needed
@riverpod
bool needsLargerTapTargets(
  NeedsLargerTapTargetsRef ref,
  BuildContext context,
) {
  final capabilities = ref.watch(accessibilityCapabilitiesProvider(context));
  return capabilities.needsLargerTapTargets;
}

/// Provider for checking if high contrast is needed
@riverpod
bool needsHighContrast(
  NeedsHighContrastRef ref,
  BuildContext context,
) {
  final capabilities = ref.watch(accessibilityCapabilitiesProvider(context));
  return capabilities.needsHighContrast;
}
