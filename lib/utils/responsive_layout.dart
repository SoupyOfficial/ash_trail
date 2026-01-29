/// Responsive Layout Utilities
///
/// Provides widgets and helpers for building responsive layouts that adapt
/// to mobile, tablet, and desktop form factors.

import 'package:flutter/material.dart';
import 'design_constants.dart';

// ============================================================================
// RESPONSIVE LAYOUT BUILDERS
// ============================================================================

/// Responsive layout that adjusts based on screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < Breakpoints.tabletBreakpoint) {
          return mobile;
        } else if (width < Breakpoints.desktopBreakpoint) {
          return tablet ?? mobile;
        } else {
          return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Responsive widget builder with MediaQuery context
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceFormFactor formFactor)
  builder;

  const ResponsiveBuilder({required this.builder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final formFactor = DeviceFormFactor.fromWidth(width);

    return builder(context, formFactor);
  }
}

/// Orientation-aware responsive builder
class OrientationAwareBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    DeviceFormFactor formFactor,
    DeviceOrientation orientation,
  )
  builder;

  const OrientationAwareBuilder({required this.builder, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final formFactor = DeviceFormFactor.fromWidth(width);
    final orientation = DeviceOrientation.from(mediaQuery);

    return builder(context, formFactor, orientation);
  }
}

// ============================================================================
// RESPONSIVE CONTAINERS
// ============================================================================

/// Responsive padding container
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobilePadding;
  final double? tabletPadding;
  final double? desktopPadding;
  final bool symmetrical;

  const ResponsivePadding({
    required this.child,
    this.mobilePadding = 16,
    this.tabletPadding = 24,
    this.desktopPadding = 32,
    this.symmetrical = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveSize.responsive(
      context: context,
      mobile: mobilePadding ?? 16,
      tablet: tabletPadding ?? 24,
      desktop: desktopPadding ?? 32,
    );

    return symmetrical
        ? Padding(padding: EdgeInsets.all(padding), child: child)
        : Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: child,
        );
  }
}

/// Responsive width container with max width constraint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveContainer({
    required this.child,
    this.maxWidth = Breakpoints.contentMaxWidth,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final containerWidth = ResponsiveSize.contentWidth(
      context: context,
      maxWidth: maxWidth ?? 1200,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: containerWidth),
        child: child,
      ),
    );
  }
}

