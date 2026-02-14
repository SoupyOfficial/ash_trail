# home_quick_log_widget

> **Source:** `lib/widgets/home_quick_log_widget.dart`

## Purpose

Minimal quick-log widget for the home screen. Provides press-and-hold duration recording (submit on release), mood/physical rating sliders, and reason filter chips. Hard-coded to eventType = vape, unit = seconds. Includes extensive multi-account safety checks and diagnostic logging.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management
- `dart:async` — `Timer`
- `../logging/app_logger.dart` — Structured logging
- `../models/app_error.dart` — `AppError`
- `../models/enums.dart` — `EventType`, `Unit`, `LogReason`
- `../models/account.dart` — `Account`
- `../services/log_record_service.dart` — `LogRecordService`
- `../providers/account_provider.dart` — `activeAccountProvider`, `accountServiceProvider`
- `../providers/log_record_provider.dart` — `activeAccountLogRecordsProvider`, `logRecordStatsProvider`
- `../services/location_service.dart` — `LocationService`
- `../utils/error_display.dart` — `ErrorDisplay`
- `reason_chips_grid.dart` — `ReasonChipsGrid`

## Pseudo-Code

### Class: HomeQuickLogWidget (ConsumerStatefulWidget)

**Constructor Parameters:**
- `onLogCreated: VoidCallback?` — called after successful log creation

### Class: _HomeQuickLogWidgetState

#### Fields

```
  _isRecording: bool = false
  _recordingStartTime: DateTime?
  _recordingTimer: Timer?
  _recordedDuration: Duration = zero
  _moodRating: double?
  _physicalRating: double?
  _selectedReasons: Set<LogReason> = {}
  _currentAccountId: String?        — tracks account for switch detection
  _locationService: LocationService
```

---

#### `_handleLongPressStart(details)`

```
SET _isRecording = true, _recordingStartTime = now
START Timer.periodic(100ms) -> update _recordedDuration
```

#### `_handleLongPressEnd(details)`

```
CANCEL timer
IF was recording -> _createVapeLog(durationMs)
RESET recording state
```

#### `_handleTapCancel()`

```
CANCEL timer, RESET recording state
```

---

#### `_createVapeLog(durationMs)` -> Future<void>

```
LOG '[QUICK_LOG_START]' with diagnostic context

// 1. Get active account (with loading/timeout handling)
IF provider is loading -> AWAIT .future with 5s timeout
IF provider has error -> LOG error
ELSE -> read directly

IF activeAccount == null -> SHOW SnackBar 'No active account' -> RETURN

// 2. Cross-check account ID integrity
IF account changed during async -> use new account, LOG warning
IF _currentAccountId mismatch with provider -> LOG warning

// 3. Verify account exists in database
accountExists = AWAIT accountService.accountExists(userId)
IF NOT exists -> SHOW SnackBar 'Account not ready yet' -> RETURN

// 4. Minimum duration check
IF durationMs < 1000 -> ErrorDisplay.showSnackBar(
  AppError.validation('Duration too short', code: 'VALIDATION_DURATION_SHORT')
) -> RETURN

// 5. Capture location (optional, non-blocking)
TRY: position = locationService.getCurrentLocation()
CATCH: LOG warning (non-fatal)

// 6. Create log record
record = service.createLogRecord(
  accountId, eventType: vape, duration: seconds,
  unit: seconds, moodRating, physicalRating, reasons,
  latitude, longitude
)

// 7. Post-creation
SHOW SnackBar with duration + UNDO action
RESET form state (_moodRating, _physicalRating, _selectedReasons)
CALL onLogCreated
INVALIDATE activeAccountLogRecordsProvider, logRecordStatsProvider

CATCH -> ErrorDisplay.showException(context, e, reportContext: 'QuickLog.submit')
```

---

#### `build(context)` -> Widget

```
WATCH activeAccountProvider

// Account switch detection
IF provider isLoading -> keep current state (LOG warning)
IF provider hasError -> LOG error
IF account changed -> POST-FRAME: _cancelRecording, update _currentAccountId
IF account went null -> POST-FRAME: _cancelRecording, clear _currentAccountId

Card -> Padding -> Column:
  // Mood slider (muted until touched, then theme primary)
  Row: 'Mood' label + SliderTheme(muted) -> Slider(1-10, divisions: 9)

  // Physical slider (same muted pattern)
  Row: 'Physical' label + SliderTheme(muted) -> Slider(1-10, divisions: 9)

  // Reason chips
  'Reasons' label + ReasonChipsGrid(selected, onToggle, showIcons: true)

  // Clear form button (visible only when form has values)
  IF hasFormValues -> TextButton.icon('Clear form') -> _resetFormState

  // Hold-to-record button
  Semantics(label: 'Hold to record duration') ->
    GestureDetector(onLongPressStart/End/Cancel) ->
      Container(full width, rounded, primary border):
        IF recording -> pause icon + duration text (e.g. '2.35s')
        ELSE -> touch_app icon + 'Hold to record duration'
```

## Notes

- Form values (mood, physical, reasons) persist across recordings; only reset on Clear or after successful log.
- Recording is cancelled (not form) on account switch to prevent logging to wrong account.
- Minimum duration threshold: 1 second. Below that, shows validation error via `ErrorDisplay`.
- Account existence check prevents creating orphan records after an incomplete account switch.
- Location capture is best-effort and non-blocking.
- Extensive warning-level logging for TestFlight/multi-account debugging.
