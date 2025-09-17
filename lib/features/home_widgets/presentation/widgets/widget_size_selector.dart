// Widget size selector component.
// Allows users to select from available widget sizes with visual representation.

import 'package:flutter/material.dart';
import '../../domain/entities/widget_size.dart';

class WidgetSizeSelector extends StatelessWidget {
  const WidgetSizeSelector({
    required this.selectedSize,
    required this.onSizeChanged,
    super.key,
  });

  final WidgetSize selectedSize;
  final ValueChanged<WidgetSize> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: WidgetSize.values.map((size) {
                final isSelected = size == selectedSize;
                return GestureDetector(
                  onTap: () => onSizeChanged(size),
                  child: Column(
                    children: [
                      Container(
                        width: _getWidthForSize(size),
                        height: _getHeightForSize(size),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${size.width}×${size.height}',
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        size.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              _getDescriptionForSize(selectedSize),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _getWidthForSize(WidgetSize size) {
    return switch (size) {
      WidgetSize.small => 60,
      WidgetSize.medium => 80,
      WidgetSize.large => 80,
      WidgetSize.extraLarge => 100,
    };
  }

  double _getHeightForSize(WidgetSize size) {
    return switch (size) {
      WidgetSize.small => 60,
      WidgetSize.medium => 40,
      WidgetSize.large => 80,
      WidgetSize.extraLarge => 50,
    };
  }

  String _getDescriptionForSize(WidgetSize size) {
    return switch (size) {
      WidgetSize.small => 'Shows hit count only. Perfect for quick glances.',
      WidgetSize.medium => 'Shows hit count and streak. Recommended for most users.',
      WidgetSize.large => 'Shows all information including last sync time.',
      WidgetSize.extraLarge => 'Maximum information display with detailed stats.',
    };
  }
}