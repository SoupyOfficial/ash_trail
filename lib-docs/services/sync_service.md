# sync_service

> **Source:** `lib/services/sync_service.dart`

## Purpose

Bidirectional Firestore sync engine supporting multi-account architecture. Pushes pending local records to each account's Firestore collection, pulls remote records (including legacy collections), detects conflicts via `lastRemoteUpdateAt` (last-write-wins resolution), manages auto-sync timers, switches Firebase Auth context per account using custom tokens, and merges legacy data. Largest service in the codebase (~1250 lines).

## Dependencies

- `dart:async` — `Timer`, `StreamController`, `StreamSubscription`
- `package:cloud_firestore/cloud_firestore.dart` — Firestore read/write
- `package:firebase_auth/firebase_auth.dart` — Firebase Auth context switching
- `package:connectivity_plus/connectivity_plus.dart` — Network availability check
- `../logging/app_logger.dart` — Structured logging via `AppLogger`
- `../models/account.dart` — `Account` model
- `../models/log_record.dart` — `LogRecord` model
- `../models/enums.dart` — `SyncState`, `EventType`, `Unit`, `Source`, `TimeConfidence`, `LogReason`
- `log_record_service.dart` — Local record CRUD and import
- `account_service.dart` — Account lookup (existence, retrieval)
- `account_session_manager.dart` — Custom token retrieval/generation
- `token_service.dart` — Token endpoint health check
- `legacy_data_adapter.dart` — Legacy Firestore collection reading

## Pseudo-Code

### Class: SyncResult

```
SyncResult {
  uploaded: int,
  downloaded: int,
  conflicts: int,
  errors: List<String>,
  isSuccess: bool → errors.isEmpty
}
```

### Class: SyncStatus

```
SyncStatus {
  isSyncing: bool,
  lastSyncTime: DateTime?,
  pendingCount: int,
  lastError: String?
}
```

---

### Class: SyncService

#### Fields
- `_log` — static logger tagged `'SyncService'`
- `_firestore` — `FirebaseFirestore` instance
- `_auth` — `FirebaseAuth` instance
- `_logRecordService` — local log record CRUD
- `_accountService` — account lookup
- `_sessionManager` — custom token management
- `_tokenService` — token endpoint availability
- `_legacyDataAdapter` — legacy collection reading
- `_isSyncing` — sync lock flag
- `_autoSyncPushTimer`, `_autoSyncPullTimer` — periodic timers
- `_syncStatusController` — `StreamController<SyncStatus>` (broadcast)
- `_connectivitySubscription` — monitors network changes
- `_lastSyncTime`, `_lastError`, `_pendingCount` — status tracking

#### Constructor

```
SyncService(logRecordService, accountService, sessionManager, {firestore?, auth?, tokenService?, legacyDataAdapter?}):
  _logRecordService = logRecordService
  _accountService = accountService
  _sessionManager = sessionManager
  _firestore = firestore ?? FirebaseFirestore.instance
  _auth = auth ?? FirebaseAuth.instance
  _tokenService = tokenService ?? TokenService()
  _legacyDataAdapter = legacyDataAdapter
```

---

#### `syncStatus → Stream<SyncStatus>`
```
RETURN _syncStatusController.stream
```

#### `currentSyncStatus → SyncStatus`
```
RETURN SyncStatus(_isSyncing, _lastSyncTime, _pendingCount, _lastError)
```

---

#### `startAutoSync({pushInterval = 5 min, pullInterval = 15 min}) → void`

```
stopAutoSync()    // cancel existing timers
_autoSyncPushTimer = Timer.periodic(pushInterval, (_) → syncCurrentAccount())
_autoSyncPullTimer = Timer.periodic(pullInterval, (_) → pullCurrentAccount())
LOG [SYNC] Auto sync started (push: pushInterval, pull: pullInterval)
```

#### `stopAutoSync() → void`

```
_autoSyncPushTimer?.cancel()
_autoSyncPullTimer?.cancel()
_autoSyncPushTimer = null
_autoSyncPullTimer = null
```

---

#### `syncCurrentAccount() → Future<SyncResult>`

