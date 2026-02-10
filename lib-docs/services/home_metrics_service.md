# home_metrics_service

> **Source:** `lib/services/home_metrics_service.dart`

## Purpose

Centralized service for computing all metrics shown on the home screen widgets. Focuses on time, duration, and count as primary data dimensions plus secondary data like mood/physical ratings and reasons. All methods operate on in-memory `LogRecord` lists and use the 6 AM day boundary for natural grouping of late-night activity.

## Dependencies

- `../models/log_record.dart` — `LogRecord` model
- `../models/enums.dart` — `Unit`, `LogReason` enums
- `../utils/day_boundary.dart` — 6 AM day boundary utilities (`getTodayStart`, `getYesterdayStart`, `getDayStartDaysAgo`)

## Pseudo-Code

### Class: HomeMetricsService

_(No fields, no constructor — stateless service)_

---

### Time-Based Metrics

#### `getTimeSinceLastHit(records) → Duration?`

```
IF records empty → RETURN null
sorted = _getNonDeletedSorted(records)  // newest first
IF sorted empty → RETURN null
RETURN NOW.difference(sorted.first.eventAt)
```

#### `getLastRecord(records) → LogRecord?`

```
sorted = _getNonDeletedSorted(records)
RETURN sorted.isEmpty ? null : sorted.first
```

#### `getAverageGap(records, {days?}) → Duration?`

```
filtered = days != null ? _filterByDays(records, days) : records
sorted = _getNonDeletedSorted(filtered)
IF sorted.length < 2 → RETURN null

gaps = []
FOR i = 0 TO sorted.length-2:
  gaps.add(sorted[i].eventAt.difference(sorted[i+1].eventAt))

totalMs = SUM(gaps.inMilliseconds)
RETURN Duration(milliseconds = totalMs ~/ gaps.length)
```

#### `getAverageGapToday(records) → Duration?`

```
todayRecords = _filterToday(records)
sorted = _getNonDeletedSorted(todayRecords)
IF sorted.length < 2 → RETURN null

firstHit = sorted.last.eventAt     // oldest today
lastHit  = sorted.first.eventAt    // newest today
totalSpan = lastHit.difference(firstHit)
numberOfGaps = sorted.length - 1

RETURN Duration(ms = totalSpan.inMilliseconds ~/ numberOfGaps)
```

#### `getLongestGap(records, {days?}) → ({gap, startTime, endTime})?`

```
filtered, sorted (newest first)
IF sorted.length < 2 → RETURN null

longestGap = Duration.zero
FOR i = 0 TO sorted.length-2:
  gap = sorted[i].eventAt.difference(sorted[i+1].eventAt)
  IF gap > longestGap:
    longestGap = gap
    gapStart = sorted[i+1].eventAt
    gapEnd   = sorted[i].eventAt

RETURN (gap: longestGap, startTime: gapStart, endTime: gapEnd)
```

#### `getFirstHitToday(records) → DateTime?`

```
today = _filterToday(records)
sorted = _getNonDeletedSorted(today)
RETURN sorted.isEmpty ? null : sorted.last.eventAt   // oldest = first hit
```

#### `getLastHitToday(records) → DateTime?`

```
today = _filterToday(records)
sorted = _getNonDeletedSorted(today)
RETURN sorted.isEmpty ? null : sorted.first.eventAt  // newest = last hit
```

#### `getPeakHour(records, {days?}) → ({hour, count, percentage})?`

```
nonDeleted = filtered.WHERE(not deleted)
IF empty → RETURN null

hourCounts = {}
FOR EACH record: hourCounts[record.eventAt.hour]++

Find hour with maxCount
percentage = (maxCount / nonDeleted.length) * 100
RETURN (hour, count, percentage)
```

#### `getActiveHoursCount(records, {days?}) → int`

```
nonDeleted = filtered.WHERE(not deleted)
activeHours = SET of record.eventAt.hour
RETURN activeHours.length
```

#### `getActiveHoursToday(records) → int`

```
RETURN getActiveHoursCount(_filterToday(records))
```

---

### Duration-Based Metrics

#### `getTotalDuration(records, {days?}) → double`

```
filtered.WHERE(not deleted).fold(0, (sum, r) → sum + _getDurationInSeconds(r))
```

#### `getTotalDurationToday(records) → double`

```
RETURN getTotalDuration(_filterToday(records))
```

#### `getTodayDurationUpTo(records, {asOf?}) → Record`

```
cutoff = asOf ?? NOW
todayStart = DayBoundary.getTodayStart()

IF cutoff BEFORE todayStart → RETURN (duration: 0, timeLabel, trend: 0, ...)

todayRecords up to cutoff → compute duration, count

// Yesterday comparison
yesterdayDuration = getTotalDuration(_filterYesterday(records))
elapsed = cutoff - todayStart (clamped 0..86400 seconds)
fraction = elapsed / 86400
expectedByNow = yesterdayDuration * fraction
trendVsYesterday = ((duration - expectedByNow) / expectedByNow) * 100  (if > 0)

// Week average comparison
weekTotal = getTotalDuration(last 7 days)
weekAvgPerDay = weekTotal / 7
expectedByNowWeek = weekAvgPerDay * fraction
trendVsWeekAvg = ((duration - expectedByNowWeek) / expectedByNowWeek) * 100

RETURN (duration, timeLabel, trendVsYesterday, trendVsWeekAvg, count)
```

