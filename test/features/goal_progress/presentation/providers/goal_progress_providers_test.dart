import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/goal.dart';
import 'package:ash_trail/features/goal_progress/domain/repositories/goal_progress_repository.dart';
import 'package:ash_trail/features/goal_progress/domain/usecases/get_goal_progress_usecase.dart';
import 'package:ash_trail/features/goal_progress/domain/usecases/update_goal_progress_usecase.dart';
import 'package:ash_trail/features/goal_progress/presentation/providers/goal_progress_providers.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class SuccessGoalProgressRepository implements GoalProgressRepository {
  SuccessGoalProgressRepository({
    required this.activeGoals,
    required this.completedGoals,
    required this.progressByGoal,
    this.updateFailure,
    this.markFailure,
    Set<String>? calculateFailureGoalIds,
  }) : calculateFailureGoalIds = calculateFailureGoalIds ?? <String>{};

  final List<Goal> activeGoals;
  final List<Goal> completedGoals;
  final Map<String, int> progressByGoal;
  final AppFailure? updateFailure;
  final AppFailure? markFailure;
  final Set<String> calculateFailureGoalIds;

  String? lastUpdatedGoalId;
  int? lastUpdatedProgress;
  String? lastMarkedGoalId;

  List<Goal> get _allGoals => <Goal>[...activeGoals, ...completedGoals];

  @override
  Future<Either<AppFailure, List<Goal>>> getActiveGoals(
      String accountId) async {
    return Right(activeGoals);
  }

  @override
  Future<Either<AppFailure, List<Goal>>> getCompletedGoals(
      String accountId) async {
    return Right(completedGoals);
  }

  @override
  Future<Either<AppFailure, List<Goal>>> getAllGoals(String accountId) async {
    return Right(_allGoals);
  }

  @override
  Future<Either<AppFailure, Goal>> updateGoalProgress({
    required String goalId,
    required int newProgress,
  }) async {
    if (updateFailure != null) {
      return Left(updateFailure!);
    }

    lastUpdatedGoalId = goalId;
    lastUpdatedProgress = newProgress;
    final Goal base = _allGoals.firstWhere((Goal goal) => goal.id == goalId);
    return Right(base.copyWith(progress: newProgress));
  }

  @override
  Future<Either<AppFailure, Goal>> markGoalAsAchieved(String goalId) async {
    if (markFailure != null) {
      return Left(markFailure!);
    }

    lastMarkedGoalId = goalId;
    final Goal base = _allGoals.firstWhere((Goal goal) => goal.id == goalId);
    return Right(base.copyWith(achievedAt: DateTime(2024, 1, 2)));
  }

  @override
  Future<Either<AppFailure, int>> calculateCurrentProgress({
    required String accountId,
    required Goal goal,
  }) async {
    if (calculateFailureGoalIds.contains(goal.id)) {
      return const Left(AppFailure.unexpected(message: 'calc failed'));
    }
    return Right(progressByGoal[goal.id] ?? goal.progress ?? 0);
  }
}

class FailingGoalProgressRepository implements GoalProgressRepository {
  const FailingGoalProgressRepository(this.failure);

  final AppFailure failure;

  @override
  Future<Either<AppFailure, List<Goal>>> getActiveGoals(
          String accountId) async =>
      Left(failure);

  @override
  Future<Either<AppFailure, List<Goal>>> getCompletedGoals(
          String accountId) async =>
      Left(failure);

  @override
  Future<Either<AppFailure, List<Goal>>> getAllGoals(String accountId) async =>
      Left(failure);

  @override
  Future<Either<AppFailure, Goal>> updateGoalProgress({
    required String goalId,
    required int newProgress,
  }) async =>
      Left(failure);

  @override
  Future<Either<AppFailure, Goal>> markGoalAsAchieved(String goalId) async =>
      Left(failure);

  @override
  Future<Either<AppFailure, int>> calculateCurrentProgress({
    required String accountId,
    required Goal goal,
  }) async =>
      Left(failure);
}