/// Responsive grid-like layout that adapts column count
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double? childAspectRatio;
  final double? mobileAspectRatio;
  final double? tabletAspectRatio;
  final double? desktopAspectRatio;

  const ResponsiveGrid({
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
    this.childAspectRatio,
    this.mobileAspectRatio,
    this.tabletAspectRatio,
    this.desktopAspectRatio,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, formFactor) {
        final columns = switch (formFactor) {
          DeviceFormFactor.mobile => mobileColumns,
          DeviceFormFactor.tablet => tabletColumns,
          DeviceFormFactor.desktop => desktopColumns,
        };

        final aspectRatio = switch (formFactor) {
          DeviceFormFactor.mobile => mobileAspectRatio ?? childAspectRatio ?? 1.0,
          DeviceFormFactor.tablet => tabletAspectRatio ?? childAspectRatio ?? 1.0,
          DeviceFormFactor.desktop => desktopAspectRatio ?? childAspectRatio ?? 1.0,
        };

        return GridView.count(
          crossAxisCount: columns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

// ============================================================================
// RESPONSIVE SPACING WIDGETS
// ============================================================================

/// Responsive horizontal spacing
class ResponsiveGap extends StatelessWidget {
  final double mobile;
  final double? tablet;
  final double? desktop;

  const ResponsiveGap({
    required this.mobile,
    this.tablet,
    this.desktop,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gap = ResponsiveSize.responsive(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );

    return SizedBox(height: gap);
  }
}

/// Responsive vertical spacing
class ResponsiveVerticalGap extends StatelessWidget {
  final double mobile;
  final double? tablet;
  final double? desktop;

  const ResponsiveVerticalGap({
    required this.mobile,
    this.tablet,
    this.desktop,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gap = ResponsiveSize.responsive(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );

    return SizedBox(height: gap);
  }
}

/// Responsive horizontal spacing
class ResponsiveHorizontalGap extends StatelessWidget {
  final double mobile;
  final double? tablet;
  final double? desktop;

  const ResponsiveHorizontalGap({
    required this.mobile,
    this.tablet,
    this.desktop,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gap = ResponsiveSize.responsive(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );

    return SizedBox(width: gap);
  }
}

// ============================================================================
// RESPONSIVE VISIBILITY
// ============================================================================

/// Hide widget below/above breakpoint
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visible;
  final bool hiddenMobile;
  final bool hiddenTablet;
  final bool hiddenDesktop;
  final Widget? replacement;

  const ResponsiveVisibility({
    required this.child,
    this.visible = true,
    this.hiddenMobile = false,
    this.hiddenTablet = false,
    this.hiddenDesktop = false,
    this.replacement,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return replacement ?? const SizedBox.shrink();
    }

    return ResponsiveBuilder(
      builder: (context, formFactor) {
        final isHidden = switch (formFactor) {
          DeviceFormFactor.mobile => hiddenMobile,
          DeviceFormFactor.tablet => hiddenTablet,
          DeviceFormFactor.desktop => hiddenDesktop,
        };

        return isHidden ? (replacement ?? const SizedBox.shrink()) : child;
      },
    );
  }
}

/// Show widget only on specific breakpoint
class VisibleOnBreakpoint extends StatelessWidget {
  final Widget child;
  final bool visibleMobile;
  final bool visibleTablet;
  final bool visibleDesktop;
  final Widget? replacement;

  const VisibleOnBreakpoint({
    required this.child,
    this.visibleMobile = true,
    this.visibleTablet = true,
    this.visibleDesktop = true,
    this.replacement,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, formFactor) {
        final isVisible = switch (formFactor) {
          DeviceFormFactor.mobile => visibleMobile,
          DeviceFormFactor.tablet => visibleTablet,
          DeviceFormFactor.desktop => visibleDesktop,
        };

        return isVisible ? child : (replacement ?? const SizedBox.shrink());
      },
    );
  }
}

// ============================================================================
// RESPONSIVE TEXT
// ============================================================================

/// Text widget that scales based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final double mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  final TextStyle? baseStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    required this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.baseStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveSize.fontSize(
      context: context,
      mobile: mobileSize,
      tablet: tabletSize ?? mobileSize,
      desktop: desktopSize ?? tabletSize ?? mobileSize,
    );

    return Text(
      text,
      style: (baseStyle ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// ============================================================================
// RESPONSIVE SLIVER HELPERS
// ============================================================================

/// Responsive sliver padding for CustomScrollView
class ResponsiveSliverPadding extends StatelessWidget {
  final Widget sliver;
  final double mobilePadding;
  final double? tabletPadding;
  final double? desktopPadding;

  const ResponsiveSliverPadding({
    required this.sliver,
    this.mobilePadding = 16,
    this.tabletPadding,
    this.desktopPadding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveSize.responsive(
      context: context,
      mobile: mobilePadding,
      tablet: tabletPadding ?? mobilePadding,
      desktop: desktopPadding ?? tabletPadding ?? mobilePadding,
    );

    return SliverPadding(padding: EdgeInsets.all(padding), sliver: sliver);
  }
}

// ============================================================================
// ADAPTIVE NAVIGATION
// ============================================================================

/// Adaptive navigation that shows different layouts on different breakpoints
class AdaptiveNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String? title;

  const AdaptiveNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, formFactor) {
        return switch (formFactor) {
          DeviceFormFactor.mobile => _buildBottomNavigation(),
          DeviceFormFactor.tablet => _buildNavigationRail(),
          DeviceFormFactor.desktop => _buildNavigationRail(),
        };
      },
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      items:
          items
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ),
              )
              .toList(),
      currentIndex: selectedIndex,
      onTap: onItemSelected,
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      destinations:
          items
              .map(
                (item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
              )
              .toList(),
    );
  }
}

/// Navigation item for adaptive navigation
class NavigationItem {
  final IconData icon;
  final String label;
  final Widget destination;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.destination,
  });
}

// ============================================================================
// RESPONSIVE DIALOGS
// ============================================================================

/// Show adaptive dialog based on screen size
class AdaptiveDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool useMobileLayout;

  const AdaptiveDialog({
    required this.title,
    required this.content,
    this.actions,
    this.useMobileLayout = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, formFactor) {
        final useBottomSheet = formFactor == DeviceFormFactor.mobile;

        if (useBottomSheet) {
          return _buildBottomSheetContent();
        } else {
          return _buildDialogContent();
        }
      },
    );
  }

  Widget _buildDialogContent() {
    return AlertDialog(title: Text(title), content: content, actions: actions);
  }

  Widget _buildBottomSheetContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: Paddings.lg,
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(child: SingleChildScrollView(child: content)),
        if (actions != null)
          Padding(padding: Paddings.lg, child: Row(children: actions!)),
      ],
    );
  }
}
