// Tests for UseCase base interface and NoParams class
// Validates base use case contract and parameter handling

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/usecases/usecase.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

// Test implementations
class TestUseCase implements UseCase<String, TestParams> {
  @override
  Future<Either<AppFailure, String>> call(TestParams params) async {
    if (params.value.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Value cannot be empty',
        field: 'value',
      ));
    }
    return Right('Result: ${params.value}');
  }
}

class TestUseCaseWithNoParams implements UseCase<int, NoParams> {
  @override
  Future<Either<AppFailure, int>> call(NoParams params) async {
    return const Right(42);
  }
}

class TestParams {
  final String value;

  const TestParams(this.value);
}

void main() {
  group('UseCase', () {
    group('UseCase interface implementation', () {
      late TestUseCase useCase;

      setUp(() {
        useCase = TestUseCase();
      });

      test('should return success result when call succeeds', () async {
        // arrange
        const params = TestParams('test-value');

        // act
        final result = await useCase.call(params);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (value) => expect(value, equals('Result: test-value')),
        );
      });

      test('should return failure when validation fails', () async {
        // arrange
        const params = TestParams('');

        // act
        final result = await useCase.call(params);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure,
                equals(const AppFailure.validation(
                  message: 'Value cannot be empty',
                  field: 'value',
                )));
          },
          (value) => fail('Expected failure but got success: $value'),
        );
      });

      test('should handle different parameter values', () async {
        // arrange
        const params1 = TestParams('first');
        const params2 = TestParams('second');

        // act
        final result1 = await useCase.call(params1);
        final result2 = await useCase.call(params2);

        // assert
        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);

        result1.fold(
          (failure) => fail('Expected success for first call'),
          (value) => expect(value, equals('Result: first')),
        );

        result2.fold(
          (failure) => fail('Expected success for second call'),
          (value) => expect(value, equals('Result: second')),
        );
      });
    });

    group('UseCase with NoParams', () {
      late TestUseCaseWithNoParams useCase;

      setUp(() {
        useCase = TestUseCaseWithNoParams();
      });

      test('should work with NoParams parameter', () async {
        // arrange
        const params = NoParams();

        // act
        final result = await useCase.call(params);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (value) => expect(value, equals(42)),
        );
      });

      test('should handle multiple calls with same NoParams instance',
          () async {
        // arrange
        const params = NoParams();

        // act
        final result1 = await useCase.call(params);
        final result2 = await useCase.call(params);

        // assert
        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);

        result1.fold(
          (failure) => fail('Expected success for first call'),
          (value) => expect(value, equals(42)),
        );

        result2.fold(
          (failure) => fail('Expected success for second call'),
          (value) => expect(value, equals(42)),
        );
      });
    });

    group('NoParams', () {
      test('should create NoParams instances', () {
        // act
        const params1 = NoParams();
        const params2 = NoParams();

        // assert
        expect(params1, isA<NoParams>());
        expect(params2, isA<NoParams>());
        expect(params1, equals(params2));
      });

      test('should be usable as const constructor', () {
        // This test verifies that NoParams can be used as a const constructor
        // and doesn't throw any compilation errors

        // arrange & act
        const noParams = NoParams();

        // assert
        expect(noParams, isNotNull);
        expect(noParams, isA<NoParams>());
      });
    });
  });
}
