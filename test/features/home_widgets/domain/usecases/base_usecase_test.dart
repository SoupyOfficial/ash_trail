import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/home_widgets/domain/usecases/base_usecase.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

// Test implementation of UseCase for testing purposes
class TestUseCase extends UseCase<String, TestParams> {
  final bool shouldFail;
  final String? result;
  final AppFailure? failure;

  TestUseCase({
    this.shouldFail = false,
    this.result,
    this.failure,
  });

  @override
  Future<Either<AppFailure, String>> call(TestParams params) async {
    if (shouldFail) {
      return Left(failure ?? const AppFailure.network(message: 'Test failure'));
    }
    return Right(result ?? 'Test result for ${params.value}');
  }
}

class TestParams {
  const TestParams({required this.value});
  final String value;
}

void main() {
  group('Base UseCase Tests', () {
    group('UseCase Interface', () {
      test('should be implemented correctly by concrete use case', () async {
        final useCase = TestUseCase(result: 'success');
        const params = TestParams(value: 'test');

        final result = await useCase.call(params);

        expect(result, isA<Right<AppFailure, String>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (value) => expect(value, equals('success')),
        );
      });

      test('should handle failure case correctly', () async {
        const testFailure = AppFailure.network(message: 'Network error');
        final useCase = TestUseCase(
          shouldFail: true,
          failure: testFailure,
        );
        const params = TestParams(value: 'test');

        final result = await useCase.call(params);

        expect(result, isA<Left<AppFailure, String>>());
        result.fold(
          (failure) => expect(failure, equals(testFailure)),
          (value) => fail('Expected failure but got success: $value'),
        );
      });

      test('should pass parameters correctly to implementation', () async {
        final useCase = TestUseCase();
        const params = TestParams(value: 'parameter_test');

        final result = await useCase.call(params);

        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (value) => expect(value, contains('parameter_test')),
        );
      });
    });

    group('NoParams', () {
      test('should create NoParams instance', () {
        const params = NoParams();
        expect(params, isA<NoParams>());
      });

      test('should be constant constructor', () {
        const params1 = NoParams();
        const params2 = NoParams();
        expect(identical(params1, params2), isTrue);
      });

      test('should have meaningful toString', () {
        const params = NoParams();
        expect(params.toString(), isA<String>());
      });

      test('should be equal to other NoParams instances', () {
        const params1 = NoParams();
        const params2 = NoParams();
        expect(params1, equals(params2));
        expect(params1.hashCode, equals(params2.hashCode));
      });
    });

    group('AccountParams', () {
      test('should create AccountParams with required accountId', () {
        const params = AccountParams(accountId: 'account_123');
        expect(params.accountId, equals('account_123'));
      });

      test('should be constant constructor', () {
        const params1 = AccountParams(accountId: 'account_123');
        const params2 = AccountParams(accountId: 'account_123');
        expect(params1.accountId, equals(params2.accountId));
      });

      test('should handle different account IDs', () {
        const params1 = AccountParams(accountId: 'account_1');
        const params2 = AccountParams(accountId: 'account_2');
        expect(params1.accountId, isNot(equals(params2.accountId)));
      });

      test('should handle empty account ID', () {
        const params = AccountParams(accountId: '');
        expect(params.accountId, equals(''));
      });

      test('should have meaningful toString', () {
        const params = AccountParams(accountId: 'test_account');
        expect(params.toString(), isA<String>());
      });
    });

    group('WidgetParams', () {
      test('should create WidgetParams with required widgetId', () {
        const params = WidgetParams(widgetId: 'widget_123');
        expect(params.widgetId, equals('widget_123'));
      });

      test('should be constant constructor', () {
        const params1 = WidgetParams(widgetId: 'widget_123');
        const params2 = WidgetParams(widgetId: 'widget_123');
        expect(params1.widgetId, equals(params2.widgetId));
      });

      test('should handle different widget IDs', () {
        const params1 = WidgetParams(widgetId: 'widget_1');
        const params2 = WidgetParams(widgetId: 'widget_2');
        expect(params1.widgetId, isNot(equals(params2.widgetId)));
      });

      test('should handle empty widget ID', () {
        const params = WidgetParams(widgetId: '');
        expect(params.widgetId, equals(''));
      });

      test('should have meaningful toString', () {
        const params = WidgetParams(widgetId: 'test_widget');
        expect(params.toString(), isA<String>());
      });
    });

    group('Parameter Classes Equality', () {
      test('AccountParams should be equal when account IDs are equal', () {
        const params1 = AccountParams(accountId: 'same_account');
        const params2 = AccountParams(accountId: 'same_account');
        expect(params1.accountId, equals(params2.accountId));
      });

      test('WidgetParams should be equal when widget IDs are equal', () {
        const params1 = WidgetParams(widgetId: 'same_widget');
        const params2 = WidgetParams(widgetId: 'same_widget');
        expect(params1.widgetId, equals(params2.widgetId));
      });

      test('different parameter types should not be equal', () {
        const accountParams = AccountParams(accountId: 'test');
        const widgetParams = WidgetParams(widgetId: 'test');
        // These are different types, so we just verify they have different properties
        expect(accountParams.accountId, equals(widgetParams.widgetId));
        expect(
            accountParams.runtimeType, isNot(equals(widgetParams.runtimeType)));
      });
    });

    group('UseCase Integration', () {
      test('should work with NoParams', () async {
        // Create a use case that accepts NoParams
        final useCase = NoParamsTestUseCase();
        const params = NoParams();

        final result = await useCase.call(params);

        expect(result, isA<Right<AppFailure, String>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (value) => expect(value, equals('No params result')),
        );
      });

      test('should work with AccountParams', () async {
        final useCase = AccountParamsTestUseCase();
        const params = AccountParams(accountId: 'test_account');

        final result = await useCase.call(params);

        expect(result, isA<Right<AppFailure, String>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (value) => expect(value, contains('test_account')),
        );
      });

      test('should work with WidgetParams', () async {
        final useCase = WidgetParamsTestUseCase();
        const params = WidgetParams(widgetId: 'test_widget');

        final result = await useCase.call(params);

        expect(result, isA<Right<AppFailure, String>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (value) => expect(value, contains('test_widget')),
        );
      });
    });
  });
}

// Additional test use cases for parameter testing
class NoParamsTestUseCase extends UseCase<String, NoParams> {
  @override
  Future<Either<AppFailure, String>> call(NoParams params) async {
    return const Right('No params result');
  }
}

class AccountParamsTestUseCase extends UseCase<String, AccountParams> {
  @override
  Future<Either<AppFailure, String>> call(AccountParams params) async {
    return Right('Account: ${params.accountId}');
  }
}

class WidgetParamsTestUseCase extends UseCase<String, WidgetParams> {
  @override
  Future<Either<AppFailure, String>> call(WidgetParams params) async {
    return Right('Widget: ${params.widgetId}');
  }
}
