# model_converters

> **Source:** `lib/models/model_converters.dart`

## Purpose

Extension methods for converting between local database models (`Account`, `LogRecord`) and web-compatible models (`WebAccount`, `WebLogRecord`). Enables platform-agnostic serialization without Isar dependencies.

## Dependencies

- `../models/account.dart` — Account model
- `../models/log_record.dart` — LogRecord model
- `../models/web_models.dart` — WebAccount, WebLogRecord models
- `../models/enums.dart` — AuthProvider, EventType, Unit, LogReason, Source, SyncState enums

## Pseudo-Code

### Extension: AccountWebConversion on Account

```
EXTENSION AccountWebConversion ON Account

  FUNCTION toWebModel() -> WebAccount
    MAP fields:
      id -> id.toString()
      userId, email, displayName, photoUrl -> direct
      isActive, isLoggedIn -> direct
      authProvider -> authProvider.name (string)
      createdAt -> direct
      updatedAt -> lastSyncedAt OR createdAt
      lastAccessedAt, refreshToken, accessToken, tokenExpiresAt -> direct
    RETURN WebAccount(...)
  END FUNCTION

  STATIC FUNCTION fromWebModel(web: WebAccount, id?: int) -> Account
    MAP fields back:
      authProvider: match name to AuthProvider enum, fallback email
      createdAt -> direct
      lastSyncedAt -> web.updatedAt
    SET account.id = provided id OR 0
    RETURN Account
  END FUNCTION

END EXTENSION
```

### Extension: LogRecordWebConversion on LogRecord

```
EXTENSION LogRecordWebConversion ON LogRecord

  FUNCTION toWebModel() -> WebLogRecord
    MAP fields:
      id -> logId
      accountId -> direct
      eventType -> eventType.name (string)
      eventAt, duration -> direct
      unit -> unit.name (string)
      note -> direct
      reasons -> list of reason names
      moodRating, physicalRating -> direct
      latitude, longitude -> direct
      isDeleted, createdAt, updatedAt -> direct
    RETURN WebLogRecord(...)
  END FUNCTION

  STATIC FUNCTION fromWebModel(web: WebLogRecord, id?: int, extraFields?: Map) -> LogRecord
    MAP fields back:
      eventType: match name, fallback EventType.inhale
      unit: match name, fallback Unit.seconds
      reasons: map names to LogReason values, fallback LogReason.other
      source: default Source.manual
      syncState: parse from extraFields['syncState'], fallback pending

    CREATE LogRecord via LogRecord.create(...)

    // Apply extra fields that aren't in WebLogRecord
    SET record.id = provided id OR 0
    SET record.isDeleted = web.isDeleted
    SET record.deletedAt = parse extraFields['deletedAt'] if present
    SET record.revision = extraFields['revision'] OR 0
    SET record.syncedAt = parse extraFields['syncedAt'] if present
    SET record.syncError = extraFields['syncError']
    SET record.lastRemoteUpdateAt = parse extraFields['lastRemoteUpdateAt'] if present

    RETURN LogRecord
  END FUNCTION

END EXTENSION
```
