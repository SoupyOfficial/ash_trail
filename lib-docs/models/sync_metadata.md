# sync_metadata

> **Source:** `lib/models/sync_metadata.dart`

## Purpose

Tracks cloud sync state and metadata for each account. Stores last sync timestamps, pending/error counts, current syncing status, and last error details.

## Dependencies

None (standalone model)

## Pseudo-Code

### Class: SyncMetadata

```
CLASS SyncMetadata

  FIELDS:
    id: int = 0                          // local database ID
    userId: String (late)                // account this metadata belongs to
    lastFullSync: DateTime?              // last time a full sync completed
    lastSuccessfulSync: DateTime?        // last successful sync of any kind
    pendingCount: int = 0                // number of records waiting to sync
    errorCount: int = 0                  // number of records with sync errors
    lastError: String?                   // most recent error message
    lastErrorAt: DateTime?               // when last error occurred
    isSyncing: bool = false              // whether a sync is currently in progress

END CLASS
```
