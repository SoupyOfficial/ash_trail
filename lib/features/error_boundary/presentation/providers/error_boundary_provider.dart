import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/telemetry/telemetry_service.dart';
import '../../domain/entities/error_event.dart';
import '../../domain/usecases/capture_error_use_case.dart';
import '../../domain/usecases/reset_error_boundary_use_case.dart';
import '../../domain/usecases/share_diagnostics_use_case.dart';
import '../../data/services/share_service.dart';

/// Provider for the share service (debug implementation for now)
final shareServiceProvider = Provider<ShareService>((ref) {
  // TODO: Switch to PlatformShareService when platform implementation is ready
  return DebugShareService();
});

/// Provider for capture error use case
final captureErrorUseCaseProvider = Provider<CaptureErrorUseCase>((ref) {
  return CaptureErrorUseCase(
    telemetryService: ref.watch(telemetryServiceProvider),
  );
});

/// Provider for reset error boundary use case
final resetErrorBoundaryUseCaseProvider =
    Provider<ResetErrorBoundaryUseCase>((ref) {
  return const ResetErrorBoundaryUseCase();
});

/// Provider for share diagnostics use case
final shareDiagnosticsUseCaseProvider =
    Provider<ShareDiagnosticsUseCase>((ref) {
  return ShareDiagnosticsUseCase(
    shareService: ref.watch(shareServiceProvider),
  );
});

/// State notifier for managing error boundary state
class ErrorBoundaryController extends StateNotifier<ErrorBoundaryState> {
  ErrorBoundaryController(this._ref) : super(const ErrorBoundaryState.normal());

  final Ref _ref;

  /// Captures an error and updates the boundary state
  Future<void> captureError(Object error, StackTrace stackTrace) async {
    // For now, default to analytics opt-out for privacy
    // TODO: Replace with actual preferences when prefs repository is implemented
    const analyticsOptIn = false;

    // Capture the error
    final captureUseCase = _ref.read(captureErrorUseCaseProvider);
    final result = await captureUseCase(
      error: error,
      stackTrace: stackTrace,
      analyticsOptIn: analyticsOptIn,
    );

    result.fold(
      (failure) {
        // If capturing fails, still show error boundary but with minimal info
        state = ErrorBoundaryState.error(
          errorEvent: ErrorEvent(
            timestamp: DateTime.now(),
            errorType: error.runtimeType.toString(),
            message: 'An error occurred',
            wasAnalyticsOptIn: false,
          ),
        );
      },
      (errorEvent) {
        state = ErrorBoundaryState.error(errorEvent: errorEvent);
      },
    );
  }

  /// Resets the error boundary to normal state
  Future<void> reset() async {
    final resetUseCase = _ref.read(resetErrorBoundaryUseCaseProvider);
    final result = await resetUseCase();

    result.fold(
      (failure) {
        // Even if reset use case fails, we still want to try resetting the UI
        state = const ErrorBoundaryState.normal();
      },
      (_) {
        state = const ErrorBoundaryState.normal();
      },
    );
  }

  /// Shares diagnostic information for the current error
  Future<void> shareDiagnostics() async {
    final currentState = state;
    if (currentState is ErrorBoundaryStateError) {
      final shareUseCase = _ref.read(shareDiagnosticsUseCaseProvider);
      await shareUseCase(errorEvent: currentState.errorEvent);
    }
  }
}

/// Provider for error boundary controller
final errorBoundaryControllerProvider =
    StateNotifierProvider<ErrorBoundaryController, ErrorBoundaryState>((ref) {
  return ErrorBoundaryController(ref);
});

/// Error boundary state
sealed class ErrorBoundaryState {
  const ErrorBoundaryState();

  const factory ErrorBoundaryState.normal() = ErrorBoundaryStateNormal;
  const factory ErrorBoundaryState.error({
    required ErrorEvent errorEvent,
  }) = ErrorBoundaryStateError;
}

class ErrorBoundaryStateNormal extends ErrorBoundaryState {
  const ErrorBoundaryStateNormal();
}

class ErrorBoundaryStateError extends ErrorBoundaryState {
  const ErrorBoundaryStateError({required this.errorEvent});

  final ErrorEvent errorEvent;
}
