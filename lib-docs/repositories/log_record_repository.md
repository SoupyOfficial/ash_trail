# log_record_repository

> **Source:** `lib/repositories/log_record_repository.dart`

## Purpose

Abstract repository interface defining the data access contract for `LogRecord` entities. Supports CRUD, filtered queries (by account, date range, event type), sync-related queries (pending sync, deleted/tombstones), counting, bulk delete, and reactive streams. Factory function returns the Hive implementation.

## Dependencies

- `../models/log_record.dart` — LogRecord model
- `../models/enums.dart` — EventType enum
- `log_record_repository_hive.dart` — Hive implementation

## Pseudo-Code

### Abstract Class: LogRecordRepository

```
ABSTRACT CLASS LogRecordRepository

  // ── CRUD ──

  ASYNC FUNCTION create(record: LogRecord) -> LogRecord
  ASYNC FUNCTION update(record: LogRecord) -> LogRecord
  ASYNC FUNCTION delete(logId: String) -> void
  ASYNC FUNCTION getByLogId(logId: String) -> LogRecord?

  // ── Queries ──

  ASYNC FUNCTION getAll() -> List<LogRecord>
  ASYNC FUNCTION getByAccount(accountId: String) -> List<LogRecord>
  ASYNC FUNCTION getByDateRange(accountId, start, end) -> List<LogRecord>
  ASYNC FUNCTION getByEventType(accountId, eventType) -> List<LogRecord>

  // ── Sync-Related ──

  ASYNC FUNCTION getPendingSync() -> List<LogRecord>
  ASYNC FUNCTION getDeleted(accountId: String) -> List<LogRecord>

  // ── Aggregation ──

  ASYNC FUNCTION countByAccount(accountId: String) -> int
  ASYNC FUNCTION deleteByAccount(accountId: String) -> void

  // ── Streams ──

  FUNCTION watchByAccount(accountId: String) -> Stream<List<LogRecord>>
  FUNCTION watchByDateRange(accountId, start, end) -> Stream<List<LogRecord>>

END ABSTRACT CLASS
```

### Factory Function: createLogRecordRepository

```
FUNCTION createLogRecordRepository(context?) -> LogRecordRepository
  IF context IS null THEN
    THROW ArgumentError("Database context cannot be null")
  END IF
  RETURN new LogRecordRepositoryHive(context as Map<String, dynamic>)
END FUNCTION
```
