// TODO: Re-enable when geolocator 12.0.0 API is fully integrated
// import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Service for handling location permissions and access
/// Follows design doc 22.3: Handle permission requests gracefully
/// TODO: Re-enable location features when geolocator 12.0.0 API is properly integrated
class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current location permission status
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  /// Returns true if permission was granted
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Permissions are denied, ask the user to grant permissions.
        final result = await Geolocator.requestPermission();
        return result == LocationPermission.whileInUse ||
            result == LocationPermission.always;
      } else if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, open app settings
        await Geolocator.openLocationSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current location
  /// Requires location permission to be granted first
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permission first
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        debugPrint('Location permission not granted');
        return null;
      }

      // Check if location service is enabled
      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        debugPrint('Location service is not enabled');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Request location permission with explanation dialog
  /// Shows a user-friendly dialog explaining why location is needed
  Future<bool> requestLocationPermissionWithDialog(
    BuildContext context, {
    String title = 'Location Permission Needed',
    String message =
        'Ash Trail needs access to your location to log hiking trails and activities. '
            'Your location is only used when you explicitly request it.',
  }) async {
    final hasPermission = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Deny'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Allow'),
              ),
            ],
          ),
    );

    if (hasPermission == true) {
      return await requestLocationPermission();
    }

    return false;
  }

  /// Check if location permission is sufficient
  /// Returns true if user has at least "whileInUse" permission
  Future<bool> hasLocationPermission() async {
    final permission = await checkPermissionStatus();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Get location permission status as a user-friendly string
  Future<String> getPermissionStatusString() async {
    final permission = await checkPermissionStatus();

    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission denied';
      case LocationPermission.deniedForever:
        return 'Location permission denied forever. Please enable in Settings.';
      case LocationPermission.whileInUse:
        return 'Location permission granted (While in use)';
      case LocationPermission.always:
        return 'Location permission granted (Always)';
      case LocationPermission.unableToDetermine:
        return 'Unable to determine location permission status';
    }
  }

  /// Open app settings to enable location permission
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Watch location changes
  /// Returns a stream of Position updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 0,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
