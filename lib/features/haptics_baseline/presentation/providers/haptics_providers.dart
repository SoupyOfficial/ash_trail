// Riverpod providers for haptics functionality
// Manages haptics service and configuration state.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/haptic_event.dart';
import '../../domain/repositories/haptics_repository.dart';
import '../../domain/services/haptics_service.dart';
import '../../domain/usecases/get_haptics_enabled_usecase.dart';
import '../../domain/usecases/trigger_haptic_usecase.dart';
import '../../data/repositories/haptics_repository_impl.dart';
import '../../data/services/haptics_service_impl.dart';

/// Provider for SharedPreferences instance used by haptics
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override this provider in main.dart');
});

/// Provider for the haptics repository
final hapticsRepositoryProvider = Provider<HapticsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HapticsRepositoryImpl(prefs);
});

/// Provider for the get haptics enabled use case
final getHapticsEnabledUseCaseProvider =
    Provider<GetHapticsEnabledUseCase>((ref) {
  return GetHapticsEnabledUseCase(ref.watch(hapticsRepositoryProvider));
});

/// Provider for the haptics service
final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return HapticsServiceImpl(ref.watch(getHapticsEnabledUseCaseProvider));
});

/// Provider for the trigger haptic use case
final triggerHapticUseCaseProvider = Provider<TriggerHapticUseCase>((ref) {
  return TriggerHapticUseCase(ref.watch(hapticsServiceProvider));
});

/// Provider to check if haptics is currently enabled
final hapticsEnabledProvider = FutureProvider<bool>((ref) async {
  final useCase = ref.watch(getHapticsEnabledUseCaseProvider);
  final result = await useCase();
  return result.fold((failure) => false, (enabled) => enabled);
});

/// Notifier for triggering haptic events
class HapticTriggerNotifier extends Notifier<void> {
  @override
  void build() {
    // Initialize
  }

  /// Trigger a haptic event
  Future<bool> trigger(HapticEvent event) async {
    final useCase = ref.read(triggerHapticUseCaseProvider);
    final result = await useCase(event);
    return result.fold((failure) => false, (wasTriggered) => wasTriggered);
  }

  /// Convenience methods for common haptic events
  Future<bool> tap() => trigger(HapticEvent.tap);
  Future<bool> success() => trigger(HapticEvent.success);
  Future<bool> warning() => trigger(HapticEvent.warning);
  Future<bool> error() => trigger(HapticEvent.error);
  Future<bool> impactLight() => trigger(HapticEvent.impactLight);
}

/// Provider for triggering haptic feedback
/// Usage: ref.read(hapticTriggerProvider.notifier).trigger(HapticEvent.tap)
final hapticTriggerProvider = NotifierProvider<HapticTriggerNotifier, void>(() {
  return HapticTriggerNotifier();
});
