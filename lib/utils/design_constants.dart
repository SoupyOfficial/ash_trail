/// Design System Constants & Enums
///
/// Centralized design tokens for consistent UI/UX across the app.
/// Includes spacing, sizing, responsive breakpoints, typography, and a11y constants.

import 'package:flutter/material.dart';

// ============================================================================
// SPACING ENUMS & CONSTANTS
// ============================================================================

/// Standard spacing values used throughout the app
enum Spacing {
  xs(4),
  sm(8),
  md(12),
  lg(16),
  xl(24),
  xxl(32),
  xxxl(48);

  const Spacing(this.value);
  final double value;
}

/// Common padding values as quick accessors
class Paddings {
  static const EdgeInsets none = EdgeInsets.zero;
  static const EdgeInsets xs = EdgeInsets.all(4);
  static const EdgeInsets sm = EdgeInsets.all(8);
  static const EdgeInsets md = EdgeInsets.all(12);
  static const EdgeInsets lg = EdgeInsets.all(16);
  static const EdgeInsets xl = EdgeInsets.all(24);
  static const EdgeInsets xxl = EdgeInsets.all(32);

  // Directional paddings
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: 24);

  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: 24);
}

// ============================================================================
// SIZING ENUMS & CONSTANTS
// ============================================================================

/// Standard icon sizes
enum IconSize {
  sm(16),
  md(24),
  lg(28),
  xl(48),
  xxl(64),
  xxxl(80);

  const IconSize(this.value);
  final double value;
}

/// Standard border radius values
enum BorderRadiusSize {
  sm(8),
  md(12),
  lg(16),
  xl(24);

  const BorderRadiusSize(this.value);
  final double value;

  BorderRadius get borderRadius => BorderRadius.circular(value);
}

/// Common border radius values as quick accessors
class BorderRadii {
  static const BorderRadius none = BorderRadius.zero;
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(24));
}

/// Standard card elevation values
enum ElevationLevel {
  none(0),
  sm(1),
  md(2),
  lg(4),
  xl(8);

  const ElevationLevel(this.value);
  final double value;
}

// ============================================================================
// RESPONSIVE BREAKPOINTS
// ============================================================================

/// Device form factors for responsive design
enum DeviceFormFactor {
  mobile,
  tablet,
  desktop;

  /// Get the form factor for a given width
  static DeviceFormFactor fromWidth(double width) {
    if (width < Breakpoints.tabletBreakpoint) {
      return DeviceFormFactor.mobile;
    } else if (width < Breakpoints.desktopBreakpoint) {
      return DeviceFormFactor.tablet;
    } else {
      return DeviceFormFactor.desktop;
    }
  }
}

/// Responsive breakpoints in logical pixels (dp)
class Breakpoints {
  /// Mobile devices: < 600dp (phones, small tablets)
  static const double mobileMaxWidth = 599;
  static const double mobileSmallMaxWidth = 350;
  static const double mobileLargeMinWidth = 481;

  /// Tablet devices: 600dp - 1199dp
  static const double tabletBreakpoint = 600;
  static const double tabletMaxWidth = 1199;
  static const double tabletLandscapeMinWidth = 800;

  /// Desktop devices: >= 1200dp
  static const double desktopBreakpoint = 1200;
  static const double desktopMaxWidth = 1600;
  static const double wideDesktopMinWidth = 1920;

  /// Common content max width for large screens
  static const double contentMaxWidth = 1200;
}

/// Orientation helper for responsive layouts
enum DeviceOrientation {
  portrait,
  landscape;

  /// Get orientation from a MediaQueryData
  static DeviceOrientation from(MediaQueryData mediaQuery) {
    return mediaQuery.size.height >= mediaQuery.size.width
        ? DeviceOrientation.portrait
        : DeviceOrientation.landscape;
  }
}

// ============================================================================
// RESPONSIVE SIZE HELPERS
// ============================================================================

