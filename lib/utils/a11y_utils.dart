/// Accessibility Utilities for Semantic Widget Support.
///
/// Provides helpers for adding semantic labels, focus management,
/// and keyboard navigation to widgets throughout the app.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'dart:math' show pow;
import 'design_constants.dart';

// ============================================================================
// SEMANTIC LABEL BUILDERS
// ============================================================================

/// Builder for semantic labels with consistent patterns
class SemanticLabelBuilder {
  /// Build label for a button
  static String button(String label) => '${A11yConstants.buttonPrefix}$label';

  /// Build label for a form field
  static String field(String label) => '${A11yConstants.fieldPrefix}$label';

  /// Build label for a toggle/switch
  static String toggle(String label, {bool enabled = false}) {
    final state = enabled ? 'enabled' : 'disabled';
    return '${A11yConstants.interactivePrefix}$label, $state';
  }

  /// Build label for a slider/progress
  static String sliderValue(String label, double value, {String? unit}) {
    final suffix = unit != null ? ' $unit' : '';
    return '${A11yConstants.fieldPrefix}$label: ${value.toStringAsFixed(1)}$suffix';
  }

  /// Build label for a list item
  static String listItem(String title, {String? subtitle, int? index}) {
    final parts = [title];
    if (subtitle != null) parts.add(subtitle);
    if (index != null) parts.add('item ${index + 1}');
    return parts.join(', ');
  }

  /// Build label for a tab
  static String tab(String label, {bool selected = false}) {
    final state = selected ? 'selected' : 'unselected';
    return '$label tab, $state';
  }

  /// Build label for a dialog/modal
  static String dialog(String title) => 'Dialog: $title';

  /// Build label for a bottom sheet
  static String bottomSheet(String title) => 'Bottom sheet: $title';

  /// Build label for an interactive element (generic)
  static String interactive(String label) =>
      '${A11yConstants.interactivePrefix}$label';

  /// Build label for an icon button
  static String iconButton(String label) =>
      '${A11yConstants.buttonPrefix}$label button';
}

// ============================================================================
// SEMANTIC WIDGET WRAPPERS
// ============================================================================

/// Minimum touch target wrapper to ensure accessibility compliance
class MinimumTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minSize;

  const MinimumTouchTarget({
    required this.child,
    this.onTap,
    this.minSize = A11yConstants.minimumTouchSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      child:
          onTap != null
              ? InkWell(onTap: onTap, child: Center(child: child))
              : Center(child: child),
    );
  }
}

/// Wrapper for semantic icon with label
class SemanticIcon extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final Color? color;
  final double size;
  final TextDirection? textDirection;

  const SemanticIcon({
    required this.icon,
    required this.semanticLabel,
    this.color,
    this.size = 24,
    this.textDirection,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      enabled: true,
      child: Icon(icon, color: color, size: size, semanticLabel: semanticLabel),
    );
  }
}

/// Wrapper for semantic icon button with accessibility
class SemanticIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final String? tooltip;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final double padding;
  final bool enabled;

  const SemanticIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.size = 24,
    this.padding = 8,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tooltipText = tooltip ?? semanticLabel;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: enabled ? onPressed : null,
      child: Tooltip(
        message: tooltipText,
        child: IconButton(
          icon: Icon(icon, size: size),
          color: color,
          padding: EdgeInsets.all(padding),
          onPressed: enabled ? onPressed : null,
        ),
      ),
    );
  }
}

/// Wrapper for semantic form field
class SemanticFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final Widget child;

  const SemanticFormField({
    required this.label,
    required this.child,
    this.hint,
    this.errorText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(label: SemanticLabelBuilder.field(label), child: child),
          if (errorText != null)
            Semantics(
              enabled: true,
              label: 'Error: $errorText',
              child: Padding(
                padding: Paddings.verticalSm,
                child: Text(
                  errorText!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wrapper for semantic list items
class SemanticListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int index;
  final int total;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SemanticListItem({
    required this.title,
    required this.index,
    required this.total,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final label = SemanticLabelBuilder.listItem(
      title,
      subtitle: subtitle,
      index: index,
    );

    return Semantics(
      label: label,
      button: onTap != null,
      enabled: true,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

// ============================================================================
// FOCUS MANAGEMENT HELPERS
// ============================================================================

/// Helper for focus border styling
class FocusBorder {
  static OutlineInputBorder focused({
    required ColorScheme colorScheme,
    double width = A11yConstants.focusIndicatorWidth,
  }) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.primary, width: width),
      borderRadius: BorderRadii.md,
    );
  }

  static OutlineInputBorder unfocused({
    required ColorScheme colorScheme,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.outline, width: width),
      borderRadius: BorderRadii.md,
    );
  }

  static OutlineInputBorder error({
    required ColorScheme colorScheme,
    double width = A11yConstants.focusIndicatorWidth,
  }) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.error, width: width),
      borderRadius: BorderRadii.md,
    );
  }
}

// ============================================================================
// COLOR CONTRAST HELPERS
// ============================================================================

/// Helper for WCAG color contrast checking
class ContrastHelper {
  /// Calculate relative luminance of a color (WCAG formula)
  static double getRelativeLuminance(Color color) {
    final r = _linearize(color.red / 255);
    final g = _linearize(color.green / 255);
    final b = _linearize(color.blue / 255);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Linearize color component for contrast calculation
  static double _linearize(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    } else {
      return pow((value + 0.055) / 1.055, 2.0) as double;
    }
  }

  /// Calculate contrast ratio between two colors
  static double getContrastRatio(Color color1, Color color2) {
    final l1 = getRelativeLuminance(color1);
    final l2 = getRelativeLuminance(color2);

    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 < l2 ? l1 : l2;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if two colors meet WCAG AA standard (4.5:1)
  static bool meetsWCAGAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >=
        ContrastConstants.minContrastNormalText;
  }

  /// Check if two colors meet WCAG AAA standard (7:1)
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >=
        ContrastConstants.minContrastAAA;
  }
}

// ============================================================================
// SEMANTIC ANNOUNCEMENT HELPERS
// ============================================================================

/// Helper for announcing messages to screen readers
class A11yAnnouncer {
  /// Announce a change to screen readers
  static Future<void> announce(
    BuildContext context,
    String message, {
    TextDirection? textDirection,
  }) {
    return SemanticsService.announce(
      message,
      textDirection ?? Directionality.of(context),
    );
  }

  /// Announce an error to screen readers
  static Future<void> announceError(BuildContext context, String errorMessage) {
    return announce(context, 'Error: $errorMessage');
  }

  /// Announce a success message
  static Future<void> announceSuccess(BuildContext context, String message) {
    return announce(context, 'Success: $message');
  }

  /// Announce a status change
  static Future<void> announceStatus(BuildContext context, String status) {
    return announce(context, status);
  }
}
