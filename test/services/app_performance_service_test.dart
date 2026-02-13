import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/app_performance_service.dart';

void main() {
  group('AppPerformanceService', () {
    test('singleton returns same instance', () {
      final a = AppPerformanceService.instance;
      final b = AppPerformanceService();
      expect(identical(a, b), true);
    });

    test('trace executes operation when Firebase not initialized', () async {
      // Firebase.apps.isEmpty == true in test environment
      final result = await AppPerformanceService.instance.trace(
        'test_trace',
        () async => 42,
      );
      expect(result, 42);
    });

    test(
      'traceStartup executes operation when Firebase not initialized',
      () async {
        final result = await AppPerformanceService.instance.traceStartup(
          'test_phase',
          () async => 'done',
        );
        expect(result, 'done');
      },
    );

    test(
      'traceSync executes operation when Firebase not initialized',
      () async {
        final result = await AppPerformanceService.instance.traceSync(
          () async => true,
          attributes: {'sync_type': 'push'},
        );
        expect(result, true);
      },
    );

    test(
      'traceTokenRefresh executes operation when Firebase not initialized',
      () async {
        final result = await AppPerformanceService.instance.traceTokenRefresh(
          () async => 'token_value',
        );
        expect(result, 'token_value');
      },
    );

    test('trace propagates exceptions when Firebase not initialized', () async {
      expect(
        () => AppPerformanceService.instance.trace(
          'failing_trace',
          () async => throw Exception('test'),
        ),
        throwsException,
      );
    });

    test('startTrace returns null when Firebase not initialized', () async {
      final trace = await AppPerformanceService.instance.startTrace('test');
      expect(trace, isNull);
    });

    test(
      'traceExport executes operation when Firebase not initialized',
      () async {
        final result = await AppPerformanceService.instance.traceExport(
          () async => 'csv_data',
          attributes: {'format': 'csv'},
        );
        expect(result, 'csv_data');
      },
    );

    test(
      'traceGoogleSignIn executes operation when Firebase not initialized',
      () async {
        final result = await AppPerformanceService.instance.traceGoogleSignIn(
          () async => 'user_credential',
        );
        expect(result, 'user_credential');
      },
    );

    test(
      'traceAccountSwitch executes operation when Firebase not initialized',
      () async {
        final result = await AppPerformanceService.instance.traceAccountSwitch(
          () async => 'switched',
        );
        expect(result, 'switched');
      },
    );
  });
}
