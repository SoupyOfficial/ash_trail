// Table header widget for logs table
// Provides column headers with sorting functionality

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/log_sort.dart';
import '../providers/logs_table_state_provider.dart';

/// Table header widget with sortable columns
/// Displays column headers with sort indicators and click handlers
class LogsTableHeader extends ConsumerWidget {
  final String accountId;

  const LogsTableHeader({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logsTableStateProvider(accountId));
    final notifier = ref.read(logsTableStateProvider(accountId).notifier);
    final theme = Theme.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        primary: false,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Selection checkbox column
          _buildHeaderCell(
            context,
            width: 56,
            child: Checkbox(
              value: _getSelectAllState(state),
              tristate: true,
              onChanged: (value) => _handleSelectAll(notifier, value),
            ),
          ),

          // Date column
          _buildSortableHeaderCell(
            context,
            title: 'Date',
            field: LogSortField.timestamp,
            currentSort: state.sort,
            onSort: (sort) => notifier.updateSort(sort),
            width: 120,
          ),

          // Duration column
          _buildSortableHeaderCell(
            context,
            title: 'Duration',
            field: LogSortField.duration,
            currentSort: state.sort,
            onSort: (sort) => notifier.updateSort(sort),
            width: 100,
          ),

          // Method column
          _buildHeaderCell(
            context,
            title: 'Method',
            width: 120,
          ),

          // Mood column
          _buildSortableHeaderCell(
            context,
            title: 'Mood',
            field: LogSortField.moodScore,
            currentSort: state.sort,
            onSort: (sort) => notifier.updateSort(sort),
            width: 80,
          ),

          // Physical column
          _buildSortableHeaderCell(
            context,
            title: 'Physical',
            field: LogSortField.physicalScore,
            currentSort: state.sort,
            onSort: (sort) => notifier.updateSort(sort),
            width: 80,
          ),

          // Notes column (fixed reasonable width to avoid overflow in tests)
          // Using a fixed width here ensures predictable layout across small widths
          // while still allowing horizontal scrolling for the entire header.
          _buildHeaderCell(
            context,
            title: 'Notes',
            width: 240,
          ),

          // Actions column
          _buildHeaderCell(
            context,
            title: 'Actions',
            width: 100,
            alignment: Alignment.center,
          ),
          ],
        ),
      ),
    );
  }

  /// Build a basic header cell
  Widget _buildHeaderCell(
    BuildContext context, {
    String? title,
    Widget? child,
    double? width,
    Alignment alignment = Alignment.centerLeft,
  }) {
    final content = child ??
        Text(
          title ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        );

    final container = Container(
      width: width,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: alignment,
      child: content,
    );

    // Keep cells fixed-width to avoid layout issues under unbounded constraints
    // inside the horizontally scrolling header container.

    return container;
  }

  /// Build a sortable header cell with sort indicators
  Widget _buildSortableHeaderCell(
    BuildContext context, {
    required String title,
    required LogSortField field,
    required LogSort currentSort,
    required ValueChanged<LogSort> onSort,
    double? width,
  }) {
    final isActive = currentSort.field == field;
    final theme = Theme.of(context);

    return _buildHeaderCell(
      context,
      width: width,
      child: InkWell(
        onTap: () {
          final newOrder = isActive && currentSort.order.isAscending
              ? LogSortOrder.descending
              : LogSortOrder.ascending;

          onSort(LogSort(field: field, order: newOrder));
        },
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? theme.colorScheme.primary : null,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isActive
                    ? (currentSort.order.isAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward)
                    : Icons.unfold_more,
                size: 16,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get the state for the select-all checkbox
  bool? _getSelectAllState(LogsTableState state) {
    if (state.selectedLogIds.isEmpty) {
      return false;
    }

    // We can't determine the total number of logs on the current page
    // without the actual logs data, so we'll use a simple heuristic:
    // - If we have selected logs, show indeterminate (null)
    // - This will be improved when we have the actual logs data
    return null;
  }

  /// Handle select-all checkbox state changes
  void _handleSelectAll(LogsTableStateNotifier notifier, bool? value) {
    if (value == true) {
      // TODO: Select all logs on current page
      // This requires access to the actual logs data
      // For now, we'll implement the clear functionality
    } else {
      // Clear all selections
      notifier.clearSelection();
    }
  }
}
