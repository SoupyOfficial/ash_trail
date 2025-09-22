// Logs table screen - main browse and edit interface
// Implements the primary table view with filtering, sorting, and actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/logs_table_state_provider.dart';
import '../providers/logs_table_actions_provider.dart';
import '../widgets/logs_table_header.dart';
import '../widgets/logs_table_content.dart';
import '../widgets/logs_table_filter_bar.dart';
import '../widgets/logs_table_pagination.dart';
import '../widgets/logs_table_selection_toolbar.dart';

/// Main logs table screen for browsing and editing smoke logs
/// Implements table view with filtering, sorting, pagination, and multi-select
class LogsTableScreen extends ConsumerWidget {
  final String accountId;

  const LogsTableScreen({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(logsTableStateProvider(accountId));
    final tableActions = ref.watch(tableActionsProvider(accountId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smoke Logs'),
        actions: [
          // Refresh button
          IconButton(
            key: const Key('logs_refresh_button'),
            icon: const Icon(Icons.refresh),
            onPressed:
                tableState.isRefreshing ? null : () => tableActions.refresh(),
            tooltip: 'Refresh',
          ),

          // More options menu
          PopupMenuButton<String>(
            key: const Key('logs_more_menu_button'),
            onSelected: (value) => _handleMenuAction(context, value, ref),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_filters',
                child: Text('Clear Filters'),
              ),
              const PopupMenuItem(
                value: 'reset_view',
                child: Text('Reset View'),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Filter bar
          LogsTableFilterBar(accountId: accountId),

          // Selection toolbar (shown when items are selected)
          if (tableState.hasSelectedLogs)
            LogsTableSelectionToolbar(accountId: accountId),

          // Table header with sorting
          LogsTableHeader(accountId: accountId),

          // Main table content
          Expanded(
            child: LogsTableContent(accountId: accountId),
          ),

          // Pagination controls
          LogsTablePagination(accountId: accountId),
        ],
      ),

      // Floating action button for quick actions
      floatingActionButton: tableState.hasSelectedLogs
          ? FloatingActionButton.extended(
              onPressed: () => _showBatchActions(context, ref),
              icon: const Icon(Icons.more_vert),
              label: Text('${tableState.selectedLogIds.length} selected'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            )
          : null,
    );
  }

  /// Handle menu actions from the app bar
  void _handleMenuAction(BuildContext context, String action, WidgetRef ref) {
    final notifier = ref.read(logsTableStateProvider(accountId).notifier);

    switch (action) {
      case 'clear_filters':
        notifier.clearFilters();
        break;
      case 'reset_view':
        notifier.reset();
        break;
    }
  }

  /// Show batch actions modal for selected items
  void _showBatchActions(BuildContext context, WidgetRef ref) {
    final selectedCount =
        ref.read(logsTableStateProvider(accountId)).selectedLogIds.length;

    showModalBottomSheet(
      context: context,
      builder: (context) => _BatchActionsSheet(
        accountId: accountId,
        selectedCount: selectedCount,
      ),
    );
  }
}

/// Bottom sheet for batch actions on selected logs
class _BatchActionsSheet extends ConsumerWidget {
  final String accountId;
  final int selectedCount;

  const _BatchActionsSheet({
    required this.accountId,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableActions = ref.watch(tableActionsProvider(accountId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$selectedCount logs selected',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Batch delete action
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Selected'),
            subtitle: Text('Delete $selectedCount logs'),
            onTap: () => _confirmBatchDelete(context, ref, tableActions),
          ),

          // Cancel action
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Cancel'),
            onTap: () => Navigator.of(context).pop(),
          ),

          // Add safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Confirm batch deletion with user
  void _confirmBatchDelete(
    BuildContext context,
    WidgetRef ref,
    TableActions tableActions,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Logs'),
        content: Text(
            'Are you sure you want to delete $selectedCount logs? This action cannot be undone.'),
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
      Navigator.of(context).pop(); // Close bottom sheet

      try {
        await tableActions.deleteSelectedLogs();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted $selectedCount logs'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete logs: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