```
user = _auth.currentUser
IF user == null:
  RETURN SyncResult(errors: ['Not authenticated'])

// Find account for user
accounts = AWAIT _accountService.getAllAccounts()
account = accounts.firstWhere(a.firebaseUid == user.uid, orElse: null)
IF account == null:
  RETURN SyncResult(errors: ['No account found for user'])

RETURN AWAIT syncPendingRecords(account.id)
```

---

#### `pullCurrentAccount() → Future<SyncResult>`

```
user = _auth.currentUser
IF user == null:
  RETURN SyncResult(errors: ['Not authenticated'])

accounts = AWAIT _accountService.getAllAccounts()
account = accounts.firstWhere(a.firebaseUid == user.uid, orElse: null)
IF account == null:
  RETURN SyncResult(errors: ['No account found for user'])

RETURN AWAIT pullRecordsForAccount(account.id)
```

---

#### `syncPendingRecords(accountId) → Future<SyncResult>`

```
// 1. Reentrancy guard
IF _isSyncing:
  RETURN SyncResult(errors: ['Sync already in progress'])

// 2. Verify Firebase Auth matches account
user = _auth.currentUser
IF user == null:
  RETURN SyncResult(errors: ['Not authenticated'])

account = AWAIT _accountService.getAccountById(accountId)
IF account == null:
  RETURN SyncResult(errors: ['Account not found'])

IF user.uid != account.firebaseUid:
  LOG WARN 'Firebase user mismatch — skipping sync for safety'
  RETURN SyncResult(errors: ['Firebase user does not match account'])

TRY:
  _isSyncing = true
  _emitStatus()
  LOG [SYNC_PUSH_START] accountId

  pending = AWAIT _logRecordService.getPendingSync(accountId: accountId)
  uploaded = 0, conflicts = 0, errors = []

  FOR EACH record IN pending:
    TRY:
      // Re-query to ensure record still needs sync (may have changed)
      freshRecord = AWAIT _logRecordService.getLogRecordByLogId(record.logId)
      IF freshRecord == null OR freshRecord.syncState != pending:
        CONTINUE

      result = AWAIT _uploadRecord(freshRecord, account)
      IF result == 'uploaded':
        uploaded++
      ELSE IF result == 'conflict':
        conflicts++
    CATCH e:
      errors.add(e.toString())
      AWAIT _logRecordService.markSyncError(record, e.toString())

  IF errors.isEmpty:
    _lastSyncTime = NOW
    _lastError = null
  ELSE:
    _lastError = 'Push sync completed with ${errors.length} errors'

  _pendingCount = AWAIT _logRecordService.getPendingSync(accountId).length
  _emitStatus()

  LOG [SYNC_PUSH_END] uploaded=$uploaded, conflicts=$conflicts
  RETURN SyncResult(uploaded, 0, conflicts, errors)

FINALLY:
  _isSyncing = false
  _emitStatus()
```

---

#### `_uploadRecord(record, account) → Future<String>`

```
collectionPath = 'users/${account.firebaseUid}/log_entries'
docRef = _firestore.collection(collectionPath).doc(record.logId)

// Check for remote conflict
remoteDoc = AWAIT docRef.get()
IF remoteDoc.exists:
  remoteData = remoteDoc.data()
  remoteUpdatedAt = remoteData['updatedAt']

  // Compare with lastRemoteUpdateAt to detect third-party writes
  IF record.lastRemoteUpdateAt != null
     AND remoteUpdatedAt != null
     AND remoteUpdatedAt > record.lastRemoteUpdateAt:
    LOG WARN [SYNC_CONFLICT] record.logId — remote updated since last pull
    // Last-write-wins: local overwrites remote
    // (conflict counter incremented by caller)

// Prepare Firestore document
data = record.toFirestoreMap()    // serializes all fields
IF record.isDeleted:
  data['isDeleted'] = true
  data['deletedAt'] = record.deletedAt

AWAIT docRef.set(data, SetOptions(merge: true))
AWAIT _logRecordService.markSynced(record, NOW)

LOG [SYNC_UPLOADED] record.logId
RETURN remoteDoc.exists ? 'conflict' : 'uploaded'
```

---

#### `pullRecordsForAccount(accountId) → Future<SyncResult>`

