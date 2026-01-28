# Screenshot Verification Guide

## Issue Found

The initial screenshot capture was capturing the iPhone home screen instead of the app content. This happens when:
- The app hasn't fully loaded yet
- The app is running but not in the foreground
- The simulator is showing the home screen

## Solution

Use the improved capture script that ensures the app is actually open:

```bash
./scripts/capture_app_screens.sh
```

This script:
1. Builds and installs the app
2. Launches it directly on the simulator
3. Waits for the app to fully load
4. Verifies the app is visible before capturing
5. Guides you through manual navigation

## Manual Verification Steps

After capturing screenshots, verify they show app content:

1. **Check file size**: Should be > 1MB (not tiny blank screens)
2. **Check dimensions**: Should match device resolution (e.g., 1320x2868 for iPhone)
3. **Open and view**: Actually open the PNG file and verify it shows your app UI

## Quick Test

To quickly test if capture is working:

```bash
# 1. Start app
flutter run -d <device-id>

# 2. Wait for app to fully load (30-45 seconds)

# 3. Make sure app is visible on screen (not home screen)

# 4. Capture
flutter screenshot -d <device-id> test.png

# 5. Open test.png and verify it shows your app, not home screen
```

## Troubleshooting

### Screenshot shows home screen
- **Solution**: Make sure the app is in the foreground
- Tap the app icon if needed
- Wait longer for app to load (45+ seconds)

### Screenshot is blank/black
- **Solution**: App may not have rendered yet
- Wait longer after app starts
- Check app logs for errors

### Screenshot is too small
- **Solution**: This usually means an error occurred
- Check Flutter output for errors
- Try capturing again

## Best Practices

1. **Always verify**: Open screenshots to confirm they show app content
2. **Wait for load**: Give app 45+ seconds to fully initialize
3. **Check foreground**: Ensure app is visible, not home screen
4. **Navigate first**: Go to each screen before capturing
5. **Use the script**: `capture_app_screens.sh` handles most of this automatically
