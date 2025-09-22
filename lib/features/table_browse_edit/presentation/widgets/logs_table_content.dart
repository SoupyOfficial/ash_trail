// Table content widget for logs table
// Displays the main data rows with editing and iOS swipe actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/smoke_log.dart';
import '../providers/logs_table_providers.dart';
import '../providers/logs_table_state_provider.dart';
import '../providers/logs_table_actions_provider.dart';
import '../widgets/logs_table_row.dart';
import '../widgets/logs_table_edit_modal.dart';

/// Main table content widget
/// Displays smoke logs in a scrollable table with iOS swipe actions
class LogsTableContent extends ConsumerWidget {
  final String accountId;

  const LogsTableContent({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logsTableStateProvider(accountId));
    final logsAsync = ref.watch(filteredSortedLogsProvider(state.queryParams));

    return logsAsync.when(
      loading: () => const _LoadingView(),
      error: (error, stackTrace) => _ErrorView(
        error: error.toString(),
        onRetry: () =>
            ref.refresh(filteredSortedLogsProvider(state.queryParams)),
      ),
      data: (logs) => _TableView(
        accountId: accountId,
        logs: logs,
        state: state,
      ),
    );
  }
}

/// Loading state view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading logs...'),
        ],
      ),
    );
  }
}

/// Error state view
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load logs',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Main table view with data
class _TableView extends ConsumerWidget {
  final String accountId;
  final List<SmokeLog> logs;
  final LogsTableState state;

  const _TableView({
    required this.accountId,
    required this.logs,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (logs.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(ref),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80), // Space for FAB
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final isSelected = state.selectedLogIds.contains(log.id);

          return _buildLogRow(context, ref, log, isSelected);
        },
      ),
    );
  }

  /// Build empty state when no logs are found
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.smoke_free,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            state.hasActiveFilters
                ? 'No logs match your filters'
                : 'No logs yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.hasActiveFilters
                ? 'Try adjusting your filters to see more logs'
                : 'Your smoke logs will appear here once you start tracking',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (state.hasActiveFilters) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final notifier =
                    ref.read(logsTableStateProvider(accountId).notifier);
                notifier.clearFilters();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  /// Build a single log row with iOS swipe actions
  Widget _buildLogRow(
    BuildContext context,
    WidgetRef ref,
    SmokeLog log,
    bool isSelected,
  ) {
    final actions = ref.read(tableActionsProvider(accountId));

    return Dismissible(
      key: Key(log.id),
      confirmDismiss: (direction) =>
          _handleSwipeAction(context, direction, log, actions, ref),
      background: _buildSwipeBackground(
        context,
        alignment: Alignment.centerLeft,
        color: Colors.blue,
        icon: Icons.edit,
        label: 'Edit',
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        alignment: Alignment.centerRight,
        color: Colors.red,
        icon: Icons.delete,
        label: 'Delete',
      ),
      child: LogsTableRow(
        log: log,
        isSelected: isSelected,
        onSelectionChanged: (selected) =>
            _handleSelection(ref, log.id, selected),
        onEdit: () => _showEditModal(context, ref, log),
        onDelete: () => _confirmDelete(context, ref, log, actions),
      ),
    );
  }

  /// Build swipe action background
  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      color: color,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle swipe actions (iOS-style)
  Future<bool?> _handleSwipeAction(
    BuildContext context,
    DismissDirection direction,
    SmokeLog log,
    TableActions actions,
    WidgetRef ref,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      // Left to right swipe - Edit
      _showEditModal(context, ref, log);
      return false; // Don't dismiss
    } else if (direction == DismissDirection.endToStart) {
      // Right to left swipe - Delete
      return await _confirmDelete(context, ref, log, actions);
    }
    return false;
  }

  /// Handle row selection
  void _handleSelection(WidgetRef ref, String logId, bool selected) {
    final notifier = ref.read(logsTableStateProvider(accountId).notifier);
    notifier.toggleLogSelection(logId);
  }

  /// Show edit modal for a log
  void _showEditModal(BuildContext context, WidgetRef ref, SmokeLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => LogsTableEditModal(
        log: log,
        onSave: (updatedLog) async {
          final actions = ref.read(tableActionsProvider(accountId));
          await actions.updateLog(updatedLog);
        },
      ),
    );
  }

  /// Confirm log deletion
  Future<bool> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SmokeLog log,
    TableActions actions,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log'),
        content: Text(
          'Are you sure you want to delete this log from ${_formatDate(log.ts)}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await actions.deleteLog(log.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete log: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    }

    return false;
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh(WidgetRef ref) async {
    final actions = ref.read(tableActionsProvider(accountId));
    await actions.refresh();
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
