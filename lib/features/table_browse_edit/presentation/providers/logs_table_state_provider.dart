// State management for logs table UI
// Manages filter, sort, pagination, and selection state

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../domain/entities/log_filter.dart';
import '../../domain/entities/log_sort.dart';
import 'logs_table_providers.dart';

part 'logs_table_state_provider.freezed.dart';

/// State for the logs table UI
/// Manages filtering, sorting, pagination, and selection
@freezed
class LogsTableState with _$LogsTableState {
  const factory LogsTableState({
    // Filter and sort state
    @Default(LogFilter()) LogFilter filter,
    @Default(LogSort.defaultSort) LogSort sort,
    
    // Pagination state
    @Default(50) int pageSize,
    @Default(0) int currentPage,
    @Default(0) int totalLogs,
    
    // Selection state for multi-select operations
    @Default({}) Set<String> selectedLogIds,
    
    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    
    // Error state
    String? error,
    
    // Account context
    required String accountId,
  }) = _LogsTableState;

  const LogsTableState._();

  /// Calculate total pages based on total logs and page size
  int get totalPages => (totalLogs / pageSize).ceil();

  /// Check if there are more pages to load
  bool get hasNextPage => currentPage < totalPages - 1;

  /// Check if we can go to previous page
  bool get hasPreviousPage => currentPage > 0;

  /// Get current offset for pagination
  int get offset => currentPage * pageSize;

  /// Check if any filters are applied
  bool get hasActiveFilters => filter.hasFilters;

  /// Check if any logs are selected
  bool get hasSelectedLogs => selectedLogIds.isNotEmpty;

  /// Get parameters for data providers
  LogsTableParams get queryParams => LogsTableParams(
    accountId: accountId,
    filter: hasActiveFilters ? filter : null,
    sort: sort,
    limit: pageSize,
    offset: offset,
  );
}

/// Notifier for logs table state management
class LogsTableStateNotifier extends StateNotifier<LogsTableState> {
  LogsTableStateNotifier({required String accountId})
      : super(LogsTableState(accountId: accountId));

  /// Update filter criteria
  void updateFilter(LogFilter newFilter) {
    state = state.copyWith(
      filter: newFilter,
      currentPage: 0, // Reset to first page when filter changes
      selectedLogIds: {}, // Clear selection
    );
  }

  /// Clear all filters
  void clearFilters() {
    updateFilter(const LogFilter());
  }

  /// Update sort criteria
  void updateSort(LogSort newSort) {
    state = state.copyWith(
      sort: newSort,
      currentPage: 0, // Reset to first page when sort changes
      selectedLogIds: {}, // Clear selection
    );
  }

  /// Go to next page
  void nextPage() {
    if (state.hasNextPage) {
      state = state.copyWith(
        currentPage: state.currentPage + 1,
        selectedLogIds: {}, // Clear selection when changing pages
      );
    }
  }

  /// Go to previous page
  void previousPage() {
    if (state.hasPreviousPage) {
      state = state.copyWith(
        currentPage: state.currentPage - 1,
        selectedLogIds: {}, // Clear selection when changing pages
      );
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 0 && page < state.totalPages) {
      state = state.copyWith(
        currentPage: page,
        selectedLogIds: {}, // Clear selection when changing pages
      );
    }
  }

  /// Update page size and reset to first page
  void updatePageSize(int newPageSize) {
    state = state.copyWith(
      pageSize: newPageSize,
      currentPage: 0,
      selectedLogIds: {},
    );
  }

  /// Update total logs count (called when data is loaded)
  void updateTotalLogs(int totalLogs) {
    state = state.copyWith(totalLogs: totalLogs);
  }

  /// Toggle selection of a log
  void toggleLogSelection(String logId) {
    final selectedIds = Set<String>.from(state.selectedLogIds);
    if (selectedIds.contains(logId)) {
      selectedIds.remove(logId);
    } else {
      selectedIds.add(logId);
    }
    state = state.copyWith(selectedLogIds: selectedIds);
  }

  /// Select all logs on current page
  void selectAllOnPage(List<SmokeLog> currentPageLogs) {
    final pageLogIds = currentPageLogs.map((log) => log.id).toSet();
    final selectedIds = Set<String>.from(state.selectedLogIds);
    selectedIds.addAll(pageLogIds);
    state = state.copyWith(selectedLogIds: selectedIds);
  }

  /// Clear all selections
  void clearSelection() {
    state = state.copyWith(selectedLogIds: {});
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Set refreshing state
  void setRefreshing(bool isRefreshing) {
    state = state.copyWith(isRefreshing: isRefreshing);
  }

  /// Set error state
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Reset state to initial values
  void reset() {
    state = LogsTableState(accountId: state.accountId);
  }
}

/// Provider for logs table state management
final logsTableStateProvider =
    StateNotifierProvider.family<LogsTableStateNotifier, LogsTableState, String>(
  (ref, accountId) => LogsTableStateNotifier(accountId: accountId),
);

/// Convenience provider for current query parameters
final currentQueryParamsProvider = Provider.family<LogsTableParams, String>(
  (ref, accountId) {
    final state = ref.watch(logsTableStateProvider(accountId));
    return state.queryParams;
  },
);