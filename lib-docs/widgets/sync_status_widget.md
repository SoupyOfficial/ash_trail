# sync_status_widget

> **Source:** `lib/widgets/sync_status_widget.dart`

## Purpose
Provides two sync status display widgets: `SyncStatusWidget` — a full Card with status text, pending count, and manual sync trigger; and `SyncStatusIndicator` — a compact icon button for app bars that opens a sync details dialog. Both are Riverpod-aware and watch the active account's sync state.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management
- `../providers/sync_provider.dart` — syncStatusProvider, syncServiceProvider
- `../providers/log_record_provider.dart` — activeAccountIdProvider
- `../services/sync_service.dart` — SyncService, SyncStatus

## Pseudo-Code

### Class: SyncStatusWidget (ConsumerWidget)

#### Method: build(context, ref) → Widget
```
WATCH activeAccountIdProvider
IF null → RETURN SizedBox.shrink()

WATCH syncStatusProvider(accountId)

RETURN syncStatusAsync.when:
  data(status):
    Card → ListTile:
      leading: _buildStatusIcon(status)
      title: _buildStatusText(status)
      subtitle: pending > 0 ? "{n} items pending" : "All synced"
      trailing:
        IF isOnline → IconButton(sync) → _triggerSync
        ELSE → Icon(cloud_off, grey)

  loading:
    Card → ListTile(CircularProgressIndicator, "Checking sync status...")

  error:
    Card → ListTile(error icon, "Sync error: $error")
```

#### Method: _buildStatusIcon(SyncStatus) → Widget
```
isSyncing     → small CircularProgressIndicator
not isOnline  → cloud_off, grey
isFullySynced → cloud_done, green
else          → cloud_upload, orange
```

#### Method: _buildStatusText(SyncStatus) → String
```
isSyncing → "Syncing..."  |  offline → "Offline"
fullySynced → "All synced"  |  else → "Pending sync"
```

#### Method: _triggerSync(context, ref) → Future<void>
```
TRY: CALL syncService.forceSyncNow() → SHOW SnackBar(result.message)
CATCH → SHOW SnackBar("Sync failed: $e")
```

---

### Class: SyncStatusIndicator (ConsumerWidget)

#### Method: build(context, ref) → Widget
```
WATCH activeAccountIdProvider
IF null → SizedBox.shrink()

WATCH syncStatusProvider(accountId)

RETURN syncStatusAsync.when:
  data(status):
    IF syncing → small CircularProgressIndicator
    IF offline → IconButton(cloud_off, grey, "Offline")
    IF synced  → IconButton(cloud_done, green, "All synced")
    ELSE       → IconButton(cloud_upload, orange, "{n} pending")
    ALL icon buttons onPressed → _showSyncDetails

  loading → small CircularProgressIndicator
  error → IconButton(error, red) → _showSyncDetails
```

#### Method: _showSyncDetails(context, ref, accountId)
```
SHOW AlertDialog("Sync Status"):
  content: Consumer watching syncStatusProvider:
    data(status) → Column:
      ├─ DetailRow("Status", detailed text)
      ├─ DetailRow("Pending", count)
      ├─ DetailRow("Online", Yes/No)
      └─ IF online AND pending > 0:
          FilledButton.icon("Sync Now") → forceSyncNow → close + SnackBar
    loading → CircularProgressIndicator
    error → Text
  actions: TextButton("Close")
```
