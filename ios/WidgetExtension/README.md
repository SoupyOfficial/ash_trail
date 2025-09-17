# iOS Widget Extension Setup Guide

## Overview
This directory contains the iOS WidgetKit extension for AshTrail home screen widgets.

## Files Structure
```
ios/WidgetExtension/
├── Info.plist                 # Widget extension configuration
├── AshTrailWidget.swift       # Main widget implementation
└── README.md                  # This file
```

## Setup Instructions

### 1. Add Widget Extension Target in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target
3. Choose "Widget Extension" 
4. Product Name: `AshTrailWidgetExtension`
5. Bundle Identifier: `com.ashtrail.app.widget`
6. Ensure "Include Configuration Intent" is unchecked (we're using StaticConfiguration)

### 2. Configure App Group

1. In main app target capabilities:
   - Enable "App Groups"
   - Add group: `group.com.ashtrail.shared`

2. In widget extension target capabilities:
   - Enable "App Groups"  
   - Add same group: `group.com.ashtrail.shared`

### 3. Update iOS Runner Info.plist

Add URL scheme for deep linking:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.ashtrail.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>ashtrail</string>
        </array>
    </dict>
</array>
```

### 4. Widget Data Sharing

The widget reads data from UserDefaults using the shared app group:

```swift
let userDefaults = UserDefaults(suiteName: "group.com.ashtrail.shared")
```

Required data keys:
- `todayHitCount` (Int): Number of hits today
- `currentStreak` (Int): Current streak in days
- `lastSyncTimestamp` (Double): Last sync timestamp
- `widgetShowStreak` (Bool): Whether to show streak
- `widgetShowLastSync` (Bool): Whether to show last sync
- `widgetTapAction` (String): Tap action ("openApp", "recordOverlay", "viewLogs", "quickRecord")

### 5. Flutter Integration

Add to your Flutter app for updating widget data:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class WidgetDataManager {
  static Future<void> updateWidgetData({
    required int todayHitCount,
    required int currentStreak,
    bool? showStreak,
    bool? showLastSync,
    String? tapAction,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('todayHitCount', todayHitCount);
    await prefs.setInt('currentStreak', currentStreak);
    await prefs.setDouble('lastSyncTimestamp', DateTime.now().millisecondsSinceEpoch / 1000);
    
    if (showStreak != null) {
      await prefs.setBool('widgetShowStreak', showStreak);
    }
    if (showLastSync != null) {
      await prefs.setBool('widgetShowLastSync', showLastSync);
    }
    if (tapAction != null) {
      await prefs.setString('widgetTapAction', tapAction);
    }
  }
}
```

### 6. Deep Link Handling

Update your Flutter app to handle widget deep links:

```dart
// In main.dart or route handler
void handleDeepLink(String link) {
  final uri = Uri.parse(link);
  
  switch (uri.host) {
    case 'record':
      if (uri.queryParameters['quick'] == 'true') {
        // Handle quick record
      } else {
        // Handle record overlay
      }
      break;
    case 'logs':
      // Navigate to logs screen
      break;
    default:
      // Navigate to home
      break;
  }
}
```

## Widget Sizes & Features

### Small Widget (2x2)
- Shows today's hit count only
- Minimal, clean design
- Perfect for quick glances

### Medium Widget (4x2) 
- Shows hit count and streak (if enabled)
- AshTrail branding
- Last sync timestamp (optional)
- More detailed information

## Theming Support

The widget automatically respects:
- System light/dark mode
- Accent color preferences
- Dynamic Type sizing
- Accessibility contrast settings

## Testing

Use Xcode's Widget simulator or physical device:
1. Long press on home screen
2. Tap "+" to add widgets
3. Search for "AshTrail" 
4. Select size and add to home screen

## Troubleshooting

### Widget Not Updating
- Ensure app group is configured correctly
- Check UserDefaults keys match exactly
- Verify data is being written from Flutter app
- Widget updates every 15 minutes automatically

### Deep Links Not Working  
- Verify URL scheme in Runner Info.plist
- Check deep link handling in Flutter app
- Ensure widget URLs are correctly formatted

### Build Issues
- Clean build folder (⌘+Shift+K)
- Ensure deployment target is iOS 14.0+
- Verify bundle identifiers are unique

## Performance Notes

- Widget refreshes every 15 minutes maximum (iOS limitation)
- Use shared UserDefaults for data persistence
- Keep widget views lightweight for best performance
- Test on older devices to ensure smooth animations