// Action providers for logs table operations
// Manages update, delete, and other table actions with state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/smoke_log.dart';
import 'logs_table_providers.dart';
import 'logs_table_state_provider.dart';

/// Provider for updating smoke logs
/// Returns the updated smoke log or throws an AppFailure
class UpdateSmokeLogNotifier
    extends AutoDisposeFamilyAsyncNotifier<SmokeLog, String> {
  @override
  Future<SmokeLog> build(String arg) {
    // Return a never-completing future initially
    return Future<SmokeLog>(() => throw UnimplementedError());
  }

  /// Update a smoke log with the given data
  Future<SmokeLog> updateSmokeLog({
    required SmokeLog smokeLog,
    required String accountId,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(updateSmokeLogUseCaseProvider);
    final result = await useCase(
      smokeLog: smokeLog,
      accountId: accountId,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw failure;
      },
      (updatedLog) {
        state = AsyncData(updatedLog);

        // Invalidate related providers to refresh the table
        ref.invalidate(filteredSortedLogsProvider);

        return updatedLog;
      },
    );
  }
}

final updateSmokeLogProvider = AutoDisposeAsyncNotifierProviderFamily<
    UpdateSmokeLogNotifier, SmokeLog, String>(() {
  return UpdateSmokeLogNotifier();
});

/// Provider for deleting single smoke logs
class DeleteSmokeLogNotifier
    extends AutoDisposeFamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) {
    return Future<void>(() => throw UnimplementedError());
  }

  /// Delete a smoke log by ID
  Future<void> deleteSmokeLog({
    required String smokeLogId,
    required String accountId,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(deleteSmokeLogUseCaseProvider);
    final result = await useCase(
      smokeLogId: smokeLogId,
      accountId: accountId,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw failure;
      },
      (_) {
        state = const AsyncData(null);

        // Invalidate related providers to refresh the table
        ref.invalidate(filteredSortedLogsProvider);
        ref.invalidate(logsCountProvider);

        // Remove from selection if it was selected
        ref
            .read(logsTableStateProvider(accountId).notifier)
            .toggleLogSelection(smokeLogId);
      },
    );
  }
}

final deleteSmokeLogProvider = AutoDisposeAsyncNotifierProviderFamily<
    DeleteSmokeLogNotifier, void, String>(() {
  return DeleteSmokeLogNotifier();
});

/// Provider for batch deleting smoke logs
class DeleteSmokeLogsBatchNotifier
    extends AutoDisposeFamilyAsyncNotifier<int, String> {
  @override
  Future<int> build(String arg) {
    return Future<int>(() => throw UnimplementedError());
  }

  /// Delete multiple smoke logs by IDs
  Future<int> deleteSmokeLogsBatch({
    required List<String> smokeLogIds,
    required String accountId,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(deleteSmokeLogsBatchUseCaseProvider);
    final result = await useCase(
      smokeLogIds: smokeLogIds,
      accountId: accountId,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw failure;
      },
      (deletedCount) {
        state = AsyncData(deletedCount);

        // Invalidate related providers to refresh the table
        ref.invalidate(filteredSortedLogsProvider);
        ref.invalidate(logsCountProvider);

        // Clear selection
        ref.read(logsTableStateProvider(accountId).notifier).clearSelection();

        return deletedCount;
      },
    );
  }

  /// Delete all selected logs
  Future<int> deleteSelectedLogs({required String accountId}) async {
    final selectedIds =
        ref.read(logsTableStateProvider(accountId)).selectedLogIds.toList();

    if (selectedIds.isEmpty) {
      throw Exception('No logs selected for deletion');
    }

    return deleteSmokeLogsBatch(
      smokeLogIds: selectedIds,
      accountId: accountId,
    );
  }
}

final deleteSmokeLogsBatchProvider = AutoDisposeAsyncNotifierProviderFamily<
    DeleteSmokeLogsBatchNotifier, int, String>(() {
  return DeleteSmokeLogsBatchNotifier();
});

/// Provider for refreshing table data
/// Handles pull-to-refresh and manual refresh operations
class RefreshLogsTableNotifier
    extends AutoDisposeFamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String arg) {
    return Future<void>(() => throw UnimplementedError());
  }

  /// Refresh the logs table data
  Future<void> refresh({required String accountId}) async {
    state = const AsyncLoading();

    try {
      // Set refreshing state in table state
      ref.read(logsTableStateProvider(accountId).notifier).setRefreshing(true);

      // Invalidate all data providers to force refresh
      ref.invalidate(filteredSortedLogsProvider);
      ref.invalidate(logsCountProvider);
      ref.invalidate(usedMethodIdsProvider);
      ref.invalidate(usedTagIdsProvider);

      // Wait for the data to be refetched
      final params = ref.read(currentQueryParamsProvider(accountId));
      await ref.read(filteredSortedLogsProvider(params).future);
      await ref.read(logsCountProvider(params).future);

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    } finally {
      // Clear refreshing state
      ref.read(logsTableStateProvider(accountId).notifier).setRefreshing(false);
    }
  }
}

