import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/enums.dart';
import '../models/log_record.dart';
import '../providers/account_provider.dart';
import '../providers/log_record_provider.dart'
    show activeAccountLogRecordsProvider, logRecordNotifierProvider;
import '../providers/sync_provider.dart';
import '../widgets/home_quick_log_widget.dart';
import '../widgets/backdate_dialog.dart';
import '../widgets/edit_log_record_dialog.dart';
import '../widgets/time_since_last_hit_widget.dart';
import '../utils/design_constants.dart';
import 'accounts_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _lastAccountId;

  @override
  void initState() {
    super.initState();

    // Trigger initial sync after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final account = ref.read(activeAccountProvider).asData?.value;
      if (account != null) {
        _lastAccountId = account.userId;
        final syncService = ref.read(syncServiceProvider);
        syncService.startAccountSync(accountId: account.userId);
      }
    });
  }

  void _checkAccountChange(Account? account) {
    final syncService = ref.read(syncServiceProvider);

    if (account == null) {
      syncService.stopAutoSync();
      _lastAccountId = null;
      return;
    }

    // Only start sync if account changed
    if (_lastAccountId != account.userId) {
      _lastAccountId = account.userId;
      syncService.startAccountSync(accountId: account.userId);
    }
  }

  @override
  void dispose() {
    final syncService = ref.read(syncServiceProvider);
    syncService.stopAutoSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeAccountAsync = ref.watch(activeAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountsScreen()),
              );
            },
            tooltip: 'Accounts',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final account = ref.read(activeAccountProvider).asData?.value;
          if (account != null) {
            ref.invalidate(activeAccountLogRecordsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          }
        },
        child: activeAccountAsync.when(
          data: (account) {
            // Check for account changes and manage sync
            _checkAccountChange(account);

            if (account == null) {
              return _buildNoAccountView(context);
            }
            return _buildMainView(context, ref);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
      floatingActionButton: activeAccountAsync.maybeWhen(
        data: (account) {
          if (account == null) return null;
          return FloatingActionButton.small(
            heroTag: 'backdate',
            onPressed: () => _showBackdateDialog(context),
            tooltip: 'Backdate Entry',
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
  ) {
    final logRecordsAsync = ref.watch(activeAccountLogRecordsProvider);

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
          // Time since last hit clock with integrated stats (Hero Section)
          logRecordsAsync.when(
            data: (records) => TimeSinceLastHitWidget(records: records),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          SizedBox(height: Spacing.xl.value),

          // Quick log widget
          HomeQuickLogWidget(
            onLogCreated: () {
              ref.invalidate(activeAccountLogRecordsProvider);
            },
          ),
          SizedBox(height: Spacing.xl.value),

          // Recent entries
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Entries',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: Spacing.md.value),

          logRecordsAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return Card(
                  elevation: ElevationLevel.sm.value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadii.md,
                  ),
                  child: Padding(
                    padding: Paddings.xxl,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: IconSize.xxl.value,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                          ),
                          SizedBox(height: Spacing.lg.value),
                          Text(
                            'No entries yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: Spacing.sm.value),
                          Text(
                            'Hold the duration button above to log your first session',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Sort records in reverse chronological order (newest first)
              final sortedRecords =
                  records.toList()
                    ..sort((a, b) => b.eventAt.compareTo(a.eventAt));
              final recentRecords = sortedRecords.take(5).toList();
              return Column(
                children: recentRecords
                    .asMap()
                    .entries
                    .map(
                      (entry) {
                        final record = entry.value;
                        final isLast = entry.key == recentRecords.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: isLast ? 0 : Spacing.sm.value,
                          ),
                          child: Dismissible(
                            key: Key(record.logId),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Log Entry'),
                                  content: Text(
                                    'Are you sure you want to delete this ${record.eventType.name} entry?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) async {
                              await _deleteLogRecord(record);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(
                                right: Spacing.lg.value,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadii.md,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
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
                                  child: Icon(
                                    _getEventIcon(record.eventType),
                                    size: IconSize.md.value,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                                title: Text(
                                  _formatDateTime(record.eventAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                subtitle: record.note != null &&
                                        record.note!.isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          top: Spacing.xs.value,
                                        ),
                                        child: Text(
                                          record.note!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      )
                                    : null,
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
                                onTap: () => _showEditDialog(context, record),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Card(
                  child: Padding(
                    padding: Paddings.lg,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: IconSize.xl.value,
                          ),
                          SizedBox(height: Spacing.md.value),
                          Text(
                            'Error loading entries',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          SizedBox(height: Spacing.xs.value),
                          Text(
                            error.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
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
      ref.invalidate(activeAccountLogRecordsProvider);
    }
  }

  Future<void> _deleteLogRecord(LogRecord record) async {
    try {
      await ref
          .read(logRecordNotifierProvider.notifier)
          .deleteLogRecord(record);

      if (!mounted) return;

      // Invalidate to refresh all widgets including time since last hit
      ref.invalidate(activeAccountLogRecordsProvider);

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
              // Invalidate again after restore
              ref.invalidate(activeAccountLogRecordsProvider);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
