# daily_rollup

> **Source:** `lib/models/daily_rollup.dart`

## Purpose

Aggregated data model for a specific day, used for performance optimization in analytics. Pre-computes daily totals so charts and summaries don't need to scan individual log records. Supports cache invalidation via source range hashing.

## Dependencies

None (standalone model)

## Pseudo-Code

### Class: DailyRollup

```
CLASS DailyRollup

  FIELDS:
    id: int = 0                          // local database ID
    accountId: String (late)             // owning account
    profileId: String?                   // optional profile filter
    date: String (late)                  // "YYYY-MM-DD" format
    totalValue: double (late)            // aggregated value for the day
    eventCount: int (late)               // number of events
    firstEventAt: DateTime?              // earliest event timestamp
    lastEventAt: DateTime?               // latest event timestamp
    updatedAt: DateTime (late)           // when rollup was computed
    sourceRangeHash: String?             // hash for cache validation
    eventTypeBreakdownJson: String?      // JSON string of per-type counts

  // ── Default Constructor ──

  CONSTRUCTOR DailyRollup()
    // leaves late fields uninitialized
  END CONSTRUCTOR

  // ── Named Constructor ──

  CONSTRUCTOR DailyRollup.create({required accountId, required date, ...})
    ASSIGN all fields
    SET updatedAt = provided OR DateTime.now()
    SET totalValue default 0
    SET eventCount default 0
  END CONSTRUCTOR

  // ── Cache Validation ──

  FUNCTION isStale(currentHash: String) -> bool
    RETURN sourceRangeHash != currentHash
    // true = underlying data changed, rollup needs recomputation
  END FUNCTION

  // ── Copy With ──

  FUNCTION copyWith({...all fields optional}) -> DailyRollup
    CREATE new DailyRollup.create with fallback-to-this pattern
    PRESERVE id from original
    RETURN new rollup
  END FUNCTION

END CLASS
```
