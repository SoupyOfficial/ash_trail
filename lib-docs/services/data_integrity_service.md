# data_integrity_service

> **Source:** `lib/services/data_integrity_service.dart`

## Purpose

Checks and repairs data integrity issues in local log records. Detects orphaned records (belonging to non-existent accounts), duplicate logIds, invalid timestamps, invalid ratings (outside 1–10 range), and invalid location data (one coordinate present but not both). Provides a repair mechanism that reassigns orphans, removes duplicates, clamps ratings, and clears incomplete locations.

## Dependencies

- `../logging/app_logger.dart` — Structured logging via `AppLogger`
- `../models/log_record.dart` — `LogRecord` model
- `../models/enums.dart` — `SyncState` enum
- `../repositories/log_record_repository.dart` — Repository interface and factory
- `account_service.dart` — Account existence checks (via adapter)
- `database_service.dart` — Singleton database for default repository creation

## Pseudo-Code

### Class: IntegrityCheckResult

#### Fields
- `orphanedRecords` — records whose accountId matches no existing account
- `duplicateRecords` — `Map<logId, List<LogRecord>>` of duplicate groups
- `invalidTimestampRecords` — records with eventAt before 10 years ago or after tomorrow
- `invalidRatingRecords` — records with mood/physical rating outside 1–10
- `invalidLocationRecords` — records with only one of lat/lon set

#### `totalIssues → int` (getter)

```
orphanedRecords.length
  + SUM(duplicateRecords.values → list.length - 1)
  + invalidTimestampRecords.length
  + invalidRatingRecords.length
  + invalidLocationRecords.length
```

#### `isHealthy → bool` (getter)

```
RETURN totalIssues == 0
```

---

### Class: RepairResult

#### Fields
- `orphansReassigned`, `duplicatesRemoved`, `ratingsFixed`, `locationsCleared` — int counters
- `errors` — list of error messages

#### `success → bool` (getter)
```
RETURN errors.isEmpty
```

---

### Abstract Class: AccountIntegrityValidator

```
accountExists(String userId) → Future<bool>
getAllAccountIds() → Future<Set<String>>
```

### Class: AccountServiceValidator implements AccountIntegrityValidator

```
Wraps AccountService to satisfy the AccountIntegrityValidator interface
```

---

### Class: DataIntegrityService

#### Fields
- `_log` — static logger tagged `'DataIntegrityService'`
- `_accountValidator` — `AccountIntegrityValidator` (injected)
- `_repository` — `LogRecordRepository` (injected or default)

#### Constructor

```
DataIntegrityService({required accountValidator, repository?}):
  _accountValidator = accountValidator
  _repository = repository ?? _createDefaultRepository()
```

---

#### `runIntegrityCheck() → Future<IntegrityCheckResult>`

```
LOG 'Starting integrity check'
validAccountIds = AWAIT _accountValidator.getAllAccountIds()
LOG 'Found {count} valid accounts'
allRecords = AWAIT _repository.getAll()

orphanedRecords = []
duplicateMap = {}
invalidTimestamps = []
invalidRatings = []
invalidLocations = []
seenLogIds = {}

FOR EACH record IN allRecords:

  // 1. Orphan check
  IF record.accountId NOT IN validAccountIds:
    orphanedRecords.add(record)
    LOG WARNING 'Orphaned record: logId (accountId)'

  // 2. Duplicate check
  IF seenLogIds CONTAINS record.logId:
    duplicateMap.putIfAbsent(logId, [seenLogIds[logId]])
    duplicateMap[logId].add(record)
    LOG WARNING 'Duplicate logId'
  ELSE:
    seenLogIds[logId] = record

  // 3. Timestamp validation
  now = NOW
  tenYearsAgo = now - 3650 days
  oneDayFromNow = now + 1 day
  IF record.eventAt BEFORE tenYearsAgo OR AFTER oneDayFromNow:
    invalidTimestamps.add(record)
    LOG WARNING 'Invalid timestamp'

  // 4. Rating validation (must be 1–10 if set)
  IF (moodRating != null AND (moodRating < 1 OR > 10))
     OR (physicalRating != null AND (physicalRating < 1 OR > 10)):
    invalidRatings.add(record)
    LOG WARNING 'Invalid rating'

  // 5. Location pair integrity (both or neither)
  IF (latitude != null AND longitude == null)
     OR (latitude == null AND longitude != null):
    invalidLocations.add(record)
    LOG WARNING 'Invalid location'

result = IntegrityCheckResult(orphanedRecords, duplicateMap, ...)
LOG 'Check complete: result'
RETURN result
```

---

#### `checkAccountIntegrity(String accountId) → Future<IntegrityCheckResult>`

```
Same logic as runIntegrityCheck() but scoped to records from _repository.getByAccount(accountId)
```

---

#### `repairIssues({checkResult, targetAccountId?, removeDuplicates=true, fixRatings=true, clearInvalidLocations=true}) → Future<RepairResult>`

```
LOG 'Starting repair'
errors = [], counters = 0

// 1. Repair orphaned records
IF checkResult.orphanedRecords is NOT empty:
  IF targetAccountId == null:
    errors.add('No target account specified')
  ELSE:
    exists = AWAIT _accountValidator.accountExists(targetAccountId)
    IF NOT exists:
      errors.add('Target account does not exist')
    ELSE:
      FOR EACH record IN orphanedRecords:
        TRY:
          fixedRecord = LogRecord.create(
            logId = record.logId,
            accountId = targetAccountId,  // reassign
            ... copy all other fields ...,
            syncState = SyncState.pending
          )
          AWAIT _repository.update(fixedRecord)
          orphansReassigned++
          LOG 'Reassigned logId to targetAccountId'
        CATCH e:
          errors.add('Failed to reassign logId: e')

// 2. Remove duplicates (keep most recently updated)
IF removeDuplicates AND duplicateRecords is NOT empty:
  FOR EACH (logId, duplicates) IN duplicateRecords:
    SORT duplicates by updatedAt DESCENDING
    FOR i = 1 TO duplicates.length-1:   // skip first (keep newest)
      TRY:
        AWAIT _repository.delete(duplicates[i].logId)
        duplicatesRemoved++
      CATCH: errors.add(...)

// 3. Fix invalid ratings (clamp to 1–10)
IF fixRatings AND invalidRatingRecords is NOT empty:
  FOR EACH record:
    TRY:
      needsUpdate = false
      IF moodRating outside 1–10 → clamp, needsUpdate = true
      IF physicalRating outside 1–10 → clamp, needsUpdate = true
      IF needsUpdate:
        record.markDirty()
        AWAIT _repository.update(record)
        ratingsFixed++
    CATCH: errors.add(...)

// 4. Clear invalid locations (set both to null)
IF clearInvalidLocations AND invalidLocationRecords is NOT empty:
  FOR EACH record:
    TRY:
      record.latitude = null
      record.longitude = null
      record.markDirty()
      AWAIT _repository.update(record)
      locationsCleared++
    CATCH: errors.add(...)

result = RepairResult(orphansReassigned, duplicatesRemoved, ratingsFixed, locationsCleared, errors)
LOG 'Repair complete: result'
RETURN result
```

---

#### `isDataHealthy() → Future<bool>`

```
result = AWAIT runIntegrityCheck()
RETURN result.isHealthy
```

---

#### `getHealthSummary() → Future<String>`

```
result = AWAIT runIntegrityCheck()
RETURN result.toString()
```
