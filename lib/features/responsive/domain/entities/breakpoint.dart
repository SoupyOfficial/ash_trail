import 'package:flutter/material.dart';

/// Represents the current screen breakpoint classification
enum Breakpoint {
  /// Mobile portrait < 600dp
  mobile,

  /// Mobile landscape or small tablet 600-839dp
  tablet,

  /// Large tablet or desktop >= 840dp
  desktop;

  /// Determine breakpoint from screen width
  static Breakpoint fromWidth(double width) {
    if (width >= 840) return Breakpoint.desktop;
    if (width >= 600) return Breakpoint.tablet;
    return Breakpoint.mobile;
  }

  /// Get breakpoint from MediaQuery size
  static Breakpoint fromContext(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return fromWidth(size.width);
  }

  /// Whether this breakpoint represents a wide layout
  bool get isWide => this == Breakpoint.desktop;

  /// Whether this breakpoint represents a compact layout
  bool get isCompact => this == Breakpoint.mobile;

  /// Whether this breakpoint supports dual-pane layouts
  bool get supportsDualPane => isWide;

  /// Whether this breakpoint should use navigation rail
  bool get useNavigationRail => isWide;

  /// Whether this breakpoint should use bottom navigation
  bool get useBottomNavigation => !useNavigationRail;
}
