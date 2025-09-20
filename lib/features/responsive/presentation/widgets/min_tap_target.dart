import 'package:flutter/material.dart';

/// A widget that enforces minimum tap target size for accessibility
class MinTapTarget extends StatelessWidget {
  const MinTapTarget({
    super.key,
    required this.child,
    this.minSize = 48.0,
    this.debugLabel,
  });

  /// The child widget to wrap
  final Widget child;

  /// Minimum size for tap targets (defaults to 48px per iOS/Android guidelines)
  final double minSize;

  /// Debug label for testing/debugging
  final String? debugLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
}

/// Extension for wrapping widgets with minimum tap target enforcement
extension MinTapTargetWidget on Widget {
  /// Wrap this widget with minimum tap target constraints
  Widget withMinTapTarget({
    double minSize = 48.0,
    String? debugLabel,
  }) {
    return MinTapTarget(
      minSize: minSize,
      debugLabel: debugLabel,
      child: this,
    );
  }
}

/// A button wrapper that automatically enforces minimum tap targets
class ResponsiveButton extends StatelessWidget {
  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.minTapTarget = 48.0,
    this.padding,
  });

  /// Button press callback
  final VoidCallback? onPressed;

  /// Button content
  final Widget child;

  /// Minimum tap target size
  final double minTapTarget;

  /// Button padding
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return MinTapTarget(
      minSize: minTapTarget,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: padding,
          minimumSize: Size(minTapTarget, minTapTarget),
        ),
        child: child,
      ),
    );
  }
}

/// Icon button with enforced minimum tap target
class ResponsiveIconButton extends StatelessWidget {
  const ResponsiveIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.minTapTarget = 48.0,
    this.tooltip,
  });

  /// Button press callback
  final VoidCallback? onPressed;

  /// Icon to display
  final Widget icon;

  /// Minimum tap target size
  final double minTapTarget;

  /// Tooltip text
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return MinTapTarget(
      minSize: minTapTarget,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        tooltip: tooltip,
        constraints: BoxConstraints(
          minWidth: minTapTarget,
          minHeight: minTapTarget,
        ),
      ),
    );
  }
}
