import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/log_record_provider.dart';
import '../providers/logging_provider.dart' show statisticsProvider;
import '../models/log_record.dart';
import '../models/enums.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final logRecordsAsync = ref.watch(activeAccountLogRecordsProvider);
    final statisticsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.table_chart), text: 'Data'),
            Tab(icon: Icon(Icons.analytics), text: 'Charts'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          // Data tab
          logRecordsAsync.when(
            data: (records) => _buildDataView(context, records),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
          // Charts tab (placeholder for now)
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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

          // Data table
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Entries (sorted by timestamp, newest first)',
                  style: Theme.of(context).textTheme.titleMedium,
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
                          if (record.tags.isNotEmpty)
                            Text(
                              'Tags: ${record.tags.join(', ')}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Text(
                            'Type: ${record.eventType.name} | Sync: ${record.syncState.name}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing:
                          record.value != null
                              ? Text(
                                '${record.value!.toStringAsFixed(1)} ${record.unit.name}',
                                style: Theme.of(context).textTheme.titleMedium,
                              )
                              : null,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    context,
                    'Total Entries',
                    stats['totalEntries'].toString(),
                  ),
                  _buildStatRow(
                    context,
                    'Total Amount',
                    stats['totalAmount'].toStringAsFixed(2),
                  ),
                  if (stats['firstEntry'] != null)
                    _buildStatRow(
                      context,
                      'First Entry',
                      DateFormat('MMM dd, yyyy').format(stats['firstEntry']),
                    ),
                  if (stats['lastEntry'] != null)
                    _buildStatRow(
                      context,
                      'Last Entry',
                      DateFormat('MMM dd, yyyy').format(stats['lastEntry']),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Charts Coming Soon',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '• Cumulative usage over time\n'
                    '• Daily/weekly breakdowns\n'
                    '• Rolling windows\n'
                    '• Session details',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
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

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
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
}
