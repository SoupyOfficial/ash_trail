# log_record

> **Source:** `lib/models/log_record.dart`

## Purpose

Core domain model for a log entry — the central entity of the app. Captures all event data with ~25 fields spanning identity, time, event payload (type, duration, unit, note, reasons, ratings), location, metadata, lifecycle (soft delete), and sync state. Designed for offline-first storage with full Firestore sync capability and conflict resolution via revision counter.

## Dependencies

- `enums.dart` — EventType, Unit, Source, SyncState, TimeConfidence, LogReason enums

## Pseudo-Code

### Class: LogRecord

```
CLASS LogRecord

  FIELDS:
    // Identity
    id: int = 0                          // local database ID
    logId: String (late)                 // stable UUID across local + Firestore
    accountId: String (late)             // owning account

    // Time
    eventAt: DateTime (late)             // when event actually happened
    createdAt: DateTime (late)           // when record was created locally
    updatedAt: DateTime (late)           // last modification time

    // Event Payload
    eventType: EventType (late)          // vape, inhale, note, etc.
    duration: double (late)              // duration value in seconds
    unit: Unit (late)                    // seconds, minutes, hits, etc.
    note: String?                        // optional description
    reasons: List<LogReason>?            // optional context (medical, social, etc.)
    moodRating: double?                  // 1-10 scale, null = not set, 0 forbidden
    physicalRating: double?              // 1-10 scale, null = not set, 0 forbidden

    // Location
    latitude: double?                    // WGS84, -90 to 90
    longitude: double?                   // WGS84, -180 to 180

    // Metadata
    source: Source (late)                // manual, imported, automation, migration
    deviceId: String?                    // creating device identifier
    appVersion: String?                  // creating app version
    timeConfidence: TimeConfidence (late) // high, medium, low

    // Lifecycle
    isDeleted: bool (late)               // soft delete flag
    deletedAt: DateTime?                 // when deleted

    // Sync
    syncState: SyncState (late)          // pending, syncing, synced, error, conflict
    syncError: String?                   // last sync error message
    syncedAt: DateTime?                  // last successful sync time
    lastRemoteUpdateAt: DateTime?        // Firestore update time for conflict resolution
    revision: int                        // revision counter for conflict resolution

  // ── Default Constructor ──

  CONSTRUCTOR LogRecord()
    SET duration = 0
    SET revision = 0
    SET timeConfidence = TimeConfidence.high
    SET isDeleted = false
  END CONSTRUCTOR

  // ── Named Constructor ──

  CONSTRUCTOR LogRecord.create({required logId, required accountId, required eventType, ...})
    ASSIGN all provided fields
    SET eventAt = provided OR DateTime.now()
    SET createdAt = provided OR DateTime.now()
    SET updatedAt = provided OR DateTime.now()
    DEFAULTS: duration=0, unit=seconds, source=manual,
              timeConfidence=high, isDeleted=false,
              syncState=pending, revision=0
  END CONSTRUCTOR

  // ── Computed Properties ──

  GETTER hasLocation -> bool
    RETURN latitude != null AND longitude != null
  END GETTER

  // ── Lifecycle Methods ──

  FUNCTION markDirty() -> void
    SET updatedAt = now
    SET syncState = pending
    INCREMENT revision
  END FUNCTION

  FUNCTION markSynced(remoteUpdateTime: DateTime) -> void
    SET syncState = synced
    SET syncedAt = now
    SET lastRemoteUpdateAt = remoteUpdateTime
    CLEAR syncError
  END FUNCTION

  FUNCTION markSyncError(error: String) -> void
    SET syncState = error
    SET syncError = error
  END FUNCTION

  FUNCTION softDelete() -> void
    SET isDeleted = true
    SET deletedAt = now
    CALL markDirty()    // triggers sync of deletion
  END FUNCTION

  // ── Copy With ──

  FUNCTION copyWith({...all fields optional}) -> LogRecord
    CREATE LogRecord.create with fallback-to-this pattern
    PRESERVE id from original
    RETURN new record
  END FUNCTION

  // ── Firestore Serialization ──

  FUNCTION toFirestore() -> Map<String, dynamic>
    RETURN {
      logId, accountId,
      eventAt/createdAt/updatedAt as ISO8601 strings,
      eventType.name, duration, unit.name,
      note, reasons as list of names,
      moodRating, physicalRating,
      latitude, longitude,
      source.name, deviceId, appVersion,
      timeConfidence.name,
      isDeleted, deletedAt as ISO8601,
      revision
    }
  END FUNCTION

  STATIC FUNCTION fromFirestore(data: Map) -> LogRecord
    PARSE all fields from map:
      eventType: match by name, fallback EventType.custom
      unit: match by name, fallback Unit.seconds
      reasons: map list of names to LogReason values, fallback LogReason.other
      source: match by name, fallback Source.manual
      timeConfidence: match by name, fallback TimeConfidence.high
      numeric fields: cast num to double with defaults
      isDeleted: default false
      revision: default 0
    SET syncState = synced (came from Firestore)
    SET lastRemoteUpdateAt = parsed updatedAt
    RETURN LogRecord
  END FUNCTION

END CLASS
```
