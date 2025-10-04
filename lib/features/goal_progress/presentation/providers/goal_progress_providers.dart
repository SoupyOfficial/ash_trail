// Riverpod providers for goal progress functionality
// Manages repository, use cases, and state for goal progress dashboard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/goal_progress_datasource_fallback.dart';
import '../../data/datasources/goal_progress_local_datasource.dart';
import '../../data/datasources/goal_progress_remote_datasource.dart';
import '../../data/repositories/goal_progress_repository_impl.dart';
import '../../domain/repositories/goal_progress_repository.dart';
import '../../domain/usecases/get_goal_progress_usecase.dart';
import '../../domain/usecases/update_goal_progress_usecase.dart';

/// Repository providers - Abstract interfaces
/// These should be overridden in main.dart with concrete implementations
final _goalProgressFallbackStoreProvider =
    Provider<GoalProgressFallbackStore>((ref) {
  return GoalProgressFallbackStore();
});

final goalProgressLocalDataSourceProvider =
    FutureProvider<GoalProgressLocalDataSource>((ref) async {
  final store = ref.watch(_goalProgressFallbackStoreProvider);
  return GoalProgressLocalDataSourceFallback(store: store);
});

final goalProgressRemoteDataSourceProvider =
    FutureProvider<GoalProgressRemoteDataSource>((ref) async {
  final store = ref.watch(_goalProgressFallbackStoreProvider);
  return GoalProgressRemoteDataSourceFallback(store: store);
});

/// Repository implementation provider
final goalProgressRepositoryProvider =
    FutureProvider<GoalProgressRepository>((ref) async {
  final local = await ref.watch(goalProgressLocalDataSourceProvider.future);
  final remote = await ref.watch(goalProgressRemoteDataSourceProvider.future);

  return GoalProgressRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
  );
});

/// Use case providers
final getGoalProgressUseCaseProvider =
    FutureProvider<GetGoalProgressUseCase>((ref) async {
  final repository = await ref.watch(goalProgressRepositoryProvider.future);
  return GetGoalProgressUseCase(repository);
});

final updateGoalProgressUseCaseProvider =
    FutureProvider<UpdateGoalProgressUseCase>((ref) async {
  final repository = await ref.watch(goalProgressRepositoryProvider.future);
  return UpdateGoalProgressUseCase(repository);
});

/// Goal Progress Dashboard Provider
/// Returns the complete dashboard data with active and completed goals
final goalProgressDashboardProvider =
    FutureProvider.family<GoalProgressDashboard, String>(
        (ref, accountId) async {
  final useCase = await ref.watch(getGoalProgressUseCaseProvider.future);
  final result = await useCase(accountId);

  return result.fold(
    (failure) => throw failure,
    (dashboard) => dashboard,
  );
});

/// Provider for updating goal progress
/// Returns the updated goal or throws an AppFailure
class UpdateGoalProgressNotifier
    extends AutoDisposeFamilyAsyncNotifier<void, UpdateGoalProgressParams> {
  @override
  Future<void> build(UpdateGoalProgressParams arg) async {}

  /// Update goal progress with the given parameters
  Future<void> updateProgress(UpdateGoalProgressParams params) async {
    state = const AsyncLoading();

    final useCase = await ref.read(updateGoalProgressUseCaseProvider.future);
    final result = await useCase(params);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw failure;
      },
      (updatedGoal) {
        state = const AsyncData(null);

        // Invalidate related providers to refresh UI
        ref.invalidate(goalProgressDashboardProvider(updatedGoal.accountId));
      },
    );
  }
}

final updateGoalProgressProvider = AutoDisposeAsyncNotifierProviderFamily<
    UpdateGoalProgressNotifier, void, UpdateGoalProgressParams>(() {
  return UpdateGoalProgressNotifier();
});

/// Selected dashboard section provider (active or completed)
enum DashboardSection { active, completed }

final selectedDashboardSectionProvider = StateProvider<DashboardSection>((ref) {
  return DashboardSection.active;
});

/// Provider to check if there are any goals at all
final hasAnyGoalsProvider = Provider.family<bool, String>((ref, accountId) {
  final dashboardAsync = ref.watch(goalProgressDashboardProvider(accountId));

  return dashboardAsync.when(
    data: (dashboard) => dashboard.hasGoals,
    loading: () => false,
    error: (error, stack) => false,
  );
});

/// Provider for completion rate percentage
final goalCompletionRateProvider =
    Provider.family<double, String>((ref, accountId) {
  final dashboardAsync = ref.watch(goalProgressDashboardProvider(accountId));

  return dashboardAsync.when(
    data: (dashboard) => dashboard.completionRate,
    loading: () => 0.0,
    error: (error, stack) => 0.0,
  );
});
