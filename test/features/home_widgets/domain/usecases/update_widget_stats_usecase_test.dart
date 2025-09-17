import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/home_widgets/domain/usecases/update_widget_stats_usecase.dart';
import 'package:ash_trail/features/home_widgets/domain/repositories/home_widgets_repository.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_data.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_size.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockHomeWidgetsRepository extends Mock implements HomeWidgetsRepository {}

void main() {
  group('UpdateWidgetStatsUseCase', () {
    late UpdateWidgetStatsUseCase useCase;
    late MockHomeWidgetsRepository mockRepository;

    setUp(() {
      mockRepository = MockHomeWidgetsRepository();
      useCase = UpdateWidgetStatsUseCase(mockRepository);
    });

    group('Success Cases', () {
      test('should update widget stats successfully with valid parameters', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: 'widget_123',
          todayHitCount: 10,
          currentStreak: 5,
        );

        final expectedWidget = WidgetData(
          id: 'widget_123',
          accountId: 'account_456',
          size: WidgetSize.medium,
          tapAction: WidgetTapAction.openApp,
          todayHitCount: 10,
          currentStreak: 5,
          lastSyncAt: DateTime(2023, 1, 15, 12, 0),
          createdAt: DateTime(2023, 1, 14, 10, 30),
        );

        when(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_123',
              todayHitCount: 10,
              currentStreak: 5,
            )).thenAnswer((_) async => Right(expectedWidget));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Right<AppFailure, WidgetData>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (widget) {
            expect(widget, equals(expectedWidget));
            expect(widget.todayHitCount, equals(10));
            expect(widget.currentStreak, equals(5));
          },
        );

        verify(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_123',
              todayHitCount: 10,
              currentStreak: 5,
            )).called(1);
      });

      test('should handle zero hit count and streak', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: 'widget_zero',
          todayHitCount: 0,
          currentStreak: 0,
        );

        final expectedWidget = WidgetData(
          id: 'widget_zero',
          accountId: 'account_456',
          size: WidgetSize.small,
          tapAction: WidgetTapAction.quickRecord,
          todayHitCount: 0,
          currentStreak: 0,
          lastSyncAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        when(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_zero',
              todayHitCount: 0,
              currentStreak: 0,
            )).thenAnswer((_) async => Right(expectedWidget));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Right<AppFailure, WidgetData>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (widget) {
            expect(widget.todayHitCount, equals(0));
            expect(widget.currentStreak, equals(0));
          },
        );

        verify(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_zero',
              todayHitCount: 0,
              currentStreak: 0,
            )).called(1);
      });

      test('should handle large hit count and streak values', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: 'widget_large',
          todayHitCount: 999,
          currentStreak: 365,
        );

        final expectedWidget = WidgetData(
          id: 'widget_large',
          accountId: 'account_456',
          size: WidgetSize.extraLarge,
          tapAction: WidgetTapAction.viewLogs,
          todayHitCount: 999,
          currentStreak: 365,
          lastSyncAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
        );

        when(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_large',
              todayHitCount: 999,
              currentStreak: 365,
            )).thenAnswer((_) async => Right(expectedWidget));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Right<AppFailure, WidgetData>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (widget) {
            expect(widget.todayHitCount, equals(999));
            expect(widget.currentStreak, equals(365));
          },
        );

        verify(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_large',
              todayHitCount: 999,
              currentStreak: 365,
            )).called(1);
      });
    });

    group('Validation Cases', () {
      test('should return validation failure when widget ID is empty', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: '',
          todayHitCount: 5,
          currentStreak: 3,
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, WidgetData>>());
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            failure.when(
              unexpected: (_, __, ___) => fail('Expected validation failure'),
              network: (_, __) => fail('Expected validation failure'),
              cache: (_) => fail('Expected validation failure'),
              validation: (message, field) {
                expect(message, equals('Widget ID cannot be empty'));
                expect(field, equals('widgetId'));
              },
              notFound: (_, __) => fail('Expected validation failure'),
              conflict: (_) => fail('Expected validation failure'),
            );
          },
          (widget) => fail('Expected failure but got success: $widget'),
        );

        verifyNever(() => mockRepository.updateWidgetStats(
              widgetId: any(named: 'widgetId'),
              todayHitCount: any(named: 'todayHitCount'),
              currentStreak: any(named: 'currentStreak'),
            ));
      });

      test('should return validation failure when hit count is negative', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: 'widget_123',
          todayHitCount: -1,
          currentStreak: 3,
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, WidgetData>>());
        result.fold(
          (failure) {
            failure.when(
              unexpected: (_, __, ___) => fail('Expected validation failure'),
              network: (_, __) => fail('Expected validation failure'),
              cache: (_) => fail('Expected validation failure'),
              validation: (message, field) {
                expect(message, equals('Hit count cannot be negative'));
                expect(field, equals('todayHitCount'));
              },
              notFound: (_, __) => fail('Expected validation failure'),
              conflict: (_) => fail('Expected validation failure'),
            );
          },
          (widget) => fail('Expected failure but got success: $widget'),
        );

        verifyNever(() => mockRepository.updateWidgetStats(
              widgetId: any(named: 'widgetId'),
              todayHitCount: any(named: 'todayHitCount'),
              currentStreak: any(named: 'currentStreak'),
            ));
      });

      test('should return validation failure when streak is negative', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: 'widget_123',
          todayHitCount: 5,
          currentStreak: -2,
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, WidgetData>>());
        result.fold(
          (failure) {
            failure.when(
              unexpected: (_, __, ___) => fail('Expected validation failure'),
              network: (_, __) => fail('Expected validation failure'),
              cache: (_) => fail('Expected validation failure'),
              validation: (message, field) {
                expect(message, equals('Streak cannot be negative'));
                expect(field, equals('currentStreak'));
              },
              notFound: (_, __) => fail('Expected validation failure'),
              conflict: (_) => fail('Expected validation failure'),
            );
          },
          (widget) => fail('Expected failure but got success: $widget'),
        );

        verifyNever(() => mockRepository.updateWidgetStats(
              widgetId: any(named: 'widgetId'),
              todayHitCount: any(named: 'todayHitCount'),
              currentStreak: any(named: 'currentStreak'),
            ));
      });

      test('should validate all parameters and return first error', () async {
        // Arrange - Multiple validation errors, should return first one encountered
        const params = UpdateWidgetStatsParams(
          widgetId: '', // First error - empty widget ID
          todayHitCount: -5, // Second error - negative hit count
          currentStreak: -3, // Third error - negative streak
        );

        // Act
        final result = await useCase.call(params);

        // Assert - Should return the first validation error (widget ID)
        expect(result, isA<Left<AppFailure, WidgetData>>());
        result.fold(
          (failure) {
            failure.when(
              unexpected: (_, __, ___) => fail('Expected validation failure'),
              network: (_, __) => fail('Expected validation failure'),
              cache: (_) => fail('Expected validation failure'),
              validation: (message, field) {
                expect(message, equals('Widget ID cannot be empty'));
                expect(field, equals('widgetId'));
              },
              notFound: (_, __) => fail('Expected validation failure'),
              conflict: (_) => fail('Expected validation failure'),
            );
          },
          (widget) => fail('Expected failure but got success: $widget'),
        );
      });
    });

    group('Repository Failure Cases', () {
      test('should return network failure when repository fails', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: 'widget_123',
          todayHitCount: 7,
          currentStreak: 4,
        );
        const expectedFailure = AppFailure.network(
          message: 'Failed to update widget stats',
          statusCode: 500,
        );

        when(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_123',
              todayHitCount: 7,
              currentStreak: 4,
            )).thenAnswer((_) async => const Left(expectedFailure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, WidgetData>>());
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (widget) => fail('Expected failure but got success: $widget'),
        );

        verify(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_123',
              todayHitCount: 7,
              currentStreak: 4,
            )).called(1);
      });

      test('should return not found failure when widget does not exist', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: 'nonexistent_widget',
          todayHitCount: 1,
          currentStreak: 1,
        );
        const expectedFailure = AppFailure.notFound(
          message: 'Widget not found',
          resourceId: 'nonexistent_widget',
        );

        when(() => mockRepository.updateWidgetStats(
              widgetId: 'nonexistent_widget',
              todayHitCount: 1,
              currentStreak: 1,
            )).thenAnswer((_) async => const Left(expectedFailure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, WidgetData>>());
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (widget) => fail('Expected failure but got success: $widget'),
        );

        verify(() => mockRepository.updateWidgetStats(
              widgetId: 'nonexistent_widget',
              todayHitCount: 1,
              currentStreak: 1,
            )).called(1);
      });

      test('should return cache failure when local storage fails', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: 'widget_123',
          todayHitCount: 15,
          currentStreak: 8,
        );
        const expectedFailure = AppFailure.cache(
          message: 'Failed to update local cache',
        );

        when(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_123',
              todayHitCount: 15,
              currentStreak: 8,
            )).thenAnswer((_) async => const Left(expectedFailure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Left<AppFailure, WidgetData>>());
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (widget) => fail('Expected failure but got success: $widget'),
        );

        verify(() => mockRepository.updateWidgetStats(
              widgetId: 'widget_123',
              todayHitCount: 15,
              currentStreak: 8,
            )).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle widget ID with special characters', () async {
        // Arrange
        const params = UpdateWidgetStatsParams(
          widgetId: 'widget-123_test@domain',
          todayHitCount: 3,
          currentStreak: 2,
        );

        final expectedWidget = WidgetData(
          id: 'widget-123_test@domain',
          accountId: 'account_456',
          size: WidgetSize.medium,
          tapAction: WidgetTapAction.openApp,
          todayHitCount: 3,
          currentStreak: 2,
          lastSyncAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        when(() => mockRepository.updateWidgetStats(
              widgetId: 'widget-123_test@domain',
              todayHitCount: 3,
              currentStreak: 2,
            )).thenAnswer((_) async => Right(expectedWidget));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Right<AppFailure, WidgetData>>());
        verify(() => mockRepository.updateWidgetStats(
              widgetId: 'widget-123_test@domain',
              todayHitCount: 3,
              currentStreak: 2,
            )).called(1);
      });

      test('should handle very long widget ID', () async {
        // Arrange
        final longWidgetId = 'widget_${'a' * 500}';
        final params = UpdateWidgetStatsParams(
          widgetId: longWidgetId,
          todayHitCount: 1,
          currentStreak: 1,
        );

        final expectedWidget = WidgetData(
          id: longWidgetId,
          accountId: 'account_456',
          size: WidgetSize.medium,
          tapAction: WidgetTapAction.openApp,
          todayHitCount: 1,
          currentStreak: 1,
          lastSyncAt: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        when(() => mockRepository.updateWidgetStats(
              widgetId: longWidgetId,
              todayHitCount: 1,
              currentStreak: 1,
            )).thenAnswer((_) async => Right(expectedWidget));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result, isA<Right<AppFailure, WidgetData>>());
        verify(() => mockRepository.updateWidgetStats(
              widgetId: longWidgetId,
              todayHitCount: 1,
              currentStreak: 1,
            )).called(1);
      });
    });

    group('UpdateWidgetStatsParams', () {
      test('should create params with all required fields', () {
        // Arrange & Act
        const params = UpdateWidgetStatsParams(
          widgetId: 'test_widget',
          todayHitCount: 10,
          currentStreak: 5,
        );

        // Assert
        expect(params.widgetId, equals('test_widget'));
        expect(params.todayHitCount, equals(10));
        expect(params.currentStreak, equals(5));
      });

      test('should be constant constructor', () {
        // Arrange & Act
        const params1 = UpdateWidgetStatsParams(
          widgetId: 'widget_123',
          todayHitCount: 7,
          currentStreak: 3,
        );
        const params2 = UpdateWidgetStatsParams(
          widgetId: 'widget_123',
          todayHitCount: 7,
          currentStreak: 3,
        );

        // Assert
        expect(params1.widgetId, equals(params2.widgetId));
        expect(params1.todayHitCount, equals(params2.todayHitCount));
        expect(params1.currentStreak, equals(params2.currentStreak));
      });
    });
  });
}