# log_record_provider

> **Source:** `lib/providers/log_record_provider.dart`

## Purpose

Riverpod state management for log records. Contains the `LogDraft` immutable form state model with validation, `LogDraftNotifier` for form interactions, and a full suite of providers for CRUD, querying, statistics, and mutations on log records. Parameter classes (`CreateLogRecordParams`, `LogRecordsParams`) use proper equality for provider deduplication.

## Dependencies

- `package:flutter_riverpod/flutter_riverpod.dart` — StateNotifier, Provider, StreamProvider, FutureProvider
- `package:flutter/foundation.dart` — @immutable annotation
- `../logging/app_logger.dart` — Structured logging
- `../models/log_record.dart` — LogRecord model
- `../models/enums.dart` — EventType, Unit, Source, LogReason, SyncState
- `../services/log_record_service.dart` — LogRecordService for business logic
- `account_provider.dart` — activeAccountProvider for deriving active account ID

## Pseudo-Code

### Class: LogDraft (@immutable)

```
CLASS LogDraft (immutable)

  FIELDS (final):
    eventType: EventType = EventType.vape
    duration: double?
    unit: Unit = Unit.seconds
    eventTime: DateTime                  // defaults to now via _DefaultDateTime
    note: String?
    moodRating: double?                  // 1-10, null = not set
    physicalRating: double?              // 1-10, null = not set
    reasons: List<LogReason>?
    latitude: double?
    longitude: double?
    isValid: bool                        // computed from validation

  FACTORY LogDraft.empty()
    RETURN LogDraft with eventTime = now
  END FACTORY

  // ── Copy With (nullable callback pattern) ──

  FUNCTION copyWith({
    eventType?,
    duration as double? Function()?,     // () => null means "set to null"
    unit?,                               // vs omitting means "keep current"
    eventTime?,
    note as String? Function()?,
    moodRating as double? Function()?,
    physicalRating as double? Function()?,
    reasons as List<LogReason>? Function()?,
    latitude as double? Function()?,
    longitude as double? Function()?,
  }) -> LogDraft
    COMPUTE isValid using _validate(...)
    RETURN new LogDraft._(all resolved values, isValid)
  END FUNCTION

  // ── Validation ──

  STATIC FUNCTION _validate(eventType, duration, unit, moodRating, physicalRating) -> bool
    IF duration != null AND duration < 0 THEN RETURN false
    IF moodRating != null AND (moodRating < 1 OR moodRating > 10) THEN RETURN false
    IF physicalRating != null AND (physicalRating < 1 OR physicalRating > 10) THEN RETURN false
    RETURN true
  END FUNCTION

  // ── Equality ──

  operator == : compare all fields including list equality for reasons
  hashCode   : Object.hash of all fields

END CLASS
```

### Class: _DefaultDateTime

```
CLASS _DefaultDateTime IMPLEMENTS DateTime
  // Const-constructible placeholder
  // All method calls delegate to DateTime.now() via noSuchMethod
END CLASS
```

### Class: LogDraftNotifier (StateNotifier\<LogDraft\>)

```
CLASS LogDraftNotifier EXTENDS StateNotifier<LogDraft>

  CONSTRUCTOR()
    INITIAL STATE = LogDraft.empty()
  END

  FUNCTION setEventType(type) -> void
    SET state with eventType = type, unit = seconds (default)
  END

  FUNCTION setDuration(duration?) -> void
    SET state with duration callback
  END

  FUNCTION setUnit(unit) -> void
    SET state with unit
  END

  FUNCTION setEventTime(time) -> void
    SET state with eventTime
  END

  FUNCTION setNote(note?) -> void
    SET state with note callback (convert empty string to null)
  END

  FUNCTION setMoodRating(moodRating?) -> void
    SET state with moodRating callback
  END

  FUNCTION setPhysicalRating(physicalRating?) -> void
    SET state with physicalRating callback
  END

  FUNCTION toggleReason(reason: LogReason) -> void
    GET currentReasons from state
    IF reason in currentReasons THEN REMOVE it
    ELSE ADD it
    SET state with reasons callback (null if empty)
  END

  FUNCTION setReasons(reasons?) -> void
    SET state with reasons callback
  END

  FUNCTION setLatitude(lat?) -> void
    SET state with latitude callback
  END

  FUNCTION setLongitude(lng?) -> void
    SET state with longitude callback
  END

  FUNCTION setLocation(lat?, lng?) -> void
    SET state with both lat/lng callbacks
  END

  FUNCTION reset() -> void
    SET state = LogDraft.empty()
  END

  GETTER isDirty -> bool
    COMPARE state fields against LogDraft.empty()
    RETURN true if any field differs from default
  END

END CLASS
```

