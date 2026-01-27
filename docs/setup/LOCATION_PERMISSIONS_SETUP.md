# Location Permissions Configuration

## Overview
Ash Trail now has full location permission support for both iOS and Android platforms. This enables the app to access the device's location for logging hiking trails and outdoor activities.

## Changes Made

### 1. **Dependencies Added** (`pubspec.yaml`)
- **geolocator** (^12.0.0): Handles location access and permission requests
- **permission_handler** (^11.4.4): Provides cross-platform permission handling

### 2. **iOS Configuration** (`ios/Runner/Info.plist`)
Added four location permission descriptions required by Apple:
- `NSLocationWhenInUseUsageDescription`: For accessing location while app is in use
- `NSLocationAlwaysAndWhenInUseUsageDescription`: For continuous location access
- `NSLocationAlwaysUsageDescription`: Legacy always-use permission
- `NSLocationAlwaysAndWhenInUseUsageDescription`: For newer iOS versions

These descriptions explain to users why the app needs location access.

### 3. **Android Configuration** (`android/app/src/main/AndroidManifest.xml`)
Added Android permissions:
- `android.permission.ACCESS_FINE_LOCATION`: High precision GPS location
- `android.permission.ACCESS_COARSE_LOCATION`: Network-based location

### 4. **Location Service** (`lib/services/location_service.dart`)
Created a comprehensive location service with:
- **Permission Management**
  - `requestLocationPermission()`: Request permission from user
  - `checkPermissionStatus()`: Check current permission status
  - `hasLocationPermission()`: Verify if app has sufficient permission

- **Location Access**
  - `getCurrentLocation()`: Get current device location with error handling
  - `getPositionStream()`: Stream location updates

- **User Interaction**
  - `requestLocationPermissionWithDialog()`: Show explanatory dialog before requesting permission
  - `getPermissionStatusString()`: Get human-readable permission status
  - `openAppSettings()`: Direct users to app settings if needed

- **Service Checks**
  - `isLocationServiceEnabled()`: Check if device location services are enabled

## Usage Example

```dart
import 'package:ash_trail/services/location_service.dart';

// Get location with permission handling
final locationService = LocationService();
final position = await locationService.getCurrentLocation();

if (position != null) {
  print('Location: ${position.latitude}, ${position.longitude}');
} else {
  print('Failed to get location');
}

// Request permission with user-friendly dialog
final hasPermission = await locationService.requestLocationPermissionWithDialog(
  context,
  title: 'Location Access Needed',
  message: 'We need your location to track hiking trails.',
);

// Check permission status
final status = await locationService.getPermissionStatusString();
print(status);

// Watch location changes
locationService.getPositionStream().listen((position) {
  print('Updated location: ${position.latitude}, ${position.longitude}');
});
```

## Permission Flow

### iOS
1. User triggers location-dependent feature
2. App calls `LocationService.requestLocationPermission()`
3. iOS shows native permission dialog using description from Info.plist
4. User grants or denies permission
5. App accesses location if granted

### Android
1. User triggers location-dependent feature
2. App calls `LocationService.requestLocationPermission()`
3. Android shows native permission dialog
4. User grants or denies permission
5. If denied, user can enable in app settings

## Testing

To test location permissions:

1. **iOS Simulator**
   - Navigate to Features → Location in simulator menu
   - Select "Apple Park" or "City Bicycle Ride"
   - The app should receive location updates

2. **iOS Device**
   - Go to Settings → Privacy → Location Services
   - Enable/disable location for Ash Trail
   - Test permission request flow

3. **Android Emulator**
   - Open the Extended Controls
   - Go to Location section
   - Select or define a location

4. **Android Device**
   - Go to Settings → Apps → Permissions → Location
   - Grant or revoke location permission
   - Test permission request flow

## Best Practices Implemented

✅ Graceful error handling per design doc 22.3
✅ Only request permissions when needed
✅ Explain permission purpose to users
✅ Support both "While in Use" and "Always" permission levels
✅ Cross-platform compatible (iOS, Android, web)
✅ Timeout handling for location requests
✅ Service availability checks

## Design Doc References

- **Design Doc 22.3**: Permission request handling
  - Graceful degradation if permission denied
  - Clear user-facing explanations
  - Fallback behavior for permission failures

## Next Steps

1. Run `flutter pub get` to install new packages
2. For iOS: Run `pod install` in ios/ directory
3. Update screens that use location to call `LocationService`
4. Test on both iOS and Android devices
5. Consider caching location data per user preferences

## Troubleshooting

### "Location permission denied"
- Check Info.plist descriptions are present
- On iOS: Go to Settings → Privacy → Location → Ash Trail → While Using the App
- On Android: Go to Settings → Apps → Ash Trail → Permissions → Location

### "Location service is not enabled"
- User must enable location services on device
- iOS: Settings → Privacy → Location Services
- Android: Settings → Location → Turn on

### "Unable to determine permission status"
- Device may not support location services
- Try restarting the app
- Check device location settings

## References

- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Permission Handler Package](https://pub.dev/packages/permission_handler)
- [Apple Location Services](https://developer.apple.com/documentation/corelocation)
- [Android Location Services](https://developer.android.com/training/location)
