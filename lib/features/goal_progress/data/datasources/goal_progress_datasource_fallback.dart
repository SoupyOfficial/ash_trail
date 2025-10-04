// Fallback in-memory implementations for goal progress data sources
// Provides lightweight offline-friendly storage until Isar/Firestore wiring is available.

import '../../../../domain/models/goal.dart';
import 'goal_progress_local_datasource.dart';
import 'goal_progress_remote_datasource.dart';

/// Shared in-memory store so local and remote fallbacks stay in sync.
class GoalProgressFallbackStore {
  GoalProgressFallbackStore({DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Map<String, Map<String, Goal>> _goalsByAccount =
      <String, Map<String, Goal>>{};
  final Map<String, String> _accountByGoalId = <String, String>{};
  final Set<String> _pendingSyncGoalIds = <String>{};
  final Map<String, DateTime> _updatedAtByGoalId = <String, DateTime>{};

  void ensureSeeded(String accountId) {
    if (_goalsByAccount.containsKey(accountId)) {
      return;
    }

    final DateTime today = _now();
    final DateTime monthStart = DateTime(today.year, today.month, 1);

    final List<Goal> seededGoals = <Goal>[
      Goal(
        id: 'demo-goal-1',
        accountId: accountId,
        type: 'smoke_free_days',
        target: 7,
        window: 'weekly',
        startDate: monthStart.subtract(const Duration(days: 14)),
        active: true,
        progress: 3,
      ),
      Goal(
        id: 'demo-goal-2',
        accountId: accountId,
        type: 'reduction_count',
        target: 15,
        window: 'monthly',
        startDate: monthStart.subtract(const Duration(days: 30)),
        active: true,
        progress: 8,
      ),
      Goal(
        id: 'demo-goal-3',
        accountId: accountId,
        type: 'duration_limit',
        target: 20,
        window: 'monthly',
        startDate: monthStart.subtract(const Duration(days: 90)),
        endDate: monthStart.subtract(const Duration(days: 30)),
        active: false,
        progress: 20,
        achievedAt: monthStart.subtract(const Duration(days: 20)),
      ),
    ];

    final Map<String, Goal> seededMap = <String, Goal>{};
    for (final Goal goal in seededGoals) {
      seededMap[goal.id] = goal;
      _accountByGoalId[goal.id] = accountId;
      _updatedAtByGoalId[goal.id] = _now();
    }

    _goalsByAccount[accountId] = seededMap;
  }

  List<Goal> goalsForAccount(String accountId) {
    ensureSeeded(accountId);
    final Map<String, Goal> goals = _goalsByAccount[accountId]!;
    return goals.values.toList(growable: false);
  }

  Goal? findGoal(String goalId) {
    final String? accountId = _accountByGoalId[goalId];
    if (accountId == null) {
      return null;
    }
    return _goalsByAccount[accountId]?[goalId];
  }

  Goal saveGoal(Goal goal) {
    final Map<String, Goal> accountGoals =
        _goalsByAccount.putIfAbsent(goal.accountId, () => <String, Goal>{});
    accountGoals[goal.id] = goal;
    _accountByGoalId[goal.id] = goal.accountId;
    _updatedAtByGoalId[goal.id] = _now();
    return goal;
  }

  void removeGoals(String accountId, Iterable<String> goalIds) {
    ensureSeeded(accountId);
    final Map<String, Goal> accountGoals = _goalsByAccount[accountId]!;
    for (final String goalId in goalIds) {
      accountGoals.remove(goalId);
      _accountByGoalId.remove(goalId);
      _pendingSyncGoalIds.remove(goalId);
      _updatedAtByGoalId.remove(goalId);
    }
  }

  void markPending(String goalId) => _pendingSyncGoalIds.add(goalId);

  void markSynced(String goalId) => _pendingSyncGoalIds.remove(goalId);

  List<Goal> pendingGoals(String accountId) {
    ensureSeeded(accountId);
    final Map<String, Goal> accountGoals = _goalsByAccount[accountId]!;
    return accountGoals.entries
        .where((entry) => _pendingSyncGoalIds.contains(entry.key))
        .map((entry) => entry.value)
        .toList(growable: false);
  }

  List<Goal> goalsModifiedSince(String accountId, DateTime since) {
    ensureSeeded(accountId);
    final Map<String, Goal> accountGoals = _goalsByAccount[accountId]!;
    return accountGoals.values
        .where((goal) => (_updatedAtByGoalId[goal.id] ??
                DateTime.fromMillisecondsSinceEpoch(0))
            .isAfter(since))
        .toList(growable: false);
  }

  void clearAccount(String accountId) {
    final Map<String, Goal>? removed = _goalsByAccount.remove(accountId);
    if (removed == null) {
      return;
    }
    for (final String goalId in removed.keys) {
      _accountByGoalId.remove(goalId);
      _pendingSyncGoalIds.remove(goalId);
      _updatedAtByGoalId.remove(goalId);
    }
  }

  DateTime now() => _now();
}

/// In-memory fallback for [GoalProgressLocalDataSource].
class GoalProgressLocalDataSourceFallback
    implements GoalProgressLocalDataSource {
  GoalProgressLocalDataSourceFallback(
      {required GoalProgressFallbackStore store})
      : _store = store;

  final GoalProgressFallbackStore _store;

  @override
  Future<List<Goal>> getActiveGoals(String accountId) async {
    return _store
        .goalsForAccount(accountId)
        .where((goal) => goal.active && goal.achievedAt == null)
        .toList(growable: false);
  }

  @override
  Future<List<Goal>> getCompletedGoals(String accountId) async {
    return _store
        .goalsForAccount(accountId)
        .where((goal) => goal.achievedAt != null)
        .toList(growable: false);
  }

  @override
  Future<List<Goal>> getAllGoals(String accountId) async {
    return _store.goalsForAccount(accountId);
  }

  @override
  Future<Goal?> getGoalById(String goalId) async {
    return _store.findGoal(goalId);
  }

  @override
  Future<Goal> updateGoalProgress({
    required String goalId,
    required int newProgress,
  }) async {
    final Goal? current = _store.findGoal(goalId);
    if (current == null) {
      throw StateError('Goal not found: $goalId');
    }

    final Goal updated = current.copyWith(progress: newProgress);
    _store.saveGoal(updated);
    _store.markPending(goalId);
    return updated;
  }

  @override
  Future<Goal> markGoalAsAchieved(String goalId) async {
    final Goal? current = _store.findGoal(goalId);
    if (current == null) {
      throw StateError('Goal not found: $goalId');
    }

    final Goal updated = current.copyWith(
      active: false,
      achievedAt: current.achievedAt ?? _store.now(),
      progress: current.progress ?? current.target,
    );

    _store.saveGoal(updated);
    _store.markPending(goalId);
    return updated;
  }

  @override
  Future<List<Goal>> getPendingSyncGoals(String accountId) async {
    return _store.pendingGoals(accountId);
  }

  @override
  Future<void> markAsSynced(String goalId) async {
    _store.markSynced(goalId);
  }

  @override
  Future<int> getGoalsCount(String accountId) async {
    return _store.goalsForAccount(accountId).length;
  }

  @override
  Future<void> clearAccountGoals(String accountId) async {
    _store.clearAccount(accountId);
  }
}

/// In-memory fallback for [GoalProgressRemoteDataSource].
class GoalProgressRemoteDataSourceFallback
    implements GoalProgressRemoteDataSource {
  GoalProgressRemoteDataSourceFallback(
      {required GoalProgressFallbackStore store})
      : _store = store;

  final GoalProgressFallbackStore _store;

  @override
  Future<List<Goal>> getActiveGoals(String accountId) async {
    return _store
        .goalsForAccount(accountId)
        .where((goal) => goal.active && goal.achievedAt == null)
        .toList(growable: false);
  }

  @override
  Future<List<Goal>> getCompletedGoals(String accountId) async {
    return _store
        .goalsForAccount(accountId)
        .where((goal) => goal.achievedAt != null)
        .toList(growable: false);
  }

  @override
  Future<List<Goal>> getAllGoals(String accountId) async {
    return _store.goalsForAccount(accountId);
  }

  @override
  Future<Goal?> getGoalById(String goalId) async {
    return _store.findGoal(goalId);
  }

  @override
  Future<Goal> updateGoalProgress({
    required String goalId,
    required int newProgress,
  }) async {
    final Goal? current = _store.findGoal(goalId);
    if (current == null) {
      throw StateError('Goal not found: $goalId');
    }
    final Goal updated = current.copyWith(progress: newProgress);
    return _store.saveGoal(updated);
  }

  @override
  Future<Goal> markGoalAsAchieved(String goalId) async {
    final Goal? current = _store.findGoal(goalId);
    if (current == null) {
      throw StateError('Goal not found: $goalId');
    }
    final Goal updated = current.copyWith(
      active: false,
      achievedAt: current.achievedAt ?? _store.now(),
      progress: current.progress ?? current.target,
    );
    return _store.saveGoal(updated);
  }

  @override
  Future<void> syncGoals(List<Goal> localGoals) async {
    for (final Goal goal in localGoals) {
      _store.saveGoal(goal);
      _store.markSynced(goal.id);
    }
  }

  @override
  Future<List<Goal>> getGoalsModifiedSince({
    required String accountId,
    required DateTime since,
  }) async {
    return _store.goalsModifiedSince(accountId, since);
  }

  @override
  Future<DateTime> getServerTimestamp() async => _store.now();

  @override
  Future<void> deleteGoals(List<String> goalIds) async {
    for (final String goalId in goalIds) {
      final Goal? existing = _store.findGoal(goalId);
      if (existing != null) {
        _store.removeGoals(existing.accountId, <String>[goalId]);
      }
    }
  }
}
