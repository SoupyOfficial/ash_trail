# log_record_service

> **Source:** `lib/services/log_record_service.dart`

## Purpose

Core CRUD service for log records implementing offline-first architecture with sync queue management. Handles creation (quick-log, backdate, duration-record), updates, soft/hard deletes, querying by account/date/type, sync state tracking, batch operations, duplicate detection, context updates, and legacy data import. Enforces business rules: accountId validation, location pair integrity (both or neither), rating range 1–10 (no zero), backdate max 30 days, minimum duration 1 second.

## Dependencies

- `package:uuid/uuid.dart` — UUID v4 generation for logIds
- `../logging/app_logger.dart` — Structured logging via `AppLogger`
- `../models/log_record.dart` — `LogRecord` model
- `../models/enums.dart` — `EventType`, `Unit`, `Source`, `SyncState`, `LogReason`, `TimeConfidence` enums
- `../repositories/log_record_repository.dart` — Repository interface and factory
- `validation_service.dart` — Value clamping, rating/location validation, duplicate detection, clock skew
- `database_service.dart` — Singleton database for Hive boxes
- `account_service.dart` — Account existence validation

## Pseudo-Code

### Class: LogRecordService

#### Fields
- `_log` — static logger tagged `'LogRecordService'`
- `_repository` — `LogRecordRepository`
- `_uuid` — `Uuid` instance
- `_accountService` — optional `AccountService` (null in tests)
- `validateAccountId` — bool (default true)

#### Constructor

```
LogRecordService({repository?, accountService?, validateAccountId=true}):
  _accountService = accountService
  IF repository != null:
    _repository = repository
  ELSE:
    dbService = DatabaseService.instance
    dbBoxes = dbService.boxes
    _repository = createLogRecordRepository(dbBoxes)
```

#### `_getDeviceId() → String`
```
RETURN 'device_{timestamp}'   // TODO: platform-specific
```

#### `_getAppVersion() → String`
```
RETURN '1.0.0'                // TODO: package_info_plus
```

---

#### `createLogRecord({accountId, eventType, eventAt?, duration=0, unit=seconds, note?, source=manual, moodRating?, physicalRating?, reasons?, latitude?, longitude?}) → Future<LogRecord>`

```
LOG [CREATE_LOG_START] accountId, eventType, duration, source

// 1. Validate accountId exists
IF validateAccountId AND _accountService != null:
  exists = AWAIT _accountService.accountExists(accountId)
  IF NOT exists:
    LOG ERROR 'Non-existent account'
    THROW ArgumentError('Account does not exist')

// 2. Validate location pair (both present or both null)
IF NOT ValidationService.isValidLocationPair(latitude, longitude):
  THROW ArgumentError('Lat/lon must both be present or both null')

// 3. Validate ratings (null or 1–10, zero not allowed)
IF moodRating != null AND (moodRating < 1 OR > 10):
  THROW ArgumentError('Mood rating must be null or 1–10')
IF physicalRating != null AND (physicalRating < 1 OR > 10):
  THROW ArgumentError('Physical rating must be null or 1–10')

logId = _uuid.v4()
now = NOW
record = LogRecord.create(logId, accountId, eventType, eventAt ?? now,
  createdAt=now, updatedAt=now, duration, unit, note, source,
  deviceId, appVersion, syncState=pending, moodRating, physicalRating,
  reasons, latitude, longitude)

LOG [CREATE_LOG] Persisting to repository
created = AWAIT _repository.create(record)
LOG [CREATE_LOG_END] Record persisted
RETURN created
```

---

#### `importLogRecord({logId, accountId, eventType, eventAt, createdAt, updatedAt, duration, unit, note?, reasons?, moodRating?, physicalRating?, latitude?, longitude?, source=imported, deviceId?, appVersion?}) → Future<LogRecord>`

```
record = LogRecord.create(
  logId = logId,          // preserve remote logId
  ... all fields ...,
  syncState = synced      // came from remote
)
RETURN AWAIT _repository.create(record)
```

---

#### `updateLogRecord(record, {eventType?, eventAt?, duration?, unit?, note?, moodRating?, physicalRating?, reasons?, latitude?, longitude?}) → Future<LogRecord>`

