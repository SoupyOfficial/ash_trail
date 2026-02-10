# analytics_charts

> **Source:** `lib/widgets/analytics_charts.dart`

## Purpose
Displays aggregated analytics data with interactive charts, time range filters, heatmaps, and trend indicators. Serves as the main analytics visualization widget per design docs 10.3.1 and 9.2.3. Allows users to explore their logging patterns over configurable date windows.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management (ConsumerStatefulWidget)
- `package:intl/intl.dart` — Date formatting (DateFormat)
- `../models/log_record.dart` — LogRecord data model
- `../services/analytics_service.dart` — AnalyticsService, RollingWindowStats, TrendDirection
- `charts/charts.dart` — All chart sub-widgets (ActivityBarChart, ActivityLineChart, heatmaps, TimeRangePicker)

## Pseudo-Code

### Provider: `analyticsServiceProvider`
```
Provider<AnalyticsService> that creates a singleton AnalyticsService instance.
```

### Enum: ChartTimeRange
```
Values: last7Days, last14Days, last30Days, custom
```

### Enum: ChartViewType
```
Values: bar, line
```

### Class: AnalyticsChartsWidget (ConsumerStatefulWidget)

**Constructor Parameters:**
- `records: List<LogRecord>` — all log records for the current account
- `accountId: String` — active account identifier

#### State: _AnalyticsChartsWidgetState

**State Variables:**
- `_selectedRange: ChartTimeRange` — defaults to `last7Days`
- `_customRange: DateTimeRange?` — user-selected custom date range
- `_stats: RollingWindowStats?` — computed analytics data
- `_isLoading: bool` — loading spinner control
- `_chartType: ChartViewType` — bar or line toggle
- `_currentFilteredRecords: List<LogRecord>?` — cached filtered records for heatmaps
- `_pendingLoadId: int?` — anti-race-condition token

**Computed Property: `_currentDays`**
```
SWITCH _selectedRange:
  last7Days  → RETURN 7
  last14Days → RETURN 14
  last30Days → RETURN 30
  custom     → IF _customRange != null: RETURN (end - start).inDays + 1
               ELSE: RETURN 7
```

#### Method: initState()
```
CALL super.initState()
CALL _loadStats()
```

#### Method: didUpdateWidget(oldWidget)
```
IF records changed OR accountId changed:
  IF accountId changed:
    RESET _selectedRange to last7Days
    CLEAR _customRange, _currentFilteredRecords
  CALL _loadStats()
```

#### Method: _loadStats() → Future<void>
```
SET loadId = current timestamp (race-condition guard)
SET _pendingLoadId = loadId
SET _isLoading = true (via setState)

READ analyticsService from provider

IF custom range selected AND _customRange exists:
  VALIDATE end >= start (abort if invalid)
  COMPUTE startOfDay = start at 00:00:00
  COMPUTE endOfDay = end at 23:59:59
  FILTER records where eventAt is within [startOfDay, endOfDay]
ELSE:
  USE all records

CACHE filtered records in _currentFilteredRecords

AWAIT analyticsService.computeRollingWindow(accountId, records, days)

IF still mounted AND loadId matches _pendingLoadId:
  SET _stats = computed stats
  SET _isLoading = false
```

#### Method: build(context) → Widget
```
RETURN Column:
  ├─ _buildTimeRangeSelector(context)
  ├─ SizedBox(height: 16)
  ├─ IF _isLoading:
  │    └─ Expanded → Center → CircularProgressIndicator
  ├─ ELSE IF _stats == null:
  │    └─ Expanded → _buildNoDataState (icon + message)
  ├─ ELSE:
  │    └─ Expanded → SingleChildScrollView → Column:
  │        ├─ _buildSummaryCards (Total Entries, Total Time, Daily Avg)
  │        ├─ _buildChartTypeSelector (SegmentedButton: Bar / Line)
  │        ├─ _buildActivityChart (bar or line based on _chartType)
  │        ├─ WeekdayHourlyHeatmap (primary color)
  │        ├─ WeekendHourlyHeatmap (orange)
  │        ├─ WeeklyHeatmap (green)
  │        └─ _buildTrendIndicators (Activity, Duration, optional Mood)
```

#### Method: _buildTimeRangeSelector(context) → Widget
```
RETURN Column:
  ├─ Row:
  │   ├─ Expanded → horizontal ScrollView of FilterChips:
  │   │   [7 Days] [14 Days] [30 Days] [Custom]
  │   └─ IconButton (date_range icon) → _showCustomRangePicker
  └─ IF custom range active:
      └─ Text showing "Range: MMM d, yyyy - MMM d, yyyy"
```

#### Method: _buildTimeChip(range, label) → FilterChip
```
ON selected:
  IF custom → CALL _showCustomRangePicker()
  ELSE → SET _selectedRange, CLEAR _customRange, CALL _loadStats()
```

#### Method: _showCustomRangePicker() → Future<void>
```
SHOW showTimeRangePicker dialog
VALIDATE result: end >= start, start not in future
IF valid → SET _selectedRange=custom, _customRange=result, CALL _loadStats()
IF invalid → SHOW SnackBar error message
```

#### Method: _buildChartTypeSelector(context) → SegmentedButton
```
Two segments: Bar (bar_chart icon) and Line (show_chart icon)
ON selection changed → setState _chartType
```

#### Method: _buildSummaryCards(context, stats) → Row
```
3 Expanded _SummaryCard widgets:
  [Total Entries | list_alt | blue]
  [Total Time    | timer    | green]
  [Daily Avg     | trending_up | orange]
```

#### Method: _buildActivityChart(context, stats) → Widget
```
IF _chartType == line → ActivityLineChart(rollups, title, lineColor)
ELSE → ActivityBarChart(rollups, title, barColor)
```

#### Method: _buildTrendIndicators(context, stats) → Card
```
COMPUTE entriesTrend via analyticsService.computeTrend(metric: 'entries')
COMPUTE durationTrend via analyticsService.computeTrend(metric: 'duration')
RETURN Card containing:
  ├─ "Trends" header with range label
  ├─ _TrendIndicator(Activity, entriesTrend)
  ├─ _TrendIndicator(Duration, durationTrend)
  └─ IF mood data exists: _TrendIndicator(Mood, moodTrend)
```

### Class: _SummaryCard (StatelessWidget)
```
Card showing: icon → value (headline) → title (caption)
Colored icon with the specified color.
```

### Class: _TrendIndicator (StatelessWidget)
```
Row: [colored icon container] [label] [spacer] [trend badge: "Increasing"/"Decreasing"/"Stable"]
Colors: up=green, down=red, stable=grey
```
