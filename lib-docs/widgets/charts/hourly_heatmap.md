# hourly_heatmap

> **Source:** `lib/widgets/charts/hourly_heatmap.dart`

## Purpose
Provides four heatmap visualizations for activity patterns: `HourlyHeatmap` (all-hours 6×4 grid), `WeeklyHeatmap` (7-day × 24-hour grid), `WeekdayHourlyHeatmap` (Mon–Fri hourly), and `WeekendHourlyHeatmap` (Sat–Sun hourly). All use color intensity to convey frequency and support tap/tooltip interactions.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `../../models/log_record.dart` — LogRecord model

## Pseudo-Code

### Class: HourlyHeatmap (StatelessWidget)

**Constructor Parameters:**
- `records: List<LogRecord>`
- `title: String` — default "Activity by Hour"
- `baseColor: Color` — default blue

#### Method: build(context) → Widget
```
IF records empty → _buildEmptyState (grid_on icon)

COMPUTE hourCounts = _computeHourlyCounts() → Map<int, int> (0–23)
COMPUTE maxCount from hourCounts

RETURN Card → Padding(16) → Column:
  ├─ Text(title)
  ├─ Text("Tap a cell to see details", bodySmall)
  ├─ _buildHeatmapGrid (GridView, 6 columns, 24 items)
  └─ _buildLegend (5-step gradient: Less → More + max count)
```

#### Data Transform: _computeHourlyCounts()
```
INIT counts[0..23] = 0
FOR each non-deleted record:
  counts[record.eventAt.hour]++
RETURN counts
```

#### Grid Cell: _HeatmapCell (StatelessWidget)
```
Props: hour, count, intensity (0.0–1.0), baseColor

RETURN Tooltip(message: "{hourLabel}: {count} entries"):
  InkWell:
    onTap → SHOW SnackBar with same message
    Container:
      color: count > 0 → baseColor at (0.1 + intensity × 0.8) alpha
             count == 0 → surfaceContainerHighest at 0.5 alpha
      border: outline at 0.2 alpha
      Center → Text(hourLabel, fontSize: 10, bold if count > 0)
        color: white if intensity > 0.5, else onSurface

  _formatHour: 0 → "12AM", 12 → "12PM", <12 → "{h}AM", else → "{h-12}PM"
```

---

### Class: WeeklyHeatmap (StatelessWidget)

**Constructor Parameters:**
- `records: List<LogRecord>`
- `title: String` — default "Weekly Pattern"
- `baseColor: Color` — default green

#### Data Transform: _computeDayHourCounts()
```
INIT counts[day 1–7][hour 0–23] = 0
FOR each non-deleted record:
  counts[weekday][hour]++
RETURN Map<int, Map<int, int>>
```

#### Method: build(context) → Widget
```
IF empty → _buildEmptyState (calendar_view_week icon)

COMPUTE dayHourCounts, maxCount

RETURN Card → Column:
  ├─ Text(title)
  ├─ _buildWeeklyGrid:
  │   Header row: hour labels at 0, 4, 8, 12, 16, 20 intervals
  │   7 rows (Mon–Sun): day label + 24 colored cells
  │   Each cell: Tooltip with "Day Hour: count"
  │   Color: baseColor at intensity alpha (0.1–0.9)
  └─ _buildLegend (5-step gradient)
```

---

### Class: WeekdayHourlyHeatmap (StatelessWidget)

**Constructor Parameters:** same as HourlyHeatmap

#### Method: build(context) → Widget
```
FILTER records: weekday Mon–Fri only, non-deleted
IF empty → _buildEmptyState (work_outline icon)

COMPUTE hourCounts, maxCount
RETURN Card with title, "Mon – Fri · Tap a cell", grid (same as HourlyHeatmap), legend
```

---

### Class: WeekendHourlyHeatmap (StatelessWidget)

**Constructor Parameters:** same as HourlyHeatmap (baseColor default orange)

#### Method: build(context) → Widget
```
FILTER records: weekday Sat–Sun only, non-deleted
IF empty → _buildEmptyState (weekend icon)

COMPUTE hourCounts, maxCount
RETURN Card with title, "Sat – Sun · Tap a cell", grid (same as HourlyHeatmap), legend
```

### Legend Pattern (shared):
```
Row: "Less" → 5 gradient boxes → "More" → Spacer → "Max: {n} entries/hour"
```