```
IF eventType != null AND changed → record.eventType = eventType
IF eventAt   != null AND changed → record.eventAt = eventAt
IF duration  != null AND changed → record.duration = duration
IF unit      != null AND changed → record.unit = unit
IF note      != null AND changed → record.note = note

record.moodRating     = moodRating ?? record.moodRating
record.physicalRating = physicalRating ?? record.physicalRating

IF reasons != null:
  record.reasons = reasons.isEmpty ? null : reasons

IF latitude != null OR longitude != null:
  record.latitude  = latitude
  record.longitude = longitude

record.markDirty()   // sets updatedAt, increments revision, sets syncState=pending
RETURN AWAIT _repository.update(record)
```

---

#### `deleteLogRecord(record) → Future<void>` (soft delete)

```
record.softDelete()    // sets isDeleted=true, deletedAt=NOW
AWAIT _repository.update(record)
```

#### `hardDeleteLogRecord(record) → Future<void>`

```
AWAIT _repository.delete(record.logId)
```

---

#### `getLogRecordByLogId(logId) → Future<LogRecord?>`

```
RETURN AWAIT _repository.getByLogId(logId)
```

---

#### `getLogRecords({accountId, startDate?, endDate?, eventTypes?, includeDeleted=false}) → Future<List<LogRecord>>`

```
IF startDate AND endDate provided:
  records = AWAIT _repository.getByDateRange(accountId, startDate, endDate)
ELSE:
  records = AWAIT _repository.getByAccount(accountId)

RETURN records.WHERE(record →
  IF not includeDeleted AND record.isDeleted → false
  IF eventTypes != null AND not contains eventType → false
  IF startDate != null AND eventAt before startDate → false
  IF endDate != null AND eventAt after endDate → false
  true
)
```

---

#### `getPendingSync({accountId?, limit=100}) → Future<List<LogRecord>>`

```
records = AWAIT _repository.getPendingSync()
IF accountId != null:
  records = records.WHERE(r.accountId == accountId)
RETURN records.take(limit).toList()
```

---

#### `countLogRecords({accountId, startDate?, endDate?, includeDeleted=false}) → Future<int>`

```
records = AWAIT getLogRecords(accountId, startDate, endDate, includeDeleted)
RETURN records.length
```

---

#### `watchLogRecords({accountId, startDate?, endDate?, includeDeleted=false}) → Stream<List<LogRecord>>`

```
stream = (startDate AND endDate)
  ? _repository.watchByDateRange(accountId, start, end)
  : _repository.watchByAccount(accountId)

RETURN stream.map(records →
  records.WHERE(not deleted unless includeDeleted)
)
```

---

#### `markSynced(record, remoteUpdateTime) → Future<void>`

```
record.markSynced(remoteUpdateTime)
AWAIT _repository.update(record)
```

#### `markSyncError(record, error) → Future<void>`

```
record.markSyncError(error)
AWAIT _repository.update(record)
```

---

#### `applyRemoteDeletion(record, {deletedAt?, remoteUpdatedAt}) → Future<void>`

```
record.isDeleted = true
record.deletedAt = deletedAt ?? record.deletedAt ?? NOW
record.updatedAt = remoteUpdatedAt
record.markSynced(remoteUpdatedAt)
AWAIT _repository.update(record)
```

---

#### `deleteAllByAccount(accountId) → Future<void>`

```
AWAIT _repository.deleteByAccount(accountId)
```

---

#### `batchCreateLogRecords(List<Map> recordData) → Future<List<LogRecord>>`

```
records = []
FOR EACH data IN recordData:
  logId = _uuid.v4(), now = NOW
  record = LogRecord.create(logId, data fields, syncState=pending)
  records.add(record)

FOR EACH record IN records:
  AWAIT _repository.create(record)

RETURN records
```

---

#### `getStatistics({accountId, startDate?, endDate?}) → Future<Map<String,dynamic>>`

```
records = AWAIT getLogRecords(accountId, startDate, endDate, includeDeleted=false)

RETURN {
  totalCount, totalDuration, averageDuration,
  eventTypeCounts (Map<EventType, int>),
  firstEvent, lastEvent
}
```

---

#### `quickLog({accountId, eventType?, duration?, unit?, note?, latitude?, longitude?}) → Future<LogRecord>`

