// Lightweight runtime feature flags access
// Default map is empty; override in main.dart or tests using tool/feature_flags.g.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the feature flags map.
/// By default empty; apps/tests should override with generated flags.
final featureFlagsProvider = Provider<Map<String, bool>>((ref) => const {});

/// Helper to check a feature flag inside widgets/providers.
bool isFeatureEnabled(WidgetRef ref, String key) {
  final flags = ref.read(featureFlagsProvider);
  return flags[key] ?? false;
}
