import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/log_record_provider.dart'
    show
        logRecordStatsProvider,
        LogRecordsParams,
        activeAccountLogRecordsProvider,
        logRecordNotifierProvider;
import '../providers/account_provider.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../widgets/edit_log_record_dialog.dart';
import '../widgets/analytics_charts.dart';
import '../utils/design_constants.dart';
import '../utils/responsive_layout.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final logRecordsAsync = ref.watch(activeAccountLogRecordsProvider);
    final statisticsAsync = ref.watch(
      logRecordStatsProvider(LogRecordsParams(accountId: null)),
    );

    return Scaffold(
      appBar: AppBar(
        key: const Key('app_bar_analytics'),
        title: const Text('Analytics'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeAccountLogRecordsProvider);
          ref.invalidate(
            logRecordStatsProvider(LogRecordsParams(accountId: null)),
          );
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: logRecordsAsync.when(
          data: (records) {
            return statisticsAsync.when(
              data: (stats) => _buildAnalyticsView(context, records, stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildAnalyticsView(
    BuildContext context,
    List<LogRecord> records,
    Map<String, dynamic> stats,
  ) {
    if (records.isEmpty) {
      return _buildEmptyView(context);
    }

    final activeAccountAsync = ref.watch(activeAccountProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveSize.responsive(
          context: context,
          mobile: Spacing.lg.value,
          tablet: Spacing.xl.value,
          desktop: Spacing.xl.value,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary stats cards
          _buildSummaryStats(context, records),
          SizedBox(height: Spacing.xl.value),

          // Charts section
          Text(
            'Charts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: Spacing.md.value),
          activeAccountAsync.when(
            data: (account) {
              if (account == null) {
                return const SizedBox.shrink();
              }
              // AnalyticsChartsWidget uses Expanded and needs bounded height.
              // SingleChildScrollView provides unbounded height, so we wrap
              // the charts in a SizedBox to avoid "RenderBox was not laid out" errors.
              return SizedBox(
                height: 600,
                child: Card(
                  elevation: ElevationLevel.sm.value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadii.md,
                  ),
                  child: Padding(
                    padding: Paddings.lg,
                    child: AnalyticsChartsWidget(
                      records: records,
                      accountId: account.userId,
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          SizedBox(height: Spacing.xl.value),

          // Recent entries section
          Text(
            'Recent Entries',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: Spacing.md.value),
          ...records.take(10).map(
                (record) => Padding(
                  padding: EdgeInsets.only(bottom: Spacing.sm.value),
                  child: Card(
                    elevation: ElevationLevel.sm.value,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadii.md,
                    ),
                    child: ListTile(
                      contentPadding: Paddings.md,
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: _getSyncStateIcon(record.syncState),
                      ),
                      title: Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(record.eventAt),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (record.note != null && record.note!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: Spacing.xs.value),
                              child: Text(
                                record.note!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(top: Spacing.xs.value),
                            child: Text(
                              '${record.eventType.name} • ${record.syncState.name}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      trailing: record.duration > 0
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Spacing.sm.value,
                                vertical: Spacing.xs.value,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadii.sm,
                              ),
                              child: Text(
                                '${record.duration.toStringAsFixed(1)} ${record.unit.name}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            )
                          : null,
                      onTap: () => _showLogRecordActions(context, record),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context, List<LogRecord> records) {
    final syncedCount =
        records.where((r) => r.syncState == SyncState.synced).length;
    final pendingCount =
        records.where((r) => r.syncState == SyncState.pending).length;
    final totalDuration = records.fold<double>(
      0,
      (sum, r) => sum + r.duration,
    );

    return ResponsiveGrid(
      mobileColumns: 2,
      tabletColumns: 4,
      desktopColumns: 4,
      spacing: Spacing.md.value,
      // Use wider aspect ratio for compact cards (width:height)
      mobileAspectRatio: 1.4,  // Shorter cards on mobile
      tabletAspectRatio: 1.2,
      desktopAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          'Total',
          records.length.toString(),
          Icons.list_alt,
        ),
        _buildStatCard(
          context,
          'Synced',
          syncedCount.toString(),
          Icons.cloud_done,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Pending',
          pendingCount.toString(),
          Icons.cloud_upload,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          'Total Duration',
          _formatDuration(totalDuration),
          Icons.timer,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, [
    Color? iconColor,
  ]) {
    return Card(
      elevation: ElevationLevel.sm.value,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadii.md,
      ),
      child: Padding(
        padding: Paddings.sm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: IconSize.md.value,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: Spacing.xs.value),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final secs = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: Paddings.xl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: IconSize.xxxl.value,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.3),
            ),
            SizedBox(height: Spacing.lg.value),
            Text(
              'No data yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: Spacing.sm.value),
            Text(
              'Start logging to see your analytics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSyncStateIcon(SyncState state) {
    IconData icon;
    Color color;

    switch (state) {
      case SyncState.synced:
        icon = Icons.cloud_done;
        color = Colors.green;
        break;
      case SyncState.pending:
        icon = Icons.cloud_upload;
        color = Colors.orange;
        break;
      case SyncState.syncing:
        icon = Icons.cloud_sync;
        color = Colors.blue;
        break;
      case SyncState.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case SyncState.conflict:
        icon = Icons.warning;
        color = Colors.amber;
        break;
    }

    return Icon(icon, size: IconSize.md.value, color: color);
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

    if (!mounted) return;

    if (confirmed == true) {
      try {
        await ref
            .read(logRecordNotifierProvider.notifier)
            .deleteLogRecord(record);

        if (!mounted) return;

        // ignore: use_build_context_synchronously
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
      } catch (e) {
        if (!mounted) return;

        // ignore: use_build_context_synchronously
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
