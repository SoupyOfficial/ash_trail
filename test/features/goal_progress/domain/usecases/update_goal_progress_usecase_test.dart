// Unit tests for UpdateGoalProgressUseCase
// Tests the business logic for updating goal progress and marking completion

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/goal_progress/domain/usecases/update_goal_progress_usecase.dart';
import 'package:ash_trail/features/goal_progress/domain/repositories/goal_progress_repository.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/goal.dart';

class _MockGoalProgressRepository extends Mock
    implements GoalProgressRepository {}

void main() {
  late _MockGoalProgressRepository mockRepository;
  late UpdateGoalProgressUseCase useCase;

  setUp(() {
    mockRepository = _MockGoalProgressRepository();
    useCase = UpdateGoalProgressUseCase(mockRepository);
  });

  group('UpdateGoalProgressUseCase', () {
    const goalId = 'test-goal-id';
    const newProgress = 25;

    final testGoal = Goal(
      id: goalId,
      accountId: 'acc1',
      type: 'smoke_free_days',
      target: 30,
      window: 'monthly',
      startDate: DateTime(2024, 1, 1),
      active: true,
      progress: newProgress,
    );

    final completedGoal = Goal(
      id: goalId,
      accountId: 'acc1',
      type: 'smoke_free_days',
      target: 30,
      window: 'monthly',
      startDate: DateTime(2024, 1, 1),
      active: true,
      progress: 30,
      achievedAt: DateTime(2024, 1, 30),
    );

    test('should update goal progress successfully', () async {
      // Arrange
      const params = UpdateGoalProgressParams(
        goalId: goalId,
        newProgress: newProgress,
      );

      when(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: newProgress,
          )).thenAnswer((_) async => Right(testGoal));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (updatedGoal) {
          expect(updatedGoal.progress, equals(newProgress));
          expect(updatedGoal.achievedAt, isNull);
        },
      );

      verify(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: newProgress,
          )).called(1);
      verifyNever(() => mockRepository.markGoalAsAchieved(any()));
    });

    test('should mark goal as achieved when target is reached', () async {
      // Arrange
      const params = UpdateGoalProgressParams(
        goalId: goalId,
        newProgress: 30, // Equals target
      );

      final goalAtTarget = testGoal.copyWith(progress: 30);

      when(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: 30,
          )).thenAnswer((_) async => Right(goalAtTarget));
      when(() => mockRepository.markGoalAsAchieved(goalId))
          .thenAnswer((_) async => Right(completedGoal));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (updatedGoal) {
          expect(updatedGoal.progress, equals(30));
          expect(updatedGoal.achievedAt, isNotNull);
        },
      );

      verify(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: 30,
          )).called(1);
      verify(() => mockRepository.markGoalAsAchieved(goalId)).called(1);
    });

    test('should mark goal as achieved when explicitly requested', () async {
      // Arrange
      const params = UpdateGoalProgressParams(
        goalId: goalId,
        newProgress: 20, // Less than target but explicitly marking complete
        markAsCompleted: true,
      );

      final goalPartiallyComplete = testGoal.copyWith(progress: 20);

      when(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: 20,
          )).thenAnswer((_) async => Right(goalPartiallyComplete));
      when(() => mockRepository.markGoalAsAchieved(goalId))
          .thenAnswer((_) async => Right(completedGoal.copyWith(progress: 20)));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (updatedGoal) {
          expect(updatedGoal.achievedAt, isNotNull);
        },
      );

      verify(() => mockRepository.markGoalAsAchieved(goalId)).called(1);
    });

    test('should not mark already achieved goal again', () async {
      // Arrange
      const params = UpdateGoalProgressParams(
        goalId: goalId,
        newProgress: 30,
        markAsCompleted: true,
      );

      final alreadyCompletedGoal = completedGoal.copyWith(progress: 30);

      when(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: 30,
          )).thenAnswer((_) async => Right(alreadyCompletedGoal));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (updatedGoal) {
          expect(updatedGoal.achievedAt, isNotNull);
        },
      );

      verify(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: 30,
          )).called(1);
      verifyNever(() => mockRepository.markGoalAsAchieved(any()));
    });

    test('should return failure when update fails', () async {
      // Arrange
      const params = UpdateGoalProgressParams(
        goalId: goalId,
        newProgress: newProgress,
      );
      const failure = AppFailure.cache(message: 'Update failed');

      when(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: newProgress,
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (_) => fail('Expected failure'),
      );
    });

    test('should return failure when marking as achieved fails', () async {
      // Arrange
      const params = UpdateGoalProgressParams(
        goalId: goalId,
        newProgress: 30,
      );
      const failure = AppFailure.network(message: 'Achievement marking failed');

      final goalAtTarget = testGoal.copyWith(progress: 30);

      when(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: 30,
          )).thenAnswer((_) async => Right(goalAtTarget));
      when(() => mockRepository.markGoalAsAchieved(goalId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (_) => fail('Expected failure'),
      );
    });

    test('should handle unexpected exceptions', () async {
      // Arrange
      const params = UpdateGoalProgressParams(
        goalId: goalId,
        newProgress: newProgress,
      );

      when(() => mockRepository.updateGoalProgress(
            goalId: goalId,
            newProgress: newProgress,
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AppFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });

  group('UpdateGoalProgressParams', () {
    test('should create params with required fields', () {
      const params = UpdateGoalProgressParams(
        goalId: 'goal123',
        newProgress: 50,
      );

      expect(params.goalId, equals('goal123'));
      expect(params.newProgress, equals(50));
      expect(params.markAsCompleted, isFalse);
    });

    test('should create params with completion flag', () {
      const params = UpdateGoalProgressParams(
        goalId: 'goal123',
        newProgress: 25,
        markAsCompleted: true,
      );

      expect(params.goalId, equals('goal123'));
      expect(params.newProgress, equals(25));
      expect(params.markAsCompleted, isTrue);
    });
  });
}
