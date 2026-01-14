/// Widget Standardization Utilities
///
/// Provides helpers for consistent widget alignment, spacing, and centering
/// across the app.

import 'package:flutter/material.dart';
import 'design_constants.dart';

// ============================================================================
// ALIGNMENT HELPERS
// ============================================================================

/// Helper for consistent widget alignment and centering
class AlignmentHelper {
  /// Center widget horizontally
  static Widget centerHorizontal({required Widget child, double? width}) {
    return Center(
      child:
          width != null
              ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width),
                child: child,
              )
              : child,
    );
  }

  /// Center widget vertically
  static Widget centerVertical({required Widget child, double? height}) {
    return SizedBox(height: height, child: Center(child: child));
  }

  /// Center widget both horizontally and vertically
  static Widget center({required Widget child, double? width, double? height}) {
    return SizedBox(width: width, height: height, child: Center(child: child));
  }

  /// Align widget with padding
  static Widget alignWithPadding({
    required Widget child,
    required AlignmentGeometry alignment,
    required EdgeInsets padding,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(padding: padding, child: child),
    );
  }
}

// ============================================================================
// SPACING HELPERS
// ============================================================================

/// Consistent spacing between widgets
class SpacedColumn extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const SpacedColumn({
    required this.children,
    this.spacing = 16,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.min,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}

/// Consistent spacing between horizontal widgets
class SpacedRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const SpacedRow({
    required this.children,
    this.spacing = 16,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}

/// Centered column with consistent spacing
class CenteredSpacedColumn extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double? maxWidth;

  const CenteredSpacedColumn({
    required this.children,
    this.spacing = 16,
    this.maxWidth,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: SpacedColumn(
          spacing: spacing,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}

/// Centered row with consistent spacing
class CenteredSpacedRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double? maxWidth;

  const CenteredSpacedRow({
    required this.children,
    this.spacing = 16,
    this.maxWidth,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: SpacedRow(
          spacing: spacing,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}

// ============================================================================
// PADDED CONTAINERS
// ============================================================================

/// Widget with standard padding applied
class PaddedContainer extends StatelessWidget {
  final Widget child;
  final Spacing padding;
  final bool fillWidth;
  final bool fillHeight;
  final double? minHeight;
  final double? minWidth;

  const PaddedContainer({
    required this.child,
    this.padding = Spacing.lg,
    this.fillWidth = true,
    this.fillHeight = false,
    this.minHeight,
    this.minWidth,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fillWidth ? double.infinity : minWidth,
      height: minHeight,
      padding: EdgeInsets.all(padding.value),
      child: child,
    );
  }
}

/// Widget with responsive padding
class ResponsivePaddedContainer extends StatelessWidget {
  final Widget child;
  final double mobilePadding;
  final double? tabletPadding;
  final double? desktopPadding;
  final bool fillWidth;
  final bool fillHeight;

  const ResponsivePaddedContainer({
    required this.child,
    this.mobilePadding = 16,
    this.tabletPadding = 24,
    this.desktopPadding = 32,
    this.fillWidth = true,
    this.fillHeight = false,
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

    return Container(
      width: fillWidth ? double.infinity : null,
      height: fillHeight ? double.infinity : null,
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

// ============================================================================
// CARD CONTAINERS
// ============================================================================

/// Standard card with consistent styling
class StandardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool filled;

  const StandardCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.filled = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? ElevationLevel.md.value,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadii.md,
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadii.md,
        child: Padding(padding: padding ?? Paddings.lg, child: child),
      ),
    );
  }
}

/// Centered card
class CenteredCard extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final double? elevation;

  const CenteredCard({
    required this.child,
    this.maxWidth = 500,
    this.padding = const EdgeInsets.all(24),
    this.elevation,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: StandardCard(
          padding: padding,
          elevation: elevation,
          child: child,
        ),
      ),
    );
  }
}

// ============================================================================
// FILL & SIZING HELPERS
// ============================================================================

/// Widget that fills available space
class FillContainer extends StatelessWidget {
  final Widget child;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool horizontal;
  final bool vertical;

  const FillContainer({
    required this.child,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.horizontal = true,
    this.vertical = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child:
          horizontal && vertical
              ? Center(child: child)
              : vertical
              ? Align(alignment: Alignment.center, child: child)
              : Align(alignment: Alignment.center, child: child),
    );
  }
}

/// Widget with minimum touch target size (accessibility)
class MinimumTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double minSize;

  const MinimumTouchTarget({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.minSize = A11yConstants.minimumTouchSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Semantics(
        button: true,
        enabled: onTap != null || onLongPress != null,
        child: Container(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ============================================================================
// DIVIDER HELPERS
// ============================================================================

/// Responsive divider with consistent spacing
class ResponsiveDivider extends StatelessWidget {
  final double? height;
  final double? thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;

  const ResponsiveDivider({
    this.height,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? 24,
      thickness: thickness ?? 1,
      color: color,
      indent: indent ?? 0,
      endIndent: endIndent ?? 0,
    );
  }
}

/// Spacing divider (just space, no visual divider)
class SpacingDivider extends StatelessWidget {
  final double height;

  const SpacingDivider({this.height = 16, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

// ============================================================================
// SECTION CONTAINERS
// ============================================================================

/// Standard section with title and content
class StyledSection extends StatelessWidget {
  final String title;
  final Widget content;
  final bool showDivider;
  final double spacing;
  final TextStyle? titleStyle;

  const StyledSection({
    required this.title,
    required this.content,
    this.showDivider = true,
    this.spacing = 12,
    this.titleStyle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              titleStyle ??
              Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: spacing),
        content,
        if (showDivider) ResponsiveDivider(),
      ],
    );
  }
}

// ============================================================================
// SAFE AREA HELPERS
// ============================================================================

/// Safe area with standard padding
class SafePadding extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final double additionalPadding;

  const SafePadding({
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.additionalPadding = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Padding(padding: EdgeInsets.all(additionalPadding), child: child),
    );
  }
}
