# a11y_utils

> **Source:** `lib/utils/a11y_utils.dart`

## Purpose

Provides accessibility utilities for semantic widget support throughout the app. Includes helpers for building consistent semantic labels, wrapping widgets with accessibility metadata (touch targets, screen reader labels), managing focus borders, calculating WCAG color contrast ratios, and announcing messages to screen readers via the `SemanticsService`.

## Dependencies

- `package:flutter/material.dart` — Core Flutter widgets and theming
- `package:flutter/semantics.dart` — `SemanticsService` for screen reader announcements
- `dart:math` — `pow` function for WCAG luminance linearization
- `design_constants.dart` — `A11yConstants`, `ContrastConstants`, `Paddings`, `BorderRadii` design tokens

## Pseudo-Code

---

### Class: SemanticLabelBuilder

Static utility class that constructs semantic label strings with consistent prefix conventions.

#### Method: button(label) → String
```
RETURN A11yConstants.buttonPrefix + label
  // e.g. "Button: Save"
```

#### Method: field(label) → String
```
RETURN A11yConstants.fieldPrefix + label
  // e.g. "Field: Email"
```

#### Method: toggle(label, {enabled = false}) → String
```
SET state = IF enabled THEN "enabled" ELSE "disabled"
RETURN A11yConstants.interactivePrefix + label + ", " + state
  // e.g. "Interactive: Dark Mode, enabled"
```

#### Method: sliderValue(label, value, {unit?}) → String
```
SET suffix = IF unit IS NOT NULL THEN " " + unit ELSE ""
RETURN A11yConstants.fieldPrefix + label + ": " + value.toStringAsFixed(1) + suffix
  // e.g. "Field: Volume: 7.5 dB"
```

#### Method: listItem(title, {subtitle?, index?}) → String
```
SET parts = [title]
IF subtitle IS NOT NULL THEN APPEND subtitle TO parts
IF index IS NOT NULL THEN APPEND "item " + (index + 1) TO parts
RETURN parts JOINED BY ", "
  // e.g. "Log Entry, Morning session, item 3"
```

#### Method: tab(label, {selected = false}) → String
```
SET state = IF selected THEN "selected" ELSE "unselected"
RETURN label + " tab, " + state
```

#### Method: dialog(title) → String
```
RETURN "Dialog: " + title
```

#### Method: bottomSheet(title) → String
```
RETURN "Bottom sheet: " + title
```

#### Method: interactive(label) → String
```
RETURN A11yConstants.interactivePrefix + label
```

#### Method: iconButton(label) → String
```
RETURN A11yConstants.buttonPrefix + label + " button"
```

---

### Class: MinimumTouchTarget (StatelessWidget)

Wraps a child widget to ensure accessibility compliance with minimum touch target sizing.

#### Properties
| Property | Type | Default | Description |
|----------|------|---------|-------------|
| child | Widget | required | The widget to wrap |
| onTap | VoidCallback? | null | Optional tap handler |
| minSize | double | A11yConstants.minimumTouchSize (48) | Minimum width/height in dp |

#### Method: build(context) → Widget
```
RETURN ConstrainedBox with minWidth = minSize, minHeight = minSize
  IF onTap IS NOT NULL
    WRAP child IN InkWell(onTap) centered
  ELSE
    Center the child directly
```

---

### Class: SemanticIcon (StatelessWidget)

Wraps an Icon with explicit `Semantics` label for screen readers.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| icon | IconData | required |
| semanticLabel | String | required |
| color | Color? | null |
| size | double | 24 |

#### Method: build(context) → Widget
```
RETURN Semantics(label = semanticLabel, enabled = true)
  CHILD: Icon(icon, color, size, semanticLabel)
```

---

### Class: SemanticIconButton (StatelessWidget)

Accessible icon button with tooltip, enable/disable state, and semantic metadata.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| icon | IconData | required |
| semanticLabel | String | required |
| onPressed | VoidCallback | required |
| tooltip | String? | null (falls back to semanticLabel) |
| color | Color? | null |
| size | double | 24 |
| padding | double | 8 |
| enabled | bool | true |

