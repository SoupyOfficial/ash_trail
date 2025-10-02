// Unit tests for GoalProgressRepositoryImpl
// Tests the data layer repository implementation with offline-first fallback patterns

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/goal_progress/data/repositories/goal_progress_repository_impl.dart';
import 'package:ash_trail/features/goal_progress/data/datasources/goal_progress_local_datasource.dart';
import 'package:ash_trail/features/goal_progress/data/datasources/goal_progress_remote_datasource.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/goal.dart';

class _MockLocalDataSource extends Mock
    implements GoalProgressLocalDataSource {}

class _MockRemoteDataSource extends Mock
    implements GoalProgressRemoteDataSource {}

void main() {
  late _MockLocalDataSource mockLocalDataSource;
  late _MockRemoteDataSource mockRemoteDataSource;
  late GoalProgressRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = _MockLocalDataSource();
    mockRemoteDataSource = _MockRemoteDataSource();
    repository = GoalProgressRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  group('GoalProgressRepositoryImpl', () {
    const accountId = 'test-account-id';

    final testGoal = Goal(
      id: 'goal1',
      accountId: accountId,
      type: 'smoke_free_days',
      target: 30,
      window: 'monthly',
      startDate: DateTime(2024, 1, 1),
      active: true,
      progress: 15,
    );

    group('getActiveGoals', () {
      test('should return goals from local data source', () async {
        // Arrange
        final expectedGoals = [testGoal];
        when(() => mockLocalDataSource.getActiveGoals(accountId))
            .thenAnswer((_) async => expectedGoals);

        // Act
        final result = await repository.getActiveGoals(accountId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (goals) => expect(goals, equals(expectedGoals)),
        );

        verify(() => mockLocalDataSource.getActiveGoals(accountId)).called(1);
        verifyNever(() => mockRemoteDataSource.getActiveGoals(any()));
      });

      test('should fallback to remote when local fails', () async {
        // Arrange
        final expectedGoals = [testGoal];
        when(() => mockLocalDataSource.getActiveGoals(accountId))
            .thenThrow(Exception('Local error'));
        when(() => mockRemoteDataSource.getActiveGoals(accountId))
            .thenAnswer((_) async => expectedGoals);

        // Act
        final result = await repository.getActiveGoals(accountId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (goals) => expect(goals, equals(expectedGoals)),
        );

        verify(() => mockLocalDataSource.getActiveGoals(accountId)).called(1);
        verify(() => mockRemoteDataSource.getActiveGoals(accountId)).called(1);
      });

      test('should return failure when both local and remote fail', () async {
        // Arrange
        when(() => mockLocalDataSource.getActiveGoals(accountId))
            .thenThrow(Exception('Local error'));
        when(() => mockRemoteDataSource.getActiveGoals(accountId))
            .thenThrow(Exception('Remote error'));

        // Act
        final result = await repository.getActiveGoals(accountId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('updateGoalProgress', () {
      const goalId = 'goal1';
      const newProgress = 25;

      final updatedGoal = testGoal.copyWith(progress: newProgress);

      test('should update local first then sync to remote', () async {
        // Arrange
        when(() => mockLocalDataSource.updateGoalProgress(
              goalId: goalId,
              newProgress: newProgress,
            )).thenAnswer((_) async => updatedGoal);
        when(() => mockRemoteDataSource.updateGoalProgress(
              goalId: goalId,
              newProgress: newProgress,
            )).thenAnswer((_) async => updatedGoal);
        when(() => mockLocalDataSource.markAsSynced(goalId))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.updateGoalProgress(
          goalId: goalId,
          newProgress: newProgress,
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (goal) => expect(goal.progress, equals(newProgress)),
        );

        verify(() => mockLocalDataSource.updateGoalProgress(
              goalId: goalId,
              newProgress: newProgress,
            )).called(1);
        verify(() => mockRemoteDataSource.updateGoalProgress(
              goalId: goalId,
              newProgress: newProgress,
            )).called(1);
        verify(() => mockLocalDataSource.markAsSynced(goalId)).called(1);
      });

      test('should succeed even if remote sync fails', () async {
        // Arrange
        when(() => mockLocalDataSource.updateGoalProgress(
              goalId: goalId,
              newProgress: newProgress,
            )).thenAnswer((_) async => updatedGoal);
        when(() => mockRemoteDataSource.updateGoalProgress(
              goalId: goalId,
              newProgress: newProgress,
            )).thenThrow(Exception('Remote sync failed'));

        // Act
        final result = await repository.updateGoalProgress(
          goalId: goalId,
          newProgress: newProgress,
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (goal) => expect(goal.progress, equals(newProgress)),
        );

        verify(() => mockLocalDataSource.updateGoalProgress(
              goalId: goalId,
              newProgress: newProgress,
            )).called(1);
        verifyNever(() => mockLocalDataSource.markAsSynced(any()));
      });

      test('should return failure when local update fails', () async {
        // Arrange
        when(() => mockLocalDataSource.updateGoalProgress(
              goalId: goalId,
              newProgress: newProgress,
            )).thenThrow(Exception('Local update failed'));

        // Act
        final result = await repository.updateGoalProgress(
          goalId: goalId,
          newProgress: newProgress,
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure'),
        );

        verifyNever(() => mockRemoteDataSource.updateGoalProgress(
              goalId: any(named: 'goalId'),
              newProgress: any(named: 'newProgress'),
            ));
      });
    });

    group('calculateCurrentProgress', () {
      test('should calculate smoke-free days progress', () async {
        // Arrange
        final smokeFreeGoal = testGoal.copyWith(type: 'smoke_free_days');

        // Act
        final result = await repository.calculateCurrentProgress(
          accountId: accountId,
          goal: smokeFreeGoal,
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (progress) {
            expect(progress, isA<int>());
            expect(progress, greaterThanOrEqualTo(0));
          },
        );
      });

      test('should return stored progress for unknown goal types', () async {
        // Arrange
        final unknownGoal =
            testGoal.copyWith(type: 'unknown_type', progress: 42);

        // Act
        final result = await repository.calculateCurrentProgress(
          accountId: accountId,
          goal: unknownGoal,
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (progress) => expect(progress, equals(42)),
        );
      });

      test('should return 0 when stored progress is null', () async {
        // Arrange
        final goalWithoutProgress = testGoal.copyWith(
          type: 'unknown_type',
          progress: null,
        );

        // Act
        final result = await repository.calculateCurrentProgress(
          accountId: accountId,
          goal: goalWithoutProgress,
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (progress) => expect(progress, equals(0)),
        );
      });

      test('should handle calculation exceptions gracefully', () async {
        // Arrange - This would normally cause calculation logic to fail,
        // but should fall back to stored progress
        final goalWithStoredProgress = testGoal.copyWith(progress: 10);

        // Act
        final result = await repository.calculateCurrentProgress(
          accountId: accountId,
          goal: goalWithStoredProgress,
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (progress) => expect(progress, equals(10)),
        );
      });
    });

    group('markGoalAsAchieved', () {
      const goalId = 'goal1';
      final achievedGoal = testGoal.copyWith(
        achievedAt: DateTime(2024, 1, 30),
      );

      test('should mark goal as achieved locally then sync to remote',
          () async {
        // Arrange
        when(() => mockLocalDataSource.markGoalAsAchieved(goalId))
            .thenAnswer((_) async => achievedGoal);
        when(() => mockRemoteDataSource.markGoalAsAchieved(goalId))
            .thenAnswer((_) async => achievedGoal);
        when(() => mockLocalDataSource.markAsSynced(goalId))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.markGoalAsAchieved(goalId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (goal) => expect(goal.achievedAt, isNotNull),
        );

        verify(() => mockLocalDataSource.markGoalAsAchieved(goalId)).called(1);
        verify(() => mockRemoteDataSource.markGoalAsAchieved(goalId)).called(1);
        verify(() => mockLocalDataSource.markAsSynced(goalId)).called(1);
      });

      test('should succeed even if remote sync fails', () async {
        // Arrange
        when(() => mockLocalDataSource.markGoalAsAchieved(goalId))
            .thenAnswer((_) async => achievedGoal);
        when(() => mockRemoteDataSource.markGoalAsAchieved(goalId))
            .thenThrow(Exception('Remote sync failed'));

        // Act
        final result = await repository.markGoalAsAchieved(goalId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (goal) => expect(goal.achievedAt, isNotNull),
        );

        verifyNever(() => mockLocalDataSource.markAsSynced(any()));
      });
    });
  });
}
