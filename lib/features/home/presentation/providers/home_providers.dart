// Home screen state management and data aggregation providers.
// Coordinates display data from multiple features for unified home experience.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/account_providers.dart';

/// State for the home screen containing aggregated data
class HomeScreenState {
  const HomeScreenState({
    required this.recentLogsCount,
    required this.todayLogsCount,
    this.hasActiveRecording = false,
  });

  final int recentLogsCount;
  final int todayLogsCount;
  final bool hasActiveRecording;
}

/// Provider for home screen state that aggregates various data sources
final homeScreenStateProvider = FutureProvider<HomeScreenState>((ref) async {
  // TODO: Replace with actual data sources once implemented

  // Simulate loading time for better UX
  await Future.delayed(const Duration(milliseconds: 500));

  // For now, return mock data
  // In Phase 2, this will pull from actual data sources:
  // - ref.watch(recentSmokeLogsProvider)
  // - ref.watch(todayStatsProvider)
  // - ref.watch(activeRecordingProvider)

  return const HomeScreenState(
    recentLogsCount: 3, // Mock: Will be actual count from last 7 days
    todayLogsCount: 1, // Mock: Will be actual count from today
    hasActiveRecording: false,
  );
});

/// Active account async provider for home screen
/// Wraps the account ID with async state for UI loading patterns
final activeAccountAsyncProvider = Provider<AsyncValue<String?>>((ref) {
  final accountId = ref.watch(currentAccountIdProvider);
  return AsyncData(accountId);
});
