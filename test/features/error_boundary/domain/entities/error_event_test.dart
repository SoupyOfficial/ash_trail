import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/error_boundary/domain/entities/error_event.dart';

void main() {
  group('ErrorEvent', () {
    group('fromError factory', () {
      test('should create error event with analytics opt-in enabled', () {
        // Arrange
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        const analyticsOptIn = true;
        final additionalContext = {'screen': 'home', 'action': 'tap'};

        // Act
        final errorEvent = ErrorEvent.fromError(
          error: error,
          stackTrace: stackTrace,
          analyticsOptIn: analyticsOptIn,
          additionalContext: additionalContext,
        );

        // Assert
        expect(errorEvent.errorType, equals('_Exception'));
        expect(errorEvent.message, equals('Exception: Test error'));
        expect(errorEvent.wasAnalyticsOptIn, isTrue);
        expect(errorEvent.sanitizedStackTrace, isNotNull);
        expect(errorEvent.context, isNotNull);
        expect(errorEvent.context!['errorDetails'],
            equals('Exception: Test error'));
        expect(errorEvent.context!['screen'], equals('home'));
      });

      test('should create sanitized error event with analytics opt-out', () {
        // Arrange
        final error = Exception('Sensitive error info');
        final stackTrace = StackTrace.current;
        const analyticsOptIn = false;
        final additionalContext = {'sensitive': 'data'};

        // Act
        final errorEvent = ErrorEvent.fromError(
          error: error,
          stackTrace: stackTrace,
          analyticsOptIn: analyticsOptIn,
          additionalContext: additionalContext,
        );

        // Assert
        expect(errorEvent.errorType, equals('_Exception'));
        expect(errorEvent.message, equals('An unexpected error occurred'));
        expect(errorEvent.wasAnalyticsOptIn, isFalse);
        expect(errorEvent.sanitizedStackTrace, isNull);
        expect(errorEvent.context, isNotNull);
        expect(errorEvent.context!['hasAdditionalContext'], isTrue);
        expect(errorEvent.context!.containsKey('sensitive'), isFalse);
      });
    });

    group('displaySummary getter', () {
      test('should show detailed summary when analytics opt-in is enabled', () {
        // Arrange
        final errorEvent = ErrorEvent(
          timestamp: DateTime.now(),
          errorType: 'TestError',
          message: 'Test message',
          wasAnalyticsOptIn: true,
        );

        // Act
        final summary = errorEvent.displaySummary;

        // Assert
        expect(summary, contains('Error: TestError'));
        expect(summary, contains('Message: Test message'));
      });

      test('should show generic summary when analytics opt-out', () {
        // Arrange
        final errorEvent = ErrorEvent(
          timestamp: DateTime.now(),
          errorType: 'TestError',
          message: 'Sensitive message',
          wasAnalyticsOptIn: false,
        );

        // Act
        final summary = errorEvent.displaySummary;

        // Assert
        expect(summary, contains('An unexpected error occurred'));
        expect(summary, contains('Enable analytics sharing'));
        expect(summary, isNot(contains('Sensitive message')));
      });
    });

    group('diagnosticInfo getter', () {
      test('should include full diagnostic info when analytics opt-in', () {
        // Arrange
        final now = DateTime.now();
        final errorEvent = ErrorEvent(
          timestamp: now,
          errorType: 'TestError',
          message: 'Test message',
          sanitizedStackTrace: 'stack trace line 1\nstack trace line 2',
          context: {'key': 'value'},
          wasAnalyticsOptIn: true,
        );

        // Act
        final diagnosticInfo = errorEvent.diagnosticInfo;

        // Assert
        expect(diagnosticInfo, contains('AshTrail Error Report'));
        expect(diagnosticInfo, contains('TestError'));
        expect(diagnosticInfo, contains('Test message'));
        expect(diagnosticInfo, contains('stack trace line 1'));
        expect(diagnosticInfo, contains('{key: value}'));
        expect(diagnosticInfo, contains('Analytics Opt-in: true'));
      });

      test('should redact diagnostic info when analytics opt-out', () {
        // Arrange
        final now = DateTime.now();
        final errorEvent = ErrorEvent(
          timestamp: now,
          errorType: 'TestError',
          message: 'Sensitive message',
          sanitizedStackTrace: 'sensitive stack trace',
          context: {'sensitive': 'data'},
          wasAnalyticsOptIn: false,
        );

        // Act
        final diagnosticInfo = errorEvent.diagnosticInfo;

        // Assert
        expect(diagnosticInfo, contains('AshTrail Error Report'));
        expect(diagnosticInfo, contains('TestError'));
        expect(diagnosticInfo, contains('[Redacted - Analytics opt-out]'));
        expect(diagnosticInfo, contains('Analytics Opt-in: false'));
        expect(diagnosticInfo, isNot(contains('Sensitive message')));
        expect(diagnosticInfo, isNot(contains('sensitive stack trace')));
        expect(diagnosticInfo, isNot(contains('sensitive')));
      });
    });
  });
}
