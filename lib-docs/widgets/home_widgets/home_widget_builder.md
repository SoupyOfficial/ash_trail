# home_widget_builder

> **Source:** `lib/widgets/home_widgets/home_widget_builder.dart`

## Purpose
Central factory widget that builds all 28 home widget types. Given a `HomeWidgetType` enum value, a list of records, and metrics data, it switches on the type to return the appropriate widget. Contains private inner classes for several inline widget implementations including comparison columns, ratings, live timers, and recent entries with swipe-to-delete.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter/services.dart` — HapticFeedback
- `package:flutter_riverpod/flutter_riverpod.dart` — ConsumerWidget
- `dart:async` — Timer (for live-updating duration widgets)
- `../../models/log_record.dart` — LogRecord model
- `../../models/enums.dart` — EventType, Unit, LogReason enums
- `../../providers/log_record_provider.dart` — logRecordNotifierProvider, activeAccountProvider
- `../../services/home_metrics_service.dart` — HomeMetricsService (computeAllMetrics)
- `../../utils/day_boundary.dart` — DayBoundary for boundary calculations
- `../../utils/design_constants.dart` — ElevationLevel, BorderRadii, Paddings, Spacing, AnimationDuration, AnimationCurves
- `../../utils/pattern_analysis.dart` — PatternAnalysis
- `./stat_card_widget.dart` — StatCardWidget, TrendIndicator
- `./widget_catalog.dart` — HomeWidgetType enum, WidgetCatalog

## Pseudo-Code

### Class: HomeWidgetBuilder (ConsumerWidget)

**Constructor Parameters:**
- `widgetType: HomeWidgetType`
- `records: List<LogRecord>`

#### Method: build(context, ref) → Widget
```
COMPUTE metrics = HomeMetricsService.computeAllMetrics(records)
COMPUTE today/yesterday/week boundaries via DayBoundary
FILTER todayRecords, yesterdayRecords, weekRecords

SWITCH widgetType:

  // ── TIME CATEGORY ──
  timeSinceLastHit    → TimeSinceLastHitWidget(records)   [external widget]
  totalDurationToday  → _TotalDurationTodayCard (live timer)
  averageDuration     → StatCardWidget(icon, title, value: formatted, subtitle: "per entry today")
  longestGap          → StatCardWidget(icon, title, value: formatted, subtitle: time)
  shortestGap         → StatCardWidget(icon, title, value: formatted, subtitle: time)

  // ── COUNT CATEGORY ──
  todayCount    → StatCardWidget(icon, value: todayCount, trend vs yesterday)
  weekCount     → StatCardWidget(icon, value: weekCount, subtitle: "avg {n}/day")
  monthCount    → StatCardWidget(icon, value: monthCount)
  totalCount    → StatCardWidget(icon, value: total, subtitle: "all time")

  // ── DURATION CATEGORY ──  
  avgDurationPerHit → StatCardWidget(icon, value: formatted secs, trend)
  totalDurationWeek → StatCardWidget(icon, value: formatted)
  totalDurationAll  → StatCardWidget(icon, value: formatted + subtitle)

  // ── COMPARISON CATEGORY ──
  todayVsYesterday → _ComparisonColumn(todayCount vs yesterdayCount)
  weekdayVsWeekend → _ComparisonColumn(weekdayAvg vs weekendAvg)
  morningVsEvening → _ComparisonColumn(morningCount vs eveningCount)
  currentStreak    → StatCardWidget(icon, value: streakDays)
  bestStreak       → StatCardWidget(icon, value: bestStreakDays)

  // ── PATTERN CATEGORY ──
  peakHour         → StatCardWidget(icon, value: peak hour label, subtitle)
  peakDay          → StatCardWidget(icon, value: peak day name, subtitle: count)
  hourlyHeatmap    → HourlyHeatmap(records)
  weeklyHeatmap    → WeeklyHeatmap(records)

  // ── SECONDARY CATEGORY ──
  averageTimeBetween → StatCardWidget(icon, value: formatted gap)
  recentEntries      → _RecentEntriesWidget(ref, last 5 records)
  dailyRating        → _RatingColumn(computed from metrics)
  currentPace        → StatCardWidget(icon, value: "X.X/hr" pace, trend)

  // ── ACTION CATEGORY ──
  quickLog           → HomeQuickLogWidget()   [external widget]
  trendChart         → ActivityLineChart(rollups from metrics)
  countdownTimer     → StatCardWidget(icon, value: next-hit estimate)

  default → Card("Unknown widget type")
```

---

### Class: _ComparisonColumn (StatelessWidget)
```
Card → Column:
  ├─ Title
  ├─ Row: CircleAvatar(leftValue) vs CircleAvatar(rightValue)
  ├─ Row: leftLabel vs rightLabel
  └─ Bottom trend badge: percentage difference with up/down arrow
```

---

### Class: _RatingColumn (StatelessWidget)
```
Card → Column:
  ├─ "Daily Rating"
  ├─ Row of 5 star icons (filled/empty based on rating)
  └─ Description text based on rating level
```

---

### Class: _TimeSinceLastHitWidget (ConsumerStatefulWidget, private)
```
Simplified inline version:
initState → start 1-second Timer
dispose → cancel timer
build:
  COMPUTE time since last record
  FORMAT as "Xh Xm Xs"
  RETURN StatCardWidget with live-updating value
```

---

### Class: _RecentEntriesWidget (StatelessWidget)
```
Card → Column:
  ├─ "Recent Entries" header
  └─ FOR each record (0..min(5, length)):
      Dismissible(key: id, direction: endToStart):
        onDismissed → ref.read(logRecordNotifier).deleteRecord
        background: red Container with delete icon
        child: _RecentEntryTile(record)
```

### Class: _RecentEntryTile (StatelessWidget)
```
ListTile:
  leading: CircleAvatar(eventType icon, eventType color)
  title: eventType displayName
  subtitle: formatted time "h:mm a, MMM d"
  trailing: IF has duration → duration badge
  onTap: haptic light
```

---

### Class: _TotalDurationTodayCard (ConsumerStatefulWidget)
```
initState → start 60-second Timer (per-minute updates)
dispose → cancel timer

build:
  COMPUTE total duration today from records
  IF any active sessions → ADD elapsed time since session start
  FORMAT as "Xh Xm" or seconds
  RETURN StatCardWidget with running total + "today" subtitle
```
