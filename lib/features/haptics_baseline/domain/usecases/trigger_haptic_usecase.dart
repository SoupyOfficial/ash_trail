// Use case for triggering haptic feedback
// Pure business logic for haptic events following Clean Architecture.

import 'package:fpdart/fpdart.dart';
import '../entities/haptic_event.dart';
import '../services/haptics_service.dart';
import '../../../../core/failures/app_failure.dart';

/// Use case for triggering semantic haptic feedback
class TriggerHapticUseCase {
  const TriggerHapticUseCase(this._hapticsService);

  final HapticsService _hapticsService;

  /// Triggers a haptic event if haptics is enabled
  /// Returns success if haptics was triggered or is disabled
  /// Returns failure only on unexpected errors
  Future<Either<AppFailure, bool>> call(HapticEvent event) async {
    try {
      final wasTriggered = await _hapticsService.triggerHaptic(event);
      return Right(wasTriggered);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to trigger haptic feedback',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
