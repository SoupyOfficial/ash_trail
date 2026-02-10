# widget_picker_sheet

> **Source:** `lib/widgets/home_widgets/widget_picker_sheet.dart`

## Purpose
Bottom sheet for adding home screen widgets. Presents all available widgets grouped by category, shows which are already added ("Added" badge), and adds selected widgets to the user's home layout with haptic feedback and a confirmation SnackBar. Rendered as a `DraggableScrollableSheet`.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter/services.dart` — HapticFeedback
- `package:flutter_riverpod/flutter_riverpod.dart` — ConsumerWidget
- `../../providers/home_layout_provider.dart` — homeLayoutConfigProvider
- `../../utils/design_constants.dart` — ElevationLevel, BorderRadii, Paddings, Spacing, IconSize
- `./widget_catalog.dart` — WidgetCatalog, WidgetCategory, HomeWidgetType, WidgetCatalogEntry

## Pseudo-Code

### Class: WidgetPickerSheet (ConsumerWidget)

#### Method: build(context, ref) → Widget
```
READ currentLayout = ref.watch(homeLayoutConfigProvider)
GET grouped = WidgetCatalog.getAllGrouped()

RETURN DraggableScrollableSheet(
  initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.95
  expand: false
):
  Container(borderRadius: top-16, surface color) → Column:
    ├─ _buildHandle:  drag indicator bar (48×4, rounded, onSurfaceVariant)
    │
    ├─ Padding(h16 v12) → Row:
    │   ├─ Text("Add Widget", titleLarge, bold)
    │   └─ IconButton(close) → Navigator.pop
    │
    ├─ Divider
    │
    └─ Expanded → ListView.builder:
        FOR each WidgetCategory in grouped.keys (sorted):
          _buildCategorySection(category, entries, currentLayout)
```

#### Method: _buildCategorySection(category, entries, currentLayout) → Widget
```
Column:
  ├─ Padding(h16 v8) → Row:
  │   ├─ Icon(category.icon, size: 18, primary)
  │   ├─ SizedBox(8)
  │   └─ Text(category.displayName, titleSmall, bold)
  │
  └─ FOR each entry in entries:
      isAdded = currentLayout.contains(entry.type)
      _WidgetPickerTile(entry, isAdded, onTap → _addWidget)
```

#### Method: _addWidget(context, ref, entry, isAdded)
```
IF already added → RETURN (no-op)

HapticFeedback.lightImpact()
ref.read(homeLayoutConfigProvider.notifier).addWidget(entry.type)
Navigator.pop(context)
ScaffoldMessenger.showSnackBar:
  "{entry.name} added to home screen"
```

---

### Class: _WidgetPickerTile (StatelessWidget)

**Constructor Parameters:**
- `entry: WidgetCatalogEntry`
- `isAdded: bool`
- `onTap: VoidCallback`

#### Method: build(context) → Widget
```
RETURN Padding(h12 v4) → Card(elevation: low):
  InkWell(onTap, borderRadius):
    Padding(12) → Row:
      ├─ Container(40×40, circle, primaryContainer):
      │   Icon(entry.icon, primary, size: 20)
      │
      ├─ SizedBox(12)
      │
      ├─ Expanded → Column(crossAxis: start):
      │   ├─ Text(entry.name, bodyMedium, bold)
      │   └─ Text(entry.description, bodySmall, onSurfaceVariant, maxLines: 2)
      │
      └─ IF isAdded:
          Container(badge: "Added", primaryContainer bg, primary text, rounded)
         ELSE:
          Icon(add_circle_outline, primary)
```

---

### Function: showWidgetPicker(context)
```
showModalBottomSheet(
  context, isScrollControlled: true, useSafeArea: true,
  backgroundColor: transparent
  builder: WidgetPickerSheet()
)
```