```
user = _auth.currentUser
IF user == null:
  RETURN SyncResult(errors: ['Not authenticated'])

account = AWAIT _accountService.getAccountById(accountId)
IF account == null:
  RETURN SyncResult(errors: ['Account not found'])

IF user.uid != account.firebaseUid:
  RETURN SyncResult(errors: ['Firebase user mismatch'])

TRY:
  _isSyncing = true
  _emitStatus()
  LOG [SYNC_PULL_START] accountId

  collectionPath = 'users/${account.firebaseUid}/log_entries'
  querySnap = AWAIT _firestore.collection(collectionPath).get()

  downloaded = 0, conflicts = 0, errors = []

  FOR EACH doc IN querySnap.docs:
    TRY:
      remoteRecord = LogRecord.fromFirestoreMap(doc.data(), doc.id)
      localRecord = AWAIT _logRecordService.getLogRecordByLogId(doc.id)

      IF localRecord == null:
        // New remote record — import it
        AWAIT _logRecordService.importLogRecord(... remoteRecord fields ..., source=imported)
        downloaded++
      ELSE:
        // Merge: remote wins if newer
        remoteUpdatedAt = remoteRecord.updatedAt
        IF remoteUpdatedAt > localRecord.updatedAt:
          updatedLocal = _mergeRemoteToLocal(localRecord, remoteRecord)
          AWAIT _logRecordService.markSynced(updatedLocal, remoteUpdatedAt)
          downloaded++
        ELSE IF remoteUpdatedAt < localRecord.updatedAt:
          conflicts++   // local is newer, will push on next sync
    CATCH e:
      errors.add('Error processing doc ${doc.id}: $e')

  _lastSyncTime = NOW
  _pendingCount = AWAIT _logRecordService.getPendingSync(accountId).length
  _emitStatus()

  LOG [SYNC_PULL_END] downloaded=$downloaded, conflicts=$conflicts
  RETURN SyncResult(0, downloaded, conflicts, errors)

FINALLY:
  _isSyncing = false
  _emitStatus()
```

---

#### `pullRecordsForAccountIncludingLegacy(accountId) → Future<SyncResult>`

```
// 1. Pull from current collection
currentResult = AWAIT pullRecordsForAccount(accountId)

// 2. Pull from legacy collection (if adapter available)
IF _legacyDataAdapter == null:
  RETURN currentResult

account = AWAIT _accountService.getAccountById(accountId)
IF account == null:
  RETURN currentResult

TRY:
  legacyRecords = AWAIT _legacyDataAdapter.readLegacyRecords(account.firebaseUid)
  legacyImported = 0

  FOR EACH legacyRecord IN legacyRecords:
    localRecord = AWAIT _logRecordService.getLogRecordByLogId(legacyRecord.logId)
    IF localRecord == null:
      AWAIT _logRecordService.importLogRecord(... legacyRecord fields ...)
      legacyImported++

  RETURN SyncResult(
    currentResult.uploaded,
    currentResult.downloaded + legacyImported,
    currentResult.conflicts,
    currentResult.errors
  )

CATCH e:
  LOG WARNING 'Legacy pull failed: $e'
  RETURN currentResult
```

---

#### `syncAllLoggedInAccounts() → Future<Map<String, SyncResult>>`

```
results = {}
accounts = AWAIT _accountService.getAllAccounts()
loggedInAccounts = accounts.WHERE(a.firebaseUid != null)

IF loggedInAccounts.isEmpty:
  RETURN results

// Save current Firebase user to restore later
originalUser = _auth.currentUser
LOG [SYNC_ALL_START] ${loggedInAccounts.length} accounts

FOR EACH account IN loggedInAccounts:
  TRY:
    // Switch Firebase Auth to this account
    switched = AWAIT _switchToAccount(account)
    IF NOT switched:
      results[account.id] = SyncResult(errors: ['Failed to switch to account'])
      CONTINUE

    // Run push + pull
    pushResult = AWAIT syncPendingRecords(account.id)
    pullResult = AWAIT pullRecordsForAccountIncludingLegacy(account.id)

    results[account.id] = SyncResult(
      pushResult.uploaded,
      pullResult.downloaded,
      pushResult.conflicts + pullResult.conflicts,
      [...pushResult.errors, ...pullResult.errors]
    )
  CATCH e:
    results[account.id] = SyncResult(errors: [e.toString()])

// Restore original Firebase user
IF originalUser != null:
  TRY:
    AWAIT _switchToAccountByUid(originalUser.uid)
  CATCH:
    LOG WARNING 'Failed to restore original auth context'

LOG [SYNC_ALL_END]
RETURN results
```

