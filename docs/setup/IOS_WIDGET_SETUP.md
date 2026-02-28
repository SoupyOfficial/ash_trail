# iOS Widget Setup Guide

This guide explains how to configure the iOS Widget Extension in Xcode for the Ash Trail app.

## Overview

The Ash Trail iOS widgets allow users to view their usage statistics directly from the iPhone home screen and lock screen without opening the app. The widgets support multiple sizes and display various metrics like hits today, total duration, time since last hit, and weekly patterns.

## Widget Features

### Supported Widget Families
- **Small (systemSmall)**: Displays hits today
- **Medium (systemMedium)**: Shows hits today + total duration
- **Large (systemLarge)**: Full stats with weekly pattern chart
- **Lock Screen Widgets**:
  - Circular: Hit count
  - Rectangular: Hits + time since last
  - Inline: Compact stats

### Metrics Displayed
- Hits Today
- Total Duration Today
- Time Since Last Hit
- Last Hit Time
- 7-Day Weekly Pattern

## Xcode Project Setup

Since the Flutter project files have been created, you need to add the Widget Extension target in Xcode. Follow these steps:

### Step 1: Add Widget Extension Target

1. Open `ios/Runner.xcworkspace` in Xcode
2. In the project navigator, select the **Runner** project
3. Click the **+** button at the bottom of the targets list
4. Select **Widget Extension** template
5. Configure the widget:
   - **Product Name**: `AshTrailWidget`
   - **Bundle Identifier**: `com.soupy.ashtrail.AshTrailWidget`
   - **Language**: Swift
   - **Include Configuration Intent**: Yes (for future customization)
   - **Uncheck** "Include Live Activity"
6. Click **Finish**
7. When asked "Activate AshTrailWidget scheme?", click **Activate**

### Step 2: Replace Auto-Generated Files

The widget files have already been created in `ios/AshTrailWidget/`. You need to replace the auto-generated files:

1. Delete the auto-generated `AshTrailWidget.swift` file created by Xcode
2. In Xcode, right-click the `AshTrailWidget` folder → **Add Files to "Runner"...**
3. Navigate to `ios/AshTrailWidget/` and add:
   - `AshTrailWidget.swift`
   - `SharedDataManager.swift`
   - `AshTrailWidgetIntent.swift`
   - `Info.plist` (if not already present)
4. Ensure **Target Membership** is set to `AshTrailWidget` for these files

### Step 3: Add SharedDataManager to Main App Target

The `SharedDataManager.swift` needs to be included in **both** the main app and widget extension:

1. In Xcode, select `SharedDataManager.swift`
2. In the **File Inspector** (right panel), under **Target Membership**:
   - ✅ Check **Runner** (main app)
   - ✅ Check **AshTrailWidget** (widget extension)

### Step 4: Configure App Groups

App Groups enable data sharing between the main app and widget extension:

1. Select the **Runner** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** → **App Groups**
4. Click **+** to add a new App Group:
   - Name: `group.com.soupy.ashtrail`
5. Enable the App Group

Repeat for the **AshTrailWidget** target:
1. Select the **AshTrailWidget** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** → **App Groups**
4. Enable the same App Group: `group.com.soupy.ashtrail`

### Step 5: Update Bundle Identifiers

Ensure bundle identifiers are correct:

1. **Runner** target:
   - Bundle Identifier: `com.soupy.ashtrail`
2. **AshTrailWidget** target:
   - Bundle Identifier: `com.soupy.ashtrail.AshTrailWidget`

### Step 6: Set Minimum Deployment Target

Widgets require iOS 14.0 or later:

1. Select **Runner** target → **General** tab
2. Set **Minimum Deployments** to **iOS 14.0**
3. Select **AshTrailWidget** target → **General** tab
4. Set **Minimum Deployments** to **iOS 14.0**

### Step 7: Configure Build Settings

Update build settings for the widget extension:

1. Select **AshTrailWidget** target
2. Go to **Build Settings** tab
3. Search for "Swift Language Version"
   - Set to **Swift 5** or later
4. Search for "Code Signing"
   - Ensure proper provisioning profile is selected

### Step 8: Update Info.plist (Main App)

The main app's `Info.plist` already has the required configurations, but verify:

