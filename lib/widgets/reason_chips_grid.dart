import 'package:flutter/material.dart';
import '../models/enums.dart';

/// A grid layout for LogReason chips using standard Flutter FilterChip.
/// 
/// This widget displays reason chips in a Wrap layout using FilterChip widgets,
/// providing standard Material Design chip behavior with multi-select support.
class ReasonChipsGrid extends StatelessWidget {
  /// The currently selected reasons.
  final Set<LogReason> selected;

  /// Callback when a reason is toggled.
  final void Function(LogReason reason) onToggle;

  /// Whether to show icons in the chips.
  final bool showIcons;

  /// Spacing between chips.
  final double spacing;

  const ReasonChipsGrid({
    super.key,
    required this.selected,
    required this.onToggle,
    this.showIcons = false,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final reasons = LogReason.values;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: reasons.map((reason) {
        final isSelected = selected.contains(reason);
        return FilterChip(
          label: Text(reason.displayName),
          selected: isSelected,
          onSelected: (_) => onToggle(reason),
          avatar: showIcons ? Icon(reason.icon, size: 18) : null,
          showCheckmark: false,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}
