import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/app_error.dart';
import 'package:ash_trail/services/error_reporting_service.dart';

void main() {
  late ErrorReportingService service;

  setUp(() {
    service = ErrorReportingService.instance;
    service.reset();
  });

  group('ErrorReportingService', () {
    test('increments error counts by category', () {
      service.report(AppError.network());
      service.report(AppError.network());
      service.report(AppError.database(message: 'db fail'));

      final diag = service.diagnostics;
      final counts = diag['errorCounts'] as Map<String, dynamic>;
      expect(counts['network'], 2);
      expect(counts['database'], 1);
    });

    test('tracks recent errors up to max buffer', () {
      for (int i = 0; i < 55; i++) {
        service.report(AppError.validation(message: 'err $i'));
      }

      final diag = service.diagnostics;
      // Buffer max is 50
      expect(diag['recentErrorCount'], 50);
    });

    test('reportException auto-classifies raw exceptions', () {
      service.reportException(
        ArgumentError('bad input'),
        context: 'TestContext',
      );

      final diag = service.diagnostics;
      final counts = diag['errorCounts'] as Map<String, dynamic>;
      expect(counts['validation'], 1);
    });

    test('reportException passes through AppError unchanged', () {
      const appError = AppError.validation(message: 'already typed');
      service.reportException(appError, context: 'Test');

      final diag = service.diagnostics;
      final counts = diag['errorCounts'] as Map<String, dynamic>;
      expect(counts['validation'], 1);
    });

    test('guard returns null on failure', () async {
      final result = await service.guard<int>(
        () async => throw Exception('boom'),
        context: 'TestGuard',
      );

      expect(result, isNull);

      final diag = service.diagnostics;
      final counts = diag['errorCounts'] as Map<String, dynamic>;
      expect(counts['unexpected'], 1);
    });

    test('guard returns value on success', () async {
      final result = await service.guard<int>(
        () async => 42,
        context: 'TestGuard',
      );

      expect(result, 42);
    });

    test('guardSync returns null on failure', () {
      final result = service.guardSync<int>(
        () => throw StateError('bad'),
        context: 'TestGuardSync',
      );

      expect(result, isNull);
    });

    test('guardSync returns value on success', () {
      final result = service.guardSync<int>(() => 99, context: 'TestGuardSync');

      expect(result, 99);
    });

    test('reset clears counts and recent errors', () {
      service.report(AppError.network());
      service.report(AppError.network());

      service.reset();

      final diag = service.diagnostics;
      final counts = diag['errorCounts'] as Map<String, dynamic>;
      expect(counts, isEmpty);
      expect(diag['recentErrorCount'], 0);
    });

    test('diagnostics returns structured data', () {
      service.report(
        AppError.auth(message: 'auth fail', code: 'AUTH_TEST'),
        context: 'TestDiag',
      );

      final diag = service.diagnostics;
      expect(diag, containsPair('errorCounts', isA<Map>()));
      expect(diag, containsPair('recentErrorCount', 1));
      expect(diag, containsPair('recentErrors', isA<List>()));

      final recentList = diag['recentErrors'] as List;
      expect(recentList.first['category'], 'auth');
      expect(recentList.first['code'], 'AUTH_TEST');
      expect(recentList.first['context'], 'TestDiag');
    });
  });
}
