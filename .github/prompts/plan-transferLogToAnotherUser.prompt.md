## Plan: Transfer Log to Another Account

**TL;DR**: Add the ability to retroactively transfer a specific log entry from the current account to another logged-in account. Triggered from the existing Edit Log dialog, the feature soft-deletes the original record, creates a copy under the target account, and syncs both changes to Firestore. A new `transferMetadata` set of fields on `LogRecord` provides an audit trail.

---

### Phase 1 — Model Changes

**1. Add transfer metadata fields to `LogRecord`** (*no dependencies*)
- In [lib/models/log_record.dart](lib/models/log_record.dart), add three nullable fields:
  - `String? transferredFromAccountId` — source account's userId
  - `DateTime? transferredAt` — when the transfer occurred
  - `String? transferredFromLogId` — the original record's logId (links the two records)
- Add these to the `LogRecord.create` constructor (optional/nullable)
- Add these to `copyWith()`
- No Hive adapter changes needed — storage is JSON-based

**2. Persist new fields in Hive** (*depends on 1*)
- In [lib/repositories/log_record_repository_hive.dart](lib/repositories/log_record_repository_hive.dart), add the three fields to both the `create()` and `update()` JSON maps (alongside existing extra fields like `syncState`, `revision`)
- In the deserialization path (`fromWebModel` / `extraFields`), read them back

