import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/app_analytics_service.dart';
import 'package:ash_trail/services/app_performance_service.dart';
import 'package:ash_trail/logging/app_logger.dart';

/// Tests that verify the observability wiring works correctly
/// without Firebase (all guards return false, operations still execute).
void main() {
  group('Observability Wiring', () {
    group('AppLogger.onErrorLog callback', () {
      tearDown(() {
        AppLogger.onErrorLog = null;
      });

      test('callback is null by default', () {
        expect(AppLogger.onErrorLog, isNull);
      });

      test('callback can be set and invoked', () {
        String? capturedName;
        String? capturedMessage;

        AppLogger.onErrorLog = (name, message) {
          capturedName = name;
          capturedMessage = message;
        };

        // Simulate what _BreadcrumbLogOutput would do
        AppLogger.onErrorLog!('TestLogger', 'Something went wrong');

        expect(capturedName, 'TestLogger');
        expect(capturedMessage, 'Something went wrong');
      });
    });

    group('Service singletons', () {
      test('AppAnalyticsService is singleton', () {
        expect(
          identical(AppAnalyticsService.instance, AppAnalyticsService()),
          true,
        );
      });

      test('AppPerformanceService is singleton', () {
        expect(
          identical(AppPerformanceService.instance, AppPerformanceService()),
          true,
        );
      });
    });

    group('Guard behavior without Firebase', () {
      test('analytics initialize is no-op without Firebase', () async {
        await AppAnalyticsService.instance.initialize();
        // No exception → success
      });

      test('analytics logEvent is no-op without Firebase', () async {
        await AppAnalyticsService.instance.logEvent('test_event');
        // No exception → success
      });

      test('performance trace executes callback without Firebase', () async {
        final result = await AppPerformanceService.instance.trace(
          'test',
          () async => 42,
        );
        expect(result, 42);
      });

      test('performance startTrace returns null without Firebase', () async {
        final trace = await AppPerformanceService.instance.startTrace('test');
        expect(trace, isNull);
      });
    });

    group('Error propagation through traces', () {
      test('performance trace rethrows exceptions', () async {
        expect(
          () => AppPerformanceService.instance.trace(
            'failing',
            () async => throw StateError('boom'),
          ),
          throwsStateError,
        );
      });

      test('analytics does not throw on logEvent failure', () async {
        // With no Firebase, logEvent should be a silent no-op
        await AppAnalyticsService.instance.logEvent(
          'test',
          parameters: {'key': 'value'},
        );
        // No exception → success
      });
    });
  });
}
