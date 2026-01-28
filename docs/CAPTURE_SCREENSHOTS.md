# How to Capture Screenshots for Figma

This guide shows you how to capture actual screenshots of your Flutter app for import into Figma.

## Quick Start

### Option 1: Interactive Manual Capture (Recommended)

Run the interactive script:
```bash
./scripts/capture_screenshots_manual.sh
```

This will:
- Show available devices
- Let you choose a device
- Provide step-by-step instructions
- Give you ready-to-use commands for each screen

### Option 2: Automated Capture

1. **Start your Flutter app first:**
   ```bash
   flutter run -d <device-id>
   ```

2. **Then run the capture script:**
   ```bash
   ./scripts/capture_flutter_screenshots.sh <device-id>
   ```

## Step-by-Step Manual Process

### 1. Start Your App

Choose a device and run:
```bash
# iOS Simulator
flutter run -d 0A875592-129B-40B6-A072-A0C0CA94AED3

# macOS Desktop
flutter run -d macos

# Chrome Web
flutter run -d chrome

# Physical iOS Device
flutter run -d 00008140-0010589430A2201C
```

Or list all devices:
```bash
flutter devices
```

### 2. Navigate to Each Screen

In your running app, navigate to:
- Home Screen
- Analytics Screen
- History Screen
- Logging Screen
- Accounts Screen
- Export Screen
- Profile Screen

### 3. Capture Screenshots

#### For iOS Simulator:

**Method A: Simulator Screenshot**
1. Navigate to the screen
2. Press `Cmd + S` in the simulator
3. Save to: `screenshots/flutter/[timestamp]/[screen-name].png`

**Method B: Flutter Command**
```bash
flutter screenshot -d <device-id> screenshots/flutter/[timestamp]/home.png
```

#### For macOS Desktop:

**Method A: macOS Screenshot**
1. Navigate to the screen
2. Press `Cmd + Shift + 4`
3. Select the app window
4. Save to: `screenshots/flutter/[timestamp]/[screen-name].png`

**Method B: Flutter Command**
```bash
flutter screenshot -d macos screenshots/flutter/[timestamp]/home.png
```

#### For Chrome/Web:

**Method A: Browser Extension**
- Use a screenshot extension
- Save to: `screenshots/flutter/[timestamp]/[screen-name].png`

**Method B: Flutter Command**
```bash
flutter screenshot -d chrome screenshots/flutter/[timestamp]/home.png
```

### 4. Screen Names

Use these exact names when saving:
- `home.png` - Home Screen
- `analytics.png` - Analytics Screen
- `history.png` - History Screen
- `logging.png` - Logging Screen
- `accounts.png` - Accounts Screen
- `export.png` - Export Screen
- `profile.png` - Profile Screen

### 5. Prepare for Figma

After capturing all screenshots:
```bash
./scripts/prepare_figma_import.sh
```

This will organize your screenshots and create import guides.

## Troubleshooting

### "App is not running" Error

The capture script needs your app to be running first. Either:
1. Start the app manually, then run the script
2. Use the interactive manual script: `./scripts/capture_screenshots_manual.sh`

### Screenshots Not Capturing

**iOS Simulator:**
- Make sure simulator is in focus
- Try `Cmd + S` directly in simulator
- Or use: `Device > Screenshot` from menu

**Flutter Command:**
- Ensure app is fully loaded
- Wait a few seconds after navigation
- Check device ID is correct: `flutter devices`

### Low Quality Screenshots

- Use 2x or 3x resolution if available
- For iOS Simulator: Check simulator scale (Window > Physical Size)
- For Flutter command: Screenshots are automatically at device resolution

### Wrong Screen Captured

- Wait for navigation to complete
- Use `flutter screenshot` immediately after screen loads
- Or use device-specific screenshot tools for more control

## Tips

1. **High Resolution**: Always capture at the device's native resolution
2. **Consistent State**: Capture screens with sample data if possible
3. **Multiple States**: Consider capturing different states (empty, loading, with data)
4. **Organize**: Use clear, consistent naming
5. **Verify**: Check screenshots before importing to Figma

## Example Workflow

```bash
# 1. Start app
flutter run -d 0A875592-129B-40B6-A072-A0C0CA94AED3

# 2. Wait for app to load, then in another terminal:

# 3. Create screenshot directory (or use script)
mkdir -p screenshots/flutter/$(date +%Y%m%d_%H%M%S)
SCREEN_DIR="screenshots/flutter/$(date +%Y%m%d_%H%M%S)"

# 4. Navigate to home screen in app, then:
flutter screenshot -d 0A875592-129B-40B6-A072-A0C0CA94AED3 $SCREEN_DIR/home.png

# 5. Navigate to analytics screen, then:
flutter screenshot -d 0A875592-129B-40B6-A072-A0C0CA94AED3 $SCREEN_DIR/analytics.png

# 6. Repeat for other screens...

# 7. Prepare for Figma
./scripts/prepare_figma_import.sh
```

## Next Steps

After capturing screenshots:
1. Review them in the `screenshots/flutter/` directory
2. Run `./scripts/prepare_figma_import.sh`
3. Import to Figma using the generated guide
4. Edit designs in Figma
5. Export edited screenshots
6. Share for code implementation

---

For more details, see [FIGMA_WORKFLOW.md](./FIGMA_WORKFLOW.md)
