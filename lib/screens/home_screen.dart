import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/log_record.dart';
import '../providers/account_provider.dart';
import '../providers/log_record_provider.dart'
    show
        logRecordStatsProvider,
        LogRecordsParams,
        activeAccountLogRecordsProvider,
        activeAccountIdProvider;
import '../widgets/home_quick_log_widget.dart';
import '../widgets/backdate_dialog.dart';
import '../widgets/edit_log_record_dialog.dart';
import 'analytics_screen.dart';
import 'accounts_screen.dart';
import 'history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final activeAccountAsync = ref.watch(activeAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ash Trail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountsScreen()),
              );
            },
          ),
        ],
      ),
      body: activeAccountAsync.when(
        data: (account) {
          if (account == null) {
            return _buildNoAccountView(context);
          }
          return _buildMainView(
            context,
            ref,
            account.displayName ?? account.email,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: activeAccountAsync.maybeWhen(
        data: (account) {
          if (account == null) return null;
          return FloatingActionButton.small(
            heroTag: 'backdate',
            onPressed: () => _showBackdateDialog(context),
            child: const Icon(Icons.history),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _buildNoAccountView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 100,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Ash Trail',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create or sign in to an account to start logging',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountsScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView(
    BuildContext context,
    WidgetRef ref,
    String accountName,
  ) {
    final logRecordsAsync = ref.watch(activeAccountLogRecordsProvider);
    final allTimeStatsAsync = ref.watch(
      logRecordStatsProvider(LogRecordsParams(accountId: null)),
    );
    final sevenDayStatsAsync = ref.watch(
      logRecordStatsProvider(
        LogRecordsParams(
          accountId: null,
          startDate: DateTime.now().subtract(const Duration(days: 7)),
          endDate: DateTime.now(),
        ),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active account card
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(accountName[0].toUpperCase())),
              title: Text(accountName),
              subtitle: const Text('Active Account'),
              trailing: IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountsScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistics cards - All-time and 7-day
          _buildStatisticsSection(
            context,
            ref,
            allTimeStatsAsync,
            sevenDayStatsAsync,
          ),
          const SizedBox(height: 16),

          // Quick action buttons row
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analytics'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick log widget
          HomeQuickLogWidget(
            onLogCreated: () {
              ref.invalidate(activeAccountLogRecordsProvider);
            },
          ),
          const SizedBox(height: 24),

          // Recent entries
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Entries',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          logRecordsAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No entries yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hold the duration button above to log your first session',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final recentRecords = records.take(5).toList();
              return Column(
                children:
                    recentRecords
                        .map(
                          (record) => Card(
                            child: ListTile(
                              leading: Icon(
                                _getEventIcon(record.eventType),
                                size: 12,
                              ),
                              title: Text(_formatDateTime(record.eventAt)),
                              subtitle:
                                  record.note != null
                                      ? Text(record.note!)
                                      : null,
                              trailing:
                                  record.duration > 0
                                      ? Text(
                                        '${record.duration.toStringAsFixed(1)} ${record.unit.name}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      )
                                      : null,
                              onTap: () => _showEditDialog(context, record),
                            ),
                          ),
                        )
                        .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error loading entries: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, dynamic>> allTimeStatsAsync,
    AsyncValue<Map<String, dynamic>> sevenDayStatsAsync,
  ) {
    return Column(
      children: [
        // All-time statistics
        allTimeStatsAsync.when(
          data: (stats) => _buildStatisticsRow(context, 'All-Time', stats),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error loading stats: $error'),
        ),
        const SizedBox(height: 8),
        // 7-day statistics
        sevenDayStatsAsync.when(
          data: (stats) => _buildStatisticsRow(context, 'Last 7 Days', stats),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error loading stats: $error'),
        ),
      ],
    );
  }

  Widget _buildStatisticsRow(
    BuildContext context,
    String label,
    Map<String, dynamic> stats,
  ) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${stats['totalCount'] ?? 0}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$label: Count',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    (stats['totalDuration'] as num?)?.toStringAsFixed(1) ?? '0',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$label: Duration (s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBackdateDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const BackdateDialog());
  }

  IconData _getEventIcon(EventType eventType) {
    switch (eventType) {
      case EventType.vape:
        return Icons.cloud;
      case EventType.inhale:
        return Icons.air;
      case EventType.sessionStart:
        return Icons.play_arrow;
      case EventType.sessionEnd:
        return Icons.stop;
      case EventType.note:
        return Icons.note;
      case EventType.purchase:
        return Icons.shopping_cart;
      case EventType.tolerance:
        return Icons.trending_up;
      case EventType.symptomRelief:
        return Icons.healing;
      case EventType.custom:
        return Icons.circle;
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
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
}