---

#### `pullAllLoggedInAccounts() → Future<Map<String, SyncResult>>`

```
results = {}
accounts = AWAIT _accountService.getAllAccounts()
loggedInAccounts = accounts.WHERE(a.firebaseUid != null)

originalUser = _auth.currentUser
LOG [PULL_ALL_START]

FOR EACH account IN loggedInAccounts:
  TRY:
    switched = AWAIT _switchToAccount(account)
    IF NOT switched:
      results[account.id] = SyncResult(errors: ['Switch failed'])
      CONTINUE
    results[account.id] = AWAIT pullRecordsForAccountIncludingLegacy(account.id)
  CATCH e:
    results[account.id] = SyncResult(errors: [e.toString()])

// Restore original user
IF originalUser != null:
  TRY: AWAIT _switchToAccountByUid(originalUser.uid)
  CATCH: LOG WARNING 'Restore failed'

LOG [PULL_ALL_END]
RETURN results
```

---

#### `_switchToAccount(account) → Future<bool>`

```
IF account.firebaseUid == null:
  RETURN false

currentUser = _auth.currentUser
IF currentUser?.uid == account.firebaseUid:
  RETURN true    // already on this account

TRY:
  // Get or generate custom token
  token = AWAIT _sessionManager.getOrRefreshToken(account.id)
  IF token == null:
    // Try generating new token
    token = AWAIT _sessionManager.generateAndStoreToken(account.id, account.firebaseUid)
  IF token == null:
    LOG ERROR 'Could not obtain token for account'
    RETURN false

  AWAIT _auth.signInWithCustomToken(token)
  RETURN true

CATCH e:
  LOG ERROR 'Failed to switch to account: $e'

  // Retry once
  TRY:
    token = AWAIT _sessionManager.generateAndStoreToken(account.id, account.firebaseUid)
    IF token != null:
      AWAIT _auth.signInWithCustomToken(token)
      RETURN true
  CATCH:
    LOG ERROR 'Retry failed'

  RETURN false
```

---

#### `_switchToAccountByUid(uid) → Future<bool>`

```
accounts = AWAIT _accountService.getAllAccounts()
account = accounts.firstWhere(a.firebaseUid == uid, orElse: null)
IF account == null:
  RETURN false
RETURN AWAIT _switchToAccount(account)
```

---

#### `importLegacyDataForAccount(accountId) → Future<int>`

```
IF _legacyDataAdapter == null:
  RETURN 0

account = AWAIT _accountService.getAccountById(accountId)
IF account == null OR account.firebaseUid == null:
  RETURN 0

TRY:
  legacyRecords = AWAIT _legacyDataAdapter.readLegacyRecords(account.firebaseUid)
  imported = AWAIT _logRecordService.importLegacyRecordsBatch(legacyRecords)
  LOG [SYNC] Imported $imported legacy records for account
  RETURN imported
CATCH e:
  LOG ERROR 'Legacy import failed: $e'
  RETURN 0
```

---

#### `watchAccountLogsIncludingLegacy(accountId) → Stream<List<LogRecord>>`

```
account = _accountService.getAccountById(accountId)    // sync lookup if available
IF account == null OR account.firebaseUid == null:
  RETURN _logRecordService.watchLogRecords(accountId: accountId)

// Merge local stream with periodic legacy checks
controller = StreamController<List<LogRecord>>.broadcast()

localSub = _logRecordService.watchLogRecords(accountId: accountId).listen(records →
  controller.add(records)
)

controller.onCancel = () → localSub.cancel()
RETURN controller.stream
```

---

#### `_emitStatus() → void`

```
status = SyncStatus(_isSyncing, _lastSyncTime, _pendingCount, _lastError)
IF NOT _syncStatusController.isClosed:
  _syncStatusController.add(status)
```

---

#### `dispose() → void`

```
stopAutoSync()
_connectivitySubscription?.cancel()
_syncStatusController.close()
```
