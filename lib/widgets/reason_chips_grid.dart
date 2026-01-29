import 'package:flutter/material.dart';
import '../models/enums.dart';

/// A grid layout for LogReason chips using styled FilterChip.
/// 
/// This widget displays reason chips in a Wrap layout using FilterChip widgets,
/// providing Material Design 3 chip behavior with multi-select support.
/// Features custom styling for selected/unselected states with icons.
class ReasonChipsGrid extends StatelessWidget {
  /// The currently selected reasons.
  final Set<LogReason> selected;

  /// Callback when a reason is toggled.
  final void Function(LogReason reason) onToggle;

  /// Whether to show icons in the chips. Defaults to true.
  final bool showIcons;

  /// Spacing between chips.
  final double spacing;

  const ReasonChipsGrid({
    super.key,
    required this.selected,
    required this.onToggle,
    this.showIcons = true,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final reasons = LogReason.values;
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: reasons.map((reason) {
        final isSelected = selected.contains(reason);
        return FilterChip(
          label: Text(
            reason.displayName,
            style: TextStyle(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onToggle(reason),
          avatar: showIcons
              ? Icon(
                  reason.icon,
                  size: 18,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                )
              : null,
          showCheckmark: false,
          selectedColor: colorScheme.primaryContainer,
          backgroundColor: colorScheme.surfaceContainerHighest,
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1.0,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      }).toList(),
    );
  }
}
