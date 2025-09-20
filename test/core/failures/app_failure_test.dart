import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFailure', () {
    group('constructors', () {
      test('should create unexpected failure', () {
        const failure = AppFailure.unexpected(
          message: 'Test error',
          cause: 'Test cause',
        );

        expect(failure, isA<AppFailure>());
        expect(failure.displayMessage, equals('Test error'));

        // Test that the failure is the expected type
        expect(failure.toString(), contains('unexpected'));
      });

      test('should create network failure', () {
        const failure = AppFailure.network(
          message: 'Network error',
          statusCode: 404,
        );

        expect(failure, isA<AppFailure>());
        expect(failure.displayMessage, equals('Network error'));
      });

      test('should create cache failure', () {
        const failure = AppFailure.cache(message: 'Cache error');

        expect(failure, isA<AppFailure>());
        expect(failure.displayMessage, equals('Cache error'));
      });

      test('should create validation failure', () {
        const failure = AppFailure.validation(
          message: 'Invalid input',
          field: 'email',
        );

        expect(failure, isA<AppFailure>());
        expect(failure.displayMessage, equals('Invalid input'));
      });

      test('should create notFound failure', () {
        const failure = AppFailure.notFound(
          message: 'Not found',
          resourceId: '123',
        );

        expect(failure, isA<AppFailure>());
        expect(failure.displayMessage, equals('Not found'));
      });

      test('should create conflict failure', () {
        const failure = AppFailure.conflict(message: 'Conflict error');

        expect(failure, isA<AppFailure>());
        expect(failure.displayMessage, equals('Conflict error'));
      });
    });

    group('displayMessage', () {
      test(
          'should return default message for network failure when message is null',
          () {
        const failure = AppFailure.network();
        expect(failure.displayMessage, equals('Network error, please retry.'));
      });

      test(
          'should return default message for cache failure when message is null',
          () {
        const failure = AppFailure.cache();
        expect(failure.displayMessage, equals('Local storage error.'));
      });

      test(
          'should return default message for notFound failure when message is null',
          () {
        const failure = AppFailure.notFound();
        expect(failure.displayMessage, equals('Requested resource not found.'));
      });

      test(
          'should return default message for conflict failure when message is null',
          () {
        const failure = AppFailure.conflict();
        expect(failure.displayMessage, equals('Update conflict occurred.'));
      });

      test(
          'should return default message for unexpected failure when message is null',
          () {
        const failure = AppFailure.unexpected();
        expect(failure.displayMessage, equals('Something went wrong.'));
      });
    });

    group('displayMessage switch expressions', () {
      test('should exercise all branches of displayMessage switch', () {
        // Test each type to ensure switch expression coverage
        const unexpectedFailure =
            AppFailure.unexpected(message: 'Custom unexpected');
        expect(unexpectedFailure.displayMessage, equals('Custom unexpected'));

        const networkFailure = AppFailure.network(message: 'Custom network');
        expect(networkFailure.displayMessage, equals('Custom network'));

        const cacheFailure = AppFailure.cache(message: 'Custom cache');
        expect(cacheFailure.displayMessage, equals('Custom cache'));

        const validationFailure =
            AppFailure.validation(message: 'Custom validation');
        expect(validationFailure.displayMessage, equals('Custom validation'));

        const notFoundFailure =
            AppFailure.notFound(message: 'Custom not found');
        expect(notFoundFailure.displayMessage, equals('Custom not found'));

        const conflictFailure = AppFailure.conflict(message: 'Custom conflict');
        expect(conflictFailure.displayMessage, equals('Custom conflict'));
      });
    });
  });
}
