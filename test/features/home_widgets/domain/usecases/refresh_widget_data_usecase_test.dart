import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/home_widgets/domain/usecases/refresh_widget_data_usecase.dart';
import 'package:ash_trail/features/home_widgets/domain/usecases/base_usecase.dart';
import 'package:ash_trail/features/home_widgets/domain/repositories/home_widgets_repository.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_data.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_size.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockHomeWidgetsRepository extends Mock implements HomeWidgetsRepository {}

void main() {
  group('RefreshWidgetDataUseCase', () {
    late RefreshWidgetDataUseCase useCase;
    late MockHomeWidgetsRepository mockRepository;

    setUp(() {
      mockRepository = MockHomeWidgetsRepository();
      useCase = RefreshWidgetDataUseCase(mockRepository);
    });

    group('Success Cases', () {
      test('should return list of widgets when repository call succeeds', () async {
        // Arrange
        const accountId = 'test_account_123';
        const params = AccountParams(accountId: accountId);
        
        final expectedWidgets = [
          WidgetData(
            id: 'widget_1',
            accountId: accountId,
            size: WidgetSize.medium,
            tapAction: WidgetTapAction.openApp,
            todayHitCount: 5,
            currentStreak: 3,
            lastSyncAt: DateTime(2023, 1, 15, 10, 30),
            createdAt: DateTime(2023, 1, 14, 10, 30),
          ),
          WidgetData(
            id: 'widget_2',
            accountId: accountId,
            size: WidgetSize.large,
            tapAction: WidgetTapAction.viewLogs,
            todayHitCount: 2,
            currentStreak: 7,
            lastSyncAt: DateTime(2023, 1, 15, 10, 30),
            createdAt: DateTime(2023, 1, 14, 10, 30),
          ),
        ];

        when(() => mockRepository.refreshWidgetData(accountId))
            .thenAnswer((_) async => Right(expectedWidgets));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Right<AppFailure, List<WidgetData>>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (widgets) {
            expect(widgets, hasLength(2));
            expect(widgets, equals(expectedWidgets));
          },
        );

        verify(() => mockRepository.refreshWidgetData(accountId)).called(1);
      });

      test('should return empty list when no widgets exist', () async {
        // Arrange
        const accountId = 'account_with_no_widgets';
        const params = AccountParams(accountId: accountId);
        
        when(() => mockRepository.refreshWidgetData(accountId))
            .thenAnswer((_) async => const Right(<WidgetData>[]));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Right<AppFailure, List<WidgetData>>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (widgets) {
            expect(widgets, hasLength(0));
            expect(widgets, equals(<WidgetData>[]));
          },
        );

        verify(() => mockRepository.refreshWidgetData(accountId)).called(1);
      });
    });

    group('Validation Cases', () {
      test('should return validation failure when account ID is empty', () async {
        // Arrange
        const params = AccountParams(accountId: '');

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, List<WidgetData>>>());
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            failure.when(
              unexpected: (_, __, ___) => fail('Expected validation failure'),
              network: (_, __) => fail('Expected validation failure'),
              cache: (_) => fail('Expected validation failure'),
              validation: (message, field) {
                expect(message, equals('Account ID cannot be empty'));
                expect(field, equals('accountId'));
              },
              notFound: (_, __) => fail('Expected validation failure'),
              conflict: (_) => fail('Expected validation failure'),
            );
          },
          (widgets) => fail('Expected failure but got success: $widgets'),
        );

        verifyNever(() => mockRepository.refreshWidgetData(any()));
      });
    });

    group('Repository Failure Cases', () {
      test('should return network failure when repository fails with network error', () async {
        // Arrange
        const accountId = 'test_account';
        const params = AccountParams(accountId: accountId);
        const expectedFailure = AppFailure.network(
          message: 'Unable to connect to server',
          statusCode: 500,
        );

        when(() => mockRepository.refreshWidgetData(accountId))
            .thenAnswer((_) async => const Left(expectedFailure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, List<WidgetData>>>());
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (widgets) => fail('Expected failure but got success: $widgets'),
        );

        verify(() => mockRepository.refreshWidgetData(accountId)).called(1);
      });

      test('should return cache failure when repository fails with cache error', () async {
        // Arrange
        const accountId = 'test_account';
        const params = AccountParams(accountId: accountId);
        const expectedFailure = AppFailure.cache(
          message: 'Local storage unavailable',
        );

        when(() => mockRepository.refreshWidgetData(accountId))
            .thenAnswer((_) async => const Left(expectedFailure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, List<WidgetData>>>());
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (widgets) => fail('Expected failure but got success: $widgets'),
        );

        verify(() => mockRepository.refreshWidgetData(accountId)).called(1);
      });

      test('should return unexpected failure when repository fails unexpectedly', () async {
        // Arrange
        const accountId = 'test_account';
        const params = AccountParams(accountId: accountId);
        const expectedFailure = AppFailure.unexpected(
          message: 'Something went wrong during refresh',
        );

        when(() => mockRepository.refreshWidgetData(accountId))
            .thenAnswer((_) async => const Left(expectedFailure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, List<WidgetData>>>());
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (widgets) => fail('Expected failure but got success: $widgets'),
        );

        verify(() => mockRepository.refreshWidgetData(accountId)).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle account ID with special characters', () async {
        // Arrange
        const accountId = 'test-account_123@domain.com';
        const params = AccountParams(accountId: accountId);
        
        when(() => mockRepository.refreshWidgetData(accountId))
            .thenAnswer((_) async => const Right(<WidgetData>[]));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Right<AppFailure, List<WidgetData>>>());
        verify(() => mockRepository.refreshWidgetData(accountId)).called(1);
      });

      test('should handle very long account ID', () async {
        // Arrange
        final longAccountId = 'a' * 1000; // Very long account ID
        final params = AccountParams(accountId: longAccountId);
        
        when(() => mockRepository.refreshWidgetData(longAccountId))
            .thenAnswer((_) async => const Right(<WidgetData>[]));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Right<AppFailure, List<WidgetData>>>());
        verify(() => mockRepository.refreshWidgetData(longAccountId)).called(1);
      });

      test('should handle whitespace-only account ID as valid', () async {
        // Arrange
        const accountId = '   '; // Whitespace only
        const params = AccountParams(accountId: accountId);
        
        when(() => mockRepository.refreshWidgetData(accountId))
            .thenAnswer((_) async => const Right(<WidgetData>[]));

        // Act
        final result = await useCase.call(params);

        // Assert  
        // Note: Current implementation treats whitespace as valid, 
        // this test documents existing behavior
        expect(result, isA<Right<AppFailure, List<WidgetData>>>());
        verify(() => mockRepository.refreshWidgetData(accountId)).called(1);
      });
    });
  });
}