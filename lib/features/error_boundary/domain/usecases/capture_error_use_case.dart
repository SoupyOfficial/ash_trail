import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/telemetry/telemetry_service.dart';
import '../entities/error_event.dart';

/// Use case for capturing and logging error events from the error boundary.
/// Respects user privacy settings when logging error information.
class CaptureErrorUseCase {
  const CaptureErrorUseCase({
    required TelemetryService telemetryService,
  }) : _telemetryService = telemetryService;

  final TelemetryService _telemetryService;

  /// Captures an error event and logs it with appropriate privacy controls.
  /// Returns the created ErrorEvent for potential UI display or sharing.
  Future<Either<AppFailure, ErrorEvent>> call({
    required Object error,
    required StackTrace stackTrace,
    required bool analyticsOptIn,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      final errorEvent = ErrorEvent.fromError(
        error: error,
        stackTrace: stackTrace,
        analyticsOptIn: analyticsOptIn,
        additionalContext: additionalContext,
      );

      // Log to telemetry with appropriate privacy controls
      // Telemetry failures should not prevent error capture from succeeding
      try {
        _telemetryService.logEvent('error_boundary_triggered', {
          'error_type': errorEvent.errorType,
          'timestamp': errorEvent.timestamp.toIso8601String(),
          'analytics_opt_in': analyticsOptIn,
          // Only include detailed information if user opted in
          if (analyticsOptIn) ...{
            'message': errorEvent.message,
            'has_stack_trace': errorEvent.sanitizedStackTrace != null,
            'context_keys': errorEvent.context?.keys.toList() ?? [],
          } else ...{
            'message': '[redacted]',
            'details': '[redacted - analytics opt-out]',
          },
        });
      } catch (telemetryError) {
        // Ignore telemetry failures - error capture should still succeed
        // This ensures graceful degradation when telemetry service fails
      }

      return right(errorEvent);
    } catch (e, st) {
      // If error capture itself fails, create a minimal error event
      // and try to log the capture failure
      try {
        _telemetryService.logEvent('error_capture_failed', {
          'capture_error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Ignore telemetry failures in error capture failure
      }

      return left(AppFailure.unexpected(
        message: 'Failed to capture error event',
        cause: e,
        stackTrace: st,
      ));
    }
  }
}
