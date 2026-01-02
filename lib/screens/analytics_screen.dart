import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/log_record_provider.dart';
import '../providers/log_record_provider.dart'
    show logRecordStatsProvider, LogRecordsParams;
import '../providers/account_provider.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../widgets/edit_log_record_dialog.dart';
import '../widgets/analytics_charts.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logRecordsAsync = ref.watch(activeAccountLogRecordsProvider);
    final statisticsAsync = ref.watch(
      logRecordStatsProvider(LogRecordsParams(accountId: null)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.table_chart), text: 'Data'),
            Tab(icon: Icon(Icons.analytics), text: 'Charts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Data tab
          logRecordsAsync.when(
            data: (records) => _buildDataView(context, records),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
          // Charts tab
          statisticsAsync.when(
            data: (stats) => _buildChartsView(context, stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }

  Widget _buildDataView(BuildContext context, List<LogRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 100,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No entries yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Summary card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, 'Total', records.length.toString()),
                  _buildStatItem(
                    context,
                    'Synced',
                    records
                        .where((r) => r.syncState == SyncState.synced)
                        .length
                        .toString(),
                  ),
                  _buildStatItem(
                    context,
                    'Pending',
                    records
                        .where((r) => r.syncState == SyncState.pending)
                        .length
                        .toString(),
                  ),
                ],
              ),
            ),
          ),

          // Recent entries list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...records.map(
                  (record) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: _getSyncStateIcon(record.syncState),
                      title: Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(record.eventAt),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (record.note != null) Text(record.note!),
                          Text(
                            'Type: ${record.eventType.name} | Sync: ${record.syncState.name}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing:
                          record.duration > 0
                              ? Text(
                                '${record.duration.toStringAsFixed(1)} ${record.unit.name}',
                                style: Theme.of(context).textTheme.titleMedium,
                              )
                              : null,
                      onTap: () => _showLogRecordActions(context, record),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChartsView(BuildContext context, Map<String, dynamic> stats) {
    final logRecordsAsync = ref.watch(activeAccountLogRecordsProvider);
    final activeAccountAsync = ref.watch(activeAccountProvider);

    return logRecordsAsync.when(
      data: (records) {
        return activeAccountAsync.when(
          data: (account) {
            if (account == null || records.isEmpty) {
              return _buildEmptyChartsView(context);
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: AnalyticsChartsWidget(
                records: records,
                accountId: account.userId,
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEmptyChartsView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No data for charts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging to see your analytics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _getSyncStateIcon(SyncState state) {
    switch (state) {
      case SyncState.synced:
        return const Icon(Icons.cloud_done, color: Colors.green);
      case SyncState.pending:
        return const Icon(Icons.cloud_upload, color: Colors.orange);
      case SyncState.syncing:
        return const Icon(Icons.cloud_sync, color: Colors.blue);
      case SyncState.error:
        return const Icon(Icons.error, color: Colors.red);
      case SyncState.conflict:
        return const Icon(Icons.warning, color: Colors.amber);
    }
  }

  void _showLogRecordActions(BuildContext context, LogRecord record) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(context, record);
                  },
                ),
                if (!record.isDeleted)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete'),
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDeleteLogRecord(context, record);
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, LogRecord record) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditLogRecordDialog(record: record),
    );

    if (result == true && mounted) {
      // Record was updated, list will refresh automatically via stream
      ref.read(logRecordNotifierProvider.notifier).reset();
    }
  }

  Future<void> _confirmDeleteLogRecord(
    BuildContext context,
    LogRecord record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Log Entry'),
            content: Text(
              'Are you sure you want to delete this ${record.eventType.name} entry from ${DateFormat('MMM d, y h:mm a').format(record.eventAt)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(logRecordNotifierProvider.notifier)
            .deleteLogRecord(record);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Entry deleted'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () async {
                  await ref
                      .read(logRecordNotifierProvider.notifier)
                      .restoreLogRecord(record);
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting entry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
