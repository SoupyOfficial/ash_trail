import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/error_boundary/presentation/providers/error_boundary_provider.dart';
import 'package:ash_trail/features/error_boundary/data/services/share_service.dart';
import 'package:ash_trail/core/telemetry/telemetry_service.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockTelemetryService implements TelemetryService {
  final List<(String, Map<String, Object?>)> loggedEvents = [];

  @override
  void logEvent(String name, Map<String, Object?> params) {
    loggedEvents.add((name, params));
  }
}

class MockShareService implements ShareService {
  @override
  Future<Either<AppFailure, Unit>> shareText({
    required String text,
    String? subject,
  }) async {
    // Mock successful sharing
    return right(unit);
  }

  @override
  Future<Either<AppFailure, Unit>> shareTextFromRect({
    required String text,
    String? subject,
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    return shareText(text: text, subject: subject);
  }
}

void main() {
  group('ErrorBoundaryController', () {
    late ProviderContainer container;
    late MockTelemetryService mockTelemetryService;
    late MockShareService mockShareService;

    setUp(() {
      mockTelemetryService = MockTelemetryService();
      mockShareService = MockShareService();

      container = ProviderContainer(
        overrides: [
          telemetryServiceProvider.overrideWithValue(mockTelemetryService),
          shareServiceProvider.overrideWithValue(mockShareService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with normal state', () {
      // Act
      final state = container.read(errorBoundaryControllerProvider);

      // Assert
      expect(state, isA<ErrorBoundaryStateNormal>());
    });

    test('should capture error and transition to error state', () async {
      // Arrange
      final controller =
          container.read(errorBoundaryControllerProvider.notifier);
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      // Act
      await controller.captureError(error, stackTrace);

      // Assert
      final state = container.read(errorBoundaryControllerProvider);
      expect(state, isA<ErrorBoundaryStateError>());

      final errorState = state as ErrorBoundaryStateError;
      expect(errorState.errorEvent.errorType, equals('_Exception'));
      expect(errorState.errorEvent.message,
          equals('An unexpected error occurred'));
      expect(errorState.errorEvent.wasAnalyticsOptIn, isFalse);

      // Verify telemetry was logged
      expect(mockTelemetryService.loggedEvents, hasLength(1));
    });

    test('should reset to normal state', () async {
      // Arrange
      final controller =
          container.read(errorBoundaryControllerProvider.notifier);

      // First trigger an error
      await controller.captureError(Exception('Test'), StackTrace.current);
      expect(container.read(errorBoundaryControllerProvider),
          isA<ErrorBoundaryStateError>());

      // Act
      await controller.reset();

      // Assert
      final state = container.read(errorBoundaryControllerProvider);
      expect(state, isA<ErrorBoundaryStateNormal>());
    });

    test('should handle capture error failure gracefully', () async {
      // Arrange
      final failingTelemetryService = FailingTelemetryService();
      final containerWithFailingService = ProviderContainer(
        overrides: [
          telemetryServiceProvider.overrideWithValue(failingTelemetryService),
          shareServiceProvider.overrideWithValue(mockShareService),
        ],
      );

      final controller = containerWithFailingService
          .read(errorBoundaryControllerProvider.notifier);

      // Act
      await controller.captureError(Exception('Test'), StackTrace.current);

      // Assert - Should still transition to error state even if telemetry fails
      final state =
          containerWithFailingService.read(errorBoundaryControllerProvider);
      expect(state, isA<ErrorBoundaryStateError>());

      containerWithFailingService.dispose();
    });

    test('should share diagnostics when in error state', () async {
      // Arrange
      final controller =
          container.read(errorBoundaryControllerProvider.notifier);

      // First trigger an error
      await controller.captureError(
          Exception('Test error'), StackTrace.current);
      expect(container.read(errorBoundaryControllerProvider),
          isA<ErrorBoundaryStateError>());

      // Act
      await controller.shareDiagnostics();

      // Assert - Should not throw and complete successfully
      // The actual sharing is handled by the ShareService mock
    });

    test('should not share diagnostics when in normal state', () async {
      // Arrange
      final controller =
          container.read(errorBoundaryControllerProvider.notifier);
      expect(container.read(errorBoundaryControllerProvider),
          isA<ErrorBoundaryStateNormal>());

      // Act
      await controller.shareDiagnostics();

      // Assert - Should complete without errors (no-op)
    });
  });
}

class FailingTelemetryService implements TelemetryService {
  @override
  void logEvent(String name, Map<String, Object?> params) {
    throw Exception('Telemetry failed');
  }
}
