# sync_provider

> **Source:** `lib/providers/sync_provider.dart`

## Purpose

Riverpod providers for cloud sync operations. Wraps `SyncService` to expose sync status polling, manual sync trigger, online status check, record pulling, and real-time Firestore update watching. Includes parameter and event classes for typed provider families.

## Dependencies

- `package:flutter_riverpod/flutter_riverpod.dart` — Provider, StreamProvider, FutureProvider
- `../services/sync_service.dart` — SyncService, SyncStatus, SyncResult
- `account_provider.dart` — accountSessionManagerProvider, tokenServiceProvider

## Pseudo-Code

### Providers

```
PROVIDER syncServiceProvider -> SyncService
  READ sessionManager from accountSessionManagerProvider
  READ tokenService from tokenServiceProvider
  CREATE service = new SyncService(sessionManager, tokenService)
  ON DISPOSE: service.dispose()
  RETURN service
END

STREAM_PROVIDER.FAMILY syncStatusProvider(accountId: String) -> SyncStatus
  READ service
  YIELD AWAIT service.getSyncStatus(accountId)     // initial status
  EVERY 5 seconds:
    YIELD AWAIT service.getSyncStatus(accountId)   // poll updates
  END
END

FUTURE_PROVIDER triggerSyncProvider -> SyncResult
  READ service
  RETURN AWAIT service.forceSyncNow()
END

FUTURE_PROVIDER isOnlineProvider -> bool
  READ service
  RETURN AWAIT service.isOnline()
END

FUTURE_PROVIDER.FAMILY pullRecordsProvider(params: PullRecordsParams) -> SyncResult
  READ service
  RETURN AWAIT service.pullRecordsForAccount(
    accountId: params.accountId,
    since: params.since
  )
END

STREAM_PROVIDER.FAMILY firestoreUpdatesProvider(accountId: String) -> LogRecordUpdate
  READ service
  SUBSCRIBE to service.watchAccountLogsIncludingLegacy(accountId)
  MAP each record to LogRecordUpdate(record)
END
```

### Class: PullRecordsParams

```
CLASS PullRecordsParams
  FIELDS (final):
    accountId: String
    since: DateTime?

  EQUALITY: accountId, since
  HASH: Object.hash(accountId, since)
END CLASS
```

### Class: LogRecordUpdate

```
CLASS LogRecordUpdate
  FIELDS:
    record: dynamic    // Firestore document snapshot
END CLASS
```
