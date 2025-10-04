// Unit tests for LogsTableStateProvider
// Tests state management for logs table UI functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_filter.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_sort.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_state_provider.dart';

void main() {
  group('LogsTableStateProvider', () {
    late ProviderContainer container;
    const accountId = 'test_account';

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('should have correct default values', () {
        final state = container.read(logsTableStateProvider(accountId));

        expect(state.accountId, accountId);
        expect(state.filter, const LogFilter());
        expect(state.sort, LogSort.defaultSort);
        expect(state.pageSize, 50);
        expect(state.currentPage, 0);
        expect(state.totalLogs, 0);
        expect(state.selectedLogIds, isEmpty);
        expect(state.isLoading, false);
        expect(state.isRefreshing, false);
        expect(state.error, isNull);
      });

      test('should have correct computed properties', () {
        final state = container.read(logsTableStateProvider(accountId));

        expect(state.totalPages, 0);
        expect(state.hasNextPage, false);
        expect(state.hasPreviousPage, false);
        expect(state.offset, 0);
        expect(state.hasActiveFilters, false);
        expect(state.hasSelectedLogs, false);
      });

      test('should generate correct query parameters', () {
        final state = container.read(logsTableStateProvider(accountId));
        final params = state.queryParams;

        expect(params.accountId, accountId);
        expect(params.filter, isNull); // No filters active initially
        expect(params.sort, LogSort.defaultSort);
        expect(params.limit, 50);
        expect(params.offset, 0);
      });
    });

    group('Filter Management', () {
      test('should update filter and reset page', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);
        const newFilter = LogFilter(minMoodScore: 7);

        notifier.updateFilter(newFilter);

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.filter, newFilter);
        expect(state.currentPage, 0); // Should reset to first page
        expect(state.selectedLogIds, isEmpty); // Should clear selection
        expect(state.hasActiveFilters, true);
      });

      test('should clear all filters', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // First set some filters
        notifier.updateFilter(const LogFilter(minMoodScore: 7, searchText: 'test'));

        // Then clear them
        notifier.clearFilters();

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.filter, const LogFilter());
        expect(state.hasActiveFilters, false);
      });

      test('should handle complex filter combinations', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);
        final complexFilter = LogFilter(
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 12, 31),
          methodIds: ['vape', 'joint'],
          includeTagIds: ['relaxing', 'social'],
          excludeTagIds: ['harsh'],
          minMoodScore: 3,
          maxMoodScore: 8,
          searchText: 'great session',
        );

        notifier.updateFilter(complexFilter);

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.filter, complexFilter);
        expect(state.hasActiveFilters, true);
        expect(state.queryParams.filter, complexFilter);
      });
    });

    group('Sort Management', () {
      test('should update sort and reset page', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);
        const newSort = LogSort(
            field: LogSortField.duration, order: LogSortOrder.ascending);

        notifier.updateSort(newSort);

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.sort, newSort);
        expect(state.currentPage, 0); // Should reset to first page
        expect(state.selectedLogIds, isEmpty); // Should clear selection
      });

      test('should handle different sort configurations', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Test descending mood score sort
        const moodSort = LogSort(
            field: LogSortField.moodScore, order: LogSortOrder.descending);
        notifier.updateSort(moodSort);

        var state = container.read(logsTableStateProvider(accountId));
        expect(state.sort, moodSort);

        // Test ascending physical score sort
        const physicalSort = LogSort(
            field: LogSortField.physicalScore, order: LogSortOrder.ascending);
        notifier.updateSort(physicalSort);

        state = container.read(logsTableStateProvider(accountId));
        expect(state.sort, physicalSort);
      });
    });

    group('Pagination Management', () {
      test('should navigate to next page when available', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Set up state with multiple pages
        notifier.updateTotalLogs(150); // 3 pages with page size 50

        notifier.nextPage();

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.currentPage, 1);
        expect(state.offset, 50);
        expect(state.hasNextPage, true);
        expect(state.hasPreviousPage, true);
        expect(state.selectedLogIds, isEmpty); // Should clear selection
      });

      test('should not navigate beyond last page', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Set up state with 2 pages
        notifier.updateTotalLogs(100);
        notifier.goToPage(1); // Go to last page

        notifier.nextPage(); // Try to go beyond

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.currentPage, 1); // Should stay on last page
      });

      test('should navigate to previous page when available', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Set up state on page 2
        notifier.updateTotalLogs(150);
        notifier.goToPage(1);

        notifier.previousPage();

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.currentPage, 0);
        expect(state.offset, 0);
        expect(state.hasPreviousPage, false);
      });

      test('should not navigate before first page', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        notifier.previousPage(); // Try to go before first page

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.currentPage, 0); // Should stay on first page
      });

      test('should go to specific page within bounds', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        notifier.updateTotalLogs(200); // 4 pages
        notifier.goToPage(2);

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.currentPage, 2);
        expect(state.offset, 100);
      });

      test('should ignore out-of-bounds page requests', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        notifier.updateTotalLogs(100); // 2 pages (0, 1)

        notifier.goToPage(-1); // Invalid page
        expect(
            container.read(logsTableStateProvider(accountId)).currentPage, 0);

        notifier.goToPage(5); // Page beyond bounds
        expect(
            container.read(logsTableStateProvider(accountId)).currentPage, 0);
      });

      test('should update page size and reset pagination', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Set up state on page 2 with selections
        notifier.updateTotalLogs(200);
        notifier.goToPage(1);
        notifier.toggleLogSelection('log1');

        notifier.updatePageSize(25);

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.pageSize, 25);
        expect(state.currentPage, 0); // Should reset to first page
        expect(state.selectedLogIds, isEmpty); // Should clear selection
        expect(state.totalPages, 8); // 200 logs / 25 per page = 8 pages
      });
    });

    group('Selection Management', () {
      test('should toggle log selection', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);
        const logId = 'log123';

        // Select log
        notifier.toggleLogSelection(logId);
        var state = container.read(logsTableStateProvider(accountId));
        expect(state.selectedLogIds, contains(logId));
        expect(state.hasSelectedLogs, true);

        // Deselect log
        notifier.toggleLogSelection(logId);
        state = container.read(logsTableStateProvider(accountId));
        expect(state.selectedLogIds, isNot(contains(logId)));
        expect(state.hasSelectedLogs, false);
      });

      test('should select multiple logs', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);
        const logIds = ['log1', 'log2', 'log3'];

        for (final id in logIds) {
          notifier.toggleLogSelection(id);
        }

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.selectedLogIds, containsAll(logIds));
        expect(state.selectedLogIds.length, 3);
        expect(state.hasSelectedLogs, true);
      });

      test('should select all logs on current page', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        final mockLogs = [
          SmokeLog(
            id: 'log1',
            accountId: accountId,
            ts: DateTime(2023, 1, 1),
            durationMs: 5000,
            moodScore: 7,
            physicalScore: 6,
            deviceLocalId: null,
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 1),
          ),
          SmokeLog(
            id: 'log2',
            accountId: accountId,
            ts: DateTime(2023, 1, 2),
            durationMs: 3000,
            moodScore: 5,
            physicalScore: 7,
            deviceLocalId: null,
            createdAt: DateTime(2023, 1, 2),
            updatedAt: DateTime(2023, 1, 2),
          ),
        ];

        notifier.selectAllOnPage(mockLogs);

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.selectedLogIds, containsAll(['log1', 'log2']));
        expect(state.selectedLogIds.length, 2);
      });

      test('should handle select all with existing selections', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Pre-select some logs
        notifier.toggleLogSelection('existing_log');

        final pageLogs = [
          SmokeLog(
            id: 'log1',
            accountId: accountId,
            ts: DateTime(2023, 1, 1),
            durationMs: 5000,
            moodScore: 7,
            physicalScore: 6,
            deviceLocalId: null,
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 1),
          ),
        ];

        notifier.selectAllOnPage(pageLogs);

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.selectedLogIds, containsAll(['existing_log', 'log1']));
        expect(state.selectedLogIds.length, 2);
      });

      test('should clear all selections', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Select multiple logs
        notifier.toggleLogSelection('log1');
        notifier.toggleLogSelection('log2');
        notifier.toggleLogSelection('log3');

        notifier.clearSelection();

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.selectedLogIds, isEmpty);
        expect(state.hasSelectedLogs, false);
      });
    });

    group('Loading States', () {
      test('should manage loading state', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        notifier.setLoading(true);
        var state = container.read(logsTableStateProvider(accountId));
        expect(state.isLoading, true);

        notifier.setLoading(false);
        state = container.read(logsTableStateProvider(accountId));
        expect(state.isLoading, false);
      });

      test('should manage refreshing state', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        notifier.setRefreshing(true);
        var state = container.read(logsTableStateProvider(accountId));
        expect(state.isRefreshing, true);

        notifier.setRefreshing(false);
        state = container.read(logsTableStateProvider(accountId));
        expect(state.isRefreshing, false);
      });

      test('should manage error state', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);
        const errorMessage = 'Test error message';

        notifier.setError(errorMessage);
        var state = container.read(logsTableStateProvider(accountId));
        expect(state.error, errorMessage);

        notifier.setError(null);
        state = container.read(logsTableStateProvider(accountId));
        expect(state.error, isNull);
      });
    });

    group('Complex Scenarios', () {
      test('should handle state reset correctly', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Set up complex state
        notifier.updateFilter(const LogFilter(minMoodScore: 5));
        notifier.updateSort(const LogSort(field: LogSortField.duration));
        notifier.updateTotalLogs(200);
        notifier.goToPage(2);
        notifier.updatePageSize(25);
        notifier.toggleLogSelection('log1');
        notifier.setLoading(true);
        notifier.setError('Some error');

        // Reset state
        notifier.reset();

        final state = container.read(logsTableStateProvider(accountId));
        expect(state.accountId, accountId); // Should preserve account ID
        expect(state.filter, const LogFilter());
        expect(state.sort, LogSort.defaultSort);
        expect(state.pageSize, 50);
        expect(state.currentPage, 0);
        expect(state.totalLogs, 0);
        expect(state.selectedLogIds, isEmpty);
        expect(state.isLoading, false);
        expect(state.isRefreshing, false);
        expect(state.error, isNull);
      });

      test('should correctly calculate pagination with various page sizes', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Test with 101 logs and page size 50
        notifier.updateTotalLogs(101);
        var state = container.read(logsTableStateProvider(accountId));
        expect(state.totalPages, 3); // 101 / 50 = 2.02 → 3 pages

        // Test with exact multiple
        notifier.updateTotalLogs(100);
        state = container.read(logsTableStateProvider(accountId));
        expect(state.totalPages, 2); // 100 / 50 = 2 pages

        // Test with small page size
        notifier.updatePageSize(10);
        state = container.read(logsTableStateProvider(accountId));
        expect(state.totalPages, 10); // 100 / 10 = 10 pages
      });

      test('should maintain query parameters consistency', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Set up complex state
        const filter = LogFilter(minMoodScore: 6, searchText: 'test');
        const sort = LogSort(
            field: LogSortField.physicalScore, order: LogSortOrder.descending);

        notifier.updateFilter(filter);
        notifier.updateSort(sort);
        notifier.updateTotalLogs(150);
        notifier.updatePageSize(25);
        notifier.goToPage(2);

        final state = container.read(logsTableStateProvider(accountId));
        final params = state.queryParams;

        expect(params.accountId, accountId);
        expect(params.filter, filter);
        expect(params.sort, sort);
        expect(params.limit, 25);
        expect(params.offset, 50); // page 2 * 25 per page
      });

      test('should handle edge cases in selection', () {
        final notifier =
            container.read(logsTableStateProvider(accountId).notifier);

        // Try to select same log multiple times
        notifier.toggleLogSelection('log1');
        notifier.toggleLogSelection('log1'); // Should deselect
        notifier.toggleLogSelection('log1'); // Should select again

        var state = container.read(logsTableStateProvider(accountId));
        expect(state.selectedLogIds, contains('log1'));
        expect(state.selectedLogIds.length, 1);

        // Select all on empty page
        notifier.selectAllOnPage([]);
        state = container.read(logsTableStateProvider(accountId));
        expect(state.selectedLogIds,
            contains('log1')); // Should still have original selection
      });
    });

    group('Provider Family Behavior', () {
      test('should create separate states for different accounts', () {
        const accountId2 = 'account_2';

        // Modify state for first account
        final notifier1 =
            container.read(logsTableStateProvider(accountId).notifier);
        notifier1.updateFilter(const LogFilter(minMoodScore: 7));

        // Check that second account has default state
        final state2 = container.read(logsTableStateProvider(accountId2));
        expect(state2.accountId, accountId2);
        expect(state2.filter, const LogFilter()); // Should be default

        // Verify first account state is preserved
        final state1 = container.read(logsTableStateProvider(accountId));
        expect(state1.filter.minMoodScore, 7);
      });

      test('should generate correct query params for different accounts', () {
        const accountId2 = 'account_2';

        // Set up different states for each account
        container
            .read(logsTableStateProvider(accountId).notifier)
            .updatePageSize(25);
        container
            .read(logsTableStateProvider(accountId2).notifier)
            .updatePageSize(100);

        final params1 = container.read(currentQueryParamsProvider(accountId));
        final params2 = container.read(currentQueryParamsProvider(accountId2));

        expect(params1.accountId, accountId);
        expect(params1.limit, 25);
        expect(params2.accountId, accountId2);
        expect(params2.limit, 100);
      });
    });
  });
}
