# validation_service

> **Source:** `lib/services/validation_service.dart`

## Purpose

Static utility class providing pure-function validation, clamping, normalization, and data-quality scoring for log records. Covers value range enforcement per unit type, statistical outlier detection (z-score), timestamp reasonableness, clock-skew detection, backdate limits (30 days), mood/craving/physical rating validation (1–10, null OK, zero invalid), location pair cross-field validation, tag sanitization, duplicate detection, and batch quality scoring.

## Dependencies

- `dart:math` — `sqrt`, `pow`, `min`, `max`
- `../models/enums.dart` — `Unit`, `TimeConfidence`

## Pseudo-Code

### Class: ValidationService (all static methods)

---

#### `clampValue(double? value, Unit? unit) → double?`

```
IF value == null → RETURN null

SWITCH unit:
  CASE seconds:  RETURN value.clamp(0, 86400)      // 0–24 hours
  CASE minutes:  RETURN value.clamp(0, 1440)        // 0–24 hours
  CASE hours:    RETURN value.clamp(0, 24)
  CASE count:    RETURN value.clamp(0, 1000)
  CASE ml:       RETURN value.clamp(0, 10000)       // 0–10 liters
  CASE mg:       RETURN value.clamp(0, 100000)      // 0–100g
  CASE puffs:    RETURN value.clamp(0, 500)
  CASE pieces:   RETURN value.clamp(0, 100)
  DEFAULT:       RETURN value.clamp(0, 100000)
```

---

#### `isOutlier(double value, List<double> historicalValues, {threshold = 3.0}) → bool`

```
IF historicalValues.length < 3 → RETURN false    // not enough data

mean = average(historicalValues)
stdDev = standardDeviation(historicalValues)

IF stdDev == 0 → RETURN value != mean

zScore = |value - mean| / stdDev
RETURN zScore > threshold
```

---

#### `detectOutliers(List<double> values, {threshold = 3.0}) → List<int>`

```
IF values.length < 3 → RETURN []

mean = average(values)
stdDev = standardDeviation(values)
IF stdDev == 0 → RETURN []

outlierIndices = []
FOR i, value IN values:
  zScore = |value - mean| / stdDev
  IF zScore > threshold:
    outlierIndices.add(i)
RETURN outlierIndices
```

---

#### `isValidValue(double value, Unit unit) → bool`

```
SWITCH unit:
  CASE seconds:  RETURN 0 ≤ value ≤ 86400
  CASE minutes:  RETURN 0 ≤ value ≤ 1440
  CASE hours:    RETURN 0 ≤ value ≤ 24
  CASE count:    RETURN 0 ≤ value ≤ 1000
  CASE ml:       RETURN 0 ≤ value ≤ 10000
  CASE mg:       RETURN 0 ≤ value ≤ 100000
  CASE puffs:    RETURN 0 ≤ value ≤ 500
  CASE pieces:   RETURN 0 ≤ value ≤ 100
  DEFAULT:       RETURN 0 ≤ value ≤ 100000
```

---

#### `normalizeToUtc(DateTime dateTime) → DateTime`

```
IF dateTime.isUtc → RETURN dateTime
RETURN dateTime.toUtc()
```

#### `toLocalTime(DateTime utcDateTime) → DateTime`

```
IF NOT utcDateTime.isUtc → RETURN utcDateTime
RETURN utcDateTime.toLocal()
```

---

#### `detectClockSkew(DateTime eventTime) → TimeConfidence`

```
now = DateTime.now()
diff = |eventTime - now|

IF diff < 1 minute   → RETURN TimeConfidence.high
IF diff < 5 minutes  → RETURN TimeConfidence.medium
IF diff < 1 hour     → RETURN TimeConfidence.low
RETURN TimeConfidence.uncertain
```

---

#### `isReasonableTimestamp(DateTime timestamp) → bool`

```
now = DateTime.now()
tenYearsAgo = now - 10 years
oneDayFuture = now + 1 day

RETURN timestamp.isAfter(tenYearsAgo) AND timestamp.isBefore(oneDayFuture)
```

---

#### `isValidBackdateTime(DateTime eventTime) → bool`

```
now = DateTime.now()
maxBackdate = now - 30 days

RETURN eventTime.isAfter(maxBackdate) AND eventTime.isBefore(now + 1 minute)
```

---

#### `validateMood(int? value) → int?`

```
IF value == null → RETURN null
IF value == 0   → RETURN null      // zero not valid, treat as no rating
RETURN value.clamp(1, 10)
```

#### `validateCraving(int? value) → int?`

```
IF value == null → RETURN null
IF value == 0   → RETURN null
RETURN value.clamp(1, 10)
```

#### `validatePhysicalRating(int? value) → int?`

