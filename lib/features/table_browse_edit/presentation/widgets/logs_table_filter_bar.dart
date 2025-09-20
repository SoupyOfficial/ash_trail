// Filter bar widget for logs table
// Provides filtering controls for date range, smoking method, tags, and mood

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/log_filter.dart';
import '../providers/logs_table_state_provider.dart';

/// Filter bar widget for the logs table
/// Displays filter chips and provides filtering controls
class LogsTableFilterBar extends ConsumerWidget {
  final String accountId;

  const LogsTableFilterBar({
    super.key,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logsTableStateProvider(accountId));
    final notifier = ref.read(logsTableStateProvider(accountId).notifier);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter toggle and quick actions
          Row(
            children: [
              Text(
                'Filters',
                style: theme.textTheme.labelMedium,
              ),
              const Spacer(),

              // Clear filters button
              if (state.hasActiveFilters)
                TextButton.icon(
                  onPressed: () => notifier.clearFilters(),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),

              // Filter options button
              IconButton(
                onPressed: () =>
                    _showFilterModal(context, state.filter, notifier),
                icon: Icon(
                  state.hasActiveFilters
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                  color:
                      state.hasActiveFilters ? theme.colorScheme.primary : null,
                ),
                tooltip: 'Filter Options',
              ),
            ],
          ),

          // Active filters display
          if (state.hasActiveFilters)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                // Date range filter chip
                if (state.filter.startDate != null ||
                    state.filter.endDate != null)
                  _buildFilterChip(
                    context,
                    label: _formatDateRange(
                        state.filter.startDate, state.filter.endDate),
                    icon: Icons.date_range,
                    onRemove: () => notifier.updateFilter(
                      state.filter.copyWith(
                        startDate: null,
                        endDate: null,
                      ),
                    ),
                  ),

                // Smoking method filter chip
                if (state.filter.methodIds?.isNotEmpty ?? false)
                  ...state.filter.methodIds!.map((methodId) => _buildFilterChip(
                        context,
                        label: 'Method: $methodId', // TODO: lookup method name
                        icon: Icons.smoking_rooms,
                        onRemove: () => notifier.updateFilter(
                          state.filter.copyWith(
                            methodIds: List.from(state.filter.methodIds!)
                              ..remove(methodId),
                          ),
                        ),
                      )),

                // Duration range filter chip
                if (state.filter.minDurationMs != null ||
                    state.filter.maxDurationMs != null)
                  _buildFilterChip(
                    context,
                    label: _formatDurationRange(
                      state.filter.minDurationMs,
                      state.filter.maxDurationMs,
                    ),
                    icon: Icons.timer,
                    onRemove: () => notifier.updateFilter(
                      state.filter.copyWith(
                        minDurationMs: null,
                        maxDurationMs: null,
                      ),
                    ),
                  ),

                // Tags filter chips - showing included tags
                if (state.filter.includeTagIds?.isNotEmpty ?? false)
                  ...state.filter.includeTagIds!
                      .map((tagId) => _buildFilterChip(
                            context,
                            label: '#$tagId', // TODO: lookup tag name
                            icon: Icons.tag,
                            onRemove: () => notifier.updateFilter(
                              state.filter.copyWith(
                                includeTagIds:
                                    List.from(state.filter.includeTagIds!)
                                      ..remove(tagId),
                              ),
                            ),
                          )),

                // Mood score filter chip
                if (state.filter.minMoodScore != null ||
                    state.filter.maxMoodScore != null)
                  _buildFilterChip(
                    context,
                    label: _formatMoodRange(
                        state.filter.minMoodScore, state.filter.maxMoodScore),
                    icon: Icons.mood,
                    onRemove: () => notifier.updateFilter(
                      state.filter.copyWith(
                        minMoodScore: null,
                        maxMoodScore: null,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  /// Build a filter chip with remove functionality
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onDeleted: onRemove,
      deleteIconColor: Theme.of(context).colorScheme.error,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  /// Format date range for display
  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    } else if (startDate != null) {
      return 'From ${_formatDate(startDate)}';
    } else if (endDate != null) {
      return 'Until ${_formatDate(endDate)}';
    }
    return 'Date Range';
  }

  /// Format single date
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Format duration range for display
  String _formatDurationRange(int? minMs, int? maxMs) {
    final minMin = minMs != null ? (minMs / 60000).round() : null;
    final maxMin = maxMs != null ? (maxMs / 60000).round() : null;

    if (minMin != null && maxMin != null) {
      return '$minMin-${maxMin}min';
    } else if (minMin != null) {
      return '${minMin}min+';
    } else if (maxMin != null) {
      return '<${maxMin}min';
    }
    return 'Duration';
  }

  /// Format mood score range for display
  String _formatMoodRange(int? minScore, int? maxScore) {
    if (minScore != null && maxScore != null) {
      return 'Mood: $minScore-$maxScore';
    } else if (minScore != null) {
      return 'Mood: $minScore+';
    } else if (maxScore != null) {
      return 'Mood: <$maxScore';
    }
    return 'Mood';
  }

  /// Show comprehensive filter modal
  void _showFilterModal(
    BuildContext context,
    LogFilter currentFilter,
    LogsTableStateNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterModal(
        currentFilter: currentFilter,
        onFilterChanged: (filter) => notifier.updateFilter(filter),
      ),
    );
  }
}

/// Comprehensive filter modal
class _FilterModal extends StatefulWidget {
  final LogFilter currentFilter;
  final ValueChanged<LogFilter> onFilterChanged;

