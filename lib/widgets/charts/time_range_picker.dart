import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/day_boundary.dart';

/// Custom time range picker dialog for analytics
/// Allows users to select preset ranges or custom date ranges
class TimeRangePicker extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final ValueChanged<DateTimeRange> onRangeSelected;

  const TimeRangePicker({
    super.key,
    this.initialStart,
    this.initialEnd,
    required this.onRangeSelected,
  });

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  late DateTime _startDate;
  late DateTime _endDate;
  TimeRangePreset? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _endDate = widget.initialEnd ?? DateTime.now();
    _startDate =
        widget.initialStart ?? _endDate.subtract(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Select Time Range',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preset options
                      Text(
                        'Quick Select',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            TimeRangePreset.values.map((preset) {
                              final isSelected = _selectedPreset == preset;
                              return ChoiceChip(
                                label: Text(preset.label),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    _applyPreset(preset);
                                  }
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Custom date range
                      Text(
                        'Custom Range',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DatePickerField(
                              label: 'Start',
                              date: _startDate,
                              onTap: () => _selectDate(isStart: true),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.arrow_forward, size: 20),
                          ),
                          Expanded(
                            child: _DatePickerField(
                              label: 'End',
                              date: _endDate,
                              onTap: () => _selectDate(isStart: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildRangeSummary(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _applySelection,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyPreset(TimeRangePreset preset) {
    final now = DateTime.now();
    // Use 6am day boundary for more natural grouping of late-night activity
    final todayStart = DayBoundary.getTodayStart();

    setState(() {
      _selectedPreset = preset;
      _endDate = DayBoundary.getTodayEnd();

      switch (preset) {
        case TimeRangePreset.today:
          _startDate = todayStart;
          break;
        case TimeRangePreset.yesterday:
          _startDate = DayBoundary.getYesterdayStart();
          _endDate = todayStart.subtract(const Duration(seconds: 1));
          break;
        case TimeRangePreset.last7Days:
          _startDate = DayBoundary.getDayStartDaysAgo(6);
          break;
        case TimeRangePreset.last14Days:
          _startDate = DayBoundary.getDayStartDaysAgo(13);
          break;
        case TimeRangePreset.last30Days:
          _startDate = DayBoundary.getDayStartDaysAgo(29);
          break;
        case TimeRangePreset.last90Days:
          _startDate = DayBoundary.getDayStartDaysAgo(89);
          break;
        case TimeRangePreset.thisWeek:
          _startDate = DayBoundary.getThisWeekStart();
          break;
        case TimeRangePreset.thisMonth:
          // For month boundaries, keep calendar month for clarity
          _startDate = DateTime(now.year, now.month, 1, DayBoundary.dayStartHour);
          break;
        case TimeRangePreset.lastMonth:
          // For month boundaries, keep calendar month for clarity
          final lastMonth = DateTime(now.year, now.month - 1, 1, DayBoundary.dayStartHour);
          _startDate = lastMonth;
          _endDate = DateTime(
            now.year,
            now.month,
            1,
            DayBoundary.dayStartHour,
          ).subtract(const Duration(seconds: 1));
          break;
        case TimeRangePreset.allTime:
          _startDate = DateTime(2020, 1, 1, DayBoundary.dayStartHour);
          break;
      }
    });
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = DateTime(2020, 1, 1);
    final lastDate = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selected != null) {
      setState(() {
        _selectedPreset = null; // Clear preset when manually selecting
        if (isStart) {
          _startDate = selected;
          // Ensure start is before end
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = selected;
          // Ensure end is after start
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Widget _buildRangeSummary(BuildContext context) {
    final days = _endDate.difference(_startDate).inDays + 1;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.date_range,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '$days day${days == 1 ? '' : 's'} selected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _applySelection() {
    widget.onRangeSelected(DateTimeRange(start: _startDate, end: _endDate));
    Navigator.pop(context);
  }
}

/// Date picker field widget
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Preset time range options
enum TimeRangePreset {
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last 7 Days'),
  last14Days('Last 14 Days'),
  last30Days('Last 30 Days'),
  last90Days('Last 90 Days'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  allTime('All Time');

  final String label;
  const TimeRangePreset(this.label);
}

/// Show time range picker dialog
Future<DateTimeRange?> showTimeRangePicker({
  required BuildContext context,
  DateTime? initialStart,
  DateTime? initialEnd,
}) async {
  DateTimeRange? result;

  await showDialog(
    context: context,
    builder:
        (context) => TimeRangePicker(
          initialStart: initialStart,
          initialEnd: initialEnd,
          onRangeSelected: (range) {
            result = range;
          },
        ),
  );

  return result;
}
