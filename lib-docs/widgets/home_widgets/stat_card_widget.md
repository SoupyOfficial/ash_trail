# stat_card_widget

> **Source:** `lib/widgets/home_widgets/stat_card_widget.dart`

## Purpose
Reusable statistic card used across all home screen widgets. Shows an icon, title, animated value (with fade+scale transition on change), subtitle, and optional trend indicator. Supports tap (haptic light) and long-press (haptic medium) interactions. Also provides `TrendIndicator` (percentage badge with directional icon) and `StatCardRow` (row layout helper for side-by-side cards).

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter/services.dart` — HapticFeedback
- `../../utils/design_constants.dart` — ElevationLevel, BorderRadii, Paddings, Spacing, IconSize, AnimationDuration, AnimationCurves

## Pseudo-Code

### Class: StatCardWidget (StatelessWidget)

**Constructor Parameters:**
- `icon: IconData`
- `title: String`
- `value: String` — main display value
- `subtitle: String?` — optional description
- `trend: Widget?` — optional TrendIndicator
- `onTap: VoidCallback?`
- `onLongPress: VoidCallback?`
- `valueColor: Color?` — override

#### Method: build(context) → Widget
```
RETURN Card(elevation: ElevationLevel.low) → InkWell:
  onTap:
    HapticFeedback.lightImpact()
    onTap?.call()
  onLongPress:
    HapticFeedback.mediumImpact()
    onLongPress?.call()
  borderRadius: BorderRadii.medium
  
  Padding(Paddings.medium) → Column(crossAxis: start):
    ├─ Row:
    │   ├─ Icon(icon, size: IconSize.small, primary color)
    │   ├─ SizedBox(Spacing.small)
    │   └─ Flexible → Text(title, bodySmall, onSurfaceVariant, ellipsis)
    │
    ├─ SizedBox(Spacing.small)
    │
    ├─ AnimatedSwitcher(
    │     duration: AnimationDuration.medium
    │     transitionBuilder: FadeTransition + ScaleTransition(0.8–1.0)
    │   ):
    │   Text(value, key: ValueKey(value), headlineMedium, bold, valueColor ?? onSurface)
    │
    ├─ IF subtitle:
    │   SizedBox(Spacing.extraSmall) + Text(subtitle, bodySmall, onSurfaceVariant)
    │
    └─ IF trend:
        SizedBox(Spacing.small) + trend widget
```

---

### Class: TrendIndicator (StatelessWidget)

**Constructor Parameters:**
- `percentage: double` — trend percentage (+/-)
- `invertColors: bool` — default false (true → up=good green, down=bad red)

#### Method: build(context) → Widget
```
IF percentage == 0 → SizedBox.shrink()

isPositive = percentage > 0
color:
  IF invertColors: positive → tertiary(green), negative → error(red)
  ELSE:            positive → error(red = more usage), negative → tertiary(green = less)

icon = isPositive ? trending_up : trending_down

RETURN Container(
  padding: h6 v2
  borderRadius: BorderRadii.small
  color: color at 0.1 alpha
):
  Row:
    ├─ Icon(icon, size: 12, color)
    ├─ SizedBox(2)
    └─ Text("{±X.X}%", labelSmall, bold, color)
```

---

### Class: StatCardRow (StatelessWidget)

**Constructor Parameters:**
- `children: List<Widget>` — typically 2 StatCardWidgets

#### Method: build(context) → Widget
```
RETURN Row:
  FOR each child (indexed):
    IF not first → SizedBox(width: Spacing.small)
    Expanded(child: child)
```
