# home_quick_log_widget

> **Source:** `lib/widgets/home_quick_log_widget.dart`

## Purpose
Minimal quick-log widget for the home screen. Uses a press-and-hold gesture to record duration (submits on release), with optional mood/physical sliders and reason chips. Hard-coded to eventType=vape, unit=seconds. Includes extensive multi-account diagnostic logging and location capture.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `../logging/app_logger.dart` — AppLogger for diagnostics
- `package:flutter_riverpod/flutter_riverpod.dart` — State management
- `dart:async` — Timer for duration recording
- `../models/enums.dart` — EventType, Unit, LogReason
- `../models/account.dart` — Account model
- `../services/log_record_service.dart` — LogRecordService
- `../providers/account_provider.dart` — activeAccountProvider, accountServiceProvider
- `../providers/log_record_provider.dart` — activeAccountLogRecordsProvider, logRecordStatsProvider
- `../services/location_service.dart` — LocationService for GPS
- `reason_chips_grid.dart` — ReasonChipsGrid widget

## Pseudo-Code

### Class: HomeQuickLogWidget (ConsumerStatefulWidget)

**Constructor Parameters:**
- `onLogCreated: VoidCallback?` — callback after successful log

#### State: _HomeQuickLogWidgetState

**State Variables:**
- `_isRecording: bool` — whether long press is active
- `_recordingStartTime: DateTime?` — when recording started
- `_recordingTimer: Timer?` — 100ms periodic timer for UI updates
- `_recordedDuration: Duration` — elapsed recording time
- `_moodRating, _physicalRating: double?` — slider values
- `_selectedReasons: Set<LogReason>` — chosen reason chips
- `_currentAccountId: String?` — tracks account for switch detection
- `_locationService: LocationService`

#### Method: _handleLongPressStart(details)
```
SET _isRecording = true
SET _recordingStartTime = DateTime.now()
SET _recordedDuration = Duration.zero
START Timer.periodic(100ms):
  UPDATE _recordedDuration = now - _recordingStartTime
```

#### Method: _handleLongPressEnd(details)
```
CANCEL _recordingTimer
IF was recording:
  COMPUTE durationMs = now - _recordingStartTime
  CALL _createVapeLog(durationMs)
  RESET recording state
```

#### Method: _handleTapCancel()
```
CANCEL timer, RESET recording state (no log created)
```

#### Method: _createVapeLog(int durationMs) → Future<void>
```
LOG diagnostic info at warning level

GET activeAccount from provider:
  IF loading → AWAIT future
  IF null → SHOW SnackBar "No active account" → RETURN

CROSS-CHECK: re-read provider in case account changed during async
CROSS-CHECK: compare with widget-level _currentAccountId

CHECK minimum threshold (1000ms):
  IF too short → SHOW SnackBar "Duration too short" → RETURN

CONVERT to seconds

CAPTURE location:
  TRY getCurrentLocation()
  LOG success or failure

CREATE record via LogRecordService.createLogRecord:
  accountId, eventType=vape, duration, unit=seconds,
  moodRating, physicalRating, reasons, latitude, longitude

SHOW SnackBar confirmation with UNDO action:
  UNDO → deleteLogRecord(record)

RESET form (mood, physical, reasons)
CALL onLogCreated callback
INVALIDATE providers (activeAccountLogRecordsProvider, logRecordStatsProvider)
```

#### Method: _toggleReason(LogReason)
```
IF already selected → REMOVE
ELSE → ADD
```

#### Method: _resetFormState()
```
CLEAR _moodRating, _physicalRating, _selectedReasons
```

#### Method: _cancelRecording()
```
CANCEL timer + RESET recording state (used on account switch)
```

#### Method: build(context) → Widget
```
WATCH activeAccountProvider to detect account switches:
  IF account changed → addPostFrameCallback: cancel recording, update _currentAccountId
  IF account null → cancel recording, clear _currentAccountId

RETURN Card(margin: vertical 12) → Padding(16) → Column:
  ├─ Mood Row:
  │   ├─ Text("Mood") — muted if unset
  │   └─ Slider(1–10, divisions: 9)
  │       SliderTheme: muted colors when null, theme primary when set
  │
  ├─ Physical Row:
  │   ├─ Text("Physical") — muted if unset
  │   └─ Slider(1–10, divisions: 9)
  │
  ├─ Reasons section:
  │   ├─ Text("Reasons")
  │   └─ ReasonChipsGrid(selected, onToggle, showIcons: true)
  │
  ├─ IF hasFormValues:
  │   └─ TextButton.icon("Clear form") → _resetFormState
  │
  └─ Press-and-hold button (GestureDetector):
      onLongPressStart → _handleLongPressStart
      onLongPressEnd → _handleLongPressEnd
      onLongPressCancel → _handleTapCancel
      Container(rounded, full width):
        IF recording: primary background + pause icon + elapsed seconds
        ELSE: surface background + touch_app icon + "Hold to record duration"
```
