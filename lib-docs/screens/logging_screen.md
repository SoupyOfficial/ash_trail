# logging_screen

> **Source:** `lib/screens/logging_screen.dart`

## Purpose

Dedicated logging screen with two tabs: a **Detailed** tab for full-featured event entry (event type, duration via long-press recording or manual input, reason chips, mood/physical ratings, notes, auto-captured location with map picker) and a **Backdate** tab for logging past events. This is the primary data-entry interface for Ash Trail.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — Riverpod state management
- `package:google_maps_flutter/google_maps_flutter.dart` — `LatLng` type for map picker results
- `dart:async` — `Timer` for recording duration updates
- `../logging/app_logger.dart` — Structured logging
- `../models/enums.dart` — `EventType`, `Unit` enums
- `../providers/log_record_provider.dart` — `activeAccountIdProvider`, `logDraftProvider`, `LogDraftNotifier`, `LogDraft`
- `../widgets/backdate_dialog.dart` — `BackdateDialog`
- `../services/log_record_service.dart` — `LogRecordService` for persisting records
- `../services/location_service.dart` — `LocationService` for GPS access
- `../widgets/location_map_picker.dart` — `LocationMapPicker` for manual location selection
- `../widgets/reason_chips_grid.dart` — `ReasonChipsGrid` for multi-select reason tags
- `../utils/design_constants.dart` — Design tokens

## Pseudo-Code

### Class: LoggingScreen (ConsumerStatefulWidget)

Creates `_LoggingScreenState`.

### Class: _LoggingScreenState (ConsumerState) with SingleTickerProviderStateMixin

#### State

```
_tabController: TabController (length: 2)
```

#### Lifecycle: initState()

```
_tabController = TabController(length: 2, vsync: this)
```

#### Lifecycle: dispose()

```
_tabController.dispose()
```

#### Method: build(context) -> Widget

```
WATCH accountId = ref.watch(activeAccountIdProvider)

IF accountId == null:
  RETURN Scaffold with "Please select an account first"

RETURN Scaffold:
  appBar = AppBar(title: "Log Event"):
    bottom = TabBar:
      Tab[0]: icon=edit_note, text="Detailed"   (key: tab_detailed)
      Tab[1]: icon=history,   text="Backdate"    (key: tab_backdate)

  body = TabBarView:
    [0] _DetailedLogTab(accountId)
    [1] _BackdateLogTab(accountId)
```

---

### Class: _DetailedLogTab (ConsumerStatefulWidget)

#### Constructor

```
REQUIRED accountId: String
```

Creates `_DetailedLogTabState`.

### Class: _DetailedLogTabState (ConsumerState)

#### State

```
_log:               AppLogger
_formKey:           GlobalKey<FormState>
_isSubmitting:      bool = false
_durationController: TextEditingController
_noteController:     TextEditingController

// Press-and-hold recording state
_longPressTimer:     Timer?
_recordingStartTime: DateTime?
_recordingTimer:     Timer?
_recordedDuration:   Duration = Duration.zero
_isRecording:        bool = false

// Location state
_isFetchingLocation: bool = false
_locationService:    LocationService
```

#### Lifecycle: initState()

```
super.initState()
_checkAndCaptureInitialLocation()
```

#### Method: _checkAndCaptureInitialLocation() -> Future<void>

```
IF PATROL_WAIT env var is set (test mode) -> RETURN  // skip in integration tests

draftNotifier = ref.read(logDraftProvider.notifier)
hasPermission = AWAIT _locationService.hasLocationPermission()

IF hasPermission:
  _captureLocationSilently(draftNotifier)
ELSE:
  IF mounted -> _promptForLocationPermission(draftNotifier)
```

#### Method: _captureLocationSilently(draftNotifier) -> Future<void>

```
TRY:
  position = AWAIT _locationService.getCurrentLocation()
  IF position != null AND mounted:
    draftNotifier.setLocation(lat, lng)
    SHOW SnackBar "Location captured"
CATCH:
  log warning
```

#### Method: _promptForLocationPermission(draftNotifier) -> Future<void>

```
SHOW AlertDialog:
  title = "Location Access"
  content = explanation of why location is needed
  actions: "Not Now", "Allow"

IF user chose Allow AND mounted:
  granted = AWAIT _locationService.requestLocationPermission()
  IF granted AND mounted -> _captureLocationSilently(draftNotifier)
```

#### Lifecycle: dispose()

```
_durationController.dispose()
_noteController.dispose()
_longPressTimer?.cancel()
_recordingTimer?.cancel()
```

#### Method: build(context) -> Widget