#### `getAverageDuration(records, {days?}) → double?`

```
nonDeleted, IF empty → null
RETURN totalDuration / nonDeleted.length
```

#### `getAverageDurationToday(records) → double?`

```
RETURN getAverageDuration(_filterToday(records))
```

#### `getLongestHit(records, {days?}) → LogRecord?`

```
nonDeleted.reduce(max by _getDurationInSeconds)
```

#### `getShortestHit(records, {days?}) → LogRecord?`

```
nonDeleted.reduce(min by _getDurationInSeconds)
```

---

### Count-Based Metrics

#### `getHitCount(records, {days?}) → int`

```
filtered.WHERE(not deleted).length
```

#### `getHitCountToday(records) → int`

```
RETURN getHitCount(_filterToday(records))
```

#### `getDailyAverageHits(records, {days=7}) → double`

```
filtered = _filterByDays(records, days)
count = nonDeleted.length

// Count unique active days using 6am boundary
daysWithData = SET of dayOffset values
activeDays = MAX(daysWithData.length, 1)
RETURN count / activeDays
```

#### `getHitsPerActiveHour(records, {days?}) → double?`

```
hitCount = getHitCount(filtered)
activeHours = getActiveHoursCount(filtered)
IF activeHours == 0 → null
RETURN hitCount / activeHours
```

---

### Comparison Metrics

#### `comparePeriods({records, metric, currentDays, previousDays}) → ({current, previous, percentChange})`

```
currentStart = DayBoundary.getDayStartDaysAgo(currentDays - 1)
currentRecords = records after currentStart, not deleted
previousStart  = currentStart - previousDays
previousRecords = records in [previousStart, currentStart), not deleted

SWITCH metric:
  'count'       → count records
  'duration'    → getTotalDuration
  'avgDuration' → getAverageDuration

percentChange = previous > 0 ? ((current - previous) / previous) * 100
                             : (current > 0 ? 100.0 : 0.0)
```

#### `getTodayVsYesterday(records) → Record`

```
todayRecords = _filterToday, yesterdayRecords = _filterYesterday
Compute counts and durations for each
percentChange for count and duration
RETURN (todayCount, yesterdayCount, todayDuration, yesterdayDuration, countChange, durationChange)
```

#### `getWeekdayVsWeekend(records, {days=7}) → Record`

```
weekdayRecords = records WHERE weekday <= 5
weekendRecords = records WHERE weekday > 5
Count unique weekday/weekend days in range
Compute averages per weekday/weekend day
RETURN (weekdayAvgCount, weekendAvgCount, weekdayAvgDuration, weekendAvgDuration)
```

---

### Secondary Data Metrics

#### `getAverageMood(records, {days?}) → double?`

```
withMood = filtered.WHERE(moodRating != null AND not deleted)
IF empty → null
RETURN SUM(moodRating) / count
```

#### `getAveragePhysical(records, {days?}) → double?`

```
Same pattern, filtering by physicalRating != null
```

#### `getTopReasons(records, {days?, limit=3}) → List<({reason, count})>`

```
Count each LogReason across all records' reasons lists
Sort by count descending
RETURN top `limit` entries
```

---

### Helper Methods (private)

#### `_getNonDeletedSorted(records) → List<LogRecord>`
```
records.WHERE(not deleted), SORT by eventAt descending (newest first)
```

#### `_filterToday(records) → List<LogRecord>`
```
todayStart = DayBoundary.getTodayStart()    // 6 AM boundary
RETURN records WHERE eventAt >= todayStart
```

#### `_filterYesterday(records) → List<LogRecord>`
```
todayStart = DayBoundary.getTodayStart()
yesterdayStart = DayBoundary.getYesterdayStart()
RETURN records WHERE eventAt >= yesterdayStart AND eventAt < todayStart
```

#### `_filterByDays(records, days) → List<LogRecord>`
```
startDate = DayBoundary.getDayStartDaysAgo(days - 1)
RETURN records WHERE eventAt >= startDate
```

#### `_getDurationInSeconds(record) → double`
```
SWITCH record.unit:
  seconds → record.duration
  minutes → record.duration * 60
  DEFAULT → record.duration
```

---

### Formatting Helpers (static)

#### `formatDuration(double seconds) → String`
```
hours, minutes, secs from Duration
IF hours > 0 → '{h}h {m}m'
ELSE IF minutes > 0 → '{m}m {s}s'
ELSE → '{s}s'
```

#### `formatDurationObject(Duration) → String`
```
Similar with days/hours/minutes/seconds
```

#### `formatHour(int hour) → String`
```
hour12 = hour % 12 (0→12)
period = hour < 12 ? 'AM' : 'PM'
RETURN '{hour12} {period}'
```

#### `formatTimeLabel(DateTime dt) → String`
```
'{hour12}{am/pm}'  e.g. '3pm'
```

#### `formatRelativeTime(DateTime time) → String`
```
diff = NOW - time
IF < 1 min → 'Just now'
IF < 1 hour → '{minutes}m ago'
IF < 1 day → '{hours}h ago'
IF < 7 days → '{days}d ago'
ELSE → '{weeks}w ago'
```
