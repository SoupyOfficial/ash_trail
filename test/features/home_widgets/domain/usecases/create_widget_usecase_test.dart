// Unit tests for CreateWidgetUseCase.
// Tests business logic, validation, and error handling for creating widgets.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_data.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_size.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';
import 'package:ash_trail/features/home_widgets/domain/repositories/home_widgets_repository.dart';
import 'package:ash_trail/features/home_widgets/domain/usecases/create_widget_usecase.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockHomeWidgetsRepository extends Mock implements HomeWidgetsRepository {}

void main() {
  late CreateWidgetUseCase useCase;
  late MockHomeWidgetsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(WidgetSize.medium);
    registerFallbackValue(WidgetTapAction.openApp);
  });

  setUp(() {
    mockRepository = MockHomeWidgetsRepository();
    useCase = CreateWidgetUseCase(mockRepository);
    reset(mockRepository); // Clear any previous mock setups
  });

  group('CreateWidgetUseCase', () {
    const testAccountId = 'test-account-123';
    final testWidget = WidgetData(
      id: 'widget-new-123',
      accountId: testAccountId,
      size: WidgetSize.medium,
      tapAction: WidgetTapAction.openApp,
      todayHitCount: 0,
      currentStreak: 0,
      lastSyncAt: DateTime(2023, 12, 1, 12, 0),
      createdAt: DateTime(2023, 12, 1, 12, 0),
    );

    test('should create widget successfully with valid parameters', () async {
      // Arrange
      const params = CreateWidgetParams(
        accountId: testAccountId,
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.openApp,
      );

      when(() => mockRepository.createWidget(
            accountId: testAccountId,
            size: WidgetSize.medium,
            tapAction: WidgetTapAction.openApp,
            showStreak: null,
            showLastSync: null,
          )).thenAnswer((_) async => Right(testWidget));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (widget) {
          expect(widget, equals(testWidget));
        },
      );

      verify(() => mockRepository.createWidget(
            accountId: testAccountId,
            size: WidgetSize.medium,
            tapAction: WidgetTapAction.openApp,
            showStreak: null,
            showLastSync: null,
          )).called(1);
    });

    test('should create widget with custom display options', () async {
      // Arrange
      const params = CreateWidgetParams(
        accountId: testAccountId,
        size: WidgetSize.large,
        tapAction: WidgetTapAction.recordOverlay,
        showStreak: true,
        showLastSync: false,
      );

      when(() => mockRepository.createWidget(
            accountId: testAccountId,
            size: WidgetSize.large,
            tapAction: WidgetTapAction.recordOverlay,
            showStreak: true,
            showLastSync: false,
          )).thenAnswer((_) async => Right(testWidget));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.createWidget(
            accountId: testAccountId,
            size: WidgetSize.large,
            tapAction: WidgetTapAction.recordOverlay,
            showStreak: true,
            showLastSync: false,
          )).called(1);
    });

    test('should return validation failure for empty account ID', () async {
      // Arrange
      const params = CreateWidgetParams(
        accountId: '', // Empty account ID
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.openApp,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(
              failure.displayMessage, contains('Account ID cannot be empty'));
        },
        (widget) =>
            fail('Expected validation failure but got success: $widget'),
      );

      // Verify repository was never called
      verifyNever(() => mockRepository.createWidget(
            accountId: any(named: 'accountId'),
            size: any(named: 'size'),
            tapAction: any(named: 'tapAction'),
            showStreak: any(named: 'showStreak'),
            showLastSync: any(named: 'showLastSync'),
          ));
    });

    test('should handle repository network failure', () async {
      // Arrange
      const params = CreateWidgetParams(
        accountId: testAccountId,
        size: WidgetSize.small,
        tapAction: WidgetTapAction.quickRecord,
      );

      const networkFailure =
          AppFailure.network(message: 'Failed to create widget remotely');
      when(() => mockRepository.createWidget(
            accountId: any(named: 'accountId'),
            size: any(named: 'size'),
            tapAction: any(named: 'tapAction'),
            showStreak: any(named: 'showStreak'),
            showLastSync: any(named: 'showLastSync'),
          )).thenAnswer((_) async => left(networkFailure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, equals(networkFailure));
          expect(failure.displayMessage,
              equals('Failed to create widget remotely'));
        },
        (widget) => fail('Expected failure but got success: $widget'),
      );

      verify(() => mockRepository.createWidget(
            accountId: testAccountId,
            size: WidgetSize.small,
            tapAction: WidgetTapAction.quickRecord,
            showStreak: null,
            showLastSync: null,
          )).called(1);
    });

    test('should handle repository cache failure', () async {
      // Arrange
      const params = CreateWidgetParams(
        accountId: testAccountId,
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.viewLogs,
      );

      const cacheFailure = AppFailure.cache(message: 'Local storage full');
      when(() => mockRepository.createWidget(
            accountId: testAccountId,
            size: WidgetSize.medium,
            tapAction: WidgetTapAction.viewLogs,
            showStreak: null,
            showLastSync: null,
          )).thenAnswer((_) async => const Left(cacheFailure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, equals(cacheFailure));
        },
        (widget) => fail('Expected failure but got success: $widget'),
      );
    });

    test('should create widget with all widget sizes', () async {
      // Test all widget sizes are supported
      when(() => mockRepository.createWidget(
            accountId: any(named: 'accountId'),
            size: any(named: 'size'),
            tapAction: any(named: 'tapAction'),
            showStreak: any(named: 'showStreak'),
            showLastSync: any(named: 'showLastSync'),
          )).thenAnswer((_) async => Right(testWidget));

      for (final size in WidgetSize.values) {
        // Arrange
        final params = CreateWidgetParams(
          accountId: testAccountId,
          size: size,
          tapAction: WidgetTapAction.openApp,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true, reason: 'Failed for size: ${size.name}');
      }
    });

    test('should create widget with all tap actions', () async {
      // Test all tap actions are supported
      when(() => mockRepository.createWidget(
            accountId: any(named: 'accountId'),
            size: any(named: 'size'),
            tapAction: any(named: 'tapAction'),
            showStreak: any(named: 'showStreak'),
            showLastSync: any(named: 'showLastSync'),
          )).thenAnswer((_) async => Right(testWidget));

      for (final action in WidgetTapAction.values) {
        // Arrange
        final params = CreateWidgetParams(
          accountId: testAccountId,
          size: WidgetSize.medium,
          tapAction: action,
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true,
            reason: 'Failed for action: ${action.name}');
      }
    });
  });
}
