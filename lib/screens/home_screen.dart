import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/log_record.dart';
import '../providers/account_provider.dart';
import '../providers/log_record_provider.dart';
import '../providers/log_record_provider.dart'
    show logRecordStatsProvider, LogRecordsParams;
import '../providers/session_provider.dart';
import '../widgets/quick_log_widget.dart';
import '../widgets/session_controls_widget.dart';
import '../widgets/template_selector_widget.dart';
import '../widgets/backdate_dialog.dart';
import '../widgets/edit_log_record_dialog.dart';
import 'analytics_screen.dart';
import 'accounts_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final activeAccountAsync = ref.watch(activeAccountProvider);
    final activeSession = ref.watch(activeSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ash Trail'),
        actions: [
          // Session controls in app bar
          activeSession.when(
            data: (session) {
              if (session != null) {
                return const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SessionControlsWidget(compact: true),
                );
              }
              return const SessionControlsWidget(compact: true);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Templates FAB
              FloatingActionButton.small(
                heroTag: 'templates',
                onPressed: () => _showTemplatesSheet(context),
                child: const Icon(Icons.bookmark),
                tooltip: 'Templates',
              ),
              const SizedBox(height: 8),
              // Backdate FAB
              FloatingActionButton.small(
                heroTag: 'backdate',
                onPressed: () => _showBackdateDialog(context),
                child: const Icon(Icons.history),
                tooltip: 'Backdate Log',
              ),
              const SizedBox(height: 8),
              // Quick Log FAB (main)
              QuickLogWidget(
                onLogCreated: () {
                  // Refresh any needed data
                },
              ),
            ],
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
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Account',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add an account to start logging',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
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
    final statisticsAsync = ref.watch(
      logRecordStatsProvider(LogRecordsParams(accountId: null)),
    );
    final activeSession = ref.watch(activeSessionProvider);

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

          // Session controls (full display when active)
          activeSession.when(
            data: (session) {
              if (session != null) {
                return Column(
                  children: [
                    const SessionControlsWidget(compact: false),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Statistics cards
          statisticsAsync.when(
            data: (stats) => _buildStatisticsRow(context, stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error loading stats: $error'),
          ),
          const SizedBox(height: 16),

          // View Analytics button
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.analytics),
            label: const Text('View Analytics'),
          ),
          const SizedBox(height: 24),

          // Templates section
          const TemplateSelectorWidget(),
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
                      builder: (context) => const AnalyticsScreen(),
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
                            ).colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No entries yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the Quick Log button to start',
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
                                      : record.tags.isNotEmpty
                                      ? Text(record.tags.join(', '))
                                      : null,
                              trailing:
                                  record.value != null
                                      ? Text(
                                        '${record.value!.toStringAsFixed(1)} ${record.unit.name}',
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

  Widget _buildStatisticsRow(BuildContext context, Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${stats['totalEntries']}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Entries',
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
                    stats['totalAmount'].toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Amount',
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

  void _showTemplatesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: const TemplateSelectorWidget(),
              );
            },
          ),
    );
  }

  void _showBackdateDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const BackdateDialog());
  }

  IconData _getEventIcon(EventType eventType) {
    switch (eventType) {
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
