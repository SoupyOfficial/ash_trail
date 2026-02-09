import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/home_widget_config.dart';
import '../models/log_record.dart';
import '../providers/account_provider.dart';
import '../providers/home_widget_config_provider.dart';
import '../providers/log_record_provider.dart'
    show activeAccountLogRecordsProvider, logRecordNotifierProvider;
import '../providers/sync_provider.dart';
import '../widgets/backdate_dialog.dart';
import '../widgets/home_widgets/home_widgets.dart';
import '../utils/design_constants.dart';
import '../utils/a11y_utils.dart';
import 'accounts_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _lastAccountId;

  /// Last successful records list; shown during refresh so we don't unmount
  /// the widget tree (preserves quick-log recording state and form values).
  List<LogRecord>? _lastRecords;

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
      _lastRecords = null;
      return;
    }

    // Only start sync if account changed
    if (_lastAccountId != account.userId) {
      _lastAccountId = account.userId;
      _lastRecords = null;
      syncService.startAccountSync(accountId: account.userId);
    }
  }

  @override
  void dispose() {
    final syncService = ref.read(syncServiceProvider);
    syncService.stopAutoSync();
    super.dispose();
  }

  /// Build a welcome greeting from the account's name, falling back to email
  /// prefix, then generic "Home".
  String _buildGreeting(Account? account) {
    if (account == null) return 'Home';
    final name =
        account.displayName ??
        account.firstName ??
        account.email.split('@').first;
    return 'Welcome, $name';
  }

  @override
  Widget build(BuildContext context) {
    final activeAccountAsync = ref.watch(activeAccountProvider);
    final isEditMode = ref.watch(homeEditModeProvider);

    final account = activeAccountAsync.asData?.value;
    final greeting = _buildGreeting(account);

    return Scaffold(
      appBar: AppBar(
        key: const Key('app_bar_home'),
        title: Text(isEditMode ? 'Edit Home' : greeting),
        actions: [
          // Edit mode toggle
          if (activeAccountAsync.asData?.value != null)
            IconButton(
              key: const Key('app_bar_edit_layout'),
              icon: Icon(isEditMode ? Icons.done : Icons.edit),
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(homeEditModeProvider.notifier).state = !isEditMode;
              },
              tooltip: isEditMode ? 'Done' : 'Edit Layout',
            ),
          SemanticIconButton(
            key: const Key('app_bar_account'),
            icon: Icons.account_circle,
            semanticLabel: 'Accounts',
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
            key: const Key('fab_backdate'),
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
            key: const Key('add_account_button'),
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

  Widget _buildMainView(BuildContext context, WidgetRef ref) {
    final logRecordsAsync = ref.watch(activeAccountLogRecordsProvider);
    final widgetConfig = ref.watch(homeLayoutConfigProvider);
    final isEditMode = ref.watch(homeEditModeProvider);

    return logRecordsAsync.when(
      data: (records) {
        _lastRecords = records;
        return _buildMainViewContent(
          context,
          ref,
          records,
          widgetConfig,
          isEditMode,
        );
      },
      loading: () {
        // Keep showing last data during refresh so we don't unmount the list
        // (preserves quick-log recording state and form values).
        if (_lastRecords != null) {
          return _buildMainViewContent(
            context,
            ref,
            _lastRecords!,
            widgetConfig,
            isEditMode,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
      error:
          (error, _) => Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: Paddings.lg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _buildMainViewContent(
    BuildContext context,
    WidgetRef ref,
    List<LogRecord> records,
    HomeLayoutConfig layoutConfig,
    bool isEditMode,
  ) {
    final visibleWidgets = layoutConfig.visibleWidgets;
    final layoutRows = _buildLayoutRows(visibleWidgets);

    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: EdgeInsets.all(
              ResponsiveSize.responsive(
                context: context,
                mobile: Spacing.lg.value,
                tablet: Spacing.xl.value,
                desktop: Spacing.xl.value,
              ),
            ),
            itemCount: layoutRows.length,
            onReorder: (oldIndex, newIndex) {
              HapticFeedback.mediumImpact();
              final oldWidgetIndex = _getFirstWidgetIndexForRow(
                layoutRows,
                oldIndex,
              );
              var newWidgetIndex = _getFirstWidgetIndexForRow(
                layoutRows,
                newIndex,
              );
              if (newIndex > oldIndex) {
                newWidgetIndex =
                    _getFirstWidgetIndexForRow(layoutRows, newIndex - 1) +
                    layoutRows[newIndex - 1].length;
              }
              ref
                  .read(homeLayoutConfigProvider.notifier)
                  .reorder(oldWidgetIndex, newWidgetIndex);
            },
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final animValue = Curves.easeInOut.transform(animation.value);
                  final elevation = lerpDouble(0, 8, animValue)!;
                  final scale = lerpDouble(1, 1.02, animValue)!;
                  return Transform.scale(
                    scale: scale,
                    child: Material(
                      elevation: elevation,
                      borderRadius: BorderRadius.circular(16),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, rowIndex) {
              final rowWidgets = layoutRows[rowIndex];
              final widgetIndex = _getFirstWidgetIndexForRow(
                layoutRows,
                rowIndex,
              );

              if (rowWidgets.length == 1) {
                final config = rowWidgets[0];
                return Padding(
                  key: ValueKey('row_${config.id}'),
                  padding: EdgeInsets.only(bottom: Spacing.md.value),
                  child: HomeWidgetWrapper(
                    widgetId: config.id,
                    type: config.type,
                    isEditMode: isEditMode,
                    index: widgetIndex,
                    onRemove: () => _confirmRemoveWidget(context, ref, config),
                    child: HomeWidgetEditPadding(
                      isEditMode: isEditMode,
                      child: HomeWidgetBuilder(
                        config: config,
                        records: records,
                        onLogCreated:
                            () =>
                                ref.invalidate(activeAccountLogRecordsProvider),
                        onRecordTap: () {},
                        onRecordDelete: (record) => _deleteLogRecord(record),
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                key: ValueKey('row_${rowWidgets[0].id}_${rowWidgets[1].id}'),
                padding: EdgeInsets.only(bottom: Spacing.md.value),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: HomeWidgetWrapper(
                          widgetId: rowWidgets[0].id,
                          type: rowWidgets[0].type,
                          isEditMode: isEditMode,
                          index: widgetIndex,
                          onRemove:
                              () => _confirmRemoveWidget(
                                context,
                                ref,
                                rowWidgets[0],
                              ),
                          child: HomeWidgetEditPadding(
                            isEditMode: isEditMode,
                            child: HomeWidgetBuilder(
                              config: rowWidgets[0],
                              records: records,
                              onLogCreated:
                                  () => ref.invalidate(
                                    activeAccountLogRecordsProvider,
                                  ),
                              onRecordTap: () {},
                              onRecordDelete:
                                  (record) => _deleteLogRecord(record),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Spacing.sm.value),
                      Expanded(
                        child: HomeWidgetWrapper(
                          widgetId: rowWidgets[1].id,
                          type: rowWidgets[1].type,
                          isEditMode: isEditMode,
                          index: widgetIndex + 1,
                          onRemove:
                              () => _confirmRemoveWidget(
                                context,
                                ref,
                                rowWidgets[1],
                              ),
                          child: HomeWidgetEditPadding(
                            isEditMode: isEditMode,
                            child: HomeWidgetBuilder(
                              config: rowWidgets[1],
                              records: records,
                              onLogCreated:
                                  () => ref.invalidate(
                                    activeAccountLogRecordsProvider,
                                  ),
                              onRecordTap: () {},
                              onRecordDelete:
                                  (record) => _deleteLogRecord(record),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (isEditMode)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                key: const Key('add_widget_button'),
                onPressed: () => showWidgetPicker(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Widget'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build layout rows from widget list
  /// Pairs consecutive compact widgets, others get their own row
  List<List<HomeWidgetConfig>> _buildLayoutRows(
    List<HomeWidgetConfig> widgets,
  ) {
    final rows = <List<HomeWidgetConfig>>[];
    int i = 0;

    while (i < widgets.length) {
      final config = widgets[i];
      final entry = WidgetCatalog.getEntry(config.type);

      if (entry.size == WidgetSize.compact && i + 1 < widgets.length) {
        // Check if next widget is also compact
        final nextConfig = widgets[i + 1];
        final nextEntry = WidgetCatalog.getEntry(nextConfig.type);

        if (nextEntry.size == WidgetSize.compact) {
          // Pair them together
          rows.add([config, nextConfig]);
          i += 2;
          continue;
        }
      }

      // Single widget row
      rows.add([config]);
      i++;
    }

    return rows;
  }

  /// Get the first widget index for a given row index
  int _getFirstWidgetIndexForRow(
    List<List<HomeWidgetConfig>> rows,
    int rowIndex,
  ) {
    int widgetIndex = 0;
    for (int i = 0; i < rowIndex && i < rows.length; i++) {
      widgetIndex += rows[i].length;
    }
    return widgetIndex;
  }

  void _confirmRemoveWidget(
    BuildContext context,
    WidgetRef ref,
    HomeWidgetConfig config,
  ) {
    final entry = WidgetCatalog.getEntry(config.type);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Widget'),
            content: Text(
              'Remove "${entry.displayName}" from your home screen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref
                      .read(homeLayoutConfigProvider.notifier)
                      .removeWidget(config.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed ${entry.displayName}'),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          ref
                              .read(homeLayoutConfigProvider.notifier)
                              .addWidget(config.type);
                        },
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  void _showBackdateDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const BackdateDialog());
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