**3. Add Firestore serialization** (*depends on 1*)
- In `LogRecord.toFirestore()` / `LogRecord.fromFirestore()` ([lib/models/log_record.dart](lib/models/log_record.dart#L167-L247)), include the three transfer fields
- In `WebLogRecord` ([lib/models/web_models.dart](lib/models/web_models.dart#L78-L151)), add the 3 fields to constructor, `toJson()`, and `fromJson()`
- In `LogRecordWebConversion` ([lib/models/model_converters.dart](lib/models/model_converters.dart#L51-L131)), map the 3 fields in both `toWebModel()` and `fromWebModel()`

---

### Phase 2 — Service Layer

**4. Add `transferLogRecord` to `LogRecordService`** (*depends on 1-3*)
- In [lib/services/log_record_service.dart](lib/services/log_record_service.dart), add:
  ```
  Future<LogRecord> transferLogRecord(LogRecord record, String targetAccountId)
  ```
- Implementation follows the pattern from [DataIntegrityService.repairIssues()](lib/services/data_integrity_service.dart#L320-L385):
  1. Validate `targetAccountId` exists via `_accountService.accountExists()`
  2. Validate `targetAccountId != record.accountId` (no self-transfer)
  3. Soft-delete the original record: set `isDeleted = true`, `deletedAt = now`, call `markDirty()`, persist via `_repository.update()`
  4. Create a new `LogRecord.create(...)` copying all payload fields from the original, but with:
     - New `logId` (UUID) to avoid collisions
     - `accountId: targetAccountId`
     - `syncState: SyncState.pending`
     - `transferredFromAccountId: record.accountId`
     - `transferredAt: DateTime.now()`
     - `transferredFromLogId: record.logId`
     - `source: Source.migration`
  5. Persist the new record via `_repository.create()`
  6. Return the new record

**5. Add `undoTransfer` to `LogRecordService`** (*depends on 4, parallel with 6*)
- Reverse a transfer: restore the original (un-soft-delete using `restoreDeleted` pattern), soft-delete the transferred copy
- Takes the new `LogRecord` (which has `transferredFromLogId`), finds the original by that logId, restores it, deletes the new

---

### Phase 3 — Provider Layer

**6. Add `transferLogRecord` to `LogRecordNotifier`** (*depends on 4*)
- In [lib/providers/log_record_provider.dart](lib/providers/log_record_provider.dart), add to `LogRecordNotifier`:
  ```
  Future<void> transferLogRecord(LogRecord record, String targetAccountId)
  ```
- Follows the same state management pattern as `updateLogRecord()`: set loading → call service → set data → handle errors via `ErrorReportingService`

---

### Phase 4 — UI

**7. Add Transfer button to Edit Log dialog** (*depends on 6*)
- In [lib/widgets/edit_log_record_dialog.dart](lib/widgets/edit_log_record_dialog.dart), add a "Transfer" `TextButton.icon` (with a `swap_horiz` or `person_add` icon) in the [action buttons row](lib/widgets/edit_log_record_dialog.dart#L393-L410), positioned between the Delete button and Cancel/Update group
- On tap, call `_showTransferDialog()`
- Only show the Transfer button if there are other logged-in accounts (watch `loggedInAccountsProvider`)

**8. Create Transfer confirmation dialog** (*parallel with 7*)
- New file: `lib/widgets/transfer_log_dialog.dart`
- A modal dialog that:
  1. Reads `loggedInAccountsProvider` to get available target accounts
  2. Filters out the current account (`record.accountId`)
  3. Shows a list of accounts with avatar, display name, and email
  4. User taps an account to select it
  5. Shows a confirmation message: "Transfer this log to {name}? The log will be moved from your history to theirs."
  6. On confirm: calls `ref.read(logRecordNotifierProvider.notifier).transferLogRecord(record, selectedAccountId)`
  7. On success: pops both dialogs, shows snackbar with **Undo** action (calls `undoTransfer`)
  8. If only one other account exists, skip the picker and go straight to confirmation

**9. Show transfer badge on transferred logs** (*parallel with 7-8, optional but recommended*)
- In the history list item widget, if a log has `transferredFromAccountId != null`, show a small "transferred" indicator (e.g., a subtle icon or chip)

---

### Phase 5 — Sync

**10. Update sync to forward transfer fields on pull** (*depends on 3*)
- In `SyncService._downloadRecord()` ([lib/services/sync_service.dart](lib/services/sync_service.dart#L238-L278)), ensure that when pulling a remote record that has transfer metadata, the fields are passed through to `importLogRecord()`
- In `LogRecordService.importLogRecord()` ([lib/services/log_record_service.dart](lib/services/log_record_service.dart#L138)), add optional parameters for `transferredFromAccountId`, `transferredAt`, and `transferredFromLogId` so records pulled from Firestore preserve their transfer provenance
- The existing sync flow already handles the two resulting records correctly for *upload*:
  - **Original record** (soft-deleted, `syncState: pending`): when syncing the source account, uploads `isDeleted: true` to `accounts/{oldAccountId}/logs/{oldLogId}`
  - **New record** (`syncState: pending`): when syncing the target account, uploads to `accounts/{newAccountId}/logs/{newLogId}`
- `syncAllLoggedInAccounts()` processes both accounts' pending records in sequence — confirmed per [implementation](lib/services/sync_service.dart#L296-L397)
- **Race condition note**: If transfer happens mid-sync, the soft-deleted original may sync before the new record exists in the target account's Firestore. This is acceptable — they're independent documents — but Firestore-side state temporarily shows data "loss" until the target account syncs

---

### Phase 6 — Downstream Ripple Changes

**11. Data Integrity Service — skip orphan flagging for transfer-deleted records** (*depends on 1*)
- In `DataIntegrityService.runIntegrityCheck()` ([lib/services/data_integrity_service.dart](lib/services/data_integrity_service.dart#L142-L219)), the orphan detection at [L174-L178](lib/services/data_integrity_service.dart#L174-L178) iterates ALL records via `_repository.getAll()`, including soft-deleted ones
- A soft-deleted original record whose source account has been deleted would be **falsely flagged as an orphan**
- In `repairIssues()` ([L228-L321](lib/services/data_integrity_service.dart#L228-L321)), a false-positive orphan would be **re-assigned** to another account, corrupting the transfer trail
- **Fix**: Add a guard — skip orphan flagging for records where `isDeleted == true && transferredFromLogId != null`. These are legitimate transfer remnants, not orphans

**12. Export Service — include transfer metadata** (*depends on 1*)
- In `ExportService.exportToCsv()` ([lib/services/export_service.dart](lib/services/export_service.dart#L20-L30)), the CSV header is hardcoded and **missing** the 3 transfer fields. Add `transferredFromAccountId`, `transferredAt`, `transferredFromLogId` columns
- In `_recordToJson()` ([lib/services/export_service.dart](lib/services/export_service.dart#L327-L352)), add the 3 transfer fields to JSON export output
- In `_parseRecordFromCsv()` ([lib/services/export_service.dart](lib/services/export_service.dart#L238-L303)), parse the 3 fields on import so round-trip export→import preserves transfer provenance
- In `_parseRecordFromJson()` ([lib/services/export_service.dart](lib/services/export_service.dart#L304-L327)), parse the 3 fields on import
- Note: `ExportScreen` uses `activeAccountLogRecordsProvider` which already filters `!isDeleted`, so soft-deleted originals won't appear in exports. Transferred-in records in the target account will be exported with their transfer metadata

**13. Account deletion — handle transfer metadata before hard-delete** (*depends on 1*)
- In `AccountService.deleteAccount()` ([lib/services/account_service.dart](lib/services/account_service.dart#L65-L69)), `deleteAllByAccount(userId)` hard-deletes all records for the account, including soft-deleted originals that carry transfer metadata
- If the **source** account is deleted: the audit trail (original soft-deleted record) is permanently lost, and the transferred record in the target account has a `transferredFromAccountId` pointing to a nonexistent account
- If the **target** account is deleted: the transferred record is deleted, but the source account's soft-deleted original still references a now-nonexistent target
- **Fix**: Before hard-deleting, find any records in *other* accounts that have `transferredFromAccountId == deletingAccountId` and clear their transfer metadata (or append a note like "source account deleted"). Optionally, un-soft-delete original records in the deleting account that were transferred out, restoring them to the target account's history

**14. Analytics retroactive impact** (*no code changes, but important for UX*)
- All analytics paths (`AnalyticsService.computeRollingWindow()`, `computeDailyRollup()`, `HomeMetricsService`) filter `!r.isDeleted` — so the source account's analytics will immediately lose the transferred record, and the target account's analytics will gain it
- **Retroactive effect**: A transferred record retains its original `eventAt`. This means the target account's daily averages, trends, "Today vs Yesterday", "Today vs Week Avg", peak hours, and time-since-last-hit calculations will change for *historical* periods — potentially surprising.
- No code change needed — this is the correct/expected behavior — but the Transfer confirmation dialog (step 8) should communicate this clearly: "This log's date and time will be preserved. It will appear in {name}'s history and analytics for {date}."

**15. History screen — searchability** (*optional, low priority*)
- `_applyFilters()` in [lib/screens/history_screen.dart](lib/screens/history_screen.dart#L119-L139) only searches `note` and `eventType.name` — transfer metadata fields are not searchable
- Consider adding `source` or transfer status as a filter chip in a future iteration, so users can find all transferred-in records
- The transfer badge from step 9 provides visual identification without needing search

---

### Relevant Files

**P0 — Core feature (must change)**
- [lib/models/log_record.dart](lib/models/log_record.dart) — Add 3 transfer metadata fields, update `create`, `copyWith`, `toFirestore`, `fromFirestore`
- [lib/models/web_models.dart](lib/models/web_models.dart) — Add 3 fields to `WebLogRecord`, `toJson()`, `fromJson()`
- [lib/models/model_converters.dart](lib/models/model_converters.dart) — Map 3 fields in `toWebModel()` and `fromWebModel()`
- [lib/repositories/log_record_repository_hive.dart](lib/repositories/log_record_repository_hive.dart) — Serialize/deserialize new fields in JSON maps
- [lib/services/log_record_service.dart](lib/services/log_record_service.dart) — Add `transferLogRecord()`, `undoTransfer()`, and transfer params to `importLogRecord()`
- [lib/providers/log_record_provider.dart](lib/providers/log_record_provider.dart) — Add `transferLogRecord()` to `LogRecordNotifier`
- [lib/widgets/edit_log_record_dialog.dart](lib/widgets/edit_log_record_dialog.dart) — Add Transfer button to action row
- **New**: `lib/widgets/transfer_log_dialog.dart` — Account picker + confirmation dialog

**P1 — Downstream ripple (must change to avoid bugs)**
- [lib/services/data_integrity_service.dart](lib/services/data_integrity_service.dart) — Skip orphan flagging for transfer-deleted records; prevent repair from corrupting transfer trail
- [lib/services/export_service.dart](lib/services/export_service.dart) — Add transfer fields to CSV header, JSON export, and both import parsers
- [lib/services/sync_service.dart](lib/services/sync_service.dart) — Forward transfer fields in `_downloadRecord()` / `importLogRecord()` calls during pull
- [lib/services/account_service.dart](lib/services/account_service.dart) — Handle transfer metadata cleanup before hard-deleting account data

**P2 — No changes needed (confirmed safe)**
- [lib/providers/account_provider.dart](lib/providers/account_provider.dart) — Reuse `loggedInAccountsProvider` as-is
- [lib/services/analytics_service.dart](lib/services/analytics_service.dart) — Already filters `!isDeleted`; retroactive analytics change is correct/expected behavior
- [lib/services/home_metrics_service.dart](lib/services/home_metrics_service.dart) — Already filters `!isDeleted`
- [lib/services/validation_service.dart](lib/services/validation_service.dart) — Duplicate detection scoped per-account; no cross-account false positives
- [lib/services/notification_service.dart](lib/services/notification_service.dart) — Stub implementation; no impact

---

### Verification

**Core feature tests**
1. **Unit test `transferLogRecord` service method** — Create a record for account A, transfer to account B, verify: original is soft-deleted, new record has correct `accountId`, `transferMetadata` is populated, `syncState` is `pending`, all payload fields are preserved
2. **Unit test `undoTransfer`** — Transfer then undo, verify original is restored and copy is deleted
3. **Unit test edge cases** — Self-transfer rejected, non-existent target account rejected, already-deleted record cannot be transferred
4. **Widget test Transfer button** — Verify button appears only when multiple accounts are logged in, hidden when only one account
5. **Widget test Transfer dialog** — Verify account picker shows correct accounts, confirm flow calls provider
6. **Integration test** — Transfer a log, run `syncAllLoggedInAccounts()`, verify Firestore has the new record under the target account path and the original is marked deleted under the source account path
7. **Manual verification** — Switch accounts after transfer and confirm the log appears in the target account's history with the transfer indicator

**Downstream impact tests**
8. **Model serialization round-trip** — Verify transfer fields survive `LogRecord` → `toFirestore()` → `fromFirestore()` → `LogRecord`, and `LogRecord` → `WebLogRecord` → `toJson()` → `fromJson()` → `LogRecord`. Update existing tests in [test/models/log_record_test.dart](test/models/log_record_test.dart) and [test/models/model_converters_test.dart](test/models/model_converters_test.dart)
9. **Data integrity false positive** — Create a soft-deleted record with `transferredFromLogId` set; verify `runIntegrityCheck()` does NOT flag it as orphaned. Update existing tests in [test/services/data_integrity_service_test.dart](test/services/data_integrity_service_test.dart)
10. **Export round-trip** — Create a transferred record, export to CSV and JSON, verify transfer fields appear in output. Import back, verify fields are preserved. Update existing tests in [test/screens/export_screen_test.dart](test/screens/export_screen_test.dart)
11. **Sync pull preserves transfer metadata** — Mock a Firestore document with transfer fields, pull via sync, verify the local record has transfer metadata populated. Update existing tests in [test/services/sync_service_test.dart](test/services/sync_service_test.dart)
12. **Account deletion with transfer records** — Transfer a log from A→B, delete account A, verify the transferred record in B is unaffected (or metadata gracefully cleared). Update tests in [test/services/log_record_service_test.dart](test/services/log_record_service_test.dart)
13. **Multi-account isolation after transfer** — Transfer a log, verify it does NOT appear in source account queries (`watchLogRecords`, `getLogRecords`), DOES appear in target account queries. Update tests in [test/providers/multi_account_log_switching_test.dart](test/providers/multi_account_log_switching_test.dart)
14. **Analytics post-transfer** — Verify source account statistics decrease by 1 and target account statistics increase by 1 for the relevant date range

---

### Decisions

- **New logId on transfer** — The transferred copy gets a fresh UUID to avoid logId collisions across account Firestore paths. The `transferredFromLogId` field maintains traceability
- **Soft-delete, not hard-delete** — The original record is soft-deleted (consistent with existing delete patterns) so it syncs as deleted to Firestore
- **No Cloud Function needed** — The existing `syncAllLoggedInAccounts()` flow handles both accounts sequentially with auth switching, so both the delete and create sync naturally
- **Both accounts must be logged in** — Transfer is only offered to accounts currently in `loggedInAccountsProvider`. If the target account isn't logged in, it won't appear as an option
- **Retroactive analytics are expected** — The transferred record keeps its original `eventAt`, so the target account's historical analytics will change. The confirmation dialog should communicate this clearly
- **No cross-account duplicate detection issues** — `findPotentialDuplicates()` is scoped per-account and filters `!isDeleted`, so the soft-deleted original and transferred copy never overlap in the same query
- **Transfer metadata survives sync round-trips** — fields are added to `toFirestore`/`fromFirestore`, `WebLogRecord`, and `ModelConverters`, and `importLogRecord()` is updated to forward them on pull
- **Scope excluded**: Batch transfer (multiple logs at once), transfer to accounts not yet logged in, cross-device transfer notifications, filtering/searching by transfer status, gamification/streak impact (not yet implemented)
