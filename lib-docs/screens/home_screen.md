# home_screen

> **Source:** `lib/screens/home_screen.dart`

## Purpose

The main dashboard screen of Ash Trail. Displays a customizable, reorderable grid of home widgets (quick-log, stats, recent entries, etc.) powered by a configurable layout system. Manages account sync lifecycle, supports edit mode for adding/removing/reordering widgets, pull-to-refresh, and a backdate FAB. Preserves widget state during refresh by caching the last successful records list.

## Dependencies

- `dart:async` — `Timer` (unused directly here, but implied by sync)
- `dart:ui` — `lerpDouble` for drag animation
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter/services.dart` — `HapticFeedback` for tactile feedback
- `package:flutter_riverpod/flutter_riverpod.dart` — Riverpod state management
- `../models/account.dart` — `Account` model
- `../models/home_widget_config.dart` — `HomeWidgetConfig`, `HomeLayoutConfig`, `WidgetCatalog`, `WidgetSize`
- `../models/log_record.dart` — `LogRecord` model
- `../providers/account_provider.dart` — `activeAccountProvider`
- `../providers/home_widget_config_provider.dart` — `homeLayoutConfigProvider`, `homeEditModeProvider`
- `../providers/log_record_provider.dart` — `activeAccountLogRecordsProvider`, `logRecordNotifierProvider`
- `../providers/sync_provider.dart` — `syncServiceProvider`
- `../widgets/backdate_dialog.dart` — `BackdateDialog`
- `../widgets/home_widgets/home_widgets.dart` — `HomeWidgetWrapper`, `HomeWidgetEditPadding`, `HomeWidgetBuilder`, `showWidgetPicker`
- `../utils/design_constants.dart` — Design tokens
- `../utils/a11y_utils.dart` — `SemanticIconButton`
- `accounts_screen.dart` — Navigation target

## Pseudo-Code

### Class: HomeScreen (ConsumerStatefulWidget)

Creates `_HomeScreenState`.

### Class: _HomeScreenState (ConsumerState)

#### State

```
_lastAccountId: String?          = null    // tracks current account for sync management
_lastRecords:   List<LogRecord>? = null    // cached records for smooth refresh UX
```

#### Lifecycle: initState()

```
super.initState()
addPostFrameCallback:
  account = ref.read(activeAccountProvider).asData?.value
  IF account != null:
    _lastAccountId = account.userId
    syncService.startAccountSync(accountId: account.userId)
```

#### Method: _checkAccountChange(account)

```
IF account == null:
  syncService.stopAutoSync()
  CLEAR _lastAccountId, _lastRecords
  RETURN

IF _lastAccountId != account.userId:
  _lastAccountId = account.userId
  _lastRecords = null
  syncService.startAccountSync(accountId: account.userId)
```

#### Lifecycle: dispose()

```
syncService.stopAutoSync()
super.dispose()
```

#### Method: _buildGreeting(account) -> String

```
IF account == null -> "Home"
name = account.displayName ?? firstName ?? email prefix
RETURN "Welcome, $name"
```

#### Method: build(context) -> Widget

```
WATCH activeAccountAsync = ref.watch(activeAccountProvider)
WATCH isEditMode = ref.watch(homeEditModeProvider)

EXTRACT account, greeting

RETURN Scaffold:
  appBar = AppBar(title: isEditMode ? "Edit Home" : greeting):
    actions:
      [1] IF account != null:
          IconButton (edit/done toggle):
            onPressed -> HapticFeedback.selectionClick()
                         toggle homeEditModeProvider
      [2] SemanticIconButton (account_circle):
          onPressed -> Navigator.push(AccountsScreen)

  body = RefreshIndicator:
    onRefresh:
      IF account != null:
        ref.invalidate(activeAccountLogRecordsProvider)
        AWAIT 500ms

    child = activeAccountAsync.when:
      data(account):
        _checkAccountChange(account)
        IF account == null -> _buildNoAccountView()
        ELSE -> _buildMainView(ref)
      loading -> CircularProgressIndicator
      error   -> "Error: $error"

  floatingActionButton:
    IF account != null:
      FloatingActionButton.small (history icon):
        onPressed -> _showBackdateDialog()
        tooltip = "Backdate Entry"