1. Open `ios/Runner/Info.plist`
2. Ensure `NSAppTransportSecurity` and other required keys are present

### Step 9: Build and Test

1. Select the **AshTrailWidget** scheme from the scheme selector
2. Choose a simulator or device (iOS 14.0+)
3. Click **Run** (or press Cmd+R)
4. This will build and install both the app and widget

To add the widget to your home screen:
1. Long-press on the home screen
2. Tap the **+** button in the top-left corner
3. Search for "Ash Trail"
4. Select a widget size
5. Tap **Add Widget**

## Architecture

### Data Flow

```
Flutter App (LogRecord changes)
    ↓
IOSWidgetService.updateWidgetData()
    ↓
Method Channel (com.soupy.ashtrail/widget)
    ↓
AppDelegate.handleUpdateWidgetData()
    ↓
SharedDataManager.saveWidgetData()
    ↓
UserDefaults (App Group: group.com.soupy.ashtrail)
    ↓
AshTrailWidget TimelineProvider
    ↓
Widget UI Updates
```

### Key Components

1. **AshTrailWidget.swift**: Main widget implementation with all views
2. **SharedDataManager.swift**: Data persistence layer using App Groups
3. **AshTrailWidgetIntent.swift**: Widget configuration (for future customization)
4. **AppDelegate.swift**: Method channel handler for Flutter ↔ iOS communication
5. **IOSWidgetService.dart**: Flutter service for widget data export
6. **ios_widget_sync_provider.dart**: Automatic widget sync when data changes

## Troubleshooting

### Widget Not Showing Data

1. **Check App Group Configuration**:
   - Verify the App Group ID matches in both targets: `group.com.soupy.ashtrail`
   - Both Runner and AshTrailWidget must have the same App Group enabled

2. **Verify SharedDataManager Target Membership**:
   - Ensure `SharedDataManager.swift` is added to both Runner and AshTrailWidget targets

3. **Check Method Channel**:
   - Look for log messages in Xcode console when updating data
   - Verify the channel name matches: `com.soupy.ashtrail/widget`

4. **Test Data Sync**:
   ```dart
   // In Flutter code, trigger a manual update:
   final widgetService = IOSWidgetService();
   await widgetService.updateWidgetData(logRecords);
   ```

### Widget Not Updating

1. **Force Reload**:
   ```dart
   final widgetService = IOSWidgetService();
   await widgetService.reloadWidgets();
   ```

2. **Check Timeline Refresh**:
   - Widgets refresh every 15 minutes by default
   - Modify the refresh interval in `AshTrailWidget.swift` if needed:
   ```swift
   let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
   ```

3. **Remove and Re-add Widget**:
   - Long-press the widget → **Remove Widget**
   - Add it again from the widget gallery

### Build Errors

1. **"No such module 'WidgetKit'"**:
   - Ensure deployment target is iOS 14.0 or later
   - Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)

2. **Code Signing Errors**:
   - Verify provisioning profiles for both Runner and AshTrailWidget targets
   - Ensure bundle IDs are correct

3. **Symbol Not Found Errors**:
   - Ensure `SharedDataManager.swift` is in both target memberships
   - Rebuild the project

## Testing Checklist

- [ ] Widget displays on home screen
- [ ] Small widget shows hit count
- [ ] Medium widget shows hits + duration
- [ ] Large widget shows full stats with weekly chart
- [ ] Lock screen widgets display correctly (iOS 16+)
- [ ] Widget updates when logging a new entry in the app
- [ ] Data persists after app restart
- [ ] Widget shows placeholder when no data is available
- [ ] All widget sizes render correctly on different iPhone models

## Future Enhancements

Potential improvements for future versions:

1. **Widget Configuration**:
   - Allow users to choose which metric to display in each widget
   - Support for multiple time ranges (today, 3 days, week, month)
   - Event type filtering (vape only, inhale only, etc.)

2. **Interactive Widgets** (iOS 17+):
   - Quick log button directly from widget
   - Tap to open specific screens in the app

3. **Live Activities** (iOS 16.1+):
   - Track active sessions in real-time
   - Show live timer for current session

4. **Additional Metrics**:
   - Mood and physical rating averages
   - Top reasons for the week
   - Comparison with previous periods

## References

- [Apple WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [App Groups Documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)
