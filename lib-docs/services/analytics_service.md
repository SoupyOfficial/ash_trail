# analytics_service

> **Source:** `lib/services/analytics_service.dart`

## Purpose

Client-side analytics computation per design doc §10 (Analytics & Aggregation). Computes daily rollups, rolling-window statistics, and trend analysis from in-memory lists of LogRecords. Uses the 6 AM day boundary to group late-night activity with the previous calendar day.

## Dependencies

- `dart:convert` — JSON encoding for event type breakdown
- `../models/log_record.dart` — `LogRecord` model
- `../models/daily_rollup.dart` — `DailyRollup` model
- `../models/enums.dart` — `EventType`, `Unit` enums
- `../utils/day_boundary.dart` — 6 AM day boundary utilities

## Pseudo-Code

### Class: AnalyticsService

_(No fields, no constructor — stateless service)_

---

#### `computeDailyRollup({accountId, date, records}) → Future<DailyRollup>`

```
dayStart = DayBoundary.getDayStart(date)        // 6 AM boundary
dayEnd   = dayStart + 1 day

dayRecords = records.WHERE(r →
  r.eventAt AFTER dayStart AND
  r.eventAt BEFORE dayEnd AND
  NOT r.isDeleted
)

totalValue = _computeTotalDuration(dayRecords).toDouble()
eventCount = dayRecords.length
eventTypeCounts = _computeEventTypeCounts(dayRecords)

IF dayRecords.isNotEmpty:
  sorted = dayRecords sorted by eventAt ascending
  firstEvent = sorted.first.eventAt
  lastEvent  = sorted.last.eventAt
ELSE:
  firstEvent = null, lastEvent = null

dateStr = 'YYYY-MM-DD' from dayStart

RETURN DailyRollup.create(
  accountId, dateStr, totalValue, eventCount,
  firstEventAt, lastEventAt,
  eventTypeBreakdownJson = JSON(eventTypeCounts mapped to name→count)
)
```

---

#### `computeRollingWindow({accountId, records, days, now?}) → Future<RollingWindowStats>`

```
referenceNow = now ?? DateTime.now()
today = DayBoundary.getDayStart(referenceNow)
windowStart = today - days days

windowRecords = records.WHERE(r → r.eventAt AFTER windowStart AND NOT r.isDeleted)

dailyRollups = []
FOR i = 0 TO days-1:
  date = windowStart + i days
  rollup = AWAIT computeDailyRollup(accountId, date, windowRecords)
  dailyRollups.add(rollup)

RETURN RollingWindowStats(
  days, windowStart, referenceNow,
  totalEntries = windowRecords.length,
  totalDurationSeconds = _computeTotalDuration(windowRecords),
  averageDailyEntries = windowRecords.length / days,
  averageMoodRating = _computeAverageMood(windowRecords),
  averagePhysicalRating = _computeAveragePhysical(windowRecords),
  dailyRollups, eventTypeCounts = _computeEventTypeCounts(windowRecords)
)
```

---

#### `getLast7DaysStats({accountId, records}) → Future<RollingWindowStats>`

```
RETURN computeRollingWindow(accountId, records, days=7)
```

---

#### `getLast30DaysStats({accountId, records}) → Future<RollingWindowStats>`

```
RETURN computeRollingWindow(accountId, records, days=30)
```

---

#### `computeTrend({rollups, metric}) → TrendDirection`

```
IF rollups.length < 2 → RETURN stable

midpoint = rollups.length ~/ 2
firstHalf  = rollups[0..midpoint]
secondHalf = rollups[midpoint..]

SWITCH metric:
  'entries':
    firstAvg  = SUM(firstHalf.eventCount) / firstHalf.length
    secondAvg = SUM(secondHalf.eventCount) / secondHalf.length
  'duration':
    firstAvg  = SUM(firstHalf.totalValue) / firstHalf.length
    secondAvg = SUM(secondHalf.totalValue) / secondHalf.length
  'mood':
    RETURN stable   // Not available from DailyRollup

percentChange = (firstAvg > 0) ? (secondAvg - firstAvg) / firstAvg : 0

IF percentChange > 0.1  → RETURN up
IF percentChange < -0.1 → RETURN down
RETURN stable
```

---

#### `_computeTotalDuration(List<LogRecord> records) → int` (private)

```
RETURN records.fold(0, (total, record) →
  IF unit == seconds → total + duration.toInt()
  IF unit == minutes → total + (duration * 60).toInt()
  ELSE → total
)
```

---

#### `_computeAverageMood(records) → double?` (private)

```
withMood = records.WHERE(r → r.moodRating != null)
IF empty → RETURN null
RETURN SUM(moodRatings) / withMood.length
```

---

#### `_computeAveragePhysical(records) → double?` (private)

```
withPhysical = records.WHERE(r → r.physicalRating != null)
IF empty → RETURN null
RETURN SUM(physicalRatings) / withPhysical.length
```

---

#### `_computeEventTypeCounts(records) → Map<EventType, int>` (private)

```
counts = {}
FOR EACH record IN records:
  counts[record.eventType] = (counts[record.eventType] ?? 0) + 1
RETURN counts
```

---

### Class: RollingWindowStats

#### Fields
- `days`, `startDate`, `endDate` — window definition
- `totalEntries`, `totalDurationSeconds` — aggregate counts
- `averageDailyEntries` — entries per day
- `averageMoodRating`, `averagePhysicalRating` — nullable averages
- `dailyRollups` — list of per-day rollups
- `eventTypeCounts` — breakdown by event type

#### `formattedDuration → String` (getter)

```
hours = totalDurationSeconds ~/ 3600
minutes = (totalDurationSeconds % 3600) ~/ 60
IF hours > 0 → RETURN '{hours}h {minutes}m'
RETURN '{minutes}m'
```

---

### Enum: TrendDirection
- `up`, `down`, `stable`

### Class: ChartDataPoint
- `date`, `value`, `label?` — simple data point for visualization
