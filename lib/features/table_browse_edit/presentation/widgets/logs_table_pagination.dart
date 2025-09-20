// Pagination widget for logs table
// Provides navigation controls for table paging

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/logs_table_state_provider.dart';

/// Pagination controls for the logs table
/// Provides page navigation and page size options
class LogsTablePagination extends ConsumerWidget {
  final String accountId;

  const LogsTablePagination({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logsTableStateProvider(accountId));
    final notifier = ref.read(logsTableStateProvider(accountId).notifier);
    final theme = Theme.of(context);

    if (state.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Page size selector
            _buildPageSizeSelector(context, state, notifier),

            const Spacer(),

            // Page navigation
            _buildPageNavigation(context, state, notifier),
          ],
        ),
      ),
    );
  }

  /// Build page size selector dropdown
  Widget _buildPageSizeSelector(
    BuildContext context,
    LogsTableState state,
    LogsTableStateNotifier notifier,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Rows per page:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: state.pageSize,
          underline: const SizedBox.shrink(),
          items: const [
            DropdownMenuItem(value: 25, child: Text('25')),
            DropdownMenuItem(value: 50, child: Text('50')),
            DropdownMenuItem(value: 100, child: Text('100')),
          ],
          onChanged: (newSize) {
            if (newSize != null) {
              notifier.updatePageSize(newSize);
            }
          },
        ),
      ],
    );
  }

  /// Build page navigation controls
  Widget _buildPageNavigation(
    BuildContext context,
    LogsTableState state,
    LogsTableStateNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final startItem = state.offset + 1;
    final endItem = (state.offset + state.pageSize).clamp(0, state.totalLogs);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Page info
        Text(
          '$startItem–$endItem of ${state.totalLogs}',
          style: theme.textTheme.bodyMedium,
        ),

        const SizedBox(width: 16),

        // Previous page button
        IconButton(
          onPressed:
              state.hasPreviousPage ? () => notifier.previousPage() : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous page',
        ),

        // Next page button
        IconButton(
          onPressed: state.hasNextPage ? () => notifier.nextPage() : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next page',
        ),
      ],
    );
  }
}
