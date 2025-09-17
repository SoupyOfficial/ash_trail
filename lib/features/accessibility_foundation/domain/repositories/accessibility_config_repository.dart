// Spec Header:
// Accessibility Configuration Repository Interface
// Abstract contract for persisting and retrieving user accessibility preferences.
// Assumption: Preferences stored locally with SharedPreferences, remote sync optional.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/accessibility_config.dart';

abstract class AccessibilityConfigRepository {
  /// Get current accessibility configuration for a user
  Future<Either<AppFailure, AccessibilityConfig>> getConfig(String userId);

  /// Update accessibility configuration
  Future<Either<AppFailure, AccessibilityConfig>> updateConfig(
      AccessibilityConfig config);

  /// Get system accessibility capabilities (from platform)
  Future<Either<AppFailure, Map<String, dynamic>>> getSystemCapabilities();

  /// Initialize default configuration for new user
  Future<Either<AppFailure, AccessibilityConfig>> initializeDefaults(
      String userId);
}
