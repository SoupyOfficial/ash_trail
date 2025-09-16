import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to detect if reduced motion accessibility setting is enabled
final reduceMotionProvider = Provider<bool>((ref) {
  return false; // Default to false, will be overridden by widget context
});

/// Provider for skeleton animation duration
final skeletonAnimationDurationProvider = Provider<Duration>((ref) {
  final reduceMotion = ref.watch(reduceMotionProvider);
  return reduceMotion
      ? const Duration(milliseconds: 800)
      : const Duration(milliseconds: 1200);
});

/// Provider for minimum loading duration (300ms as per requirements)
final minimumLoadingDurationProvider = Provider<Duration>((ref) {
  return const Duration(milliseconds: 300);
});