/// Helper class for responsive sizing and spacing
/// Usage: ResponsiveSize.padding(context, mobile: 8, tablet: 12, desktop: 16)
class ResponsiveSize {
  /// Get responsive value based on device size
  static double responsive({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    tablet ??= mobile;
    desktop ??= tablet;

    if (width < Breakpoints.tabletBreakpoint) {
      return mobile;
    } else if (width < Breakpoints.desktopBreakpoint) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get responsive padding
  static EdgeInsets paddingResponsive({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final value = responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.all(value);
  }

  /// Get responsive padding (all sides)
  static EdgeInsets paddingAll({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return paddingResponsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive padding (horizontal)
  static EdgeInsets paddingHorizontal({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final value = responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.symmetric(horizontal: value);
  }

  /// Get responsive padding (vertical)
  static EdgeInsets paddingVertical({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final value = responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return EdgeInsets.symmetric(vertical: value);
  }

  /// Get responsive icon size
  static double iconSize({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive border radius
  static BorderRadius borderRadius({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final value = responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    return BorderRadius.circular(value);
  }

  /// Get responsive font size
  static double fontSize({
    required BuildContext context,
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get max width for content container
  static double contentWidth({
    required BuildContext context,
    double maxWidth = Breakpoints.contentMaxWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = ResponsiveSize.responsive(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
    );

    final availableWidth = screenWidth - (horizontalPadding * 2);
    return availableWidth > maxWidth ? maxWidth : availableWidth;
  }
}

// ============================================================================
// TYPOGRAPHY CONSTANTS
// ============================================================================

/// Font size scale for responsive typography
class FontSizeScale {
  /// Small text (captions, helpers, labels)
  static const double captionSmall = 10;
  static const double captionMedium = 11;
  static const double captionLarge = 12;

  /// Body text
  static const double bodySmall = 12;
  static const double bodyMedium = 14;
  static const double bodyLarge = 16;

  /// Label text
  static const double labelSmall = 11;
  static const double labelMedium = 12;
  static const double labelLarge = 14;

  /// Headline text
  static const double headlineSmall = 20;
  static const double headlineMedium = 28;
  static const double headlineLarge = 32;

  /// Title text
  static const double titleSmall = 14;
  static const double titleMedium = 16;
  static const double titleLarge = 22;
}

// ============================================================================
// ACCESSIBILITY CONSTANTS
// ============================================================================

/// Accessibility and interaction constants
class A11yConstants {
  /// Minimum touch target size (Material Design recommendation: 48x48 dp)
  static const double minimumTouchSize = 48;

  /// Recommended touch target size (48 dp × 48 dp)
  static const double recommendedTouchSize = 48;

  /// Focus indicator width for keyboard navigation
  static const double focusIndicatorWidth = 2;

  /// Semantic label prefix for interactive elements
  static const String interactivePrefix = 'Interactive: ';

  /// Semantic label prefix for buttons
  static const String buttonPrefix = 'Button: ';

  /// Semantic label prefix for form fields
  static const String fieldPrefix = 'Field: ';

  /// Animation duration for focus transitions (milliseconds)
  static const Duration focusAnimationDuration = Duration(milliseconds: 200);

  /// Color contrast ratio for WCAG AA compliance (4.5:1 for normal text)
  static const double wcagAAContrast = 4.5;

  /// Color contrast ratio for WCAG AAA compliance (7:1 for normal text)
  static const double wcagAAAContrast = 7.0;

  /// Animation durations for semantic interactions
  static const Duration tooltipShowDuration = Duration(milliseconds: 500);
  static const Duration tooltipHideDuration = Duration(milliseconds: 200);
}

// ============================================================================
// ANIMATION CONSTANTS
// ============================================================================

/// Standard animation durations
enum AnimationDuration {
  fast(Duration(milliseconds: 150)),
  normal(Duration(milliseconds: 300)),
  slow(Duration(milliseconds: 500)),
  verySlow(Duration(milliseconds: 1000));

  const AnimationDuration(this.duration);
  final Duration duration;
}

/// Standard animation curves
class AnimationCurves {
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve linear = Curves.linear;
  static const Curve decelerate = Curves.decelerate;
}

// ============================================================================
// COLOR & CONTRAST CONSTANTS
// ============================================================================

/// Color contrast validation helpers
class ContrastConstants {
  /// Minimum contrast ratio for normal text (4.5:1 per WCAG AA)
  static const double minContrastNormalText = 4.5;

  /// Minimum contrast ratio for large text (3:1 per WCAG AA)
  static const double minContrastLargeText = 3.0;

  /// Recommended contrast ratio for AAA compliance (7:1)
  static const double minContrastAAA = 7.0;
}

// ============================================================================
// SCREEN SIZES & DIMENSIONS
// ============================================================================

/// Common device screen sizes for testing and layout
class ScreenSizes {
  // Mobile sizes
  static const smallPhone = Size(360, 640); // iPhone SE
  static const mediumPhone = Size(390, 844); // iPhone 14
  static const largePhone = Size(412, 915); // Pixel 6

  // Tablet sizes
  static const smallTablet = Size(600, 800); // Small tablet
  static const mediumTablet = Size(768, 1024); // iPad
  static const largeTablet = Size(1024, 1366); // iPad Pro

  // Desktop sizes
  static const smallDesktop = Size(1200, 800);
  static const mediumDesktop = Size(1440, 900);
  static const largeDesktop = Size(1920, 1080);
}
