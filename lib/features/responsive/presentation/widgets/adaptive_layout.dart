import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/breakpoint.dart';
import '../providers/layout_provider.dart';
import 'breakpoint_builder.dart';

/// Adaptive layout widget that provides different layouts based on screen size
class AdaptiveLayout extends ConsumerWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.breakpoints,
  });

  /// Layout for mobile screens
  final Widget mobile;

  /// Layout for tablet screens (defaults to mobile if not provided)
  final Widget? tablet;

  /// Layout for desktop screens (defaults to tablet or mobile if not provided)
  final Widget? desktop;

  /// Custom breakpoint overrides
  final Map<Breakpoint, Widget>? breakpoints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BreakpointBuilder(
      builder: (context, breakpoint, _) {
        // Use custom breakpoints if provided
        if (breakpoints != null && breakpoints!.containsKey(breakpoint)) {
          return breakpoints![breakpoint]!;
        }

        // Default breakpoint behavior
        return switch (breakpoint) {
          Breakpoint.mobile => mobile,
          Breakpoint.tablet => tablet ?? mobile,
          Breakpoint.desktop => desktop ?? tablet ?? mobile,
        };
      },
    );
  }
}

/// Dual-pane layout for tablet and desktop
class DualPaneLayout extends ConsumerWidget {
  const DualPaneLayout({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
    this.divider,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Primary (left/top) pane content
  final Widget primary;

  /// Secondary (right/bottom) pane content
  final Widget secondary;

  /// Flex ratio for primary pane
  final int primaryFlex;

  /// Flex ratio for secondary pane
  final int secondaryFlex;

  /// Optional divider between panes
  final Widget? divider;

  /// Cross axis alignment for the row/column
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = ref.watch(layoutStateProvider);

    // Only show dual pane on wide layouts
    if (!layoutState.supportsDualPane) {
      return primary;
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Expanded(
          flex: primaryFlex,
          child: primary,
        ),
        if (divider != null) divider!,
        Expanded(
          flex: secondaryFlex,
          child: secondary,
        ),
      ],
    );
  }
}

/// Responsive container that constrains content width on wide screens
class ResponsiveContainer extends ConsumerWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
    this.alignment = Alignment.topCenter,
  });

  /// Child widget to contain
  final Widget child;

  /// Maximum content width (defaults to layout config value)
  final double? maxWidth;

  /// Container padding
  final EdgeInsets? padding;

  /// Container margin
  final EdgeInsets? margin;

  /// Container alignment
  final Alignment alignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutState = ref.watch(layoutStateProvider);
    final effectiveMaxWidth = maxWidth ?? layoutState.config.contentMaxWidth;
    final effectivePadding = padding ?? layoutState.padding;

    return Container(
      alignment: alignment,
      margin: margin,
      padding: effectivePadding,
      constraints: BoxConstraints(
        maxWidth: effectiveMaxWidth,
      ),
      child: child,
    );
  }
}

/// Grid layout that adapts columns based on screen size
class ResponsiveGrid extends ConsumerWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  /// Grid items
  final List<Widget> children;

  /// Number of columns on mobile
  final int mobileColumns;

  /// Number of columns on tablet
  final int tabletColumns;

  /// Number of columns on desktop
  final int desktopColumns;

  /// Horizontal spacing between items
  final double spacing;

  /// Vertical spacing between rows
  final double runSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakpoint = ref.watch(breakpointProvider);

    final columns = switch (breakpoint) {
      Breakpoint.mobile => mobileColumns,
      Breakpoint.tablet => tabletColumns,
      Breakpoint.desktop => desktopColumns,
    };

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width:
              (MediaQuery.sizeOf(context).width - (spacing * (columns - 1))) /
                  columns,
          child: child,
        );
      }).toList(),
    );
  }
}