```

#### Method: _buildNoAccountView(context) -> Widget

```
Center Column:
  Icon: account_circle_outlined (100px, faded)
  "Welcome to Ash Trail" headline
  "Create or sign in to an account to start logging"
  FilledButton.icon "Add Account" -> Navigator.push(AccountsScreen)
```

#### Method: _buildMainView(context, ref) -> Widget

```
WATCH logRecordsAsync = ref.watch(activeAccountLogRecordsProvider)
WATCH widgetConfig = ref.watch(homeLayoutConfigProvider)
WATCH isEditMode = ref.watch(homeEditModeProvider)

logRecordsAsync.when:
  data(records):
    _lastRecords = records
    _buildMainViewContent(records, widgetConfig, isEditMode)
  loading:
    IF _lastRecords != null -> reuse cached records (smooth refresh)
    ELSE -> CircularProgressIndicator
  error -> error card with icon and message
```

#### Method: _buildMainViewContent(context, ref, records, layoutConfig, isEditMode) -> Widget

```
visibleWidgets = layoutConfig.visibleWidgets
layoutRows = _buildLayoutRows(visibleWidgets)

Column:
  Expanded: ReorderableListView.builder:
    buildDefaultDragHandles = false
    responsive padding
    itemCount = layoutRows.length
    onReorder(oldIndex, newIndex):
      HapticFeedback.mediumImpact()
      COMPUTE old/new widget indices from row mapping
      ref.read(homeLayoutConfigProvider.notifier).reorder(old, new)

    proxyDecorator: AnimatedBuilder with:
      scale = lerp(1, 1.02, animValue)
      elevation = lerp(0, 8, animValue)

    itemBuilder(rowIndex):
      rowWidgets = layoutRows[rowIndex]
      widgetIndex = _getFirstWidgetIndexForRow(rows, rowIndex)

      IF single widget row:
        Padding (key: "row_{id}"):
          HomeWidgetWrapper -> HomeWidgetEditPadding -> HomeWidgetBuilder

      IF paired compact widget row:
        Padding (key: "row_{id1}_{id2}"):
          IntrinsicHeight:
            Row:
              Expanded: HomeWidgetWrapper[0]
              spacing
              Expanded: HomeWidgetWrapper[1]

  IF isEditMode:
    SafeArea: FilledButton.icon "Add Widget" -> showWidgetPicker(context)
```

#### Method: _buildLayoutRows(widgets) -> List<List<HomeWidgetConfig>>

```
rows = []
i = 0
WHILE i < widgets.length:
  config = widgets[i]
  entry = WidgetCatalog.getEntry(config.type)

  IF entry.size == compact AND i+1 < widgets.length:
    nextEntry = WidgetCatalog.getEntry(widgets[i+1].type)
    IF nextEntry.size == compact:
      rows.add([config, widgets[i+1]])  // pair them
      i += 2
      CONTINUE

  rows.add([config])  // single row
  i++

RETURN rows
```

#### Method: _getFirstWidgetIndexForRow(rows, rowIndex) -> int

```
SUM lengths of all rows before rowIndex
```

#### Method: _confirmRemoveWidget(context, ref, config) -> void

```
entry = WidgetCatalog.getEntry(config.type)
SHOW AlertDialog: "Remove Widget" — 'Remove "{displayName}"?'
  Cancel / Remove (red)
  onRemove:
    ref.read(homeLayoutConfigProvider.notifier).removeWidget(config.id)
    SHOW SnackBar "Removed {name}" with UNDO:
      onPressed -> addWidget(config.type)
```

#### Method: _showBackdateDialog(context) -> void

```
SHOW Dialog: BackdateDialog()
```

#### Method: _deleteLogRecord(record) -> Future<void>

```
TRY:
  AWAIT ref.read(logRecordNotifierProvider.notifier).deleteLogRecord(record)
  ref.invalidate(activeAccountLogRecordsProvider)
  SHOW SnackBar "Entry deleted" with UNDO -> restoreLogRecord, invalidate
CATCH:
  SHOW SnackBar error (red)
```
