import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_provider.dart';
import '../providers/log_record_provider.dart';
import '../services/sync_service.dart';

/// Widget to display sync status
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountId = ref.watch(activeAccountIdProvider);

    if (accountId == null) {
      return const SizedBox.shrink();
    }

    final syncStatusAsync = ref.watch(syncStatusProvider(accountId));

    return syncStatusAsync.when(
      data: (status) {
        return Card(
          child: ListTile(
            leading: _buildStatusIcon(status),
            title: Text(_buildStatusText(status)),
            subtitle:
                status.pendingCount > 0
                    ? Text('${status.pendingCount} items pending')
                    : const Text('All synced'),
            trailing:
                status.isOnline
                    ? IconButton(
                      icon: const Icon(Icons.sync),
                      onPressed: () => _triggerSync(context, ref),
                      tooltip: 'Sync now',
                    )
                    : const Icon(Icons.cloud_off, color: Colors.grey),
          ),
        );
      },
      loading:
          () => const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Checking sync status...'),
            ),
          ),
      error:
          (error, stack) => Card(
            child: ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: Text('Sync error: $error'),
            ),
          ),
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    if (status.isSyncing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (!status.isOnline) {
      return const Icon(Icons.cloud_off, color: Colors.grey);
    }

    if (status.isFullySynced) {
      return const Icon(Icons.cloud_done, color: Colors.green);
    }

    return const Icon(Icons.cloud_upload, color: Colors.orange);
  }

  String _buildStatusText(SyncStatus status) {
    if (status.isSyncing) {
      return 'Syncing...';
    }

    if (!status.isOnline) {
      return 'Offline';
    }

    if (status.isFullySynced) {
      return 'All synced';
    }

    return 'Pending sync';
  }

  Future<void> _triggerSync(BuildContext context, WidgetRef ref) async {
    try {
      final syncService = ref.read(syncServiceProvider);
      final result = await syncService.forceSyncNow();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// Compact sync status indicator (for app bars, etc.)
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountId = ref.watch(activeAccountIdProvider);

    if (accountId == null) {
      return const SizedBox.shrink();
    }

    final syncStatusAsync = ref.watch(syncStatusProvider(accountId));

    return syncStatusAsync.when(
      data: (status) {
        IconData icon;
        Color color;
        String tooltip;

        if (status.isSyncing) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (!status.isOnline) {
          icon = Icons.cloud_off;
          color = Colors.grey;
          tooltip = 'Offline';
        } else if (status.isFullySynced) {
          icon = Icons.cloud_done;
          color = Colors.green;
          tooltip = 'All synced';
        } else {
          icon = Icons.cloud_upload;
          color = Colors.orange;
          tooltip = '${status.pendingCount} pending';
        }

        return IconButton(
          icon: Icon(icon, color: color),
          tooltip: tooltip,
          onPressed: () => _showSyncDetails(context, ref, accountId),
        );
      },
      loading:
          () => const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      error:
          (error, stack) => IconButton(
            icon: const Icon(Icons.error, color: Colors.red),
            tooltip: 'Sync error',
            onPressed: () => _showSyncDetails(context, ref, accountId),
          ),
    );
  }

  void _showSyncDetails(
    BuildContext context,
    WidgetRef ref,
    String? accountId,
  ) {
    if (accountId == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sync Status'),
            content: Consumer(
              builder: (context, ref, child) {
                final syncStatusAsync = ref.watch(
                  syncStatusProvider(accountId),
                );

                return syncStatusAsync.when(
                  data:
                      (status) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            'Status',
                            _buildStatusTextDetailed(status),
                          ),
                          _buildDetailRow('Pending', '${status.pendingCount}'),
                          _buildDetailRow(
                            'Online',
                            status.isOnline ? 'Yes' : 'No',
                          ),
                          const SizedBox(height: 16),
                          if (status.isOnline && status.pendingCount > 0)
                            FilledButton.icon(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                final syncService = ref.read(
                                  syncServiceProvider,
                                );
                                final result = await syncService.forceSyncNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result.message),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.sync),
                              label: const Text('Sync Now'),
                            ),
                        ],
                      ),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _buildStatusTextDetailed(SyncStatus status) {
    if (status.isSyncing) {
      return 'Syncing...';
    }
    if (!status.isOnline) {
      return 'Offline';
    }
    if (status.isFullySynced) {
      return 'All synced';
    }
    return 'Pending sync';
  }
}