  const _FilterModal({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late LogFilter _workingFilter;

  @override
  void initState() {
    super.initState();
    _workingFilter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Filter Logs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _workingFilter = const LogFilter();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),

              // Filter options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Date range section
                    _buildSection(
                      title: 'Date Range',
                      icon: Icons.date_range,
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Start Date'),
                            subtitle: Text(_workingFilter.startDate
                                    ?.toString()
                                    .split(' ')[0] ??
                                'Not set'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectStartDate(context),
                          ),
                          ListTile(
                            title: const Text('End Date'),
                            subtitle: Text(_workingFilter.endDate
                                    ?.toString()
                                    .split(' ')[0] ??
                                'Not set'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectEndDate(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Method section - simplified for now
                    _buildSection(
                      title: 'Methods',
                      icon: Icons.smoking_rooms,
                      child: const Text(
                        'Method filtering will be implemented when Method lookup is available.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Duration range section
                    _buildSection(
                      title: 'Duration (minutes)',
                      icon: Icons.timer,
                      child: Column(
                        children: [
                          RangeSlider(
                            values: RangeValues(
                              (_workingFilter.minDurationMs ?? 0) / 60000,
                              (_workingFilter.maxDurationMs ?? 60 * 60000) /
                                  60000,
                            ),
                            min: 0,
                            max: 60,
                            divisions: 60,
                            labels: RangeLabels(
                              '${((_workingFilter.minDurationMs ?? 0) / 60000).round()}min',
                              '${((_workingFilter.maxDurationMs ?? 60 * 60000) / 60000).round()}min',
                            ),
                            onChanged: (values) {
                              setState(() {
                                _workingFilter = _workingFilter.copyWith(
                                  minDurationMs: values.start > 0
                                      ? (values.start * 60000).round()
                                      : null,
                                  maxDurationMs: values.end < 60
                                      ? (values.end * 60000).round()
                                      : null,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Apply/Cancel buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onFilterChanged(_workingFilter);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _workingFilter.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _workingFilter = _workingFilter.copyWith(startDate: date);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _workingFilter.endDate ?? DateTime.now(),
      firstDate: _workingFilter.startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _workingFilter = _workingFilter.copyWith(endDate: date);
      });
    }
  }
}
