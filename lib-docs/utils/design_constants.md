# design_constants

> **Source:** `lib/utils/design_constants.dart`

## Purpose

Centralized design system tokens for consistent UI/UX across the app. Defines spacing scales, sizing enums, responsive breakpoints, typography scales, accessibility constants, animation presets, color contrast thresholds, and standard screen sizes for testing.

## Dependencies

- `package:flutter/material.dart` — `EdgeInsets`, `BorderRadius`, `Size`, `Curves`, `Duration`, `Color`, `MediaQueryData`

## Pseudo-Code

---

### Enum: Spacing

Standard spacing values used throughout the app.

| Value | Pixels |
|-------|--------|
| xs | 4 |
| sm | 8 |
| md | 12 |
| lg | 16 |
| xl | 24 |
| xxl | 32 |
| xxxl | 48 |

Each enum member exposes a `double value` property.

---

### Class: Paddings

Quick-access `EdgeInsets` constants.

#### Uniform Padding
| Constant | Value |
|----------|-------|
| none | EdgeInsets.zero |
| xs | all(4) |
| sm | all(8) |
| md | all(12) |
| lg | all(16) |
| xl | all(24) |
| xxl | all(32) |

#### Directional Padding
| Constant | Value |
|----------|-------|
| horizontalSm | symmetric(horizontal: 8) |
| horizontalMd | symmetric(horizontal: 12) |
| horizontalLg | symmetric(horizontal: 16) |
| horizontalXl | symmetric(horizontal: 24) |
| verticalSm | symmetric(vertical: 8) |
| verticalMd | symmetric(vertical: 12) |
| verticalLg | symmetric(vertical: 16) |
| verticalXl | symmetric(vertical: 24) |

---

### Enum: IconSize

| Value | Pixels |
|-------|--------|
| sm | 16 |
| md | 24 |
| lg | 28 |
| xl | 48 |
| xxl | 64 |
| xxxl | 80 |

---

### Enum: BorderRadiusSize

| Value | Radius | Accessor |
|-------|--------|----------|
| sm | 8 | `.borderRadius` → `BorderRadius.circular(8)` |
| md | 12 | `.borderRadius` → `BorderRadius.circular(12)` |
| lg | 16 | `.borderRadius` → `BorderRadius.circular(16)` |
| xl | 24 | `.borderRadius` → `BorderRadius.circular(24)` |

---

### Class: BorderRadii

Quick-access `BorderRadius` constants.

| Constant | Value |
|----------|-------|
| none | BorderRadius.zero |
| sm | circular(8) |
| md | circular(12) |
| lg | circular(16) |
| xl | circular(24) |

---

### Enum: ElevationLevel

| Value | Elevation |
|-------|-----------|
| none | 0 |
| sm | 1 |
| md | 2 |
| lg | 4 |
| xl | 8 |

---

### Enum: DeviceFormFactor

Values: `mobile`, `tablet`, `desktop`

#### Static Method: fromWidth(width) → DeviceFormFactor
```
IF width < Breakpoints.tabletBreakpoint (600)
  RETURN mobile
ELSE IF width < Breakpoints.desktopBreakpoint (1200)
  RETURN tablet
ELSE
  RETURN desktop
```

---

### Class: Breakpoints

Responsive breakpoint constants in logical pixels (dp).

| Constant | Value | Description |
|----------|-------|-------------|
| mobileMaxWidth | 599 | Max width for mobile |
| mobileSmallMaxWidth | 350 | Small phones |
| mobileLargeMinWidth | 481 | Large phones |
| tabletBreakpoint | 600 | Tablet starts here |
| tabletMaxWidth | 1199 | Max width for tablet |
| tabletLandscapeMinWidth | 800 | Tablet landscape |
| desktopBreakpoint | 1200 | Desktop starts here |
| desktopMaxWidth | 1600 | Standard desktop max |
| wideDesktopMinWidth | 1920 | Wide/ultrawide monitors |
| contentMaxWidth | 1200 | Max content width on large screens |

---

### Enum: DeviceOrientation

Values: `portrait`, `landscape`

#### Static Method: from(mediaQuery) → DeviceOrientation
```
IF mediaQuery.size.height >= mediaQuery.size.width
  RETURN portrait
ELSE
  RETURN landscape
```

---

### Class: ResponsiveSize

Helper class for computing responsive sizing values from `BuildContext`.

#### Method: responsive({context, mobile, tablet?, desktop?}) → double
```
SET width = MediaQuery.of(context).size.width
SET tablet = tablet ?? mobile
SET desktop = desktop ?? tablet

IF width < Breakpoints.tabletBreakpoint → RETURN mobile
ELSE IF width < Breakpoints.desktopBreakpoint → RETURN tablet
ELSE → RETURN desktop
```

