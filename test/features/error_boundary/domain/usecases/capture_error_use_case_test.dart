import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/error_boundary/domain/usecases/capture_error_use_case.dart';
import 'package:ash_trail/core/telemetry/telemetry_service.dart';

class MockTelemetryService implements TelemetryService {
  final List<(String, Map<String, Object?>)> loggedEvents = [];

  @override
  void logEvent(String name, Map<String, Object?> params) {
    loggedEvents.add((name, params));
  }
}

void main() {
  group('CaptureErrorUseCase', () {
    late MockTelemetryService mockTelemetryService;
    late CaptureErrorUseCase useCase;

    setUp(() {
      mockTelemetryService = MockTelemetryService();
      useCase = CaptureErrorUseCase(telemetryService: mockTelemetryService);
    });

    test('should capture error with analytics opt-in enabled', () async {
      // Arrange
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      const analyticsOptIn = true;
      final additionalContext = {'screen': 'home'};

      // Act
      final result = await useCase(
        error: error,
        stackTrace: stackTrace,
        analyticsOptIn: analyticsOptIn,
        additionalContext: additionalContext,
      );

      // Assert
      expect(result.isRight(), isTrue);

      result.fold(
        (failure) => fail('Expected success'),
        (errorEvent) {
          expect(errorEvent.errorType, equals('_Exception'));
          expect(errorEvent.message, equals('Exception: Test error'));
          expect(errorEvent.wasAnalyticsOptIn, isTrue);
          expect(errorEvent.sanitizedStackTrace, isNotNull);
        },
      );

      // Verify telemetry was logged
      expect(mockTelemetryService.loggedEvents, hasLength(1));
      final loggedEvent = mockTelemetryService.loggedEvents.first;
      expect(loggedEvent.$1, equals('error_boundary_triggered'));
      expect(loggedEvent.$2['analytics_opt_in'], isTrue);
      expect(loggedEvent.$2['message'], equals('Exception: Test error'));
    });

    test('should capture error with analytics opt-out', () async {
      // Arrange
      final error = Exception('Sensitive error');
      final stackTrace = StackTrace.current;
      const analyticsOptIn = false;

      // Act
      final result = await useCase(
        error: error,
        stackTrace: stackTrace,
        analyticsOptIn: analyticsOptIn,
      );

      // Assert
      expect(result.isRight(), isTrue);

      result.fold(
        (failure) => fail('Expected success'),
        (errorEvent) {
          expect(errorEvent.errorType, equals('_Exception'));
          expect(errorEvent.message, equals('An unexpected error occurred'));
          expect(errorEvent.wasAnalyticsOptIn, isFalse);
          expect(errorEvent.sanitizedStackTrace, isNull);
        },
      );

      // Verify telemetry was logged with redacted info
      expect(mockTelemetryService.loggedEvents, hasLength(1));
      final loggedEvent = mockTelemetryService.loggedEvents.first;
      expect(loggedEvent.$1, equals('error_boundary_triggered'));
      expect(loggedEvent.$2['analytics_opt_in'], isFalse);
      expect(loggedEvent.$2['message'], equals('[redacted]'));
    });

    test('should handle telemetry service failures gracefully', () async {
      // Arrange
      final throwingTelemetryService = ThrowingTelemetryService();
      final throwingUseCase =
          CaptureErrorUseCase(telemetryService: throwingTelemetryService);
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      // Act
      final result = await throwingUseCase(
        error: error,
        stackTrace: stackTrace,
        analyticsOptIn: true,
      );

      // Assert - Should still return success even if telemetry fails
      expect(result.isRight(), isTrue);
    });
  });
}

class ThrowingTelemetryService implements TelemetryService {
  @override
  void logEvent(String name, Map<String, Object?> params) {
    throw Exception('Telemetry service failed');
  }
}
