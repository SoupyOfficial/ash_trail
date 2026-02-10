# day_boundary

> **Source:** `lib/utils/day_boundary.dart`

## Purpose

Utility class for calculating "logical day" boundaries where 6 AM is treated as the start of a new day instead of midnight. This aligns late-night activity (e.g., 2 AM) with the previous calendar day, matching natural sleep/wake cycles. Used for grouping log records, date comparisons, and week calculations throughout the app.

## Dependencies

_No external imports — pure Dart utility class._

## Pseudo-Code

---

### Class: DayBoundary

Static-only utility class (private constructor prevents instantiation).

#### Constant: dayStartHour = 6
The hour (24h format) at which a new logical day begins. Times from 6:00 AM to 5:59 AM the next day belong to the same logical day.

---

#### Method: getDayStart(dateTime) → DateTime
Returns the start of the logical day for the given `dateTime`.

```
IF dateTime.hour < dayStartHour (6)
  // Before 6 AM → belongs to the PREVIOUS calendar day
  SET previousDay = dateTime - 1 day
  RETURN DateTime(previousDay.year, previousDay.month, previousDay.day, dayStartHour)
ELSE
  // 6 AM or later → current calendar day
  RETURN DateTime(dateTime.year, dateTime.month, dateTime.day, dayStartHour)

// Examples:
//   2 AM Tuesday  → Monday 6:00 AM
//   7 AM Tuesday  → Tuesday 6:00 AM
//  11 PM Tuesday  → Tuesday 6:00 AM
```

---

#### Method: getTodayStart() → DateTime
```
RETURN getDayStart(DateTime.now())
```

---

#### Method: getYesterdayStart() → DateTime
```
RETURN getTodayStart() - 1 day
```

---

#### Method: getDayStartDaysAgo(daysAgo) → DateTime
```
// daysAgo = 0 → today, 1 → yesterday, etc.
RETURN getTodayStart() - daysAgo days
```

---

#### Method: getDayEnd(dateTime) → DateTime
Returns the instant before the next logical day starts (exclusive upper bound).

```
RETURN getDayStart(dateTime) + 1 day - 1 microsecond
```

---

#### Method: getTodayEnd() → DateTime
```
RETURN getDayEnd(DateTime.now())
```

---

#### Method: isSameDay(a, b) → bool
Checks if two DateTimes fall within the same logical day.

```
SET dayA = getDayStart(a)
SET dayB = getDayStart(b)
RETURN dayA.year == dayB.year
   AND dayA.month == dayB.month
   AND dayA.day == dayB.day
```

---

#### Method: isToday(dateTime) → bool
```
RETURN isSameDay(dateTime, DateTime.now())
```

---

#### Method: isYesterday(dateTime) → bool
```
SET yesterday = DateTime.now() - 1 day
RETURN isSameDay(dateTime, yesterday)
```

---

#### Method: isWithinDays(dateTime, days) → bool
Checks if `dateTime` is within the last `days` logical days (inclusive of today).

```
SET todayStart = getTodayStart()
SET rangeStart = todayStart - (days - 1) days
RETURN dateTime > rangeStart OR dateTime == rangeStart
```

---

#### Method: daysBetween(from, to) → int
Returns the number of logical days between two DateTimes (positive if `to` is after `from`).

```
SET fromStart = getDayStart(from)
SET toStart = getDayStart(to)
RETURN toStart.difference(fromStart).inDays
```

---

#### Method: getCalendarDate(dateTime) → DateTime
Returns midnight (00:00) of the calendar date representing this logical day. Useful for grouping by date.

```
SET dayStart = getDayStart(dateTime)
RETURN DateTime(dayStart.year, dayStart.month, dayStart.day)

// Examples:
//   2 AM Tuesday  → Monday 00:00
//   7 AM Tuesday  → Tuesday 00:00
```

---

#### Method: getWeekStart(dateTime) → DateTime
Returns the start of the logical week containing `dateTime`. Weeks start on Monday at `dayStartHour`.

```
SET dayStart = getDayStart(dateTime)
SET weekday = dayStart.weekday   // Monday = 1, Sunday = 7
SET daysFromMonday = weekday - 1
RETURN dayStart - daysFromMonday days
```

---

#### Method: getThisWeekStart() → DateTime
```
RETURN getWeekStart(DateTime.now())
```