#### Method: paddingResponsive({context, mobile, tablet?, desktop?}) → EdgeInsets
```
SET value = responsive(context, mobile, tablet, desktop)
RETURN EdgeInsets.all(value)
```

#### Method: paddingAll — alias for paddingResponsive

#### Method: paddingHorizontal({context, mobile, tablet?, desktop?}) → EdgeInsets
```
SET value = responsive(...)
RETURN EdgeInsets.symmetric(horizontal: value)
```

#### Method: paddingVertical({context, mobile, tablet?, desktop?}) → EdgeInsets
```
SET value = responsive(...)
RETURN EdgeInsets.symmetric(vertical: value)
```

#### Method: iconSize({context, mobile, tablet?, desktop?}) → double
```
RETURN responsive(...)
```

#### Method: borderRadius({context, mobile, tablet?, desktop?}) → BorderRadius
```
SET value = responsive(...)
RETURN BorderRadius.circular(value)
```

#### Method: fontSize({context, mobile, tablet?, desktop?}) → double
```
RETURN responsive(...)
```

#### Method: contentWidth({context, maxWidth = Breakpoints.contentMaxWidth}) → double
```
SET screenWidth = MediaQuery.of(context).size.width
SET horizontalPadding = responsive(context, mobile: 16, tablet: 24, desktop: 32)
SET availableWidth = screenWidth - (horizontalPadding * 2)
RETURN MIN(availableWidth, maxWidth)
```

---

### Class: FontSizeScale

Static font size constants for responsive typography.

| Category | Constant | Size (dp) |
|----------|----------|-----------|
| Caption | captionSmall | 10 |
| Caption | captionMedium | 11 |
| Caption | captionLarge | 12 |
| Body | bodySmall | 12 |
| Body | bodyMedium | 14 |
| Body | bodyLarge | 16 |
| Label | labelSmall | 11 |
| Label | labelMedium | 12 |
| Label | labelLarge | 14 |
| Headline | headlineSmall | 20 |
| Headline | headlineMedium | 28 |
| Headline | headlineLarge | 32 |
| Title | titleSmall | 14 |
| Title | titleMedium | 16 |
| Title | titleLarge | 22 |

---

### Class: A11yConstants

Accessibility and interaction constants.

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| minimumTouchSize | double | 48 | Min touch target (dp) |
| recommendedTouchSize | double | 48 | Recommended touch target |
| focusIndicatorWidth | double | 2 | Focus ring width |
| interactivePrefix | String | "Interactive: " | Semantic prefix |
| buttonPrefix | String | "Button: " | Semantic prefix |
| fieldPrefix | String | "Field: " | Semantic prefix |
| focusAnimationDuration | Duration | 200ms | Focus transition |
| wcagAAContrast | double | 4.5 | WCAG AA ratio |
| wcagAAAContrast | double | 7.0 | WCAG AAA ratio |
| tooltipShowDuration | Duration | 500ms | Tooltip appear delay |
| tooltipHideDuration | Duration | 200ms | Tooltip dismiss delay |

---

### Enum: AnimationDuration

| Value | Duration |
|-------|----------|
| fast | 150ms |
| normal | 300ms |
| slow | 500ms |
| verySlow | 1000ms |

---

### Class: AnimationCurves

| Constant | Curve |
|----------|-------|
| easeIn | Curves.easeIn |
| easeOut | Curves.easeOut |
| easeInOut | Curves.easeInOut |
| linear | Curves.linear |
| decelerate | Curves.decelerate |

---

### Class: ContrastConstants

| Constant | Value | Description |
|----------|-------|-------------|
| minContrastNormalText | 4.5 | WCAG AA normal text |
| minContrastLargeText | 3.0 | WCAG AA large text |
| minContrastAAA | 7.0 | WCAG AAA compliance |

---

### Class: ScreenSizes

Common device sizes (`Size(width, height)`) for testing and layout.

| Category | Constant | Size |
|----------|----------|------|
| Mobile | smallPhone | 360 × 640 (iPhone SE) |
| Mobile | mediumPhone | 390 × 844 (iPhone 14) |
| Mobile | largePhone | 412 × 915 (Pixel 6) |
| Tablet | smallTablet | 600 × 800 |
| Tablet | mediumTablet | 768 × 1024 (iPad) |
| Tablet | largeTablet | 1024 × 1366 (iPad Pro) |
| Desktop | smallDesktop | 1200 × 800 |
| Desktop | mediumDesktop | 1440 × 900 |
| Desktop | largeDesktop | 1920 × 1080 |
