# pattern_analysis

> **Source:** `lib/utils/pattern_analysis.dart`

## Purpose

Pattern analysis utilities for identifying usage trends and behavioral patterns from log records. Provides peak-hour detection, hourly distribution, day-of-week pattern analysis (simple and detailed), and weekday-vs-weekend comparison with trend detection.

## Dependencies

- `../models/log_record.dart` — `LogRecord` model (provides `eventAt`, `logId`, etc.)

## Pseudo-Code

---

### Class: PeakHourData

Data class representing peak usage hour information.

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| hour | int | Hour of day (0–23) |
| count | int | Number of records in that hour |
| percentage | double | Percentage of total records |

#### Getter: formattedHour → String
```
SET hour12 = IF hour % 12 == 0 THEN 12 ELSE hour % 12
SET period = IF hour < 12 THEN "AM" ELSE "PM"
RETURN "{hour12} {period}"
  // e.g. "3 PM", "12 AM"
```

---

### Class: DayPatternData

Data class representing day-of-week pattern information.

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| dayOfWeek | int | 1–7 (Monday–Sunday) |
| dayName | String | Full day name |
| count | int | Total record count for this day |
| average | double | Average records per week for this day |

#### Static Method: getDayName(dayOfWeek) → String
```
SWITCH dayOfWeek
  CASE 1 → "Monday"
  CASE 2 → "Tuesday"
  CASE 3 → "Wednesday"
  CASE 4 → "Thursday"
  CASE 5 → "Friday"
  CASE 6 → "Saturday"
  CASE 7 → "Sunday"
  DEFAULT → "Unknown"
```

---

### Class: PatternAnalysis

Static utility class for analyzing log record collections.

---

#### Method: getPeakHour(records) → PeakHourData?

Finds the single hour with the most log records.

```
IF records IS EMPTY → RETURN null

// Step 1: Count records per hour
INIT hourCounts = empty Map<int, int>
FOR EACH record IN records
  SET hour = record.eventAt.hour
  INCREMENT hourCounts[hour]

// Step 2: Find the hour with the maximum count
SET peakHour = 0
SET maxCount = 0
FOR EACH (hour, count) IN hourCounts
  IF count > maxCount
    SET maxCount = count
    SET peakHour = hour

// Step 3: Calculate percentage
SET percentage = (maxCount / records.length) * 100

RETURN PeakHourData(hour: peakHour, count: maxCount, percentage: percentage)
```

---

#### Method: getHourDistribution(records) → Map<int, int>

Produces a complete 24-hour distribution map (0–23), filling missing hours with 0.

```
INIT hourCounts = empty Map<int, int>

FOR EACH record IN records
  SET hour = record.eventAt.hour
  INCREMENT hourCounts[hour]

// Fill gaps
FOR i FROM 0 TO 23
  IF i NOT IN hourCounts
    SET hourCounts[i] = 0

RETURN hourCounts
```

---

#### Method: getDayPatterns(records) → List\<DayPatternData\>

Simple day-of-week analysis. Returns all 7 days sorted by count (descending).

```
IF records IS EMPTY → RETURN _emptyDayPatterns()

// Step 1: Group records by day of week
INIT dayCounts = empty Map<int, List<LogRecord>>
FOR EACH record IN records
  SET dayOfWeek = record.eventAt.weekday   // 1=Mon, 7=Sun
  APPEND record TO dayCounts[dayOfWeek]

// Step 2: Build statistics per day
INIT dayPatterns = empty List
FOR day FROM 1 TO 7
  SET recordsForDay = dayCounts[day] ?? []
  SET count = recordsForDay.length
  SET average = count as double   // Simple: same as count for single period

  ADD DayPatternData(dayOfWeek: day, dayName: getDayName(day), count, average)

// Step 3: Sort by count descending
SORT dayPatterns BY count DESC

RETURN dayPatterns
```

---

#### Method: getDayPatternsDetailed(records) → List\<DayPatternData\>

More accurate day-of-week analysis that normalizes by the number of weeks in the data range.

```
IF records IS EMPTY → RETURN _emptyDayPatterns()

// Step 1: Find date range
SET earliest = records.first.eventAt
SET latest = records.last.eventAt
FOR EACH record IN records
  earliest = MIN(earliest, record.eventAt)
  latest = MAX(latest, record.eventAt)

SET daysBetween = latest - earliest (in days) + 1
SET weeksInRange = daysBetween / 7.0

// Step 2: Count records per day of week
INIT dayCounts = empty Map<int, int>
FOR EACH record IN records
  INCREMENT dayCounts[record.eventAt.weekday]

// Step 3: Calculate weekly average per day
INIT dayPatterns = empty List
FOR day FROM 1 TO 7
  SET count = dayCounts[day] ?? 0
  SET average = count / weeksInRange

  ADD DayPatternData(dayOfWeek: day, dayName: getDayName(day), count, average)

// Step 4: Sort by average descending
SORT dayPatterns BY average DESC

RETURN dayPatterns
```

---

#### Method: getWeekdayWeekendComparison(records) → Record{weekdayAvg, weekendAvg, trend}

Compares weekday (Mon–Fri) vs weekend (Sat–Sun) average usage.

```
SET dayPatterns = getDayPatternsDetailed(records)

// Split into weekdays (dayOfWeek 1–5) and weekends (dayOfWeek 6–7)
SET weekdayDays = dayPatterns WHERE dayOfWeek <= 5
SET weekendDays = dayPatterns WHERE dayOfWeek > 5

// Calculate averages
SET weekdayAvg = IF weekdayDays IS EMPTY THEN 0.0
                 ELSE SUM(weekdayDays.average) / weekdayDays.length

SET weekendAvg = IF weekendDays IS EMPTY THEN 0.0
                 ELSE SUM(weekendDays.average) / weekendDays.length

// Determine trend (10% threshold)
SET trend = "→"  // neutral
IF weekendAvg > weekdayAvg * 1.1
  SET trend = "weekends higher"
ELSE IF weekdayAvg > weekendAvg * 1.1
  SET trend = "weekdays higher"

RETURN (weekdayAvg, weekendAvg, trend)
```

---

#### Method: _emptyDayPatterns() → List\<DayPatternData\> (private)

Returns a list of 7 `DayPatternData` entries (Monday–Sunday) with `count = 0` and `average = 0`.