#### Method: build(context) → Widget
```
SET tooltipText = tooltip ?? semanticLabel
RETURN Semantics(button = true, enabled, label = semanticLabel, onTap = IF enabled THEN onPressed ELSE null)
  CHILD: Tooltip(message = tooltipText)
    CHILD: IconButton(icon, color, padding, onPressed = IF enabled THEN onPressed ELSE null)
```

---

### Class: SemanticFormField (StatelessWidget)

Wraps a form field with semantic label, optional hint, and error display.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| label | String | required |
| child | Widget | required |
| hint | String? | null |
| errorText | String? | null |

#### Method: build(context) → Widget
```
RETURN Semantics(label, hint, enabled = true)
  CHILD: Column(crossAxisAlignment = start)
    1. Semantics(label = SemanticLabelBuilder.field(label)) wrapping child
    2. IF errorText IS NOT NULL
       THEN Semantics(label = "Error: " + errorText)
         CHILD: Padding(verticalSm)
           Text(errorText, style = labelSmall with error color)
```

---

### Class: SemanticListItem (StatelessWidget)

List item widget with semantic labeling including position context.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| title | String | required |
| index | int | required |
| total | int | required |
| subtitle | String? | null |
| leading / trailing | Widget? | null |
| onTap | VoidCallback? | null |

#### Method: build(context) → Widget
```
SET label = SemanticLabelBuilder.listItem(title, subtitle, index)
RETURN Semantics(label, button = (onTap != null), enabled = true)
  CHILD: ListTile(title, subtitle, leading, trailing, onTap)
```

---

### Class: FocusBorder

Static helper producing `OutlineInputBorder` instances for form field focus states.

#### Method: focused({colorScheme, width = A11yConstants.focusIndicatorWidth}) → OutlineInputBorder
```
RETURN OutlineInputBorder(
  borderSide = colorScheme.primary with given width,
  borderRadius = BorderRadii.md
)
```

#### Method: unfocused({colorScheme, width = 1}) → OutlineInputBorder
```
RETURN OutlineInputBorder(
  borderSide = colorScheme.outline with given width,
  borderRadius = BorderRadii.md
)
```

#### Method: error({colorScheme, width = A11yConstants.focusIndicatorWidth}) → OutlineInputBorder
```
RETURN OutlineInputBorder(
  borderSide = colorScheme.error with given width,
  borderRadius = BorderRadii.md
)
```

---

### Class: ContrastHelper

Static helper for WCAG color contrast calculations.

#### Method: getRelativeLuminance(color) → double
```
SET r = _linearize(color.red / 255)
SET g = _linearize(color.green / 255)
SET b = _linearize(color.blue / 255)
RETURN 0.2126 * r + 0.7152 * g + 0.0722 * b
```

#### Method: _linearize(value) → double (private)
```
IF value <= 0.03928
  RETURN value / 12.92
ELSE
  RETURN ((value + 0.055) / 1.055) ^ 2.0
```

#### Method: getContrastRatio(color1, color2) → double
```
SET l1 = getRelativeLuminance(color1)
SET l2 = getRelativeLuminance(color2)
SET lighter = MAX(l1, l2)
SET darker = MIN(l1, l2)
RETURN (lighter + 0.05) / (darker + 0.05)
```

#### Method: meetsWCAGAA(foreground, background) → bool
```
RETURN getContrastRatio(foreground, background) >= ContrastConstants.minContrastNormalText  // 4.5
```

#### Method: meetsWCAGAAA(foreground, background) → bool
```
RETURN getContrastRatio(foreground, background) >= ContrastConstants.minContrastAAA  // 7.0
```

---

### Class: A11yAnnouncer

Static helper for broadcasting messages to screen readers via `SemanticsService`.

#### Method: announce(context, message, {textDirection?}) → Future<void>
```
CALL SemanticsService.announce(message, textDirection ?? Directionality.of(context))
```

#### Method: announceError(context, errorMessage) → Future<void>
```
CALL announce(context, "Error: " + errorMessage)
```

#### Method: announceSuccess(context, message) → Future<void>
```
CALL announce(context, "Success: " + message)
```

#### Method: announceStatus(context, status) → Future<void>
```
CALL announce(context, status)
```
