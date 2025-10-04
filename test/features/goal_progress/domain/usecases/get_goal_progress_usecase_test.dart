// Unit tests for GetGoalProgressUseCase
// Tests the business logic for retrieving goal progress dashboard data

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/goal_progress/domain/usecases/get_goal_progress_usecase.dart';
import 'package:ash_trail/features/goal_progress/domain/repositories/goal_progress_repository.dart';
import 'package:ash_trail/features/goal_progress/domain/entities/goal_progress_view.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/goal.dart';

class _MockGoalProgressRepository extends Mock
    implements GoalProgressRepository {}

void main() {
  late _MockGoalProgressRepository mockRepository;
  late GetGoalProgressUseCase useCase;

  setUp(() {
    mockRepository = _MockGoalProgressRepository();
    useCase = GetGoalProgressUseCase(mockRepository);
  });

  group('GetGoalProgressUseCase', () {
    const accountId = 'test-account-id';

    final testActiveGoal = Goal(
      id: 'goal1',
      accountId: accountId,
      type: 'smoke_free_days',
      target: 30,
      window: 'monthly',
      startDate: DateTime(2024, 1, 1),
      active: true,
      progress: 15,
    );

    final testCompletedGoal = Goal(
      id: 'goal2',
      accountId: accountId,
      type: 'reduction_count',
      target: 10,
      window: 'weekly',
      startDate: DateTime(2024, 1, 1),
      active: true,
      progress: 10,
      achievedAt: DateTime(2024, 1, 15),
    );

    test('should return dashboard with active and completed goals', () async {
      // Arrange
      when(() => mockRepository.getActiveGoals(accountId))
          .thenAnswer((_) async => Right([testActiveGoal]));
      when(() => mockRepository.getCompletedGoals(accountId))
          .thenAnswer((_) async => Right([testCompletedGoal]));
      when(() => mockRepository.calculateCurrentProgress(
            accountId: accountId,
            goal: testActiveGoal,
          )).thenAnswer((_) async => const Right(15));

      // Act
      final result = await useCase(accountId);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (dashboard) {
          expect(dashboard.activeGoals, hasLength(1));
          expect(dashboard.completedGoals, hasLength(1));
          expect(dashboard.hasGoals, isTrue);
          expect(dashboard.totalGoals, equals(2));
        },
      );

      // Verify repository calls
      verify(() => mockRepository.getActiveGoals(accountId)).called(1);
      verify(() => mockRepository.getCompletedGoals(accountId)).called(1);
      verify(() => mockRepository.calculateCurrentProgress(
            accountId: accountId,
            goal: testActiveGoal,
          )).called(1);
    });

    test('should handle empty goal lists', () async {
      // Arrange
      when(() => mockRepository.getActiveGoals(accountId))
          .thenAnswer((_) async => const Right([]));
      when(() => mockRepository.getCompletedGoals(accountId))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(accountId);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (dashboard) {
          expect(dashboard.activeGoals, isEmpty);
          expect(dashboard.completedGoals, isEmpty);
          expect(dashboard.hasGoals, isFalse);
          expect(dashboard.totalGoals, equals(0));
          expect(dashboard.completionRate, equals(0.0));
        },
      );
    });

    test('should return failure when active goals fetch fails', () async {
      // Arrange
      const failure = AppFailure.cache(message: 'Cache error');
      when(() => mockRepository.getActiveGoals(accountId))
          .thenAnswer((_) async => const Left(failure));
      // Mock completed goals to return empty (shouldn't be called but needed for safety)
      when(() => mockRepository.getCompletedGoals(accountId))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(accountId);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (_) => fail('Expected failure'),
      );
    });

    test('should return failure when completed goals fetch fails', () async {
      // Arrange
      const failure = AppFailure.network(message: 'Network error');
      when(() => mockRepository.getActiveGoals(accountId))
          .thenAnswer((_) async => Right([testActiveGoal]));
      when(() => mockRepository.getCompletedGoals(accountId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(accountId);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (_) => fail('Expected failure'),
      );
    });

    test('should handle progress calculation failure gracefully', () async {
      // Arrange
      when(() => mockRepository.getActiveGoals(accountId))
          .thenAnswer((_) async => Right([testActiveGoal]));
      when(() => mockRepository.getCompletedGoals(accountId))
          .thenAnswer((_) async => const Right([]));
      when(() => mockRepository.calculateCurrentProgress(
                accountId: accountId,
                goal: testActiveGoal,
              ))
          .thenAnswer(
              (_) async => const Left(AppFailure.cache(message: 'Calc error')));

      // Act
      final result = await useCase(accountId);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success despite calc failure: $failure'),
        (dashboard) {
          expect(dashboard.activeGoals, hasLength(1));
          // Should use stored progress when calculation fails
          expect(dashboard.activeGoals.first.goal.progress, equals(15));
        },
      );
    });

    test('should handle unexpected exceptions', () async {
      // Arrange
      when(() => mockRepository.getActiveGoals(accountId))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(accountId);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AppFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('should calculate correct completion rate', () async {
      // Arrange - 3 active, 2 completed = 40% completion rate
      final activeGoals = List.generate(
          3,
          (i) => Goal(
                id: 'active$i',
                accountId: accountId,
                type: 'smoke_free_days',
                target: 30,
                window: 'monthly',
                startDate: DateTime(2024, 1, 1),
                active: true,
              ));

      final completedGoals = List.generate(
          2,
          (i) => Goal(
                id: 'completed$i',
                accountId: accountId,
                type: 'reduction_count',
                target: 10,
                window: 'weekly',
                startDate: DateTime(2024, 1, 1),
                active: true,
                achievedAt: DateTime(2024, 1, 15),
              ));

      when(() => mockRepository.getActiveGoals(accountId))
          .thenAnswer((_) async => Right(activeGoals));
      when(() => mockRepository.getCompletedGoals(accountId))
          .thenAnswer((_) async => Right(completedGoals));

      // Mock progress calculations for all active goals
      for (final goal in activeGoals) {
        when(() => mockRepository.calculateCurrentProgress(
              accountId: accountId,
              goal: goal,
            )).thenAnswer((_) async => const Right(0));
      }

      // Act
      final result = await useCase(accountId);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success: $failure'),
        (dashboard) {
          expect(dashboard.totalGoals, equals(5));
          expect(dashboard.completionRate, equals(40.0));
        },
      );
    });
  });

  group('GoalProgressDashboard', () {
    test('should calculate properties correctly when empty', () {
      const dashboard = GoalProgressDashboard(
        activeGoals: [],
        completedGoals: [],
      );

      expect(dashboard.hasGoals, isFalse);
      expect(dashboard.totalGoals, equals(0));
      expect(dashboard.completionRate, equals(0.0));
    });

    test('should calculate properties correctly with goals', () {
      final activeGoals = [
        GoalProgressView.fromGoal(Goal(
          id: 'goal1',
          accountId: 'acc1',
          type: 'smoke_free_days',
          target: 30,
          window: 'monthly',
          startDate: DateTime(2024, 1, 1),
          active: true,
        )),
      ];

      final completedGoals = [
        GoalProgressView.fromGoal(Goal(
          id: 'goal2',
          accountId: 'acc1',
          type: 'reduction_count',
          target: 10,
          window: 'weekly',
          startDate: DateTime(2024, 1, 1),
          active: true,
          achievedAt: DateTime(2024, 1, 15),
        )),
      ];

      final dashboard = GoalProgressDashboard(
        activeGoals: activeGoals,
        completedGoals: completedGoals,
      );

      expect(dashboard.hasGoals, isTrue);
      expect(dashboard.totalGoals, equals(2));
    });
  });
}