void main() {
  const String accountId = 'account-1';
  final Goal activeGoal = Goal(
    id: 'goal-active',
    accountId: accountId,
    type: 'smoke_free_days',
    target: 10,
    window: 'weekly',
    startDate: DateTime(2024, 1, 1),
    active: true,
    progress: 3,
  );
  final Goal completedGoal = Goal(
    id: 'goal-completed',
    accountId: accountId,
    type: 'reduction_count',
    target: 5,
    window: 'monthly',
    startDate: DateTime(2023, 12, 20),
    endDate: DateTime(2024, 1, 20),
    active: false,
    progress: 5,
    achievedAt: DateTime(2024, 1, 5),
  );

  group('goalProgressDashboardProvider', () {
    test('returns dashboard data composed from repository results', () async {
      final SuccessGoalProgressRepository repository =
          SuccessGoalProgressRepository(
        activeGoals: <Goal>[activeGoal],
        completedGoals: <Goal>[completedGoal],
        progressByGoal: <String, int>{'goal-active': 4},
      );

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          goalProgressRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final GoalProgressDashboard dashboard =
          await container.read(goalProgressDashboardProvider(accountId).future);

      expect(dashboard.activeGoals, hasLength(1));
      expect(dashboard.completedGoals, hasLength(1));
      expect(dashboard.hasGoals, isTrue);
      expect(dashboard.totalGoals, 2);
      expect(dashboard.completionRate, closeTo(50.0, 0.001));

      final goalView = dashboard.activeGoals.first;
      expect(goalView.progressPercentage, closeTo(0.4, 0.0001));
      expect(goalView.isCompleted, isFalse);
      expect(container.read(hasAnyGoalsProvider(accountId)), isTrue);
      expect(container.read(goalCompletionRateProvider(accountId)),
          closeTo(50.0, 0.001));
    });

    test('falls back to stored progress when calculation fails', () async {
      final Goal fallbackGoal = activeGoal.copyWith(progress: 2);
      final SuccessGoalProgressRepository repository =
          SuccessGoalProgressRepository(
        activeGoals: <Goal>[fallbackGoal],
        completedGoals: const <Goal>[],
        progressByGoal: const <String, int>{},
        calculateFailureGoalIds: <String>{fallbackGoal.id},
      );

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          goalProgressRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final GoalProgressDashboard dashboard =
          await container.read(goalProgressDashboardProvider(accountId).future);

      final goalView = dashboard.activeGoals.single;
      expect(goalView.progressPercentage, closeTo(0.2, 0.0001));
      expect(goalView.displayText, contains('2 / 10'));
    });

    test('throws failure when repository returns error', () async {
      const AppFailure failure = AppFailure.unexpected(message: 'load failed');
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          goalProgressRepositoryProvider.overrideWith(
              (ref) => const FailingGoalProgressRepository(failure)),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(goalProgressDashboardProvider(accountId).future),
        throwsA(equals(failure)),
      );

      expect(container.read(hasAnyGoalsProvider(accountId)), isFalse);
      expect(container.read(goalCompletionRateProvider(accountId)), 0.0);
    });
  });

  group('UpdateGoalProgressNotifier', () {
    test('updates progress and marks goal as achieved when target reached',
        () async {
      final SuccessGoalProgressRepository repository =
          SuccessGoalProgressRepository(
        activeGoals: <Goal>[activeGoal],
        completedGoals: <Goal>[completedGoal],
        progressByGoal: <String, int>{'goal-active': 4},
      );

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          goalProgressRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      const UpdateGoalProgressParams params =
          UpdateGoalProgressParams(goalId: 'goal-active', newProgress: 12);
      final ProviderSubscription<AsyncValue<void>> subscription =
          container.listen(
        updateGoalProgressProvider(params),
        (_, __) {},
      );
      addTearDown(subscription.close);

      final notifier =
          container.read(updateGoalProgressProvider(params).notifier);

      await notifier.updateProgress(params);

      expect(notifier.state, const AsyncData<void>(null));
      expect(repository.lastUpdatedGoalId, 'goal-active');
      expect(repository.lastUpdatedProgress, 12);
      expect(repository.lastMarkedGoalId, 'goal-active');
    });

    test('updates progress without marking completion when below target',
        () async {
      final SuccessGoalProgressRepository repository =
          SuccessGoalProgressRepository(
        activeGoals: <Goal>[activeGoal],
        completedGoals: <Goal>[completedGoal],
        progressByGoal: const <String, int>{},
      );

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          goalProgressRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      const UpdateGoalProgressParams params =
          UpdateGoalProgressParams(goalId: 'goal-active', newProgress: 6);
      final ProviderSubscription<AsyncValue<void>> subscription =
          container.listen(
        updateGoalProgressProvider(params),
        (_, __) {},
      );
      addTearDown(subscription.close);

      final notifier =
          container.read(updateGoalProgressProvider(params).notifier);

      await notifier.updateProgress(params);

      expect(repository.lastUpdatedGoalId, 'goal-active');
      expect(repository.lastUpdatedProgress, 6);
      expect(repository.lastMarkedGoalId, isNull);
    });

    test('propagates failure from repository', () async {
      const AppFailure failure =
          AppFailure.unexpected(message: 'update failed');
      final SuccessGoalProgressRepository repository =
          SuccessGoalProgressRepository(
        activeGoals: <Goal>[activeGoal],
        completedGoals: <Goal>[completedGoal],
        progressByGoal: const <String, int>{},
        updateFailure: failure,
      );

      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          goalProgressRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      const UpdateGoalProgressParams params =
          UpdateGoalProgressParams(goalId: 'goal-active', newProgress: 4);
      final ProviderSubscription<AsyncValue<void>> subscription =
          container.listen(
        updateGoalProgressProvider(params),
        (_, __) {},
      );
      addTearDown(subscription.close);

      final notifier =
          container.read(updateGoalProgressProvider(params).notifier);

      await expectLater(
        notifier.updateProgress(params),
        throwsA(equals(failure)),
      );
      expect(notifier.state.hasError, isTrue);
    });
  });

  group('selectedDashboardSectionProvider', () {
    test('defaults to active and can be updated', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedDashboardSectionProvider),
          DashboardSection.active);

      container.read(selectedDashboardSectionProvider.notifier).state =
          DashboardSection.completed;

      expect(container.read(selectedDashboardSectionProvider),
          DashboardSection.completed);
    });
  });
}
