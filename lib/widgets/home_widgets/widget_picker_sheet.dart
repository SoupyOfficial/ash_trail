import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_widget_config_provider.dart';
import 'widget_catalog.dart';

/// Bottom sheet for selecting widgets to add to the home screen
class WidgetPickerSheet extends ConsumerWidget {
  const WidgetPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedWidgets = WidgetCatalog.getAllGrouped();
    final config = ref.watch(homeLayoutConfigProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.widgets_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add Widget',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Widget list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: WidgetCategory.values.length,
                  itemBuilder: (context, index) {
                    final category = WidgetCategory.values[index];
                    final widgets = groupedWidgets[category] ?? [];

                    if (widgets.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category header
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                category.icon,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category.displayName,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Widgets in category
                        ...widgets.map((entry) {
                          final isAdded = config.hasWidgetType(entry.type);
                          final canAdd = entry.allowMultiple || !isAdded;

                          return _WidgetPickerTile(
                            entry: entry,
                            isAdded: isAdded,
                            canAdd: canAdd,
                            onTap: canAdd
                                ? () {
                                    HapticFeedback.mediumImpact();
                                    ref
                                        .read(homeLayoutConfigProvider.notifier)
                                        .addWidget(entry.type);
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added ${entry.displayName}'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                : null,
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WidgetPickerTile extends StatelessWidget {
  final WidgetCatalogEntry entry;
  final bool isAdded;
  final bool canAdd;
  final VoidCallback? onTap;

  const _WidgetPickerTile({
    required this.entry,
    required this.isAdded,
    required this.canAdd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isAdded
          ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: canAdd
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            entry.icon,
            size: 20,
            color: canAdd
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
        title: Text(
          entry.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: canAdd
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
        subtitle: Text(
          entry.description,
          style: TextStyle(
            color: canAdd
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurfaceVariant.withOpacity(0.4),
          ),
        ),
        trailing: isAdded
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Added',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : Icon(
                Icons.add_circle_outline,
                color: colorScheme.primary,
              ),
        onTap: onTap,
      ),
    );
  }
}

/// Show the widget picker bottom sheet
Future<void> showWidgetPicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const WidgetPickerSheet(),
  );
}