### Providers

```
STATE_NOTIFIER_PROVIDER logDraftProvider -> LogDraft
  RETURN new LogDraftNotifier()
END

PROVIDER logRecordServiceProvider -> LogRecordService
  RETURN new LogRecordService()
END

PROVIDER activeAccountIdProvider -> String?
  WATCH activeAccountProvider
  EXTRACT userId from data state, null if loading/error
  LOG current value and state
  RETURN userId or null
END

STREAM_PROVIDER activeAccountLogRecordsProvider -> List<LogRecord>
  WATCH activeAccountIdProvider
  IF accountId IS null THEN RETURN Stream.value([])
  CREATE LogRecordsParams with accountId
  WATCH logRecordsProvider(params)
  MAP inner provider state to stream:
    data → Stream.value(records)
    loading → Stream.value([])
    error → Stream.value([])
  RETURN stream
END

FUTURE_PROVIDER.FAMILY createLogRecordProvider(params: CreateLogRecordParams) -> LogRecord
  READ service, activeAccountId
  IF accountId IS null THEN THROW "No active account selected"
  RETURN AWAIT service.createLogRecord(accountId, params.*)
END

STREAM_PROVIDER.FAMILY logRecordsProvider(params: LogRecordsParams) -> List<LogRecord>
  READ service
  RESOLVE accountId = params.accountId OR activeAccountIdProvider
  IF null THEN RETURN empty stream
  RETURN service.watchLogRecords(accountId, params.startDate, params.endDate, params.includeDeleted)
END

FUTURE_PROVIDER.FAMILY getLogRecordsProvider(params: LogRecordsParams) -> List<LogRecord>
  READ service
  RESOLVE accountId, RETURN [] if null
  RETURN AWAIT service.getLogRecords(accountId, params.*)
END

FUTURE_PROVIDER.FAMILY logRecordByIdProvider(logId: String) -> LogRecord?
  READ service
  RETURN AWAIT service.getLogRecordByLogId(logId)
END

STREAM_PROVIDER.FAMILY logRecordStatsProvider(params: LogRecordsParams) -> Map<String, dynamic>
  READ service, RESOLVE accountId (return {} if null)
  SUBSCRIBE to watchLogRecords
  MAP records to stats:
    totalCount = records.length
    totalDuration = SUM of all durations
    averageDuration = totalDuration / totalCount (or 0)
    eventTypeCounts = count per EventType
    firstEvent / lastEvent = boundary timestamps
  RETURN stats map
END

FUTURE_PROVIDER pendingSyncCountProvider -> int
  READ service, accountId
  IF null RETURN 0
  RETURN AWAIT service.countLogRecords(accountId)
END
```

### Class: CreateLogRecordParams

```
CLASS CreateLogRecordParams
  FIELDS: eventType, eventAt?, duration?, unit, note?, source, moodRating?, physicalRating?, reasons?, latitude?, longitude?
  EQUALITY: all fields including list equality for reasons
  HASH: Object.hash of all fields
END CLASS
```

### Class: LogRecordsParams

```
CLASS LogRecordsParams
  FIELDS: accountId?, startDate?, endDate?, eventTypes?, includeDeleted=false
  EQUALITY: accountId, startDate, endDate, includeDeleted
  HASH: Object.hash of those fields
END CLASS
```

### Class: LogRecordNotifier (StateNotifier\<AsyncValue\<LogRecord?\>\>)

```
CLASS LogRecordNotifier EXTENDS StateNotifier<AsyncValue<LogRecord?>>

  CONSTRUCTOR(ref)
    INITIAL STATE = data(null)
  END

  ASYNC FUNCTION updateLogRecord(record, {...field overrides}) -> void
    SET state = loading
    TRY
      READ service
      updated = AWAIT service.updateLogRecord(record, overrides)
      SET state = data(updated)
    CATCH: SET state = error
  END

  ASYNC FUNCTION deleteLogRecord(record: LogRecord) -> void
    SET state = loading
    TRY
      READ service
      AWAIT service.deleteLogRecord(record)
      SET state = data(null)
    CATCH: SET state = error
  END

  ASYNC FUNCTION restoreLogRecord(record: LogRecord) -> void
    SET state = loading
    TRY
      READ service
      AWAIT service.restoreDeleted(record)
      SET state = data(record)
    CATCH: SET state = error
  END

  FUNCTION reset() -> void
    SET state = data(null)
  END

END CLASS
```
