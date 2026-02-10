import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/app_error.dart';

void main() {
  group('AppError', () {
    group('named constructors', () {
      test('validation creates warning-severity error', () {
        const error = AppError.validation(
          message: 'Name is required',
          code: 'VALIDATION_NAME_REQUIRED',
        );

        expect(error.message, 'Name is required');
        expect(error.category, ErrorCategory.validation);
        expect(error.severity, ErrorSeverity.warning);
        expect(error.code, 'VALIDATION_NAME_REQUIRED');
      });

      test('auth creates error-severity error', () {
        final error = AppError.auth(
          message: 'Invalid credentials',
          code: 'AUTH_INVALID_CREDS',
        );

        expect(error.category, ErrorCategory.auth);
        expect(error.severity, ErrorSeverity.error);
        expect(error.code, 'AUTH_INVALID_CREDS');
      });

      test('network creates warning-severity error with default message', () {
        final error = AppError.network();

        expect(error.category, ErrorCategory.network);
        expect(error.severity, ErrorSeverity.warning);
        expect(error.message, contains('internet'));
      });

      test('database creates error-severity error', () {
        final error = AppError.database(
          message: 'Write failed',
          originalError: Exception('disk full'),
        );

        expect(error.category, ErrorCategory.database);
        expect(error.severity, ErrorSeverity.error);
        expect(error.originalError, isA<Exception>());
      });

      test('sync creates warning-severity error', () {
        final error = AppError.sync(message: 'Sync timed out');

        expect(error.category, ErrorCategory.sync);
        expect(error.severity, ErrorSeverity.warning);
      });

      test('platform creates warning-severity error', () {
        final error = AppError.platform(
          message: 'Location denied',
          code: 'PLATFORM_LOCATION_DENIED',
        );

        expect(error.category, ErrorCategory.platform);
        expect(error.severity, ErrorSeverity.warning);
      });

      test('unexpected wraps original error', () {
        final original = StateError('bad state');
        final error = AppError.unexpected(originalError: original);

        expect(error.category, ErrorCategory.unexpected);
        expect(error.severity, ErrorSeverity.error);
        expect(error.originalError, original);
        expect(error.technicalDetail, contains('bad state'));
      });
    });

    group('AppError.from auto-classification', () {
      test('returns same AppError if already an AppError', () {
        const original = AppError.validation(message: 'test');
        final result = AppError.from(original);
        expect(identical(result, original), isTrue);
      });

      test('classifies ArgumentError as validation', () {
        final error = AppError.from(ArgumentError('bad arg'));
        expect(error.category, ErrorCategory.validation);
      });

      test('classifies network-related exceptions', () {
        final error = AppError.from(
          Exception('SocketException: connection refused'),
        );
        expect(error.category, ErrorCategory.network);
      });

      test('classifies timeout exceptions', () {
        final error = AppError.from(Exception('Connection timeout'));
        expect(error.category, ErrorCategory.network);
      });

      test('classifies hive/database exceptions', () {
        final error = AppError.from(Exception('HiveError: box not found'));
        expect(error.category, ErrorCategory.database);
      });

      test('classifies permission denied exceptions', () {
        final error = AppError.from(Exception('Permission denied'));
        expect(error.category, ErrorCategory.platform);
      });

      test('unknown exceptions become unexpected', () {
        final error = AppError.from(Exception('something weird'));
        expect(error.category, ErrorCategory.unexpected);
      });
    });

    group('toString / toLogString', () {
      test('toString returns user-facing message', () {
        const error = AppError.validation(message: 'Name is required');
        expect(error.toString(), 'Name is required');
      });

      test('toLogString includes category, severity, and code', () {
        const error = AppError.validation(
          message: 'Name is required',
          code: 'VALIDATION_NAME_REQUIRED',
        );

        final log = error.toLogString();
        expect(log, contains('[VALIDATION]'));
        expect(log, contains('[WARNING]'));
        expect(log, contains('[VALIDATION_NAME_REQUIRED]'));
        expect(log, contains('Name is required'));
      });
    });
  });
}
