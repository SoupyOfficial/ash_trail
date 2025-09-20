// Unit tests for GetAllWidgetsUseCase.
// Tests business logic and error handling for retrieving widget configurations.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_data.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_size.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';
import 'package:ash_trail/features/home_widgets/domain/repositories/home_widgets_repository.dart';
import 'package:ash_trail/features/home_widgets/domain/usecases/get_all_widgets_usecase.dart';
import 'package:ash_trail/features/home_widgets/domain/usecases/base_usecase.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockHomeWidgetsRepository extends Mock implements HomeWidgetsRepository {}

void main() {
  late GetAllWidgetsUseCase useCase;
  late MockHomeWidgetsRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeWidgetsRepository();
    useCase = GetAllWidgetsUseCase(mockRepository);
  });

  group('GetAllWidgetsUseCase', () {
    const testAccountId = 'test-account-123';
    final testWidgets = [
      WidgetData(
        id: 'widget-1',
        accountId: testAccountId,
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.openApp,
        todayHitCount: 5,
        currentStreak: 3,
        lastSyncAt: DateTime(2023, 12, 1, 10, 30),
        createdAt: DateTime(2023, 12, 1, 9, 0),
      ),
      WidgetData(
        id: 'widget-2',
        accountId: testAccountId,
        size: WidgetSize.small,
        tapAction: WidgetTapAction.quickRecord,
        todayHitCount: 2,
        currentStreak: 1,
        lastSyncAt: DateTime(2023, 12, 1, 11, 0),
        createdAt: DateTime(2023, 12, 1, 8, 0),
      ),
    ];

    test('should return list of widgets when repository call succeeds',
        () async {
      // Arrange
      when(() => mockRepository.getAllWidgets(testAccountId))
          .thenAnswer((_) async => Right(testWidgets));

      // Act
      final result =
          await useCase(const AccountParams(accountId: testAccountId));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (widgets) {
          expect(widgets, equals(testWidgets));
          expect(widgets.length, equals(2));
          expect(widgets.first.id, equals('widget-1'));
          expect(widgets.last.id, equals('widget-2'));
        },
      );

      verify(() => mockRepository.getAllWidgets(testAccountId)).called(1);
    });

    test('should return empty list when no widgets exist', () async {
      // Arrange
      when(() => mockRepository.getAllWidgets(testAccountId))
          .thenAnswer((_) async => const Right(<WidgetData>[]));

      // Act
      final result =
          await useCase(const AccountParams(accountId: testAccountId));

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (widgets) {
          expect(widgets, isEmpty);
        },
      );

      verify(() => mockRepository.getAllWidgets(testAccountId)).called(1);
    });

    test(
        'should return network failure when repository fails with network error',
        () async {
      // Arrange
      const networkFailure = AppFailure.network(message: 'Connection timeout');
      when(() => mockRepository.getAllWidgets(testAccountId))
          .thenAnswer((_) async => const Left(networkFailure));

      // Act
      final result =
          await useCase(const AccountParams(accountId: testAccountId));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, equals(networkFailure));
          expect(failure.displayMessage, equals('Connection timeout'));
        },
        (widgets) => fail('Expected failure but got success: $widgets'),
      );

      verify(() => mockRepository.getAllWidgets(testAccountId)).called(1);
    });

    test('should return cache failure when repository fails with cache error',
        () async {
      // Arrange
      const cacheFailure = AppFailure.cache(message: 'Local storage error');
      when(() => mockRepository.getAllWidgets(testAccountId))
          .thenAnswer((_) async => const Left(cacheFailure));

      // Act
      final result =
          await useCase(const AccountParams(accountId: testAccountId));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, equals(cacheFailure));
          expect(failure.displayMessage, equals('Local storage error'));
        },
        (widgets) => fail('Expected failure but got success: $widgets'),
      );

      verify(() => mockRepository.getAllWidgets(testAccountId)).called(1);
    });

    test('should return unexpected failure when repository throws exception',
        () async {
      // Arrange
      const unexpectedFailure =
          AppFailure.unexpected(message: 'Something went wrong');
      when(() => mockRepository.getAllWidgets(testAccountId))
          .thenAnswer((_) async => const Left(unexpectedFailure));

      // Act
      final result =
          await useCase(const AccountParams(accountId: testAccountId));

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, equals(unexpectedFailure));
        },
        (widgets) => fail('Expected failure but got success: $widgets'),
      );

      verify(() => mockRepository.getAllWidgets(testAccountId)).called(1);
    });

    test('should pass correct account ID to repository', () async {
      // Arrange
      const differentAccountId = 'different-account-456';
      when(() => mockRepository.getAllWidgets(differentAccountId))
          .thenAnswer((_) async => const Right(<WidgetData>[]));

      // Act
      await useCase(const AccountParams(accountId: differentAccountId));

      // Assert
      verify(() => mockRepository.getAllWidgets(differentAccountId)).called(1);
      verifyNever(() => mockRepository.getAllWidgets(testAccountId));
    });
  });
}
