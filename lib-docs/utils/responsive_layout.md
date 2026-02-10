# responsive_layout

> **Source:** `lib/utils/responsive_layout.dart`

## Purpose

Provides a comprehensive set of widgets and helpers for building responsive layouts that adapt to mobile, tablet, and desktop form factors. Includes layout builders, responsive containers/grids, spacing widgets, visibility controls, responsive text, sliver helpers, adaptive navigation, and adaptive dialogs.

## Dependencies

- `package:flutter/material.dart` — Core Flutter widgets, `LayoutBuilder`, `MediaQuery`, `GridView`, `NavigationRail`, `BottomNavigationBar`, etc.
- `design_constants.dart` — `Breakpoints`, `DeviceFormFactor`, `DeviceOrientation`, `ResponsiveSize`, `Paddings`

## Pseudo-Code

---

### Class: ResponsiveLayout (StatelessWidget)

Renders different widgets based on screen width using `LayoutBuilder`.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| mobile | Widget | required |
| tablet | Widget? | null |
| desktop | Widget? | null |

#### Method: build(context) → Widget
```
RETURN LayoutBuilder
  SET width = constraints.maxWidth

  IF width < Breakpoints.tabletBreakpoint (600)
    RETURN mobile
  ELSE IF width < Breakpoints.desktopBreakpoint (1200)
    RETURN tablet ?? mobile
  ELSE
    RETURN desktop ?? tablet ?? mobile
```

---

### Class: ResponsiveBuilder (StatelessWidget)

Provides a builder callback with the resolved `DeviceFormFactor` from `MediaQuery`.

#### Properties
| Property | Type |
|----------|------|
| builder | Function(BuildContext, DeviceFormFactor) → Widget |

#### Method: build(context) → Widget
```
SET width = MediaQuery.of(context).size.width
SET formFactor = DeviceFormFactor.fromWidth(width)
RETURN builder(context, formFactor)
```

---

### Class: OrientationAwareBuilder (StatelessWidget)

Builder that provides both form factor and orientation.

#### Method: build(context) → Widget
```
SET mediaQuery = MediaQuery.of(context)
SET width = mediaQuery.size.width
SET formFactor = DeviceFormFactor.fromWidth(width)
SET orientation = DeviceOrientation.from(mediaQuery)
RETURN builder(context, formFactor, orientation)
```

---

### Class: ResponsivePadding (StatelessWidget)

Applies responsive padding that scales with screen size.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| mobilePadding | double? | 16 |
| tabletPadding | double? | 24 |
| desktopPadding | double? | 32 |
| symmetrical | bool | true |

#### Method: build(context) → Widget
```
SET padding = ResponsiveSize.responsive(context, mobile, tablet, desktop)

IF symmetrical
  RETURN Padding(all: padding) wrapping child
ELSE
  RETURN Padding(horizontal: padding) wrapping child
```

---

### Class: ResponsiveContainer (StatelessWidget)

Width-constrained container centered on screen, useful for constraining content width on large screens.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| maxWidth | double? | Breakpoints.contentMaxWidth (1200) |

#### Method: build(context) → Widget
```
SET containerWidth = ResponsiveSize.contentWidth(context, maxWidth)
RETURN Center → ConstrainedBox(maxWidth: containerWidth) → child
```

---

### Class: ResponsiveGrid (StatelessWidget)

Grid layout that adapts column count per form factor.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| children | List\<Widget\> | required |
| mobileColumns | int | 1 |
| tabletColumns | int | 2 |
| desktopColumns | int | 3 |
| spacing | double | 16 |
| childAspectRatio | double? | null |
| mobileAspectRatio / tabletAspectRatio / desktopAspectRatio | double? | null |

#### Method: build(context) → Widget
```
USE ResponsiveBuilder to get formFactor

SET columns = SWITCH formFactor
  mobile  → mobileColumns
  tablet  → tabletColumns
  desktop → desktopColumns

SET aspectRatio = SWITCH formFactor
  mobile  → mobileAspectRatio ?? childAspectRatio ?? 1.0
  tablet  → tabletAspectRatio ?? childAspectRatio ?? 1.0
  desktop → desktopAspectRatio ?? childAspectRatio ?? 1.0

RETURN GridView.count(
  crossAxisCount: columns,
  mainAxisSpacing: spacing,
  crossAxisSpacing: spacing,
  childAspectRatio: aspectRatio,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics,
  children: children
)
```

---

### Class: ResponsiveGap (StatelessWidget)

Vertical gap that scales with screen size.

```
SET gap = ResponsiveSize.responsive(context, mobile, tablet, desktop)
RETURN SizedBox(height: gap)
```

---

### Class: ResponsiveVerticalGap (StatelessWidget)

Same as `ResponsiveGap` — vertical spacing that scales.