```
now = NOW, logId = _uuid.v4()
clampedDuration = ValidationService.clampValue(duration, unit) ?? duration ?? 0

record = LogRecord.create(
  logId, accountId, eventType=eventType ?? vape, eventAt=now,
  duration=clampedDuration, unit=unit ?? seconds, note,
  latitude, longitude, source=manual,
  timeConfidence=high, syncState=pending
)
RETURN AWAIT _repository.create(record)
```

---

#### `backdateLog({accountId, eventAt, eventType, duration=0, unit=seconds, note?, latitude?, longitude?}) → Future<LogRecord>`

```
now = NOW, logId = _uuid.v4()

IF NOT ValidationService.isValidBackdateTime(eventAt):
  THROW ArgumentError('Backdate time too far in past (max 30 days)')

timeConfidence = ValidationService.detectClockSkew(eventAt)
clampedDuration = ValidationService.clampValue(duration, unit) ?? 0

record = LogRecord.create(logId, accountId, eventType, eventAt,
  createdAt=now, updatedAt=now, clampedDuration, unit, note,
  latitude, longitude, source=manual, syncState=pending, timeConfidence)

AWAIT _repository.create(record)
RETURN record
```

---

#### `recordDurationLog({accountId, durationMs, eventType?, note?, latitude?, longitude?}) → Future<LogRecord>`

```
now = NOW, logId = _uuid.v4()
durationSeconds = durationMs / 1000.0

IF durationSeconds < 1.0:
  THROW ArgumentError('Duration too short (minimum 1 second)')

clampedDuration = ValidationService.clampValue(durationSeconds, seconds) ?? durationSeconds

record = LogRecord.create(logId, accountId, eventType ?? vape,
  eventAt=now, duration=clampedDuration, unit=seconds, note,
  latitude, longitude, source=manual, timeConfidence=high, syncState=pending)

RETURN AWAIT _repository.create(record)
```

---

#### `restoreDeleted(record) → Future<void>`

```
record.isDeleted = false
record.deletedAt = null
record.markDirty()
AWAIT _repository.update(record)
```

---

#### `findPotentialDuplicates(record, {timeTolerance = 1 minute}) → Future<List<LogRecord>>`

```
startTime = record.eventAt - timeTolerance
endTime   = record.eventAt + timeTolerance
candidates = AWAIT _repository.getByDateRange(record.accountId, startTime, endTime)

RETURN candidates.WHERE(candidate →
  candidate.logId != record.logId
  AND same eventType
  AND NOT deleted
  AND ValidationService.isPotentialDuplicate(eventAt1, eventAt2, value1, value2, eventType1, eventType2, timeTolerance)
)
```

---

#### `updateContext(record, {latitude?, longitude?, moodRating?, physicalRating?}) → Future<LogRecord>`

```
changed = false
IF latitude AND longitude both non-null:
  record.latitude = latitude, record.longitude = longitude
  changed = true

IF moodRating != null:
  validatedMood = ValidationService.validateMood(moodRating)    // clamp 1–10
  IF validatedMood != record.moodRating → record.moodRating = validatedMood, changed = true

IF physicalRating != null:
  validatedPhysical = ValidationService.validateCraving(physicalRating)  // clamp 1–10
  IF changed → record.physicalRating = validatedPhysical, changed = true

IF changed:
  record.markDirty()
  AWAIT _repository.update(record)

RETURN record
```

---

#### `importLegacyRecordsBatch(List<LogRecord> records) → Future<int>`

```
importedCount = 0
FOR EACH record:
  TRY:
    existing = AWAIT _repository.getByLogId(record.logId)
    IF existing == null:
      imported = LogRecord.create(... copy fields ..., source=imported, syncState=synced)
      AWAIT _repository.create(imported)
      importedCount++
    ELSE IF record.updatedAt > existing.updatedAt:
      UPDATE existing fields from record
      existing.markDirty()
      AWAIT _repository.update(existing)
      importedCount++
  CATCH e:
    LOG ERROR 'Error importing legacy record'

RETURN importedCount
```

---

#### `hasLegacyDataForAccount(accountId) → Future<bool>`

```
RETURN false   // Marker for LegacyDataAdapter integration
```

#### `getLegacyMigrationStatus(accountId) → Future<Map<String,dynamic>>`

```
RETURN {
  hasPendingMigration: false,
  legacyRecordCount: 0,
  localRecordCount: AWAIT countLogRecords(accountId),
  lastChecked: NOW
}
```
