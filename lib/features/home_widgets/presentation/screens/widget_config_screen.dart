// Configuration screen for managing home screen widget settings.
// Allows users to create and configure widget behavior and appearance.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/widget_size.dart';
import '../providers/home_widgets_notifiers.dart';
import '../widgets/widget_size_selector.dart';
import '../widgets/widget_tap_action_selector.dart';
import '../widgets/widget_preview.dart';

class WidgetConfigScreen extends ConsumerWidget {
  const WidgetConfigScreen({
    required this.accountId,
    super.key,
  });

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(widgetConfigurationProvider);
    final widgetsList = ref.watch(homeWidgetsListProvider(accountId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Widget'),
        actions: [
          TextButton(
            onPressed: () => _saveWidget(context, ref),
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Widget Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: WidgetPreview(
                          size: config.size,
                          tapAction: config.tapAction,
                          showStreak: config.showStreak,
                          showLastSync: config.showLastSync,
                          todayHitCount: 3, // Mock data
                          currentStreak: 5, // Mock data
                          lastSyncAt: DateTime.now(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Size Selection
              Text(
                'Widget Size',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              WidgetSizeSelector(
                selectedSize: config.size,
                onSizeChanged: (size) {
                  ref
                      .read(widgetConfigurationProvider.notifier)
                      .updateSize(size);
                },
              ),
              const SizedBox(height: 24),

              // Tap Action Selection
              Text(
                'Tap Action',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              WidgetTapActionSelector(
                selectedAction: config.tapAction,
                onActionChanged: (action) {
                  ref
                      .read(widgetConfigurationProvider.notifier)
                      .updateTapAction(action);
                },
              ),
              const SizedBox(height: 24),

              // Display Options
              Text(
                'Display Options',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Show Streak'),
                      subtitle: Text(config.size.canShowStreak
                          ? 'Display current streak in widget'
                          : 'Not available for small widgets'),
                      value: config.showStreak && config.size.canShowStreak,
                      onChanged: config.size.canShowStreak
                          ? (value) => ref
                              .read(widgetConfigurationProvider.notifier)
                              .updateShowStreak(value)
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Show Last Sync'),
                      subtitle: Text(config.size.canShowDetails
                          ? 'Display last sync timestamp'
                          : 'Not available for small widgets'),
                      value: config.showLastSync && config.size.canShowDetails,
                      onChanged: config.size.canShowDetails
                          ? (value) => ref
                              .read(widgetConfigurationProvider.notifier)
                              .updateShowLastSync(value)
                          : null,
                    ),
                  ],
                ),
              ),

              // Current Widgets Info
              widgetsList.when(
                data: (widgets) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Widgets: ${widgets.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (widgets.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...widgets.map((widget) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getIconForSize(widget.size),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        '${widget.size.name.capitalize()} - ${widget.tapAction.displayName}'),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error loading widgets: ${error.toString()}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveWidget(BuildContext context, WidgetRef ref) async {
    final config = ref.read(widgetConfigurationProvider);
    final notifier = ref.read(homeWidgetsListProvider(accountId).notifier);

    final widget = await notifier.createWidget(
      accountId: accountId,
      size: config.size,
      tapAction: config.tapAction,
      showStreak: config.showStreak,
      showLastSync: config.showLastSync,
    );

    if (widget != null) {
      ref.read(widgetConfigurationProvider.notifier).reset();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget created successfully!'),
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create widget'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getIconForSize(WidgetSize size) {
    return switch (size) {
      WidgetSize.small => Icons.crop_din,
      WidgetSize.medium => Icons.crop_landscape,
      WidgetSize.large => Icons.crop_square,
      WidgetSize.extraLarge => Icons.crop_16_9,
    };
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