```
IF value == null → RETURN null
IF value == 0   → RETURN null
RETURN value.clamp(1, 10)
```

---

#### `isValidRating(int? value) → bool`

```
IF value == null → RETURN true      // null is acceptable
RETURN value >= 1 AND value <= 10
```

---

#### `isValidLocationPair(double? latitude, double? longitude) → bool`

```
bothNull    = (latitude == null AND longitude == null)
bothPresent = (latitude != null AND longitude != null)

IF bothNull    → RETURN true
IF bothPresent → RETURN isValidLatitude(latitude) AND isValidLongitude(longitude)
RETURN false     // one null, one not → invalid
```

#### `isValidLatitude(double lat) → bool`

```
RETURN lat >= -90 AND lat <= 90
```

#### `isValidLongitude(double lon) → bool`

```
RETURN lon >= -180 AND lon <= 180
```

---

#### `cleanTags(List<String>? tags) → List<String>?`

```
IF tags == null OR tags.isEmpty → RETURN null
cleaned = tags
  .map(t → t.trim().toLowerCase())
  .where(t → t.isNotEmpty AND isValidTag(t))
  .toSet()         // deduplicate
  .toList()
RETURN cleaned.isEmpty ? null : cleaned
```

#### `isValidTag(String tag) → bool`

```
// Alphanumeric, hyphens, underscores; 1–50 chars
RETURN RegExp(r'^[a-zA-Z0-9_-]{1,50}$').hasMatch(tag)
```

---

#### `areTimestampsWithinTolerance(DateTime a, DateTime b, {tolerance = 1 minute}) → bool`

```
diff = |a - b|
RETURN diff <= tolerance
```

---

#### `isPotentialDuplicate(DateTime time1, DateTime time2, double? value1, double? value2, dynamic type1, dynamic type2, {timeTolerance = 1 minute}) → bool`

```
IF NOT areTimestampsWithinTolerance(time1, time2, tolerance=timeTolerance):
  RETURN false

IF type1 != type2 → RETURN false

// If both values present, check if they're the same
IF value1 != null AND value2 != null:
  RETURN value1 == value2

// If both null, timestamps and type match → possible duplicate
RETURN true
```

---

#### `validateBatch(List<Map<String, dynamic>> records) → Map<String, dynamic>`

```
valid = [], invalid = [], warnings = []

FOR EACH record IN records:
  recordWarnings = []

  // Check timestamp
  IF record has 'eventAt':
    IF NOT isReasonableTimestamp(record['eventAt']):
      invalid.add({ record, reason: 'unreasonable timestamp' })
      CONTINUE

  // Check value + unit
  IF record has 'duration' AND 'unit':
    IF NOT isValidValue(record['duration'], record['unit']):
      recordWarnings.add('value out of range, will be clamped')

  // Check ratings
  IF record has 'moodRating':
    IF NOT isValidRating(record['moodRating']):
      recordWarnings.add('invalid mood rating')

  // Check location pair
  IF record has 'latitude' OR 'longitude':
    IF NOT isValidLocationPair(record['latitude'], record['longitude']):
      invalid.add({ record, reason: 'incomplete location pair' })
      CONTINUE

  valid.add(record)
  IF recordWarnings.isNotEmpty:
    warnings.addAll(recordWarnings)

RETURN {
  validRecords: valid,
  invalidRecords: invalid,
  warnings: warnings,
  totalProcessed: records.length,
  validCount: valid.length,
  invalidCount: invalid.length
}
```

---

#### `calculateDataQualityScore(List<Map<String, dynamic>> records) → double`

```
IF records.isEmpty → RETURN 100.0

totalScore = 0.0
FOR EACH record IN records:
  recordScore = 100.0

  // Timestamp quality (-20 if unreasonable)
  IF record has 'eventAt' AND NOT isReasonableTimestamp(record['eventAt']):
    recordScore -= 20

  // Value quality (-15 if out of range)
  IF record has 'duration' AND 'unit' AND NOT isValidValue(record['duration'], record['unit']):
    recordScore -= 15

  // Rating quality (-10 per invalid rating)
  IF record has 'moodRating' AND NOT isValidRating(record['moodRating']):
    recordScore -= 10
  IF record has 'physicalRating' AND NOT isValidRating(record['physicalRating']):
    recordScore -= 10

  // Location quality (-10 if incomplete pair)
  IF (record has 'latitude' OR 'longitude') AND NOT isValidLocationPair(...):
    recordScore -= 10

  // Completeness bonus (-5 for each missing optional field)
  IF record missing 'note'         → recordScore -= 5
  IF record missing 'moodRating'   → recordScore -= 5
  IF record missing 'latitude'     → recordScore -= 5

  totalScore += max(0, recordScore)

RETURN totalScore / records.length    // average score 0–100
```
