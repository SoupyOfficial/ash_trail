# home_widget_wrapper

> **Source:** `lib/widgets/home_widgets/home_widget_wrapper.dart`

## Purpose
Wraps each home screen widget with edit-mode UI overlays: a drag handle for reordering (via `ReorderableDragStartListener`), a remove button with haptic feedback, and an animated container border. Also provides `HomeWidgetEditPadding` for consistent spacing in edit mode.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter/services.dart` — HapticFeedback
- `../../utils/design_constants.dart` — ElevationLevel, BorderRadii, Paddings, Spacing, AnimationDuration

## Pseudo-Code

### Class: HomeWidgetWrapper (StatelessWidget)

**Constructor Parameters:**
- `index: int` — position in the reorderable list
- `isEditing: bool` — whether edit mode is active
- `onRemove: VoidCallback` — remove callback
- `child: Widget` — the actual home widget

#### Method: build(context) → Widget
```
IF not isEditing:
  RETURN child  (no wrapper)

RETURN AnimatedContainer(duration: AnimationDuration.medium):
  decoration: BoxDecoration(
    border: 2px dashed outline color at 0.3 alpha
    borderRadius: BorderRadii.medium
  )
  margin: Paddings.small
  
  Stack:
    ├─ child  (underlying widget)
    │
    ├─ Positioned(top: 4, left: 4):  // drag handle
    │   ReorderableDragStartListener(index):
    │     Container(circle, surface color, shadow):
    │       Icon(drag_handle, onSurfaceVariant)
    │
    └─ Positioned(top: 4, right: 4):  // remove button
        GestureDetector:
          onTap:
            HapticFeedback.mediumImpact()
            onRemove()
          Container(circle, errorContainer color, shadow):
            Icon(close, onErrorContainer, size: 16)
```

---

### Class: HomeWidgetEditPadding (StatelessWidget)

**Constructor Parameters:**
- `isEditing: bool`
- `child: Widget`

#### Method: build(context) → Widget
```
RETURN AnimatedPadding(
  duration: AnimationDuration.medium
  padding: isEditing ? EdgeInsets.only(bottom: 80) : EdgeInsets.zero
  child: child
)
```

> Adds bottom padding in edit mode to keep content visible above FAB.
