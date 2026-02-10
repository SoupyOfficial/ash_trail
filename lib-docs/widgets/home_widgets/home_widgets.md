# home_widgets

> **Source:** `lib/widgets/home_widgets/home_widgets.dart`

## Purpose
Barrel file that re-exports all home widget modules from a single import point.

## Dependencies (re-exports)
- `widget_catalog.dart` — HomeWidgetType enum, WidgetSize, WidgetCategory, WidgetCatalogEntry, WidgetCatalog
- `home_widget_wrapper.dart` — HomeWidgetWrapper, HomeWidgetEditPadding
- `home_widget_builder.dart` — HomeWidgetBuilder
- `stat_card_widget.dart` — StatCardWidget, TrendIndicator, StatCardRow
- `widget_picker_sheet.dart` — WidgetPickerSheet, showWidgetPicker

## Pseudo-Code

```
EXPORT widget_catalog.dart
EXPORT home_widget_wrapper.dart
EXPORT home_widget_builder.dart
EXPORT stat_card_widget.dart
EXPORT widget_picker_sheet.dart
```
