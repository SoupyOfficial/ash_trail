import 'package:flutter/material.dart';
import 'breakpoint.dart';

/// Configuration for responsive layout behavior
class LayoutConfig {
  const LayoutConfig({
    this.minimumTapTarget = 48.0,
    this.dualPaneBreakpoint = 840.0,
    this.compactMaxWidth = 600.0,
    this.contentMaxWidth = 1200.0,
    this.padding = const EdgeInsets.all(16.0),
    this.compactPadding = const EdgeInsets.all(12.0),
    this.gutter = 16.0,
  });

  /// Minimum touch target size in logical pixels
  final double minimumTapTarget;

  /// Width threshold for dual-pane layouts
  final double dualPaneBreakpoint;

  /// Maximum width for compact layouts
  final double compactMaxWidth;

  /// Maximum content width for centered layouts
  final double contentMaxWidth;

  /// Default padding for normal layouts
  final EdgeInsets padding;

  /// Padding for compact layouts
  final EdgeInsets compactPadding;

  /// Spacing between layout elements
  final double gutter;

  /// Get appropriate padding for current breakpoint
  EdgeInsets paddingFor(Breakpoint breakpoint) {
    return breakpoint.isCompact ? compactPadding : padding;
  }

  /// Check if width supports dual-pane layout
  bool supportsDualPane(double width) {
    return width >= dualPaneBreakpoint;
  }

  /// Get constrained content width
  double constrainContentWidth(double screenWidth) {
    return screenWidth > contentMaxWidth ? contentMaxWidth : screenWidth;
  }
}
