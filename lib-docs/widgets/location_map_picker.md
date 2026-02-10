# location_map_picker

> **Source:** `lib/widgets/location_map_picker.dart`

## Purpose
Full-screen Google Maps-based location picker for iOS. Allows users to select a location by tapping, dragging a marker, or using their current GPS position. Returns a `LatLng` on save, or `null` if cleared. Used by the edit log dialog for location tagging.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:google_maps_flutter/google_maps_flutter.dart` — GoogleMap, LatLng, Marker
- `../logging/app_logger.dart` — AppLogger
- `../services/location_service.dart` — LocationService for GPS

## Pseudo-Code

### Class: LocationMapPicker (StatefulWidget)

**Constructor Parameters:**
- `initialLatitude: double?` — pre-selected latitude
- `initialLongitude: double?` — pre-selected longitude
- `title: String` — app bar title (default: "Select Location")

#### State: _LocationMapPickerState

**State Variables:**
- `_mapController: GoogleMapController?`
- `_selectedLocation: LatLng?` — user's chosen point
- `_currentLocation: LatLng?` — device GPS position
- `_isLoadingCurrentLocation: bool`
- `_locationService: LocationService`
- `_markers: Set<Marker>` — single draggable marker

#### Method: initState()
```
CALL _initializeLocation()
```

#### Method: _initializeLocation() → Future<void>
```
IF initialLatitude AND initialLongitude provided:
  SET _selectedLocation = LatLng(lat, lon)
  CALL _updateMarker(location)
ELSE:
  CALL _getCurrentLocation()
```

#### Method: _getCurrentLocation() → Future<void>
```
SET _isLoadingCurrentLocation = true
TRY:
  GET position from _locationService.getCurrentLocation()
  IF position != null:
    SET _currentLocation and _selectedLocation
    UPDATE marker
    ANIMATE camera to location at zoom 15.0
CATCH → LOG error, SHOW SnackBar
FINALLY → _isLoadingCurrentLocation = false
```

#### Method: _updateMarker(LatLng location)
```
CLEAR all markers
ADD Marker:
  markerId: 'selected_location'
  position: location
  draggable: true
  onDragEnd: UPDATE _selectedLocation to new position
```

#### Method: _onMapTap(LatLng location)
```
SET _selectedLocation = tapped location
CALL _updateMarker(location)
```

#### Method: _onSave()
```
IF _selectedLocation != null → POP returning _selectedLocation
ELSE → SHOW SnackBar "Please select a location on the map"
```

#### Method: build(context) → Widget
```
DEFAULT position: _selectedLocation ?? _currentLocation ?? San Francisco (37.7749, -122.4194)

RETURN Scaffold:
  ├─ AppBar:
  │   ├─ title: widget.title
  │   └─ actions: TextButton("Save") → _onSave
  │
  ├─ body: Stack:
  │   ├─ GoogleMap:
  │   │   initialCameraPosition: (target, zoom: 15)
  │   │   onMapCreated: store controller
  │   │   onTap: _onMapTap
  │   │   markers: _markers
  │   │   myLocationEnabled: true
  │   │   myLocationButtonEnabled: true
  │   │
  │   ├─ IF loading → dark overlay + CircularProgressIndicator
  │   │
  │   └─ IF _selectedLocation != null:
  │       └─ Positioned(bottom: 16) → Card:
  │           "Selected Location"
  │           "Latitude: X.XXXXXX"
  │           "Longitude: X.XXXXXX"
  │           "Tap on the map or drag the marker to adjust"
  │
  └─ floatingActionButton: Column:
      ├─ FAB(heroTag: current_location) → _getCurrentLocation
      │   (shows spinner while loading)
      └─ FAB(heroTag: clear_location, red) → POP returning null
```

#### Method: dispose()
```
DISPOSE _mapController
```
