import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../providers/log_record_provider.dart';
import '../widgets/edit_log_record_dialog.dart';
import '../utils/design_constants.dart';
import '../utils/day_boundary.dart';

/// History View per design doc 9.2.2
/// Displays persisted logs with support for filtering and grouping
/// Account-scoped data display
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // Filter state
  EventType? _selectedEventType;
  DateTimeRange? _dateRange;
  String _searchQuery = '';
  HistoryGrouping _grouping = HistoryGrouping.day;

  @override
  Widget build(BuildContext context) {
    final logRecordsAsync = ref.watch(activeAccountLogRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        key: const Key('app_bar_history'),
        title: const Text('History'),
        actions: [
          IconButton(
            key: const Key('history_filter_button'),
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          PopupMenuButton<HistoryGrouping>(
            key: const Key('history_group_button'),
            icon: const Icon(Icons.view_agenda),
            tooltip: 'Group by',
            onSelected: (grouping) {
              setState(() => _grouping = grouping);
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: HistoryGrouping.none,
                    child: Text('No grouping'),
                  ),
                  const PopupMenuItem(
                    value: HistoryGrouping.day,
                    child: Text('By day'),
                  ),
                  const PopupMenuItem(
                    value: HistoryGrouping.week,
                    child: Text('By week'),
                  ),
                  const PopupMenuItem(
                    value: HistoryGrouping.month,
                    child: Text('By month'),
                  ),
                  const PopupMenuItem(
                    value: HistoryGrouping.eventType,
                    child: Text('By event type'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(
              ResponsiveSize.responsive(
                context: context,
                mobile: Spacing.lg.value,
                tablet: Spacing.xl.value,
                desktop: Spacing.xl.value,
              ),
            ),
            child: TextField(
              key: const Key('history_search'),
              decoration: InputDecoration(
                hintText: 'Search entries...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadii.md,
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Active filters display
          if (_hasActiveFilters) _buildActiveFilters(),
          // Records list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(activeAccountLogRecordsProvider);
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: logRecordsAsync.when(
                data: (records) {
                  final filtered = _applyFilters(records);
                  if (filtered.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildGroupedList(context, filtered);
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedEventType != null ||
      _dateRange != null ||
      _searchQuery.isNotEmpty;

  List<LogRecord> _applyFilters(List<LogRecord> records) {
    var filtered = records.toList();

    // Filter by event type
    if (_selectedEventType != null) {
      filtered =
          filtered.where((r) => r.eventType == _selectedEventType).toList();
    }

    // Filter by date range
    if (_dateRange != null) {
      filtered =
          filtered.where((r) {
            return r.eventAt.isAfter(_dateRange!.start) &&
                r.eventAt.isBefore(
                  _dateRange!.end.add(const Duration(days: 1)),
                );
          }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered.where((r) {
            return (r.note?.toLowerCase().contains(query) ?? false) ||
                r.eventType.name.toLowerCase().contains(query);
          }).toList();
    }

    return filtered;
  }

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (_selectedEventType != null)
            Chip(
              label: Text(_selectedEventType!.name),
              onDeleted: () => setState(() => _selectedEventType = null),
            ),
          if (_dateRange != null)
            Chip(
              label: Text(
                '${DateFormat.MMMd().format(_dateRange!.start)} - ${DateFormat.MMMd().format(_dateRange!.end)}',
              ),
              onDeleted: () => setState(() => _dateRange = null),
            ),
          if (_searchQuery.isNotEmpty)
            Chip(
              label: Text('"$_searchQuery"'),
              onDeleted: () => setState(() => _searchQuery = ''),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: Paddings.xl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: IconSize.xxxl.value,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.3),
            ),
            SizedBox(height: Spacing.lg.value),
            Text(
              _hasActiveFilters ? 'No matching entries' : 'No entries yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_hasActiveFilters) ...[
              SizedBox(height: Spacing.sm.value),
              Text(
                'Try adjusting your filters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              SizedBox(height: Spacing.md.value),
              FilledButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList(BuildContext context, List<LogRecord> records) {
    switch (_grouping) {
      case HistoryGrouping.none:
        return _buildFlatList(records);
      case HistoryGrouping.day:
        return _buildDayGroupedList(records);
      case HistoryGrouping.week:
        return _buildWeekGroupedList(records);
      case HistoryGrouping.month:
        return _buildMonthGroupedList(records);
      case HistoryGrouping.eventType:
        return _buildEventTypeGroupedList(records);
    }
  }

  Widget _buildFlatList(List<LogRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder:
          (context, index) => _buildRecordTile(context, records[index]),
    );
  }

  Widget _buildDayGroupedList(List<LogRecord> records) {
    final grouped = _groupByDay(records);
    return ListView.builder(
      padding: EdgeInsets.all(
        ResponsiveSize.responsive(
          context: context,
          mobile: Spacing.lg.value,
          tablet: Spacing.xl.value,
          desktop: Spacing.xl.value,
        ),
      ),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final isLast = index == grouped.length - 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(DateFormat.yMMMMd().format(entry.key)),
            ...entry.value.asMap().entries.map((mapEntry) {
              final recordList = entry.value;
              final isLastInGroup =
                  mapEntry.key == recordList.length - 1 && isLast;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isLastInGroup ? 0 : Spacing.sm.value,
                ),
                child: _buildRecordTile(context, mapEntry.value),
              );
            }),
            if (!isLast) SizedBox(height: Spacing.lg.value),
          ],
        );
      },
    );
  }

  Widget _buildWeekGroupedList(List<LogRecord> records) {
    final grouped = _groupByWeek(records);
    return ListView.builder(
      padding: EdgeInsets.all(
        ResponsiveSize.responsive(
          context: context,
          mobile: Spacing.lg.value,
          tablet: Spacing.xl.value,
          desktop: Spacing.xl.value,
        ),
      ),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final isLast = index == grouped.length - 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader('Week of ${DateFormat.MMMd().format(entry.key)}'),
            ...entry.value.asMap().entries.map((mapEntry) {
              final recordList = entry.value;
              final isLastInGroup =
                  mapEntry.key == recordList.length - 1 && isLast;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isLastInGroup ? 0 : Spacing.sm.value,
                ),
                child: _buildRecordTile(context, mapEntry.value),
              );
            }),
            if (!isLast) SizedBox(height: Spacing.lg.value),
          ],
        );
      },
    );
  }

  Widget _buildMonthGroupedList(List<LogRecord> records) {
    final grouped = _groupByMonth(records);
    return ListView.builder(
      padding: EdgeInsets.all(
        ResponsiveSize.responsive(
          context: context,
          mobile: Spacing.lg.value,
          tablet: Spacing.xl.value,
          desktop: Spacing.xl.value,
        ),
      ),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final isLast = index == grouped.length - 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(DateFormat.yMMMM().format(entry.key)),
            ...entry.value.asMap().entries.map((mapEntry) {
              final recordList = entry.value;
              final isLastInGroup =
                  mapEntry.key == recordList.length - 1 && isLast;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isLastInGroup ? 0 : Spacing.sm.value,
                ),
                child: _buildRecordTile(context, mapEntry.value),
              );
            }),
            if (!isLast) SizedBox(height: Spacing.lg.value),
          ],
        );
      },
    );
  }

  Widget _buildEventTypeGroupedList(List<LogRecord> records) {
    final grouped = _groupByEventType(records);
    return ListView.builder(
      padding: EdgeInsets.all(
        ResponsiveSize.responsive(
          context: context,
          mobile: Spacing.lg.value,
          tablet: Spacing.xl.value,
          desktop: Spacing.xl.value,
        ),
      ),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final isLast = index == grouped.length - 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(entry.key.name.toUpperCase()),
            ...entry.value.asMap().entries.map((mapEntry) {
              final recordList = entry.value;
              final isLastInGroup =
                  mapEntry.key == recordList.length - 1 && isLast;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isLastInGroup ? 0 : Spacing.sm.value,
                ),
                child: _buildRecordTile(context, mapEntry.value),
              );
            }),
            if (!isLast) SizedBox(height: Spacing.lg.value),
          ],
        );
      },
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Spacing.sm.value,
        top: Spacing.md.value,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildRecordTile(BuildContext context, LogRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getEventIcon(record.eventType),
        title: Text(
          record.eventType.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat.yMMMd().add_jm().format(record.eventAt)),
            if (record.note != null && record.note!.isNotEmpty)
              Text(record.note!, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSyncIndicator(record.syncState),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(context, record),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteLogRecord(context, record),
            ),
          ],
        ),
        isThreeLine: record.note != null && record.note!.isNotEmpty,
        onTap: () => _showEditDialog(context, record),
      ),
    );
  }

  Widget _getEventIcon(EventType type) {
    IconData icon;
    Color color;

    switch (type) {
      case EventType.vape:
        icon = Icons.cloud;
        color = Colors.indigo;
        break;
      case EventType.inhale:
        icon = Icons.air;
        color = Colors.blue;
        break;
      case EventType.sessionStart:
        icon = Icons.play_circle;
        color = Colors.green;
        break;
      case EventType.sessionEnd:
        icon = Icons.stop_circle;
        color = Colors.red;
        break;
      case EventType.note:
        icon = Icons.note;
        color = Colors.orange;
        break;
      case EventType.tolerance:
        icon = Icons.trending_up;
        color = Colors.purple;
        break;
      case EventType.symptomRelief:
        icon = Icons.healing;
        color = Colors.teal;
        break;
      case EventType.purchase:
        icon = Icons.shopping_cart;
        color = Colors.amber;
        break;
      case EventType.custom:
        icon = Icons.star;
        color = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.2),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildSyncIndicator(SyncState state) {
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
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case SyncState.error:
        icon = Icons.cloud_off;
        color = Colors.red;
        break;
      case SyncState.conflict:
        icon = Icons.warning;
        color = Colors.amber;
        break;
    }

    return Icon(icon, size: IconSize.sm.value, color: color);
  }

  // Grouping helpers
  Map<DateTime, List<LogRecord>> _groupByDay(List<LogRecord> records) {
    final grouped = <DateTime, List<LogRecord>>{};
    for (final record in records) {
      final day = DateTime(
        record.eventAt.year,
        record.eventAt.month,
        record.eventAt.day,
      );
      grouped.putIfAbsent(day, () => []).add(record);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  Map<DateTime, List<LogRecord>> _groupByWeek(List<LogRecord> records) {
    final grouped = <DateTime, List<LogRecord>>{};
    for (final record in records) {
      // Use 6am day boundary for more natural grouping of late-night activity
      final weekStart = DayBoundary.getWeekStart(record.eventAt);
      grouped.putIfAbsent(weekStart, () => []).add(record);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  Map<DateTime, List<LogRecord>> _groupByMonth(List<LogRecord> records) {
    final grouped = <DateTime, List<LogRecord>>{};
    for (final record in records) {
      final month = DateTime(record.eventAt.year, record.eventAt.month);
      grouped.putIfAbsent(month, () => []).add(record);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  Map<EventType, List<LogRecord>> _groupByEventType(List<LogRecord> records) {
    final grouped = <EventType, List<LogRecord>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.eventType, () => []).add(record);
    }
    return grouped;
  }

  void _clearFilters() {
    setState(() {
      _selectedEventType = null;
      _dateRange = null;
      _searchQuery = '';
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => _FilterBottomSheet(
            selectedEventType: _selectedEventType,
            dateRange: _dateRange,
            onEventTypeChanged: (type) {
              setState(() => _selectedEventType = type);
              Navigator.pop(context);
            },
            onDateRangeChanged: (range) {
              setState(() => _dateRange = range);
              Navigator.pop(context);
            },
            onClear: () {
              _clearFilters();
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showEditDialog(BuildContext context, LogRecord record) {
    showDialog(
      context: context,
      builder: (context) => EditLogRecordDialog(record: record),
    ).then((_) {
      // Refresh records after dialog closes
      ref.invalidate(activeAccountLogRecordsProvider);
    });
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
      await _deleteLogRecord(record);
    }
  }

  Future<void> _deleteLogRecord(LogRecord record) async {
    try {
      await ref
          .read(logRecordNotifierProvider.notifier)
          .deleteLogRecord(record);

      if (!mounted) return;

      // Invalidate to refresh the list
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

/// Grouping options for history view
enum HistoryGrouping { none, day, week, month, eventType }

/// Bottom sheet for filter options
class _FilterBottomSheet extends StatelessWidget {
  final EventType? selectedEventType;
  final DateTimeRange? dateRange;
  final ValueChanged<EventType?> onEventTypeChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.selectedEventType,
    required this.dateRange,
    required this.onEventTypeChanged,
    required this.onDateRangeChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter History', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Event Type', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                EventType.values.map((type) {
                  final isSelected = selectedEventType == type;
                  return FilterChip(
                    label: Text(type.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      onEventTypeChanged(selected ? type : null);
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Date Range', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: dateRange,
              );
              if (range != null) {
                onDateRangeChanged(range);
              }
            },
            icon: const Icon(Icons.date_range),
            label: Text(
              dateRange != null
                  ? '${DateFormat.MMMd().format(dateRange!.start)} - ${DateFormat.MMMd().format(dateRange!.end)}'
                  : 'Select date range',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
