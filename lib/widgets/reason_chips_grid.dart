import 'package:flutter/material.dart';
import '../models/enums.dart';

/// A grid layout for LogReason chips with equal-width, equal-height cells.
/// 
/// This widget displays reason chips in a fixed 3-column grid layout
/// where each chip fills its entire cell (full width, 2-line height),
/// creating a perfectly symmetrical grid.
class ReasonChipsGrid extends StatelessWidget {
  /// The currently selected reasons.
  final Set<LogReason> selected;

  /// Callback when a reason is toggled.
  final void Function(LogReason reason) onToggle;

  /// Number of columns per row (default: 2).
  final int columnsPerRow;

  /// Whether to show icons in the chips.
  final bool showIcons;

  /// Spacing between chips.
  final double spacing;

  const ReasonChipsGrid({
    super.key,
    required this.selected,
    required this.onToggle,
    this.columnsPerRow = 2,
    this.showIcons = false,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final reasons = LogReason.values;
    final rows = <Widget>[];
    
    // Fixed chip height for 2 lines of text
    const double chipHeight = 52.0;

    // Split reasons into rows
    for (var i = 0; i < reasons.length; i += columnsPerRow) {
      final endIndex = (i + columnsPerRow).clamp(0, reasons.length);
      final rowReasons = reasons.sublist(i, endIndex);

      // Build chips for this row
      final rowChildren = <Widget>[];
      for (var j = 0; j < rowReasons.length; j++) {
        final reason = rowReasons[j];
        
        // Add spacing between chips (not before first)
        if (j > 0) {
          rowChildren.add(SizedBox(width: spacing));
        }
        
        rowChildren.add(
          Expanded(
            child: _ReasonChipButton(
              reason: reason,
              isSelected: selected.contains(reason),
              onTap: () => onToggle(reason),
              height: chipHeight,
              showIcon: showIcons,
            ),
          ),
        );
      }

      // If last row has fewer items, add empty Expanded widgets to maintain alignment
      final emptySlots = columnsPerRow - rowReasons.length;
      for (var k = 0; k < emptySlots; k++) {
        rowChildren.add(SizedBox(width: spacing));
        rowChildren.add(Expanded(child: SizedBox(height: chipHeight)));
      }

      rows.add(Row(children: rowChildren));

      // Add vertical spacing between rows (not after last)
      if (endIndex < reasons.length) {
        rows.add(SizedBox(height: spacing));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

/// A custom chip-like button that fills its entire container.
class _ReasonChipButton extends StatelessWidget {
  final LogReason reason;
  final bool isSelected;
  final VoidCallback onTap;
  final double height;
  final bool showIcon;

  const _ReasonChipButton({
    required this.reason,
    required this.isSelected,
    required this.onTap,
    required this.height,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final backgroundColor = isSelected 
        ? colorScheme.secondaryContainer 
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = isSelected 
        ? colorScheme.onSecondaryContainer 
        : colorScheme.onSurfaceVariant;
    final borderColor = isSelected 
        ? colorScheme.outline 
        : colorScheme.outlineVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Center(
            child: showIcon
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(reason.icon, size: 16, color: foregroundColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          reason.displayName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: foregroundColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    reason.displayName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foregroundColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
      ),
    );
  }
}
