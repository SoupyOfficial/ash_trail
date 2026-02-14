import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/home_widget_config.dart';
import '../../providers/home_widget_config_provider.dart';
import 'widget_catalog.dart';

/// Bottom sheet for editing widget-specific settings.
///
/// Currently supports:
/// - `recentEntries`: number of entries to display (1–20)
/// - `durationTrend`: number of comparison days (1–14)
///
/// For widget types without configurable settings, an informational message
/// is shown.
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
    _settings = {...?widget.config.settings};
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
    switch (type) {
      case HomeWidgetType.recentEntries:
        final count = _settings['count'] as int? ?? 5;
        return [
          _SettingSlider(
            label: 'Number of entries',
            value: count.toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (v) => setState(() => _settings['count'] = v.round()),
          ),
        ];
      case HomeWidgetType.durationTrend:
        final days = _settings['days'] as int? ?? 3;
        return [
          _SettingSlider(
            label: 'Comparison period (days)',
            value: days.toDouble(),
            min: 1,
            max: 14,
            divisions: 13,
            onChanged: (v) => setState(() => _settings['days'] = v.round()),
          ),
        ];
      default:
        return [];
    }
  }

  void _save() {
    ref
        .read(homeLayoutConfigProvider.notifier)
        .updateWidgetSettings(widget.config.id, _settings);
    Navigator.pop(context);
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
