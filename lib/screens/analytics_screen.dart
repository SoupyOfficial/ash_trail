import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/logging_provider.dart';
import '../models/log_entry.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final logEntriesAsync = ref.watch(logEntriesProvider);
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
          logEntriesAsync.when(
            data: (entries) => _buildDataView(context, entries),
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

  Widget _buildDataView(BuildContext context, List<LogEntry> entries) {
    if (entries.isEmpty) {
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
                  _buildStatItem(context, 'Total', entries.length.toString()),
                  _buildStatItem(
                    context,
                    'Synced',
                    entries
                        .where((e) => e.syncState == SyncState.synced)
                        .length
                        .toString(),
                  ),
                  _buildStatItem(
                    context,
                    'Pending',
                    entries
                        .where((e) => e.syncState == SyncState.pending)
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
                ...entries.map(
                  (entry) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: _getSyncStateIcon(entry.syncState),
                      title: Text(
                        DateFormat(
                          'MMM dd, yyyy HH:mm',
                        ).format(entry.timestamp),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (entry.notes != null) Text(entry.notes!),
                          Text(
                            'Sync: ${entry.syncState.name}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing:
                          entry.amount != null
                              ? Text(
                                entry.amount!.toStringAsFixed(1),
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
      case SyncState.error:
        return const Icon(Icons.error, color: Colors.red);
      case SyncState.conflict:
        return const Icon(Icons.warning, color: Colors.amber);
    }
  }
}