---

### Class: ResponsiveHorizontalGap (StatelessWidget)

Horizontal spacing that scales with screen size.

```
SET gap = ResponsiveSize.responsive(context, mobile, tablet, desktop)
RETURN SizedBox(width: gap)
```

---

### Class: ResponsiveVisibility (StatelessWidget)

Conditionally hides a widget based on form factor.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| visible | bool | true |
| hiddenMobile | bool | false |
| hiddenTablet | bool | false |
| hiddenDesktop | bool | false |
| replacement | Widget? | null |

#### Method: build(context) → Widget
```
IF NOT visible
  RETURN replacement ?? SizedBox.shrink()

USE ResponsiveBuilder to get formFactor
SET isHidden = SWITCH formFactor
  mobile  → hiddenMobile
  tablet  → hiddenTablet
  desktop → hiddenDesktop

IF isHidden
  RETURN replacement ?? SizedBox.shrink()
ELSE
  RETURN child
```

---

### Class: VisibleOnBreakpoint (StatelessWidget)

Shows a widget only on specified breakpoints (inverse of `ResponsiveVisibility`).

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| visibleMobile | bool | true |
| visibleTablet | bool | true |
| visibleDesktop | bool | true |
| replacement | Widget? | null |

#### Method: build(context) → Widget
```
USE ResponsiveBuilder to get formFactor
SET isVisible = SWITCH formFactor
  mobile  → visibleMobile
  tablet  → visibleTablet
  desktop → visibleDesktop

RETURN isVisible ? child : (replacement ?? SizedBox.shrink())
```

---

### Class: ResponsiveText (StatelessWidget)

Text widget with font size that scales across breakpoints.

#### Properties
| Property | Type |
|----------|------|
| text | String |
| mobileSize | double (required) |
| tabletSize / desktopSize | double? |
| baseStyle | TextStyle? |
| textAlign | TextAlign? |
| maxLines | int? |
| overflow | TextOverflow? |

#### Method: build(context) → Widget
```
SET fontSize = ResponsiveSize.fontSize(context, mobileSize, tabletSize, desktopSize)
RETURN Text(text, style = (baseStyle ?? TextStyle()).copyWith(fontSize), textAlign, maxLines, overflow)
```

---

### Class: ResponsiveSliverPadding (StatelessWidget)

Responsive padding wrapper for use inside `CustomScrollView` slivers.

```
SET padding = ResponsiveSize.responsive(context, mobilePadding, tabletPadding, desktopPadding)
RETURN SliverPadding(padding: EdgeInsets.all(padding), sliver: sliver)
```

---

### Class: NavigationItem

Data class for adaptive navigation items.

| Property | Type |
|----------|------|
| icon | IconData |
| label | String |
| destination | Widget |

---

### Class: AdaptiveNavigation (StatelessWidget)

Navigation that renders as `BottomNavigationBar` on mobile or `NavigationRail` on tablet/desktop.

#### Properties
| Property | Type |
|----------|------|
| items | List\<NavigationItem\> |
| selectedIndex | int |
| onItemSelected | Function(int) |
| title | String? |

#### Method: build(context) → Widget
```
USE ResponsiveBuilder to get formFactor
SWITCH formFactor
  mobile  → _buildBottomNavigation()
  tablet  → _buildNavigationRail()
  desktop → _buildNavigationRail()
```

#### Method: _buildBottomNavigation() → Widget
```
RETURN BottomNavigationBar(
  items: items.map → BottomNavigationBarItem(icon, label),
  currentIndex: selectedIndex,
  onTap: onItemSelected
)
```

#### Method: _buildNavigationRail() → Widget
```
RETURN NavigationRail(
  selectedIndex: selectedIndex,
  onDestinationSelected: onItemSelected,
  destinations: items.map → NavigationRailDestination(icon, label)
)
```

---

### Class: AdaptiveDialog (StatelessWidget)

Dialog that renders as a bottom sheet on mobile or as an `AlertDialog` on tablet/desktop.

#### Properties
| Property | Type |
|----------|------|
| title | String |
| content | Widget |
| actions | List\<Widget\>? |
| useMobileLayout | bool (default false) |

#### Method: build(context) → Widget
```
USE ResponsiveBuilder to get formFactor
IF formFactor == mobile
  RETURN _buildBottomSheetContent()
ELSE
  RETURN _buildDialogContent()
```

#### Method: _buildDialogContent() → Widget
```
RETURN AlertDialog(title: Text(title), content, actions)
```

#### Method: _buildBottomSheetContent() → Widget
```
RETURN Column(mainAxisSize: min)
  1. Padding(lg) → Text(title, bold, 18pt)
  2. Flexible → SingleChildScrollView → content
  3. IF actions IS NOT NULL
     Padding(lg) → Row(actions)
```
