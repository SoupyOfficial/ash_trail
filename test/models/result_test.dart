import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/app_error.dart';
import 'package:ash_trail/models/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('isSuccess returns true', () {
        const result = Result.success(42);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('valueOrNull returns value', () {
        const result = Result.success('hello');
        expect(result.valueOrNull, 'hello');
      });

      test('errorOrNull returns null', () {
        const result = Result.success(42);
        expect(result.errorOrNull, isNull);
      });

      test('valueOrThrow returns value', () {
        const result = Result.success(42);
        expect(result.valueOrThrow, 42);
      });

      test('toString includes value', () {
        const result = Result.success(42);
        expect(result.toString(), 'Success(42)');
      });
    });

    group('Failure', () {
      test('isFailure returns true', () {
        final result = Result<int>.failure(
          AppError.database(message: 'write failed'),
        );
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('valueOrNull returns null', () {
        final result = Result<int>.failure(
          AppError.database(message: 'write failed'),
        );
        expect(result.valueOrNull, isNull);
      });

      test('errorOrNull returns error', () {
        final error = AppError.database(message: 'write failed');
        final result = Result<int>.failure(error);
        expect(result.errorOrNull, error);
      });

      test('valueOrThrow throws AppError', () {
        final result = Result<int>.failure(
          AppError.database(message: 'write failed'),
        );
        expect(() => result.valueOrThrow, throwsA(isA<AppError>()));
      });
    });

    group('when', () {
      test('calls success callback on success', () {
        const result = Result.success(10);
        final value = result.when(success: (v) => v * 2, failure: (e) => -1);
        expect(value, 20);
      });

      test('calls failure callback on failure', () {
        final result = Result<int>.failure(AppError.network());
        final value = result.when(success: (v) => v * 2, failure: (e) => -1);
        expect(value, -1);
      });
    });

    group('map', () {
      test('transforms success value', () {
        const result = Result.success(10);
        final mapped = result.map((v) => v.toString());
        expect(mapped.valueOrNull, '10');
      });

      test('preserves failure', () {
        final error = AppError.network();
        final result = Result<int>.failure(error);
        final mapped = result.map((v) => v.toString());
        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull, error);
      });
    });

    group('flatMap', () {
      test('chains successful operations', () {
        const result = Result.success(10);
        final chained = result.flatMap((v) => Result.success(v * 3));
        expect(chained.valueOrNull, 30);
      });

      test('short-circuits on failure', () {
        final error = AppError.network();
        final result = Result<int>.failure(error);
        final chained = result.flatMap((v) => Result.success(v * 3));
        expect(chained.isFailure, isTrue);
      });

      test('inner failure propagates', () {
        const result = Result.success(10);
        final chained = result.flatMap<String>(
          (v) => Result.failure(AppError.validation(message: 'bad')),
        );
        expect(chained.isFailure, isTrue);
        expect(chained.errorOrNull?.message, 'bad');
      });
    });
  });
}
