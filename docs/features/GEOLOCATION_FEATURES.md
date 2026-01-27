# Geolocation Features in Ash Trail

## Overview

Ash Trail now includes comprehensive geolocation support, allowing users to optionally tag their log entries with location data. This helps users track where events occur and provides valuable context for their logging history.

## Architecture

### Core Components

1. **LocationService** (`lib/services/location_service.dart`)
   - Handles all location permission requests
   - Fetches current device location using `geolocator` package
   - Provides user-friendly permission dialogs
   - Implements graceful error handling

2. **LogRecord Model** (`lib/models/log_record.dart`)
   - Contains `latitude` and `longitude` optional fields
   - Includes `hasLocation` getter for easy checking
   - Validates that both coordinates are present or both are null

3. **Data Persistence**
   - Location data is stored in local database
   - Synced to Firestore with other log data
   - Included in CSV export/import operations

## User-Facing Features

### 1. Location Capture in Detailed Log Screen

**File:** `lib/screens/logging_screen.dart`

**Features:**
- Optional "Capture Current Location" button in the logging form
- Visual feedback during location fetching
- Display of captured coordinates with clear button
- Permission request dialog with explanation
- Automatic retry after permission grant

**User Flow:**
1. User fills out log details
2. User taps "Capture Current Location" button
3. If permission needed, dialog explains why and offers to grant
4. Location is fetched and displayed (Lat/Lon)
5. User can clear location if desired
6. Location is saved with log entry

### 2. Location Capture in Backdate Dialog

**File:** `lib/widgets/backdate_dialog.dart`

**Features:**
- Same location capture functionality as detailed log
- Suitable for backdating entries with location context
- Compact UI that fits within dialog layout

### 3. Location Display in Log Lists

**File:** `lib/widgets/log_record_list.dart`

**Features:**
- Location icon badge on log tiles when location is present
- Full coordinate display in detail dialog
- "View on Map" button (ready for url_launcher integration)
- Shows mood, physical ratings, and reasons alongside location

### 4. Location Editing

**File:** `lib/widgets/edit_log_record_dialog.dart`

**Features:**
- Manual latitude/longitude editing
- Validation that both coordinates are present or both are null
- Clear visual feedback for input validation

## Data Model

### LogRecord Fields

```dart
class LogRecord {
  // ... other fields ...
  
  /// Latitude coordinate (WGS84 decimal degrees, -90 to 90)
  double? latitude;
  
  /// Longitude coordinate (WGS84 decimal degrees, -180 to 180)
  double? longitude;
  
  /// Check if location is set (both coordinates must be present)
  bool get hasLocation => latitude != null && longitude != null;
}
```

### LogDraft Fields (Form State)

```dart
class LogDraft {
  // ... other fields ...
  
  final double? latitude;
  final double? longitude;
}
```

## Service Layer

### LocationService API

```dart
class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled()
  
  /// Check current permission status
  Future<LocationPermission> checkPermissionStatus()
  
  /// Request location permission
  Future<bool> requestLocationPermission()
  
  /// Get current location (handles permissions automatically)
  Future<Position?> getCurrentLocation()
  
  /// Check if sufficient permission granted
  Future<bool> hasLocationPermission()
  
  /// Get human-readable permission status
  Future<String> getPermissionStatusString()
}
```

### LogRecordService Integration

All logging methods support optional location parameters:

```dart
Future<LogRecord> createLogRecord({
  // ... other params ...
  double? latitude,
  double? longitude,
})

Future<LogRecord> backdateLog({
  // ... other params ...
  double? latitude,
  double? longitude,
})

Future<LogRecord> updateLogRecord(
  LogRecord record, {
  // ... other params ...
  double? latitude,
  double? longitude,
})
```

## Privacy & Permissions

### iOS Configuration

**File:** `ios/Runner/Info.plist`

Required keys:
- `NSLocationWhenInUseUsageDescription`: "Ash Trail needs your location to tag log entries with where they occurred."
- `NSLocationAlwaysUsageDescription`: "Ash Trail can use your location to automatically tag log entries."

### Android Configuration

**File:** `android/app/src/main/AndroidManifest.xml`

Required permissions:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### User Control

- Location is **always optional** - users can skip it
- Permission request includes clear explanation
- Users can clear location from any log entry
- No background location tracking (only when user explicitly requests)

## Data Validation

### Cross-Field Validation

The app enforces that location coordinates must both be present or both be null:

```dart
ValidationService.isValidLocationPair(latitude, longitude)
```

This prevents invalid states like having latitude without longitude.

### Coordinate Ranges

- Latitude: -90 to 90 degrees
- Longitude: -180 to 180 degrees

These are validated by the `geolocator` package and displayed to users in input hints.

## Testing

### Unit Tests

Location validation is tested in the existing test suite:
- `ValidationService.isValidLocationPair()` tests
- LogRecord creation with location tests
- LogDraft state management tests

### Integration Testing

Manual testing checklist:
- [ ] Detailed log screen location capture
- [ ] Backdate dialog location capture
- [ ] Permission request flow (grant)
- [ ] Permission request flow (deny)
- [ ] Location display in list
- [ ] Location display in detail dialog
- [ ] Location editing
- [ ] Location clearing
- [ ] CSV export with location
- [ ] CSV import with location
- [ ] Firestore sync with location

## Future Enhancements

### Potential Improvements

1. **Map Integration**
   - Add `url_launcher` package
   - Actually open maps app from "View on Map" button
   - Show map thumbnail in log details

2. **Reverse Geocoding**
   - Display human-readable address
   - Use `geocoding` package
   - Cache address lookups

3. **Location-Based Insights**
   - "Most common logging locations"
   - Heatmap of log locations
   - Filter logs by location proximity

4. **Background Location** (Optional)
   - Automatic location capture for quick logs
   - Geofencing for location-based reminders
   - Requires more permissions and battery consideration

5. **Location History**
   - View all logs on a map
   - Timeline view with location markers
   - Export GPX/KML files

## Dependencies

- `geolocator: ^12.0.0` - Location services and permissions

## Summary

The geolocation features in Ash Trail provide optional, privacy-conscious location tagging for log entries. The implementation:

✅ Respects user privacy with clear permission requests  
✅ Makes location completely optional  
✅ Integrates seamlessly into existing logging workflows  
✅ Stores and syncs location data reliably  
✅ Provides visual feedback and validation  
✅ Follows platform best practices for permissions  

Location data enhances the logging experience without adding complexity or compromising the app's core functionality.
