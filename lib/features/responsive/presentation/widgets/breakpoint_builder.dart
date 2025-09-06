import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/breakpoint.dart';
import '../providers/layout_provider.dart';

/// A widget that rebuilds when the screen breakpoint changes
/// and provides breakpoint context to descendant widgets
class BreakpointBuilder extends ConsumerWidget {
  const BreakpointBuilder({
    super.key,
    required this.builder,
  });

  /// Builder function that receives the current breakpoint
  final Widget Function(
      BuildContext context, Breakpoint breakpoint, Widget? child) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final breakpoint = Breakpoint.fromWidth(size.width);

    // Override providers with current values
    return ProviderScope(
      overrides: [
        breakpointProvider.overrideWithValue(breakpoint),
        screenSizeProvider.overrideWithValue(size),
      ],
      child: Builder(
        builder: (context) => builder(context, breakpoint, null),
      ),
    );
  }
}

/// A simplified version that just provides breakpoint without rebuild optimization
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Widget to show on mobile breakpoint
  final Widget mobile;

  /// Widget to show on tablet breakpoint (defaults to mobile if not provided)
  final Widget? tablet;

  /// Widget to show on desktop breakpoint (defaults to tablet or mobile if not provided)
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final breakpoint = Breakpoint.fromContext(context);

    return switch (breakpoint) {
      Breakpoint.mobile => mobile,
      Breakpoint.tablet => tablet ?? mobile,
      Breakpoint.desktop => desktop ?? tablet ?? mobile,
    };
  }
}

/// Extension to easily access breakpoint from BuildContext
extension BreakpointContext on BuildContext {
  /// Get current breakpoint
  Breakpoint get breakpoint => Breakpoint.fromContext(this);

  /// Whether current breakpoint is mobile
  bool get isMobile => breakpoint == Breakpoint.mobile;

  /// Whether current breakpoint is tablet
  bool get isTablet => breakpoint == Breakpoint.tablet;

  /// Whether current breakpoint is desktop
  bool get isDesktop => breakpoint == Breakpoint.desktop;

  /// Whether current breakpoint supports wide layouts
  bool get isWideLayout => breakpoint.isWide;

  /// Whether current breakpoint is compact
  bool get isCompactLayout => breakpoint.isCompact;
}
