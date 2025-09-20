import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/breakpoint.dart';
import '../providers/layout_provider.dart';

/// Provides responsive padding based on current breakpoint
class ResponsivePadding extends ConsumerWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Child widget to wrap
  final Widget child;

  /// Padding for mobile breakpoint
  final EdgeInsets? mobile;

  /// Padding for tablet breakpoint (defaults to mobile if not provided)
  final EdgeInsets? tablet;

  /// Padding for desktop breakpoint (defaults to tablet or mobile if not provided)
  final EdgeInsets? desktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakpoint = ref.watch(breakpointProvider);
    final layoutState = ref.watch(layoutStateProvider);

    final padding = switch (breakpoint) {
      Breakpoint.mobile => mobile ?? layoutState.config.compactPadding,
      Breakpoint.tablet => tablet ?? mobile ?? layoutState.config.padding,
      Breakpoint.desktop =>
        desktop ?? tablet ?? mobile ?? layoutState.config.padding,
    };

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Provides responsive margin based on current breakpoint
class ResponsiveMargin extends ConsumerWidget {
  const ResponsiveMargin({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Child widget to wrap
  final Widget child;

  /// Margin for mobile breakpoint
  final EdgeInsets? mobile;

  /// Margin for tablet breakpoint
  final EdgeInsets? tablet;

  /// Margin for desktop breakpoint
  final EdgeInsets? desktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakpoint = ref.watch(breakpointProvider);

    final margin = switch (breakpoint) {
      Breakpoint.mobile => mobile ?? EdgeInsets.zero,
      Breakpoint.tablet => tablet ?? mobile ?? EdgeInsets.zero,
      Breakpoint.desktop => desktop ?? tablet ?? mobile ?? EdgeInsets.zero,
    };

    return Container(
      margin: margin,
      child: child,
    );
  }
}

/// Provides responsive spacing values
class ResponsiveSpacing {
  const ResponsiveSpacing._();

  /// Get spacing value based on breakpoint
  static double spacing(
    Breakpoint breakpoint, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    return switch (breakpoint) {
      Breakpoint.mobile => mobile,
      Breakpoint.tablet => tablet,
      Breakpoint.desktop => desktop,
    };
  }

  /// Small spacing values
  static double small(Breakpoint breakpoint) => spacing(
        breakpoint,
        mobile: 4.0,
        tablet: 6.0,
        desktop: 8.0,
      );

  /// Medium spacing values
  static double medium(Breakpoint breakpoint) => spacing(
        breakpoint,
        mobile: 8.0,
        tablet: 12.0,
        desktop: 16.0,
      );

  /// Large spacing values
  static double large(Breakpoint breakpoint) => spacing(
        breakpoint,
        mobile: 16.0,
        tablet: 20.0,
        desktop: 24.0,
      );

  /// Extra large spacing values
  static double extraLarge(Breakpoint breakpoint) => spacing(
        breakpoint,
        mobile: 24.0,
        tablet: 32.0,
        desktop: 40.0,
      );
}

/// SizedBox with responsive spacing
class ResponsiveGap extends ConsumerWidget {
  const ResponsiveGap({
    super.key,
    this.mobile = 8.0,
    this.tablet,
    this.desktop,
    this.axis = Axis.vertical,
  });

  /// Gap size for mobile
  final double mobile;

  /// Gap size for tablet (defaults to mobile if not provided)
  final double? tablet;

  /// Gap size for desktop (defaults to tablet or mobile if not provided)
  final double? desktop;

  /// Whether gap is vertical or horizontal
  final Axis axis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakpoint = ref.watch(breakpointProvider);

    final size = switch (breakpoint) {
      Breakpoint.mobile => mobile,
      Breakpoint.tablet => tablet ?? mobile,
      Breakpoint.desktop => desktop ?? tablet ?? mobile,
    };

    return axis == Axis.vertical
        ? SizedBox(height: size)
        : SizedBox(width: size);
  }
}
