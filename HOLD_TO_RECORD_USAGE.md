# How to Use Hold-to-Record Duration Logging

## Quick Reference

### Recording a Duration Log

1. **Find the Quick Log button** (FAB with + icon in bottom-right corner)
2. **Press and hold** for at least 500ms
3. **Keep holding** while the full-screen timer appears showing elapsed time
4. **Release** when done
5. Duration is automatically saved with an **Undo** option

### Gestures

| Action | Result |
|--------|--------|
| **Quick tap** | Instant log (1 count) |
| **Hold 500-800ms** | Duration recording mode |
| **Hold 800ms+** | Time adjustment overlay |
| **Swipe away during recording** | Cancel recording |

## Visual Feedback

When recording:
- Full-screen dark overlay appears
- Pulsing circle with timer icon
- Live duration display (e.g., "8.3 seconds")
- "Release to save" instruction
- "Swipe away to cancel" hint

## What Gets Saved

Each duration log creates a `LogRecord` with:
- **Type**: Inhale (or configured default)
- **Value**: Duration in seconds (decimal, e.g., 8.3)
- **Unit**: seconds
- **Timestamp**: Release time (when you let go)
- **Confidence**: High (measured duration)

## Viewing Duration Logs

Duration logs appear in the **Logs** list view with:
- Event icon (air icon for inhale)
- Event type label
- **Duration value** (e.g., "8.3s") in bold
- Time ago (e.g., "5m ago")
- Sync status indicator

Example log entry:
```
🌬️ Inhale
   5m ago
   8.3s
```

## Undo a Recording

After releasing:
1. Snackbar appears: **"Logged inhale (8.3s)"**
2. Tap **UNDO** within 3 seconds
3. Log is soft-deleted (won't appear in charts/stats)

## Minimum Duration

- **Minimum**: 1.0 seconds
- If you release before 1 second, you'll see:
  - Error message: "Duration too short (minimum 1 second)"
  - No log is created

## Offline Support

Duration logs work without internet:
- Duration computed locally
- Saved to local database immediately
- Synced to cloud when connection returns
- Cloud icon shows sync status:
  - 🔄 Orange = Pending sync
  - ✅ Green = Synced
  - ❌ Red = Sync error

## Editing Duration Logs

You can edit duration logs after creation:
1. Tap the log entry in the list
2. Dialog shows full details
3. Tap **Edit** button
4. Adjust duration value or other fields
5. Save changes

## Tips

### For Short Sessions (< 10s)
- Hold-to-record is ideal
- Real-time measurement eliminates guessing
- More accurate than manual entry

### For Long Sessions (> 1 minute)
- Hold-to-record still works
- Or use manual entry if you forgot to start recording
- Maximum duration: 1 hour (3600s)

### To Log Multiple Events
Hold-to-record logs **one event** per press/release cycle.

For multiple events in one session:
1. Use Session feature (future enhancement)
2. Or record multiple times separately

### Accidental Recordings
If you accidentally hold too long:
- Tap **UNDO** immediately after release
- Or delete from logs list later

## Troubleshooting

### "Duration too short" error
- You released before 1 second
- Try holding longer
- Or use quick tap for instant log

### Time adjustment overlay appears instead
- You held for 800ms+ 
- That triggers time adjustment mode
- Release sooner (500-800ms range) for duration recording

### Recording doesn't start
- Make sure you're holding on the button itself
- Don't start dragging/swiping
- Wait for overlay to appear

### Undo button disappeared
- 3-second window expired
- Manually delete from logs list:
  - Go to Logs screen
  - Swipe left on entry
  - Tap Delete

## Examples

### Example 1: Quick 5-second session
```
1. Hold Quick Log button
2. See overlay: "0.0 seconds"
3. Count to 5 (watch timer: "5.2 seconds")
4. Release
5. Snackbar: "Logged inhale (5.2s)"
6. Done!
```

### Example 2: Cancel recording
```
1. Hold Quick Log button
2. Start recording: "2.1 seconds"
3. Changed mind — swipe away
4. Recording cancelled
5. No log created
```

### Example 3: Undo recording
```
1. Hold and record: 12.7 seconds
2. Release
3. Snackbar: "Logged inhale (12.7s) | UNDO"
4. Tap UNDO within 3 seconds
5. Log removed
```

## Comparison with Other Logging Methods

| Method | Use Case | Duration Captured |
|--------|----------|-------------------|
| **Quick tap** | Instant event | None (count only) |
| **Hold-to-record** | Real-time session | ✅ Measured (accurate) |
| **Manual entry** | Retroactive logging | Estimated by user |
| **Time adjustment** | Log with custom time | None (count at specific time) |

## Next Steps

After recording duration logs:
- View in **Logs** tab (chronological list)
- Analyze in **Charts** tab (duration trends)
- Export via **Settings** > Export Data

---

**Note**: Hold-to-record integrates seamlessly with existing logging. All duration logs sync to cloud, appear in charts, and support full editing/deletion.
