# Hold-to-Record Duration Logging Implementation

## Overview

This implementation adds **press-and-hold duration capture** to AshTrail's logging system, allowing users to measure and log session durations in real-time by holding down the Quick Log button.

## Key Features

### 1. Dual-Mode Quick Log Button

The Quick Log FAB now supports **two interaction modes**:

- **Quick tap** → Instant log (existing behavior)
- **Long press (500ms)** → Duration recording with live timer
- **Longer hold (800ms)** → Time adjustment overlay (existing behavior)

### 2. Duration Recording Flow

1. **User presses and holds** the Quick Log button (500ms threshold)
2. **Recording starts** with visual feedback:
   - Full-screen overlay with pulsing circle animation
   - Live timer display (seconds.tenths format)
   - "Release to save" prompt
3. **User releases** the button
4. **Duration is computed** from hold time (ms precision)
5. **LogRecord is created** with:
   - `value` = duration in seconds (decimal)
   - `unit` = Unit.seconds
   - `eventAt` = release timestamp
   - `timeConfidence` = TimeConfidence.high
6. **Undo snackbar** appears with 3-second window

### 3. Edge Case Handling

- **Minimum threshold**: 1 second minimum duration enforced
- **Accidental taps**: Taps < 500ms trigger instant log (not recording)
- **Cancel gesture**: Swipe away or tap cancel during recording
- **Maximum duration**: Clamped via ValidationService (max 1 hour)

## Implementation Details

### New Service Method: `LogRecordService.recordDurationLog()`

```dart
Future<LogRecord> recordDurationLog({
  required String accountId,
  required int durationMs,
  String? profileId,
  EventType? eventType,
  List<String>? tags,
  String? note,
  String? location,
})
```

**Parameters:**
- `durationMs` — Measured duration in milliseconds
- Other parameters same as `quickLog()`

**Behavior:**
- Converts milliseconds to seconds with decimal precision
- Validates minimum 1-second threshold
- Clamps to maximum duration via ValidationService
- Creates LogRecord with `unit = Unit.seconds`
- Sets `timeConfidence = TimeConfidence.high` (measured time)
- Marks for sync with `syncState = SyncState.pending`

### Widget State Updates: `QuickLogWidget`

**New State Variables:**
```dart
bool _isRecording = false;
DateTime? _recordingStartTime;
Timer? _recordingTimer;
Duration _recordedDuration = Duration.zero;
```

**New Gesture Handlers:**
- `_handleLongPressStart()` — Enters recording mode at 500ms
- `_handleLongPressEnd()` — Saves duration log on release
- `_handleTapCancel()` — Cleans up both recording and time adjustment states

**New UI Method:**
- `_buildRecordingOverlay()` — Full-screen recording interface with pulsing animation

### Display Formatting: `LogRecordList`

**New Method:**
```dart
String _formatValue(double value, Unit unit) {
  if (unit == Unit.seconds || unit == Unit.minutes) {
    return value.toStringAsFixed(1); // "12.5s"
  }
  // ... other formats
}
```

Duration logs display as: **"12.5s"** in the log list and detail view.

## Usage Examples

### Basic Duration Recording

```dart
// User holds Quick Log button for 8.3 seconds
// → Creates LogRecord with value=8.3, unit=seconds
// → Displays in log list as "Inhale" with "8.3s" subtitle
```

### With Undo

```dart
// User records 15.2s session
// → Snackbar: "Logged inhale (15.2s)" with UNDO button
// User taps UNDO within 3 seconds
// → LogRecord soft-deleted (isDeleted=true)
```

### From Logs View

Duration logs appear identically to manual logs:
- Same icon, same formatting
- Can be edited inline
- Can be filtered/sorted
- Can be deleted

## Data Model

No schema changes required — duration logs use existing `LogRecord` structure:

```dart
LogRecord(
  logId: "uuid",
  accountId: "user123",
  eventType: EventType.inhale,
  eventAt: DateTime(2025, 12, 25, 14, 30, 12), // Release time
  value: 8.3,                                    // Duration in seconds
  unit: Unit.seconds,                            // Always seconds for duration logs
  timeConfidence: TimeConfidence.high,           // Measured time
  syncState: SyncState.pending,
  // ... other fields
)
```

## Gesture Conflict Resolution

To avoid conflicts between recording and time adjustment:

| Hold Duration | Behavior |
|---------------|----------|
| < 500ms | Quick tap → instant log |
| 500-800ms | **Duration recording** (new) |
| > 800ms | Time adjustment overlay (existing) |

This provides a natural "hold a bit longer" UX for accessing time adjustment while making duration recording the primary long-press action.

## Offline Support

Duration logs work fully offline:

1. Recorded duration computed locally (monotonic clock)
2. Saved to Isar immediately
3. Marked as `SyncState.pending`
4. Synced to Firestore when connection available
5. Conflict resolution uses `lastRemoteUpdateAt` timestamp

## Analytics Implications

Duration logs enable new analytics:

- **Average session duration** per day/week/month
- **Duration trends** over time
- **Short vs. long sessions** classification
- **Total time logged** vs. event count

Existing chart/stat code automatically includes duration logs since they use the same data model.

## Testing Checklist

- [ ] Hold Quick Log button for various durations (1s, 5s, 30s, 60s)
- [ ] Verify live timer updates during hold
- [ ] Release and confirm log created with correct duration
- [ ] Test undo within 3-second window
- [ ] Test minimum threshold (< 1s shows error)
- [ ] Test gesture cancel (swipe away)
- [ ] Test offline recording + sync
- [ ] Verify duration logs display correctly in list
- [ ] Test inline edit of duration logs
- [ ] Confirm time adjustment overlay still works (800ms+ hold)

## Future Enhancements

Potential improvements (not implemented):

1. **Session Integration**
   - Link duration logs to Session model
   - Track multiple events within one session
   - Session metrics: entryCount, totalValue, averageIntervalSeconds

2. **Capture Type Field**
   - Add `captureType` enum: `instant`, `timed`, `session`
   - Enable analytics by recording method
   - Optional visual badge in UI

3. **Configurable Thresholds**
   - User preference for minimum duration
   - Custom gesture timing preferences

4. **Haptic Feedback**
   - Vibrate on recording start/end
   - Pulse during recording

5. **Audio Cues**
   - Optional beep on start/end
   - Tick sound during recording

## Files Modified

1. **[lib/services/log_record_service.dart](lib/services/log_record_service.dart)**
   - Added `recordDurationLog()` method

2. **[lib/widgets/quick_log_widget.dart](lib/widgets/quick_log_widget.dart)**
   - Added recording state tracking
   - Added gesture handlers for hold-to-record
   - Added `_buildRecordingOverlay()` with pulsing animation
   - Added `_createDurationLog()` with undo support

3. **[lib/widgets/log_record_list.dart](lib/widgets/log_record_list.dart)**
   - Added `_formatValue()` for proper duration display
   - Updated subtitle to use formatted values

## Summary

The hold-to-record feature provides a **low-friction, real-time logging method** that complements the existing manual/backdated logging workflows. It uses the same data model, supports undo, works offline, and integrates seamlessly with existing UI/analytics code.

**Key principle:** The button *is* the timer — no separate stopwatch UI required.
