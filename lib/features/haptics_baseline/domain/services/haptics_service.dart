// Core haptics service interface
// Provides semantic haptic feedback following Clean Architecture principles.

import '../entities/haptic_event.dart';

/// Abstract service for triggering haptic feedback
abstract class HapticsService {
  /// Trigger a haptic event
  /// Returns true if haptics was triggered, false if disabled or unavailable
  Future<bool> triggerHaptic(HapticEvent event);

  /// Check if haptics is currently enabled and available
  Future<bool> isHapticsEnabled();

  /// Enable or disable haptics
  Future<void> setHapticsEnabled(bool enabled);
}
