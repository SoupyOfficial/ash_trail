# Ash Trail iOS Widget Extension

This directory contains the native iOS Widget Extension for Ash Trail, allowing users to view their usage statistics directly from the iPhone home screen and lock screen.

## Files

- **AshTrailWidget.swift**: Main widget implementation with all view components
- **SharedDataManager.swift**: Data persistence manager using App Groups for sharing data between the main app and widget
- **AshTrailWidgetIntent.swift**: Widget configuration intent (for future customization support)
- **Info.plist**: Widget extension configuration

## Setup Instructions

See [docs/setup/IOS_WIDGET_SETUP.md](/docs/setup/IOS_WIDGET_SETUP.md) for complete setup instructions.

## Quick Start

1. Open `ios/Runner.xcworkspace` in Xcode
2. Add a new Widget Extension target named "AshTrailWidget"
3. Replace auto-generated files with the files in this directory
4. Add `SharedDataManager.swift` to both Runner and AshTrailWidget targets
5. Enable App Groups capability for both targets with ID: `group.com.soupy.ashtrail`
6. Build and run

## Widget Sizes Supported

- **Small (systemSmall)**: Shows hits today with a large number display
- **Medium (systemMedium)**: Displays hits today and total duration side-by-side
- **Large (systemLarge)**: Full statistics with 7-day weekly pattern bar chart
- **Lock Screen Widgets** (iOS 16+):
  - Circular: Compact hit count
  - Rectangular: Hits and time since last hit
  - Inline: Condensed stats in a single line

## Data Synchronization

The widget receives data from the Flutter app via:

1. **Method Channel**: `com.soupy.ashtrail/widget`
2. **App Groups**: `group.com.soupy.ashtrail`
3. **Shared UserDefaults**: Widget data stored in shared container

When log records change in the Flutter app, the `IOSWidgetService` automatically exports the computed metrics to the shared container, and WidgetKit refreshes the widget UI.

## Customization

To modify widget appearance or data:

1. **Change Colors**: Edit the gradient colors in each widget view
2. **Update Refresh Interval**: Modify the timeline policy in `getTimeline()`
3. **Add New Metrics**: Update `WidgetData` model and export from Flutter

## Troubleshooting

If widgets don't show data:
- Verify App Group ID matches in both targets
- Check that `SharedDataManager.swift` is in both target memberships
- Ensure method channel name matches in both Swift and Dart code
- Check Xcode console for error messages

## Future Features

- Widget configuration UI (select metric, time range, event type)
- Interactive widgets with quick log button (iOS 17+)
- Live Activities for active sessions (iOS 16.1+)
- Additional metrics (mood averages, top reasons, trends)
