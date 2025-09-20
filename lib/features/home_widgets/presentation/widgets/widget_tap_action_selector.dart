// Widget tap action selector component.
// Allows users to choose what happens when they tap the widget.

import 'package:flutter/material.dart';
import '../../domain/entities/widget_tap_action.dart';

class WidgetTapActionSelector extends StatelessWidget {
  const WidgetTapActionSelector({
    required this.selectedAction,
    required this.onActionChanged,
    super.key,
  });

  final WidgetTapAction selectedAction;
  final ValueChanged<WidgetTapAction> onActionChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...WidgetTapAction.values.map((action) {
              final isSelected = action == selectedAction;
              return ListTile(
                leading: Icon(
                  _getIconForAction(action),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  action.displayName,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(_getDescriptionForAction(action)),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => onActionChanged(action),
                selected: isSelected,
                selectedTileColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Deep link path: ${selectedAction.deepLinkPath}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAction(WidgetTapAction action) {
    return switch (action) {
      WidgetTapAction.openApp => Icons.home,
      WidgetTapAction.recordOverlay => Icons.add_circle,
      WidgetTapAction.viewLogs => Icons.list,
      WidgetTapAction.quickRecord => Icons.flash_on,
    };
  }

  String _getDescriptionForAction(WidgetTapAction action) {
    return switch (action) {
      WidgetTapAction.openApp => 'Opens the main app screen',
      WidgetTapAction.recordOverlay => 'Opens recording overlay for timing',
      WidgetTapAction.viewLogs => 'Shows your smoking history',
      WidgetTapAction.quickRecord => 'Quickly records a hit without timing',
    };
  }
}
