# widget_catalog

> **Source:** `lib/widgets/home_widgets/widget_catalog.dart`

## Purpose
Defines the complete catalog of all 28 home screen widget types. Provides the `HomeWidgetType` enum, `WidgetSize` and `WidgetCategory` enums, `WidgetCatalogEntry` metadata class, and the `WidgetCatalog` static registry with lookup helpers. Acts as the single source of truth for widget metadata, default layout, and picker display.

## Dependencies
- `package:flutter/material.dart` — IconData references (no widgets built)

## Pseudo-Code

### Enum: HomeWidgetType (28 values, 7 categories)
```
// ── Time ──
timeSinceLastHit, totalDurationToday, averageDuration, longestGap, shortestGap

// ── Count ──
todayCount, weekCount, monthCount, totalCount

// ── Duration ──
avgDurationPerHit, totalDurationWeek, totalDurationAll

// ── Comparison ──
todayVsYesterday, weekdayVsWeekend, morningVsEvening, currentStreak, bestStreak

// ── Pattern ──
peakHour, peakDay, hourlyHeatmap, weeklyHeatmap

// ── Secondary ──
averageTimeBetween, recentEntries, dailyRating, currentPace

// ── Action ──
quickLog, trendChart, countdownTimer
```

### Enum: WidgetSize
```
compact   — small single-stat cards
standard  — default size (1 column)
large     — full-width or multi-row (charts, heatmaps)
```

### Enum: WidgetCategory
```
time(displayName, icon: timer)
count(displayName, icon: tag)
duration(displayName, icon: hourglass_empty)
comparison(displayName, icon: compare_arrows)
pattern(displayName, icon: insights)
secondary(displayName, icon: widgets)
action(displayName, icon: flash_on)
```

### Class: WidgetCatalogEntry
```
Fields:
  type: HomeWidgetType
  name: String                   — human-readable name
  description: String            — short explanation
  category: WidgetCategory
  icon: IconData
  size: WidgetSize               — layout hint
  isDefault: bool                — included in initial layout
```

### Class: WidgetCatalog (static)

#### Static Field: entries → Map<HomeWidgetType, WidgetCatalogEntry>
```
Complete map of all 28 widget types, e.g.:
  timeSinceLastHit → ("Time Since Last Hit", "Live counter...", time, timer, large, true)
  todayCount       → ("Today's Count", "Number of entries...", count, today, compact, true)
  quickLog         → ("Quick Log", "Quickly log...", action, add_circle, standard, true)
  hourlyHeatmap    → ("Hourly Heatmap", "Heatmap...", pattern, grid_on, large, false)
  ... (all 28 entries)
```

#### Static Method: getEntry(type) → WidgetCatalogEntry?
```
RETURN entries[type]
```

#### Static Method: getByCategory(category) → List<WidgetCatalogEntry>
```
FILTER entries.values WHERE entry.category == category
```

#### Static Method: getAllGrouped() → Map<WidgetCategory, List<WidgetCatalogEntry>>
```
GROUP all entries by category
RETURN map
```

#### Static Field: defaultWidgets → List<HomeWidgetType>
```
FILTER entries WHERE isDefault == true
RETURN list of types in insertion order
  [timeSinceLastHit, totalDurationToday, todayCount, weekCount,
   todayVsYesterday, peakHour, quickLog, recentEntries, ...]
```
