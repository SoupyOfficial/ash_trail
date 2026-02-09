# range_query_spec

> **Source:** `lib/models/range_query_spec.dart`

## Purpose

Immutable specification object for querying and aggregating log records over time ranges. Used as transient UI state for analytics screens. Provides convenience factories for common ranges (today, week, month, year, YTD) using 6am day boundaries for natural late-night grouping.

## Dependencies

- `enums.dart` — RangeType, GroupBy, EventType enums
- `../utils/day_boundary.dart` — DayBoundary utility for 6am-based day start/end

## Pseudo-Code

### Class: RangeQuerySpec (immutable)

```
CLASS RangeQuerySpec

  FIELDS (final):
    rangeType: RangeType                 // today, week, month, year, ytd, custom, all
    startAt: DateTime                    // inclusive start
    endAt: DateTime                      // inclusive end
    groupBy: GroupBy = day               // how to bucket results
    eventTypes: List<EventType>?         // optional filter by event type
    tags: List<String>?                  // optional tag filter
    minValue: double?                    // optional min value filter
    maxValue: double?                    // optional max value filter
    profileId: String?                   // optional profile filter
    includeDeleted: bool = false         // whether to include soft-deleted records

  // ── Convenience Factories ──

  FACTORY RangeQuerySpec.today({groupBy?})
    startOfDay = DayBoundary.getTodayStart()    // 6:00 AM today
    endOfDay = DayBoundary.getTodayEnd()        // 5:59 AM tomorrow
    RETURN RangeQuerySpec(today, startOfDay, endOfDay, groupBy: hour)
  END FACTORY

  FACTORY RangeQuerySpec.week({groupBy?})
    startOfWeek = DayBoundary.getWeekStart(now)
    RETURN RangeQuerySpec(week, startOfWeek, now, groupBy: day)
  END FACTORY

  FACTORY RangeQuerySpec.month({groupBy?})
    startOfMonth = first day of current month
    RETURN RangeQuerySpec(month, startOfMonth, now, groupBy: day)
  END FACTORY

  FACTORY RangeQuerySpec.year({groupBy?})
    startOfYear = January 1 of current year
    RETURN RangeQuerySpec(year, startOfYear, now, groupBy: month)
  END FACTORY

  FACTORY RangeQuerySpec.ytd({groupBy?})
    startOfYear = January 1 of current year
    RETURN RangeQuerySpec(ytd, startOfYear, now, groupBy: month)
  END FACTORY

  FACTORY RangeQuerySpec.custom({required startAt, required endAt, ...filters})
    RETURN RangeQuerySpec(custom, startAt, endAt, groupBy: day, ...filters)
  END FACTORY

  // ── Copy With ──

  FUNCTION copyWith({...all fields optional}) -> RangeQuerySpec
    RETURN new RangeQuerySpec with fallback-to-this pattern
  END FUNCTION

  // ── Utility ──

  GETTER durationInDays -> int
    RETURN endAt.difference(startAt).inDays
  END GETTER

  FUNCTION containsDate(date: DateTime) -> bool
    RETURN date > (startAt - 1 second) AND date < (endAt + 1 second)
  END FUNCTION

  FUNCTION toString() -> String
    RETURN "RangeQuerySpec(type: {rangeType}, start: {startAt}, end: {endAt}, groupBy: {groupBy})"
  END FUNCTION

END CLASS
```
