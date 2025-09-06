import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';

/// Use case for resetting the error boundary state.
/// Allows the app to attempt recovery from error states.
class ResetErrorBoundaryUseCase {
  const ResetErrorBoundaryUseCase();

  /// Resets the error boundary state, allowing the app to retry rendering.
  /// Returns success if reset was successful, or failure if reset cannot proceed.
  Future<Either<AppFailure, Unit>> call() async {
    try {
      // In a real implementation, this might:
      // - Clear any cached error states
      // - Reset any global error flags
      // - Trigger garbage collection if needed
      // - Notify telemetry of the reset attempt

      // For now, this is a simple success return
      // The actual reset logic will be handled by the UI layer
      return right(unit);
    } catch (e, st) {
      return left(AppFailure.unexpected(
        message: 'Failed to reset error boundary',
        cause: e,
        stackTrace: st,
      ));
    }
  }
}
