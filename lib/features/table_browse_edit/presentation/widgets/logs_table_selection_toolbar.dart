// Selection toolbar widget for logs table
// Provides batch actions when multiple logs are selected

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/logs_table_state_provider.dart';
import '../providers/logs_table_actions_provider.dart';
import '../providers/logs_table_providers.dart';
import 'package:ash_trail/core/feature_flags/feature_flags.dart';

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

            // Tags menu (feature gated)
            if (isFeatureEnabled(ref, 'logging.batch_edit_delete')) ...[
              FutureBuilder<List<String>>(
                future: ref.read(usedTagIdsProvider(accountId).future),
                builder: (context, snapshot) {
                  final tags = snapshot.data ?? const <String>[];
                  final hasSelection = state.selectedLogIds.isNotEmpty;

                  return PopupMenuButton<_TagAction>(
                    enabled: hasSelection,
                    tooltip: hasSelection
                        ? 'Batch tag actions'
                        : 'Select logs to manage tags',
                    onSelected: (value) async {
                      switch (value) {
                        case _TagAction.add:
                          final selected = await _pickTagsDialog(
                            context: context,
                            title: 'Add tags to selected logs',
                            allTagIds: tags,
                          );
                          if (selected != null && selected.isNotEmpty) {
                            await _applyAddTags(
                              context: context,
                              actions: actions,
                              accountId: accountId,
                              smokeLogIds: state.selectedLogIds.toList(),
                              tagIds: selected,
                            );
                          }
                          break;
                        case _TagAction.remove:
                          final selected = await _pickTagsDialog(
                            context: context,
                            title: 'Remove tags from selected logs',
                            allTagIds: tags,
                          );
                          if (selected != null && selected.isNotEmpty) {
                            final confirmed = await _confirmTagRemoval(
                              context,
                              state.selectedLogIds.length,
                              selected.length,
                            );
                            if (confirmed == true) {
                              await _applyRemoveTags(
                                context: context,
                                actions: actions,
                                accountId: accountId,
                                smokeLogIds: state.selectedLogIds.toList(),
                                tagIds: selected,
                              );
                            }
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _TagAction.add,
                        child: ListTile(
                          leading: Icon(Icons.label_outline),
                          title: Text('Add tags'),
                        ),
                      ),
                      PopupMenuItem(
                        value: _TagAction.remove,
                        child: ListTile(
                          leading: Icon(Icons.label_off_outlined),
                          title: Text('Remove tags'),
                        ),
                      ),
                    ],
                    child: TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.label),
                      label: const Text('Tags'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],

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

  Future<void> _applyAddTags({
    required BuildContext context,
    required TableActions actions,
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    try {
      final count = await actions.addTagsToLogs(
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added tags to $count logs'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add tags: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _applyRemoveTags({
    required BuildContext context,
    required TableActions actions,
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    try {
      final count = await actions.removeTagsFromLogs(
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed tags from $count logs'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove tags: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _confirmTagRemoval(
      BuildContext context, int logsCount, int tagsCount) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Tags'),
        content: Text(
            'Remove $tagsCount tag(s) from $logsCount selected log(s)? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<List<String>?> _pickTagsDialog({
    required BuildContext context,
    required String title,
    required List<String> allTagIds,
  }) async {
    final selected = <String>{};
    return showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (allTagIds.isEmpty) const Text('No tags found'),
                      for (final tag in allTagIds)
                        FilterChip(
                          label: Text(tag),
                          selected: selected.contains(tag),
                          onSelected: (value) {
                            setState(() {
                              if (value) {
                                selected.add(tag);
                              } else {
                                selected.remove(tag);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.of(context)
                          .pop(selected.toList(growable: false)),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

enum _TagAction { add, remove }