```
WATCH draft = ref.watch(logDraftProvider)
READ draftNotifier = ref.read(logDraftProvider.notifier)

RETURN SingleChildScrollView (responsive padding):
  Form (key: _formKey):
    Column (cross-axis stretch):

      [1] Card: EVENT TYPE
        DropdownButtonFormField<EventType>:
          value = draft.eventType
          items = EventType.values
          onChanged -> draftNotifier.setEventType(value)

      [2] Card: DURATION (manual entry)
        TextFormField "Seconds":
          controller = _durationController
          keyboardType = number
          onChanged -> draftNotifier.setDuration(parsed)

      [3] Card: PRESS & HOLD TO RECORD DURATION (primary pattern)
        Elevated card (primaryContainer)
        Title: "Press & Hold to Record Duration"
        Subtitle: "Recording..." or "Hold down the button"

        GestureDetector (circular 120x120 button):
          onLongPressStart   -> _startDurationRecording(draftNotifier)
          onLongPressEnd     -> _endDurationRecording(draft, draftNotifier)
          onLongPressCancel  -> _cancelDurationRecording()

          Visual: circle with touch_app / pause icon
          Shows recorded seconds count

      [4] Card: REASON (optional, multi-select)
        ReasonChipsGrid:
          selected = Set.from(draft.reasons ?? [])
          onToggle = draftNotifier.toggleReason

      [5] Card: MOOD & PHYSICAL RATING (optional)
        Mood Slider (1-10, divisions 9):
          value = draft.moodRating ?? 5.5
          onChanged -> draftNotifier.setMoodRating(value)
          Clear button -> setMoodRating(null)
        Physical Slider (1-10, divisions 9):
          value = draft.physicalRating ?? 5.5
          onChanged -> draftNotifier.setPhysicalRating(value)
          Clear button -> setPhysicalRating(null)

      [6] Card: NOTES
        TextFormField (maxLines 3):
          controller = _noteController
          onChanged -> draftNotifier.setNote(value)

      [7] Card: LOCATION (auto-collected)
        IF lat/lng available:
          Container: "Location Captured" with coordinates
          Row buttons: "Edit on Map" -> _openMapPicker(), "Recapture" -> _captureLocation()
        ELSE:
          Warning container: "Location not available"
          FilledButton "Enable Location":
            onPressed -> _captureLocation(draftNotifier)

      [8] SUBMIT BUTTONS Row:
        OutlinedButton "Clear" -> draftNotifier.reset(), clear controllers
        FilledButton "Log Event" -> _submitLog(draft)
```

#### Method: _startDurationRecording(draftNotifier) -> void

```
SET _isRecording = true, _recordingStartTime = now, _recordedDuration = zero
START _recordingTimer: every 100ms -> update _recordedDuration from diff
```

#### Method: _endDurationRecording(draft, draftNotifier) -> void

```
CANCEL _recordingTimer
durationSeconds = _recordedDuration.inMilliseconds / 1000.0

IF durationSeconds >= 1.0:
  _durationController.text = formatted
  draftNotifier.setDuration(durationSeconds)
  SHOW SnackBar "Recorded {seconds}s duration"
ELSE:
  SHOW SnackBar "Duration too short (minimum 1 second)"

SET _isRecording = false, _recordingStartTime = null
```

#### Method: _cancelDurationRecording() -> void

```
CANCEL _recordingTimer
SET _isRecording = false, _recordingStartTime = null
```

#### Method: _formatEnumName(name) -> String

```
Insert spaces before uppercase letters, capitalize first letter
```

#### Method: _openMapPicker(draftNotifier) -> Future<void>

```
result = AWAIT Navigator.push(LocationMapPicker(initialLat, initialLng))
IF result != null -> draftNotifier.setLocation(result.lat, result.lng), SnackBar
ELSE IF result cleared -> draftNotifier.setLocation(null, null), SnackBar
```

#### Method: _captureLocation(draftNotifier) -> Future<void>

```
SET _isFetchingLocation = true
TRY:
  position = AWAIT _locationService.getCurrentLocation()
  IF position != null -> setLocation, SnackBar "captured"
  ELSE:
    SHOW permission dialog
    IF user grants -> requestPermission, retry _captureLocation()
CATCH:
  SHOW SnackBar error
FINALLY:
  SET _isFetchingLocation = false
```

#### Method: _submitLog(draft) -> Future<void>

```
IF !draft.isValid -> SHOW SnackBar "Please check your input", RETURN

SET _isSubmitting = true
TRY:
  service = LogRecordService()
  AWAIT service.createLogRecord(
    accountId, eventType, eventAt, duration, unit,
    note, moodRating, physicalRating, reasons, lat, lng
  )
  RESET form: draftNotifier.reset(), clear controllers
  SHOW SnackBar success (with location info if captured)
CATCH:
  SHOW SnackBar error
FINALLY:
  SET _isSubmitting = false
```

---

### Class: _BackdateLogTab (ConsumerWidget)

#### Constructor

```
REQUIRED accountId: String
```

#### Method: build(context, ref) -> Widget

```
RETURN SingleChildScrollView (responsive padding):
  Column:
    Card:
      Icon: history (large)
      "Backdate Entry" title
      "Log an event that happened in the past (up to 30 days)"
      FilledButton.icon "Create Backdated Entry":
        onPressed -> showDialog(BackdateDialog)

    Card (info, primaryContainer):
      Icon: info_outline
      "Backdated entries are marked with lower time confidence
       and will be clearly identified in your timeline."
```
