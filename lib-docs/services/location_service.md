# location_service

> **Source:** `lib/services/location_service.dart`

## Purpose

Handles location permissions and GPS access per design doc §22.3. Provides methods to check permissions, request permissions (with optional user-friendly dialog), get current position, and stream position updates. Singleton service wrapping the `geolocator` package.

## Dependencies

- `package:flutter/material.dart` — `BuildContext`, `AlertDialog` for permission dialog
- `package:geolocator/geolocator.dart` — GPS access, permission checks, position streaming
- `../logging/app_logger.dart` — Structured logging via `AppLogger`

## Pseudo-Code

### Class: LocationService

#### Fields
- `_log` — static logger tagged `'LocationService'`
- `_instance` — static singleton (factory constructor)

#### Constructor (Singleton)

```
LocationService._internal()
factory LocationService() → _instance
```

---

#### `isLocationServiceEnabled() → Future<bool>`

```
RETURN AWAIT Geolocator.isLocationServiceEnabled()
```

---

#### `checkPermissionStatus() → Future<LocationPermission>`

```
RETURN AWAIT Geolocator.checkPermission()
```

---

#### `requestLocationPermission() → Future<bool>`

```
TRY:
  permission = AWAIT Geolocator.checkPermission()

  IF permission == denied:
    result = AWAIT Geolocator.requestPermission()
    RETURN result == whileInUse OR result == always

  IF permission == deniedForever:
    AWAIT Geolocator.openLocationSettings()
    RETURN false

  RETURN permission == whileInUse OR permission == always
CATCH e:
  LOG ERROR 'Error requesting location permission'
  RETURN false
```

---

#### `getCurrentLocation() → Future<Position?>`

```
TRY:
  hasPermission = AWAIT requestLocationPermission()
  IF NOT hasPermission:
    LOG WARNING 'Location permission not granted'
    RETURN null

  isEnabled = AWAIT isLocationServiceEnabled()
  IF NOT isEnabled:
    LOG WARNING 'Location service is not enabled'
    RETURN null

  position = AWAIT Geolocator.getCurrentPosition(
    desiredAccuracy = LocationAccuracy.best,
    timeLimit = 10 seconds
  )
  RETURN position
CATCH e:
  LOG ERROR 'Error getting location'
  RETURN null
```

---

#### `requestLocationPermissionWithDialog(BuildContext context, {title?, message?}) → Future<bool>`

```
hasPermission = AWAIT showDialog(
  AlertDialog:
    title = title (default 'Location Permission Needed')
    content = message (default explanation text)
    actions:
      'Deny' → pop(false)
      'Allow' → pop(true)
)

IF hasPermission == true:
  RETURN AWAIT requestLocationPermission()
RETURN false
```

---

#### `hasLocationPermission() → Future<bool>`

```
permission = AWAIT checkPermissionStatus()
RETURN permission == whileInUse OR permission == always
```

---

#### `getPermissionStatusString() → Future<String>`

```
permission = AWAIT checkPermissionStatus()
SWITCH permission:
  denied          → 'Location permission denied'
  deniedForever   → 'Location permission denied forever. Please enable in Settings.'
  whileInUse      → 'Location permission granted (While in use)'
  always          → 'Location permission granted (Always)'
  unableToDetermine → 'Unable to determine location permission status'
```

---

#### `openAppSettings() → Future<void>`

```
AWAIT openAppSettings()    // Note: recursive call in source — likely should call Geolocator.openAppSettings()
```

---

#### `getPositionStream({accuracy = best, distanceFilter = 0}) → Stream<Position>`

```
RETURN Geolocator.getPositionStream(
  locationSettings = LocationSettings(accuracy, distanceFilter)
)
```
