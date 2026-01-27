# Location Collection Feature - Setup Guide

## Overview

The app now automatically collects location data when creating logs and provides a map-based interface for editing locations. This feature is iOS-focused and uses Google Maps for an enhanced user experience.

## Features Implemented

1. **Automatic Location Collection on App Launch**
   - When the app opens, it checks for location permissions
   - If permission is granted, location is automatically collected
   - If not granted, the user is prompted with a clear explanation

2. **Required Location Collection for New Logs**
   - When the logging screen opens, it automatically attempts to capture the user's location
   - Location is displayed prominently with a visual indicator
   - Users can recapture or edit location on a map

3. **Map-Based Location Editing**
   - When editing or backlogging logs, users see a full map interface
   - Users can:
     - Tap on the map to select a location
     - Drag the marker to adjust the location
     - Search for locations (via map interaction)
     - Clear the location if needed
   - Displays latitude/longitude coordinates clearly

4. **iOS-Specific Implementation**
   - Uses native iOS location services via `geolocator`
   - Google Maps integration via `google_maps_flutter`
   - Proper iOS permission descriptions in Info.plist

## Setup Instructions

### 1. Get a Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/google/maps-apis)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for iOS
   - Maps SDK for Android (if needed later)
4. Create credentials → API Key
5. Restrict the API key to iOS apps for security:
   - Application restrictions: iOS apps
   - Add your app's bundle identifier: `com.example.ashTrail` (or your actual bundle ID)

### 2. Configure iOS

Edit [ios/Runner/AppDelegate.swift](ios/Runner/AppDelegate.swift) and replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key:

```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

### 3. Run the App

```bash
flutter pub get
flutter run
```

## File Changes

### New Files
- `lib/widgets/location_map_picker.dart` - Map-based location picker widget

### Modified Files
- `lib/main.dart` - Added location permission check on app launch
- `lib/screens/logging_screen.dart` - Auto-collects location and provides map editing
- `lib/widgets/edit_log_record_dialog.dart` - Uses map interface for location editing
- `ios/Runner/AppDelegate.swift` - Google Maps configuration
- `pubspec.yaml` - Added `google_maps_flutter` dependency

### Existing Files (No Changes Required)
- `lib/services/location_service.dart` - Already had location permission handling
- `lib/models/log_record.dart` - Already had latitude/longitude fields
- `ios/Runner/Info.plist` - Already had location permission descriptions

## User Experience Flow

### Creating a New Log
1. User opens the app → Location permission is checked
2. User navigates to Logging screen → Location is automatically captured
3. If location is available:
   - Green indicator shows "Location Captured"
   - Coordinates are displayed
   - User can "Edit on Map" or "Recapture"
4. If location is not available:
   - Warning indicator shows "Location not available"
   - User can tap "Enable Location" to request permissions

### Editing an Existing Log
1. User taps on a log to edit
2. If location exists:
   - Shows location indicator with coordinates
   - "Edit on Map" button opens full map interface
   - "Clear" button removes location
3. If no location:
   - "Select Location on Map" button opens map interface
4. In map interface:
   - User can tap anywhere to place marker
   - Drag marker to adjust position
   - "Save" button confirms selection
   - "Clear" button (bottom right) removes location

## Testing Checklist

- [ ] Location permission prompt appears on first app launch
- [ ] Location is automatically captured when opening logging screen
- [ ] Map interface opens when tapping "Edit on Map"
- [ ] Can tap on map to select new location
- [ ] Can drag marker to adjust location
- [ ] Location displays correctly after selection
- [ ] Can clear location and set a new one
- [ ] Logs save with correct latitude/longitude
- [ ] Edited logs maintain other data while updating location

## Technical Notes

### iOS Permissions
The app uses "When In Use" location permission, which is appropriate for this use case since location is only needed when actively logging activities.

### Location Accuracy
The app requests `LocationAccuracy.best` for the most accurate positioning possible. This uses GPS, Wi-Fi, and cellular data.

### Offline Support
- Location collection requires active location services
- Previously captured locations are stored in the log record
- Map display requires internet connection for map tiles

### Privacy
- Location is only collected when the user is actively creating/editing a log
- Location data is stored locally with the log record
- Users can always clear or modify location data

## Troubleshooting

### "Location not available" message
- Check that location services are enabled on the device
- Ensure the app has location permission in Settings
- Try the "Enable Location" button to re-request permission

### Map not displaying
- Verify Google Maps API key is correctly configured
- Check that Maps SDK for iOS is enabled in Google Cloud Console
- Ensure device has internet connection for map tiles

### Location permission not requesting
- Check Info.plist has proper NSLocationWhenInUseUsageDescription
- Restart the app after making permission changes

## Future Enhancements

Potential improvements for future iterations:
- Search bar in map interface for address lookup
- Reverse geocoding to show location names
- Save recent/favorite locations
- Offline map caching
- Location-based log filtering/search
