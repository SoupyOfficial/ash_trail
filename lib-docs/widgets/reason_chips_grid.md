# reason_chips_grid

> **Source:** `lib/widgets/reason_chips_grid.dart`

## Purpose
A reusable grid layout for LogReason filter/selection chips. Displays all `LogReason` enum values in a fixed-column grid with equal-width, equal-height cells. Supports multi-select toggling with optional icons. Used by quick log, backdate dialog, edit dialog, and create log entry dialog.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `../models/enums.dart` — LogReason enum (with `displayName`, `icon` extensions)

## Pseudo-Code

### Class: ReasonChipsGrid (StatelessWidget)

**Constructor Parameters:**
- `selected: Set<LogReason>` — currently selected reasons
- `onToggle: (LogReason) → void` — callback when a chip is tapped
- `columnsPerRow: int` — default `2`
- `showIcons: bool` — default `false`
- `spacing: double` — default `8.0`

#### Method: build(context) → Widget
```
GET reasons = LogReason.values
SET chipHeight = 52.0 (fixed height for 2-line text)

BUILD rows:
  FOR i = 0 to reasons.length STEP columnsPerRow:
    GET rowReasons = reasons[i..i+columnsPerRow]
    
    BUILD rowChildren:
      FOR each reason in rowReasons:
        IF not first → ADD SizedBox(width: spacing)
        ADD Expanded → _ReasonChipButton(
          reason, isSelected, onTap: onToggle(reason), height, showIcon
        )
    
    IF last row has fewer items:
      PAD with empty SizedBox(height: chipHeight) wrapped in Expanded
    
    ADD Row(children: rowChildren) to rows
    IF not last row → ADD SizedBox(height: spacing)

RETURN Column(crossAxisAlignment: stretch, children: rows)
```

---

### Class: _ReasonChipButton (StatelessWidget, private)

**Constructor Parameters:**
- `reason: LogReason`
- `isSelected: bool`
- `onTap: VoidCallback`
- `height: double`
- `showIcon: bool`

#### Method: build(context) → Widget
```
COMPUTE colors from theme:
  backgroundColor: selected → secondaryContainer, else → surfaceContainerHighest
  foregroundColor: selected → onSecondaryContainer, else → onSurfaceVariant
  borderColor:     selected → outline, else → outlineVariant

RETURN Material(color: bg, borderRadius: 8) → InkWell(onTap, borderRadius: 8):
  └─ Container(height, border, padding: h8 v4):
      └─ Center:
          IF showIcon:
            Row(center):
              ├─ Icon(reason.icon, size: 16, color: fg)
              ├─ SizedBox(width: 4)
              └─ Flexible → Text(reason.displayName, labelMedium, center, 2 lines, ellipsis)
          ELSE:
            Text(reason.displayName, labelMedium, center, 2 lines, ellipsis)
```
