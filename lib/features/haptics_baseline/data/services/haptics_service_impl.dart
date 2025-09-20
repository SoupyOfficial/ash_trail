// Haptics service implementation using Flutter's HapticFeedback
// Provides concrete haptic feedback implementation following Clean Architecture.

import 'package:flutter/services.dart';
import '../../domain/entities/haptic_event.dart';
import '../../domain/services/haptics_service.dart';
import '../../domain/usecases/get_haptics_enabled_usecase.dart';

/// Implementation of HapticsService using the vibration package
class HapticsServiceImpl implements HapticsService {
  const HapticsServiceImpl(this._getHapticsEnabledUseCase);

  final GetHapticsEnabledUseCase _getHapticsEnabledUseCase;

  @override
  Future<bool> triggerHaptic(HapticEvent event) async {
    try {
      final isEnabled = await isHapticsEnabled();
      if (!isEnabled) {
        return false;
      }

      switch (event) {
        case HapticEvent.tap:
          await HapticFeedback.selectionClick();
          break;
        case HapticEvent.success:
          await HapticFeedback
              .mediumImpact(); // No success haptic, use medium impact
          break;
        case HapticEvent.warning:
          await HapticFeedback
              .mediumImpact(); // No warning haptic, use medium impact
          break;
        case HapticEvent.error:
          await HapticFeedback.heavyImpact(); // Use heavy impact for errors
          break;
        case HapticEvent.impactLight:
          await HapticFeedback.lightImpact();
          break;
      }

      return true;
    } catch (e) {
      // Haptics failure should not crash the app
      return false;
    }
  }

  @override
  Future<bool> isHapticsEnabled() async {
    final result = await _getHapticsEnabledUseCase();
    return result.fold((failure) => false, (enabled) => enabled);
  }

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    // This would require a SetHapticsEnabledUseCase, but for now we'll keep it simple
    // In a full implementation, this would go through the use case layer
    throw UnimplementedError('Use HapticsRepository directly for settings');
  }
}