final refreshLogsTableProvider = AutoDisposeAsyncNotifierProviderFamily<
    RefreshLogsTableNotifier, void, String>(() {
  return RefreshLogsTableNotifier();
});

/// Provider for batch adding tags to logs
class AddTagsToLogsBatchNotifier
    extends AutoDisposeFamilyAsyncNotifier<int, String> {
  @override
  Future<int> build(String arg) {
    return Future<int>(() => throw UnimplementedError());
  }

  Future<int> addTagsToLogs({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(addTagsToLogsBatchUseCaseProvider);
    final result = await useCase(
      accountId: accountId,
      smokeLogIds: smokeLogIds,
      tagIds: tagIds,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw failure;
      },
      (count) {
        state = AsyncData(count);

        // Refresh table and used tags
        ref.invalidate(filteredSortedLogsProvider);
        ref.invalidate(usedTagIdsProvider);

        return count;
      },
    );
  }
}

final addTagsToLogsBatchProvider = AutoDisposeAsyncNotifierProviderFamily<
    AddTagsToLogsBatchNotifier, int, String>(() {
  return AddTagsToLogsBatchNotifier();
});

/// Provider for batch removing tags from logs
class RemoveTagsFromLogsBatchNotifier
    extends AutoDisposeFamilyAsyncNotifier<int, String> {
  @override
  Future<int> build(String arg) {
    return Future<int>(() => throw UnimplementedError());
  }

  Future<int> removeTagsFromLogs({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    state = const AsyncLoading();

    final useCase = ref.read(removeTagsFromLogsBatchUseCaseProvider);
    final result = await useCase(
      accountId: accountId,
      smokeLogIds: smokeLogIds,
      tagIds: tagIds,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw failure;
      },
      (count) {
        state = AsyncData(count);

        // Refresh table and used tags
        ref.invalidate(filteredSortedLogsProvider);
        ref.invalidate(usedTagIdsProvider);

        return count;
      },
    );
  }
}

final removeTagsFromLogsBatchProvider = AutoDisposeAsyncNotifierProviderFamily<
    RemoveTagsFromLogsBatchNotifier, int, String>(() {
  return RemoveTagsFromLogsBatchNotifier();
});

/// Convenience provider for table operations
/// Provides a unified interface for common table actions
final tableActionsProvider = Provider.family<TableActions, String>(
  (ref, accountId) => TableActions(ref, accountId),
);

/// Helper class that provides convenient methods for table operations
class TableActions {
  final Ref _ref;
  final String _accountId;

  TableActions(this._ref, this._accountId);

  /// Update a smoke log
  Future<SmokeLog> updateLog(SmokeLog smokeLog) {
    return _ref
        .read(updateSmokeLogProvider(_accountId).notifier)
        .updateSmokeLog(smokeLog: smokeLog, accountId: _accountId);
  }

  /// Delete a smoke log
  Future<void> deleteLog(String smokeLogId) {
    return _ref
        .read(deleteSmokeLogProvider(_accountId).notifier)
        .deleteSmokeLog(smokeLogId: smokeLogId, accountId: _accountId);
  }

  /// Delete multiple smoke logs
  Future<int> deleteLogs(List<String> smokeLogIds) {
    return _ref
        .read(deleteSmokeLogsBatchProvider(_accountId).notifier)
        .deleteSmokeLogsBatch(smokeLogIds: smokeLogIds, accountId: _accountId);
  }

  /// Delete all selected logs
  Future<int> deleteSelectedLogs() {
    return _ref
        .read(deleteSmokeLogsBatchProvider(_accountId).notifier)
        .deleteSelectedLogs(accountId: _accountId);
  }

  /// Refresh table data
  Future<void> refresh() {
    return _ref
        .read(refreshLogsTableProvider(_accountId).notifier)
        .refresh(accountId: _accountId);
  }

  /// Add tags to logs in batch
  Future<int> addTagsToLogs({
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) {
    return _ref
        .read(addTagsToLogsBatchProvider(_accountId).notifier)
        .addTagsToLogs(
          accountId: _accountId,
          smokeLogIds: smokeLogIds,
          tagIds: tagIds,
        );
  }

  /// Remove tags from logs in batch
  Future<int> removeTagsFromLogs({
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) {
    return _ref
        .read(removeTagsFromLogsBatchProvider(_accountId).notifier)
        .removeTagsFromLogs(
          accountId: _accountId,
          smokeLogIds: smokeLogIds,
          tagIds: tagIds,
        );
  }
}
