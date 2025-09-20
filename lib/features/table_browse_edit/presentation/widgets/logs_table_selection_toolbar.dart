// Selection toolbar widget for logs table
// Provides batch actions when multiple logs are selected

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/logs_table_state_provider.dart';
import '../providers/logs_table_actions_provider.dart';

/// Selection toolbar shown when logs are selected
/// Provides batch operations and selection management
class LogsTableSelectionToolbar extends ConsumerWidget {
  final String accountId;

  const LogsTableSelectionToolbar({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logsTableStateProvider(accountId));
    final notifier = ref.read(logsTableStateProvider(accountId).notifier);
    final actions = ref.read(tableActionsProvider(accountId));
    final theme = Theme.of(context);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Selection count
            Text(
              '${state.selectedLogIds.length} selected',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            // Clear selection
            TextButton.icon(
              onPressed: () => notifier.clearSelection(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 8),

            // Batch delete action
            ElevatedButton.icon(
              onPressed: () => _confirmBatchDelete(context, state, actions),
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirm batch deletion with user
  Future<void> _confirmBatchDelete(
    BuildContext context,
    LogsTableState state,
    TableActions actions,
  ) async {
    final selectedCount = state.selectedLogIds.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Logs'),
        content: Text(
          'Are you sure you want to delete $selectedCount logs? This action cannot be undone.',
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
        await actions.deleteSelectedLogs();

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
