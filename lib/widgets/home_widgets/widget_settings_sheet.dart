import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/home_widget_config.dart';
import '../../models/enums.dart';
import '../../providers/home_widget_config_provider.dart';
import 'widget_catalog.dart';
import 'widget_settings_keys.dart';

/// Bottom sheet for editing widget-specific settings.
///
/// Supports shared settings (time window, event type filter) for all widget
/// types, plus widget-specific settings (entry count, comparison days, etc.).
class WidgetSettingsSheet extends ConsumerStatefulWidget {
  final HomeWidgetConfig config;

  const WidgetSettingsSheet({super.key, required this.config});

  /// Show the settings sheet for a widget.
  static void show(BuildContext context, HomeWidgetConfig config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => WidgetSettingsSheet(config: config),
    );
  }

  @override
  ConsumerState<WidgetSettingsSheet> createState() =>
      _WidgetSettingsSheetState();
}

class _WidgetSettingsSheetState extends ConsumerState<WidgetSettingsSheet> {
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    // Merge persisted settings on top of defaults so every key is present.
    final defaults = WidgetSettingsDefaults.defaultsFor(widget.config.type);
    _settings = {...defaults, ...?widget.config.settings};
  }

  @override
  Widget build(BuildContext context) {
    final entry = WidgetCatalog.getEntry(widget.config.type);
    final settingsWidgets = _buildSettingsForType(widget.config.type);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(entry.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${entry.displayName} Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (settingsWidgets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No configurable settings for this widget.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...settingsWidgets,
            const SizedBox(height: 16),
            if (settingsWidgets.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSettingsForType(HomeWidgetType type) {
    final widgets = <Widget>[];

    // ── Shared: Time Window ─────────────────────────────────────────────
    if (WidgetSettingsDefaults.supportsTimeWindow(type)) {
      widgets.add(_buildTimeWindowSetting());
      widgets.add(const SizedBox(height: 16));
    }

    // ── Shared: Event Type Filter ──────────────────────────────────────
    if (WidgetSettingsDefaults.supportsEventTypeFilter(type)) {
      widgets.add(_buildEventTypeFilterSetting());
      widgets.add(const SizedBox(height: 16));
    }

    // ── Heatmap: Day Filter ─────────────────────────────────────────────
    if (type == HomeWidgetType.weekdayHeatmap ||
        type == HomeWidgetType.weekendHeatmap) {
      widgets.add(_buildHeatmapDayFilterSetting());
      widgets.add(const SizedBox(height: 16));
    }

    // ── Widget-specific settings ───────────────────────────────────────
    switch (type) {
      case HomeWidgetType.recentEntries:
        final count = _settings['count'] as int? ?? 5;
        widgets.add(
          _SettingSlider(
            label: 'Number of entries',
            value: count.toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (v) => setState(() => _settings['count'] = v.round()),
          ),
        );
      case HomeWidgetType.durationTrend:
        // The time window selector already handles the days setting.
        break;
      case HomeWidgetType.customStat:
        widgets.add(_buildMetricTypeSetting());
        widgets.add(const SizedBox(height: 16));
      default:
        break;
    }

    return widgets;
  }

  // ── Time Window Selector ────────────────────────────────────────────
  Widget _buildTimeWindowSetting() {
    final currentDays = _settings[kTimeWindowDays] as int? ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time Window', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              WidgetSettingsDefaults.timeWindowOptions.map((days) {
                final selected = currentDays == days;
                return ChoiceChip(
                  label: Text(WidgetSettingsDefaults.timeWindowLabel(days)),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _settings[kTimeWindowDays] = days);
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  // ── Event Type Filter ───────────────────────────────────────────────
  Widget _buildEventTypeFilterSetting() {
    final raw = _settings[kEventTypeFilter] as List<dynamic>? ?? [];
    final selectedNames = raw.cast<String>().toSet();
    final allSelected = selectedNames.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Event Type Filter',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            if (!allSelected)
              TextButton(
                onPressed: () {
                  setState(() => _settings[kEventTypeFilter] = <String>[]);
                },
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: allSelected,
              onSelected: (_) {
                setState(() => _settings[kEventTypeFilter] = <String>[]);
              },
            ),
            ...EventType.values.map((type) {
              final selected = selectedNames.contains(type.name);
              return FilterChip(
                label: Text(_eventTypeDisplayName(type)),
                selected: selected,
                onSelected: (isSelected) {
                  setState(() {
                    final current = Set<String>.from(selectedNames);
                    if (isSelected) {
                      current.add(type.name);
                    } else {
                      current.remove(type.name);
                    }
                    _settings[kEventTypeFilter] = current.toList();
                  });
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  // ── Heatmap Day Filter ──────────────────────────────────────────────
  Widget _buildHeatmapDayFilterSetting() {
    final currentName = _settings[kHeatmapDayFilter] as String? ?? 'all';
    final current = HeatmapDayFilter.values.firstWhere(
      (e) => e.name == currentName,
      orElse: () => HeatmapDayFilter.all,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Day Filter', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<HeatmapDayFilter>(
          segments:
              HeatmapDayFilter.values
                  .map(
                    (f) => ButtonSegment(value: f, label: Text(f.displayName)),
                  )
                  .toList(),
          selected: {current},
          onSelectionChanged: (selection) {
            setState(() {
              _settings[kHeatmapDayFilter] = selection.first.name;
            });
          },
        ),
      ],
    );
  }

  // ── Metric Type Selector ────────────────────────────────────────────
  Widget _buildMetricTypeSetting() {
    final currentName = _settings[kMetricType] as String? ?? 'count';
    final current = MetricType.values.firstWhere(
      (e) => e.name == currentName,
      orElse: () => MetricType.count,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metric', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              MetricType.values.map((metric) {
                final selected = current == metric;
                return ChoiceChip(
                  label: Text(metric.displayName),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _settings[kMetricType] = metric.name);
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  void _save() {
    ref
        .read(homeLayoutConfigProvider.notifier)
        .updateWidgetSettings(widget.config.id, _settings);
    Navigator.pop(context);
  }

  static String _eventTypeDisplayName(EventType type) {
    return switch (type) {
      EventType.vape => 'Vape',
      EventType.inhale => 'Inhale',
      EventType.sessionStart => 'Session Start',
      EventType.sessionEnd => 'Session End',
      EventType.note => 'Note',
      EventType.purchase => 'Purchase',
      EventType.tolerance => 'Tolerance',
      EventType.symptomRelief => 'Symptom Relief',
      EventType.custom => 'Custom',
    };
  }
}

class _SettingSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              value.round().toString(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
