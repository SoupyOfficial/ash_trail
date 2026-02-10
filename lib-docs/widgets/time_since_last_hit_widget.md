# time_since_last_hit_widget

> **Source:** `lib/widgets/time_since_last_hit_widget.dart`

## Purpose
The primary home-screen statistics widget. Shows a live-updating timer since the last log entry, collapsible statistics sections (today vs yesterday vs 7-day averages for duration and hit counts with trend indicators), and pattern analysis (peak hour, weekday/weekend comparison). Each stat card supports tap for detail bottom sheet and long-press for tooltip. Uses 6am day boundaries, haptic feedback, and animated transitions throughout.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter/services.dart` — HapticFeedback
- `package:flutter_riverpod/flutter_riverpod.dart` — ConsumerStatefulWidget
- `dart:async` — Timer for 1-second updates
- `../models/log_record.dart` — LogRecord model
- `../services/home_metrics_service.dart` — HomeMetricsService (formatTimeLabel, formatRelativeTime)
- `../utils/pattern_analysis.dart` — PatternAnalysis, PeakHourData, DayPatternData
- `../utils/design_constants.dart` — ElevationLevel, BorderRadii, Paddings, Spacing, IconSize, AnimationDuration, AnimationCurves
- `../utils/day_boundary.dart` — DayBoundary (6am boundary helpers)

## Pseudo-Code

### Class: _DailyStats (data class)
```
Fields: count (int), totalDuration (double), avgDuration (double)
Static: empty = all zeros
```

### Class: TimeSinceLastHitWidget (ConsumerStatefulWidget)

**Constructor Parameters:**
- `records: List<LogRecord>` — all records for user

#### State: _TimeSinceLastHitWidgetState

**State Variables:**
- `_timer: Timer?` — 1-second periodic timer
- `_timeSinceLastHit: Duration?`
- `_todayStats, _yesterdayStats, _weekStats: _DailyStats`
- `_weekCount: int`
- `_peakHour: PeakHourData?`
- `_dayPatterns: List<DayPatternData>`
- `_weekdayWeekendComparison` — record with weekdayAvg, weekendAvg, trend
- `_statsSectionExpanded: bool` — default `true`
- `_patternSectionExpanded: bool` — default `false`

#### Method: initState()
```
START 1-second timer → _updateTimeSinceLastHit
CALL _calculateStats()
```

#### Method: didUpdateWidget(old)
```
IF records changed → _updateTimeSinceLastHit + _calculateStats()
```

#### Method: _updateTimeSinceLastHit()
```
IF records empty → SET null → RETURN
SORT records by eventAt descending
SET _timeSinceLastHit = now - mostRecentRecord.eventAt
```

#### Method: _calculateStats()
```
IF records empty → SET all stats to empty → RETURN

COMPUTE today/yesterday/week boundaries using DayBoundary (6am)
FILTER records for each period
COMPUTE _todayStats, _yesterdayStats via _calculatePeriodStats
COMPUTE _weekStats with per-day average (total / days-with-data)
COMPUTE pattern analysis:
  _peakHour = PatternAnalysis.getPeakHour(weekRecords)
  _dayPatterns = PatternAnalysis.getDayPatternsDetailed(weekRecords)
  _weekdayWeekendComparison = PatternAnalysis.getWeekdayWeekendComparison(weekRecords)
```

#### Method: _calculateTrend(currentAvg, comparisonAvg) → double
```
IF comparisonAvg == 0 → RETURN 0
RETURN ((current - comparison) / comparison) * 100
```

#### Method: _calculateTrendHourBlock(actualSoFar, fullDayReference) → double
```
COMPUTE elapsed fraction of day since 6am boundary
expectedByNow = fullDayReference × fraction
RETURN ((actual - expected) / expected) * 100
```

#### Method: _buildTrendIndicator(trendPercent, context) → Widget
```
IF 0 → SizedBox.shrink
isUp → error color (red = more usage)
isDown → tertiary color (green = less usage)
Container with icon + "{+/-}XX%" badge
```

#### Method: _buildStatCard(context, {title, value, subtitle, trendWidget, tooltip, onTap, icon}) → Expanded
```
Card with InkWell:
  onTap: haptic light + onTap callback
  onLongPress: haptic medium + _showTooltip dialog
  Content Column:
    ├─ Row: optional icon + title (bodySmall, muted)
    ├─ AnimatedSwitcher(FadeTransition + ScaleTransition):
    │   └─ value text (headlineMedium, bold)
    └─ Row: subtitle (bodySmall, muted) + optional trendWidget
```

#### Method: _showDetailView(context, title, value, subtitle, additionalData)
```
SHOW ModalBottomSheet (DraggableScrollableSheet):
  ├─ Drag handle bar
  ├─ Title (headlineSmall, bold)
  ├─ Value (displaySmall, bold) + subtitle
  └─ IF additionalData: key-value detail rows
```

#### Method: build(context) → Widget
```
IF _timeSinceLastHit == null:
  RETURN Card with empty state:
    icon(timer_outlined), "No entries yet", "Time since last hit will appear here"

COMPUTE trends:
  todayVsYesterdayTrend (avg duration per hit)
  todayTotalVsYesterdayTotalTrend (hour-block pace)
  todayTotalVsWeekAvgTrend (hour-block pace)
  timeLabel from HomeMetricsService

RETURN Card(key: time_since_last_hit) → Padding → SingleChildScrollView → Column:
  ├─ GestureDetector (onLongPress: tooltip, onTap: detail view):
  │   ├─ Row: timer icon + "Time Since Last Hit"
  │   └─ Text: _formatRelativeDuration (displaySmall, bold)
  │
  ├─ Divider
  │
  ├─ _buildCollapsibleSection("Statistics", _statsSectionExpanded):
  │   ├─ Row 1: "Total up to {time}" + trend vs yesterday pace │ "Total Yesterday"
  │   ├─ Row 2: "Total up to {time}" + trend vs week avg pace  │ "Avg/Day (7d)"
  │   ├─ Row 3: "Avg Today" sec/hit + vs yesterday trend       │ "Avg Yesterday" sec/hit
  │   └─ Row 4: "Hits Today" count                              │ "Hits This Week" count
  │
  └─ IF pattern data exists:
      _buildCollapsibleSection("Patterns", _patternSectionExpanded):
        ├─ _buildPeakHourSection (onTap: top 3 hours detail)
        └─ _buildDayPatternSection (weekday/weekend averages)
```

#### Method: _buildCollapsibleSection({title, content, isExpanded, onToggle})
```
InkWell header: title + AnimatedRotation(expand_more icon)
  onTap: haptic selectionClick + toggle
AnimatedSize → IF expanded: content ELSE: SizedBox.shrink
```

### Formatting Helpers:
- `_formatDuration(Duration)` — "Xd Xh Xm" or "Xh Xm Xs" etc.
- `_formatRelativeDuration(Duration)` — "Just now", "5m ago", "2h ago", "3d ago", "2w ago"
- `_formatSeconds(double)` — seconds to "Xh Xm" or "Xm Xs"
