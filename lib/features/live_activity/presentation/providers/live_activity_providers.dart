// Providers for live activity recording functionality.
// Manages state and dependency injection for live activity features.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/live_activity_entity.dart';
import '../../domain/repositories/live_activity_repository.dart';
import '../../domain/usecases/start_activity_use_case.dart';
import '../../domain/usecases/complete_activity_use_case.dart';
import '../../domain/usecases/cancel_activity_use_case.dart';
import '../../domain/usecases/get_current_activity_use_case.dart';
import '../../domain/usecases/cleanup_orphaned_activities_use_case.dart';
import '../../data/repositories/live_activity_repository_impl.dart';
import '../../data/datasources/live_activity_data_source.dart';

// SharedPreferences provider (reused across features)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This should be overridden in main.dart with the actual instance
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with the actual SharedPreferences instance',
  );
});

// Data source provider
final liveActivityDataSourceProvider = Provider<LiveActivityDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LiveActivityDataSource(prefs);
});

// Repository provider
final liveActivityRepositoryProvider = Provider<LiveActivityRepository>((ref) {
  final dataSource = ref.watch(liveActivityDataSourceProvider);
  return LiveActivityRepositoryImpl(dataSource);
});

// Use case providers
final startActivityUseCaseProvider = Provider<StartActivityUseCase>((ref) {
  final repository = ref.watch(liveActivityRepositoryProvider);
  return StartActivityUseCase(repository);
});

final completeActivityUseCaseProvider =
    Provider<CompleteActivityUseCase>((ref) {
  final repository = ref.watch(liveActivityRepositoryProvider);
  return CompleteActivityUseCase(repository);
});

final cancelActivityUseCaseProvider = Provider<CancelActivityUseCase>((ref) {
  final repository = ref.watch(liveActivityRepositoryProvider);
  return CancelActivityUseCase(repository);
});

final getCurrentActivityUseCaseProvider =
    Provider<GetCurrentActivityUseCase>((ref) {
  final repository = ref.watch(liveActivityRepositoryProvider);
  return GetCurrentActivityUseCase(repository);
});

final cleanupOrphanedActivitiesUseCaseProvider =
    Provider<CleanupOrphanedActivitiesUseCase>((ref) {
  final repository = ref.watch(liveActivityRepositoryProvider);
  return CleanupOrphanedActivitiesUseCase(repository);
});

// Current activity provider - streams the current recording session
final currentActivityProvider = StreamProvider<LiveActivityEntity?>((ref) {
  final repository = ref.watch(liveActivityRepositoryProvider);
  return repository.watchCurrentActivity();
});

// Live activity controller - manages recording lifecycle
final liveActivityControllerProvider = StateNotifierProvider<
    LiveActivityController, AsyncValue<LiveActivityEntity?>>((ref) {
  return LiveActivityController(ref);
});

// Timer provider for elapsed time updates - only active when recording
final elapsedTimeProvider =
    StreamProvider.family<Duration, String>((ref, activityId) {
  final currentActivity = ref.watch(currentActivityProvider);

  return currentActivity.when(
    data: (activity) {
      if (activity?.id != activityId || !activity!.isActive) {
        // Return a stream that emits once with current duration then completes
        return Stream.value(activity?.elapsedDuration ?? Duration.zero);
      }

      // Return a periodic stream that updates elapsed time every second
      return Stream.periodic(const Duration(seconds: 1), (_) {
        return activity.elapsedDuration;
      }).distinct(); // Only emit when duration changes (by seconds)
    },
    loading: () => Stream.value(Duration.zero),
    error: (_, __) => Stream.value(Duration.zero),
  );
});

class LiveActivityController
    extends StateNotifier<AsyncValue<LiveActivityEntity?>> {
  LiveActivityController(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final Ref _ref;

  void _initialize() async {
    // Clean up any orphaned activities on startup
    final cleanupUseCase = _ref.read(cleanupOrphanedActivitiesUseCaseProvider);
    await cleanupUseCase();

    // Load current activity
    await _loadCurrentActivity();
  }

  Future<void> _loadCurrentActivity() async {
    state = const AsyncValue.loading();

    final getCurrentUseCase = _ref.read(getCurrentActivityUseCaseProvider);
    final result = await getCurrentUseCase();

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (activity) => AsyncValue.data(activity),
    );
  }

  /// Start a new recording session
  Future<void> startRecording() async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    final startUseCase = _ref.read(startActivityUseCaseProvider);
    final result = await startUseCase();

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (activity) => AsyncValue.data(activity),
    );
  }

  /// Complete the current recording session
  Future<void> completeRecording() async {
    final currentActivity = state.valueOrNull;
    if (currentActivity == null || !currentActivity.isActive) return;

    state = const AsyncValue.loading();

    final completeUseCase = _ref.read(completeActivityUseCaseProvider);
    final result = await completeUseCase(currentActivity.id);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) =>
          const AsyncValue.data(null), // No current activity after completion
    );
  }

  /// Cancel the current recording session
  Future<void> cancelRecording({String? reason}) async {
    final currentActivity = state.valueOrNull;
    if (currentActivity == null || !currentActivity.isActive) return;

    state = const AsyncValue.loading();

    final cancelUseCase = _ref.read(cancelActivityUseCaseProvider);
    final result = await cancelUseCase(currentActivity.id, reason: reason);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) =>
          const AsyncValue.data(null), // No current activity after cancellation
    );
  }

  /// Refresh current activity state
  Future<void> refresh() async {
    await _loadCurrentActivity();
  }
}
