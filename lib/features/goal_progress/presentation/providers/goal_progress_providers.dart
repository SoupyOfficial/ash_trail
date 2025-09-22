// Riverpod providers for goal progress functionality
// Manages repository, use cases, and state for goal progress dashboard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/goal_progress_local_datasource.dart';
import '../../data/datasources/goal_progress_remote_datasource.dart';
import '../../data/repositories/goal_progress_repository_impl.dart';
import '../../domain/repositories/goal_progress_repository.dart';
import '../../domain/usecases/get_goal_progress_usecase.dart';
import '../../domain/usecases/update_goal_progress_usecase.dart';

/// Repository providers - Abstract interfaces
/// These should be overridden in main.dart with concrete implementations
final goalProgressLocalDataSourceProvider =
    Provider<GoalProgressLocalDataSource>((ref) {
  throw UnimplementedError(
    'goalProgressLocalDataSourceProvider must be overridden with Isar implementation',
  );
});

final goalProgressRemoteDataSourceProvider =
    Provider<GoalProgressRemoteDataSource>((ref) {
  throw UnimplementedError(
    'goalProgressRemoteDataSourceProvider must be overridden with Firestore implementation',
  );
});

/// Repository implementation provider
final goalProgressRepositoryProvider = Provider<GoalProgressRepository>((ref) {
  return GoalProgressRepositoryImpl(
    localDataSource: ref.watch(goalProgressLocalDataSourceProvider),
    remoteDataSource: ref.watch(goalProgressRemoteDataSourceProvider),
  );
});

/// Use case providers
final getGoalProgressUseCaseProvider = Provider<GetGoalProgressUseCase>((ref) {
  return GetGoalProgressUseCase(
    ref.watch(goalProgressRepositoryProvider),
  );
});

final updateGoalProgressUseCaseProvider = Provider<UpdateGoalProgressUseCase>((ref) {
  return UpdateGoalProgressUseCase(
    ref.watch(goalProgressRepositoryProvider),
  );
});

/// Goal Progress Dashboard Provider
/// Returns the complete dashboard data with active and completed goals
final goalProgressDashboardProvider =
    FutureProvider.family<GoalProgressDashboard, String>((ref, accountId) async {
  final useCase = ref.watch(getGoalProgressUseCaseProvider);
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
  Future<void> build(UpdateGoalProgressParams arg) {
    // Return a never-completing future initially
    return Future<void>(() => throw UnimplementedError());
  }

  /// Update goal progress with the given parameters
  Future<void> updateProgress(UpdateGoalProgressParams params) async {
    state = const AsyncLoading();

    final useCase = ref.read(updateGoalProgressUseCaseProvider);
    final result = await useCase(params);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw failure;
      },
      (updatedGoal) {
        state = const AsyncData(null);

        // Invalidate related providers to refresh UI
        ref.invalidate(goalProgressDashboardProvider);
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
final goalCompletionRateProvider = Provider.family<double, String>((ref, accountId) {
  final dashboardAsync = ref.watch(goalProgressDashboardProvider(accountId));
  
  return dashboardAsync.when(
    data: (dashboard) => dashboard.completionRate,
    loading: () => 0.0,
    error: (error, stack) => 0.0,
  );
});