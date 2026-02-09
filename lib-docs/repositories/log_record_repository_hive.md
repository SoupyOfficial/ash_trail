# log_record_repository_hive

> **Source:** `lib/repositories/log_record_repository_hive.dart`

## Purpose

Hive-backed implementation of `LogRecordRepository`. Stores log records as JSON in a Hive `Box`, converting between `LogRecord` and `WebLogRecord` models. Maintains auto-incrementing internal IDs, broadcast stream for reactive updates, and stores extra sync fields (syncState, revision, syncError, etc.) alongside the web model JSON.

## Dependencies

- `dart:async` — StreamController, StreamSubscription
- `package:hive/hive.dart` — Hive Box for local storage
- `../models/log_record.dart` — LogRecord model
- `../models/web_models.dart` — WebLogRecord for JSON serialization
- `../models/model_converters.dart` — LogRecordWebConversion extension
- `../models/enums.dart` — SyncState, EventType enums
- `log_record_repository.dart` — LogRecordRepository interface

## Pseudo-Code

### Class: LogRecordRepositoryHive (implements LogRecordRepository)

```
CLASS LogRecordRepositoryHive IMPLEMENTS LogRecordRepository

  _box: Hive Box (late)
  _controller: StreamController<List<LogRecord>> (broadcast)
  _boxWatchSubscription: StreamSubscription?
  _nextId: int = 1

  // ── Constructor ──

  CONSTRUCTOR(boxes: Map)
    SET _box = boxes['logRecords'] as Box
    SUBSCRIBE _box.watch() → _emitChanges on each change
    SET _nextId = MAX(all existing record IDs) + 1
    CALL _emitChanges()    // initial emission
  END

  FUNCTION dispose()
    CANCEL _boxWatchSubscription
    CLOSE _controller
  END

  // ── Internal Helpers ──

  PRIVATE FUNCTION _emitChanges() -> void
    IF _box is not open THEN RETURN
    ADD _getAllRecords() to _controller
  END

  PRIVATE FUNCTION _getAllRecords() -> List<LogRecord>
    FOR EACH key IN _box.keys
      PARSE json from _box.get(key)
      CONVERT WebLogRecord.fromJson → LogRecord via LogRecordWebConversion
      USE stored _internalId OR assign _nextId++
      PASS full json as extraFields (for sync metadata)
      ADD to records list
    END FOR
    RETURN records
  END

  // ── CRUD ──

  ASYNC FUNCTION create(record: LogRecord) -> LogRecord
    IF record.id == 0 THEN ASSIGN _nextId++
    CONVERT record → WebLogRecord → JSON
    AUGMENT json with extra sync fields:
      _internalId, syncState, revision, deletedAt, syncedAt, syncError, lastRemoteUpdateAt
    PUT json into _box using record.logId as key
    RETURN record
  END

  ASYNC FUNCTION update(record: LogRecord) -> LogRecord
    CONVERT record → WebLogRecord → JSON
    AUGMENT json with extra sync fields
    PUT json into _box using record.logId as key
    // Re-read from box to ensure consistency
    RETURN AWAIT getByLogId(record.logId)
  END

  ASYNC FUNCTION delete(logId: String) -> void
    DELETE from _box using logId as key
  END

  ASYNC FUNCTION getByLogId(logId: String) -> LogRecord?
    json = _box.get(logId)
    IF null THEN RETURN null
    CONVERT json → WebLogRecord → LogRecord with extraFields
    RETURN record
  END

  // ── Query Methods ──

  ASYNC FUNCTION getAll() -> List<LogRecord>
    RETURN _getAllRecords()
  END

  ASYNC FUNCTION getByAccount(accountId: String) -> List<LogRecord>
    FILTER _getAllRecords() WHERE accountId matches
    SORT by eventAt descending (newest first)
    RETURN filtered list
  END

  ASYNC FUNCTION getByDateRange(accountId, start, end) -> List<LogRecord>
    FILTER WHERE accountId matches AND NOT deleted AND eventAt in range
    SORT by eventAt descending
    RETURN filtered list
  END

  ASYNC FUNCTION getByEventType(accountId, eventType) -> List<LogRecord>
    FILTER WHERE accountId matches AND NOT deleted AND eventType matches
    SORT by eventAt descending
    RETURN filtered list
  END

  ASYNC FUNCTION getPendingSync() -> List<LogRecord>
    FILTER WHERE syncState == pending OR syncState == error
    RETURN filtered list
  END

  ASYNC FUNCTION getDeleted(accountId: String) -> List<LogRecord>
    FILTER WHERE accountId matches AND isDeleted
    RETURN filtered list
  END

  ASYNC FUNCTION countByAccount(accountId: String) -> int
    FILTER WHERE accountId matches AND NOT deleted
    RETURN count
  END

  ASYNC FUNCTION deleteByAccount(accountId: String) -> void
    FILTER records WHERE accountId matches
    FOR EACH: DELETE from _box using logId
  END

  // ── Stream Methods ──

  FUNCTION watchByAccount(accountId: String) -> Stream<List<LogRecord>>
    GET initial matching records (accountId, not deleted, sorted desc)
    MAP _controller.stream → filter + sort same criteria
    EMIT initial records THEN continue with mapped stream
    RETURN combined stream
  END

  FUNCTION watchByDateRange(accountId, start, end) -> Stream<List<LogRecord>>
    GET initial matching records (accountId, not deleted, in date range)
    MAP _controller.stream → filter same criteria
    EMIT initial records THEN continue with mapped stream
    RETURN combined stream
  END

END CLASS
```
