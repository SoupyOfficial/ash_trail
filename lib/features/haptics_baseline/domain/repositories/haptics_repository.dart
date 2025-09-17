// Repository interface for haptics service configuration
// Manages haptics settings and preferences following Clean Architecture patterns.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';

/// Abstract repository for haptics configuration management
abstract class HapticsRepository {
  /// Get the current haptics enabled state
  Future<Either<AppFailure, bool>> getHapticsEnabled();

  /// Set whether haptics is enabled
  Future<Either<AppFailure, void>> setHapticsEnabled(bool enabled);

  /// Check if system haptics/vibration is available
  Future<Either<AppFailure, bool>> isHapticsSupported();

  /// Check if reduce motion is enabled (for accessibility)
  Future<Either<AppFailure, bool>> isReduceMotionEnabled();
}
