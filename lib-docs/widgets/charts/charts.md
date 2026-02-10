# charts

> **Source:** `lib/widgets/charts/charts.dart`

## Purpose
Barrel file that re-exports all chart widgets used in the analytics screen. Provides a single import point for consumers.

## Dependencies (re-exports)
- `activity_line_chart.dart` — ActivityLineChart widget
- `activity_bar_chart.dart` — ActivityBarChart widget
- `event_type_pie_chart.dart` — EventTypePieChart widget
- `hourly_heatmap.dart` — HourlyHeatmap, WeeklyHeatmap, WeekdayHourlyHeatmap, WeekendHourlyHeatmap widgets
- `time_range_picker.dart` — TimeRangePicker widget, TimeRangePreset enum, showTimeRangePicker function

## Pseudo-Code

```
EXPORT activity_line_chart.dart
EXPORT activity_bar_chart.dart
EXPORT event_type_pie_chart.dart
EXPORT hourly_heatmap.dart
EXPORT time_range_picker.dart
```
