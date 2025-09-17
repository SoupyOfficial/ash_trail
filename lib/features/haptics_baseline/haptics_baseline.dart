// Public API for haptics functionality
// Provides convenient access to haptic feedback throughout the app.

export 'domain/entities/haptic_event.dart';
export 'domain/services/haptics_service.dart';
export 'presentation/providers/haptics_providers.dart';

/// Convenience class for accessing haptics functionality
///
/// Usage:
/// ```dart
/// // In a widget or provider:
/// await ref.read(hapticTriggerProvider.notifier).tap();
/// await ref.read(hapticTriggerProvider.notifier).success();
/// await ref.read(hapticTriggerProvider.notifier).trigger(HapticEvent.error);
///
/// // Check if haptics is enabled:
/// final isEnabled = await ref.read(hapticsEnabledProvider.future);
/// ```
class HapticsAPI {
  const HapticsAPI._();

  // This class is just for documentation - use providers directly
}
