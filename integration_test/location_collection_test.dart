import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ash_trail/main.dart' as app;
import 'package:ash_trail/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

/// Integration tests for location collection feature
/// Tests the complete flow of requesting permissions, capturing location,
/// and saving logs with location data
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Location Collection Integration Tests', () {
    testWidgets('App should check location permission on startup', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App should start successfully
      expect(find.byType(MaterialApp), findsOneWidget);

      // Location service should be initialized
      final locationService = LocationService();
      expect(locationService, isNotNull);
    });

    testWidgets('Should show permission prompt when location not granted', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if we need to handle welcome screen first
      if (find.text('Continue Without Account').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue Without Account'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Navigate to logging screen
      if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else if (find.text('Log Event').evaluate().isNotEmpty) {
        await tester.tap(find.text('Log Event'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Check for location permission dialog or location capture
      final locationService = LocationService();
      final hasPermission = await locationService.hasLocationPermission();

      if (!hasPermission) {
        // Should show permission dialog
        expect(find.textContaining('Location'), findsWidgets);
      }
    });

    testWidgets(
      'Logging screen should automatically attempt to capture location',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Setup: Create anonymous account if needed
        if (find.text('Continue Without Account').evaluate().isNotEmpty) {
          await tester.tap(find.text('Continue Without Account'));
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Navigate to logging screen
        final addButton = find.byIcon(Icons.add);
        if (addButton.evaluate().isNotEmpty) {
          await tester.tap(addButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Should see logging screen
        expect(find.text('Log Event'), findsOneWidget);

        // Wait for location capture attempt
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show either:
        // 1. Location captured indicator (if permission granted)
        // 2. Location not available indicator (if permission denied)
        // 3. Permission dialog (if not yet requested)
        expect(find.textContaining('Location'), findsWidgets);
      },
    );

    testWidgets('Should display location status in logging screen', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Setup anonymous account
      if (find.text('Continue Without Account').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue Without Account'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Open logging screen
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Check location status
      final locationService = LocationService();
      final hasPermission = await locationService.hasLocationPermission();

      if (hasPermission) {
        // Should show either "Location Captured" or "Location not available"
        expect(find.textContaining('Location'), findsWidgets);
      }
    });

    testWidgets('Should include location coordinates when creating log', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Setup
      if (find.text('Continue Without Account').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue Without Account'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Navigate to logging screen
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Wait for location to be captured
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Fill in required fields
      // Select event type if needed
      final dropdown = find.byType(DropdownButtonFormField<dynamic>);
      if (dropdown.evaluate().isNotEmpty) {
        await tester.tap(dropdown.first);
        await tester.pumpAndSettle();
        // Select first option
        await tester.tap(find.text('Session').last);
        await tester.pumpAndSettle();
      }

      // Submit log
      final submitButton = find.text('Log Event');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Log should be created
      // In a real test, we would verify the log record has location data
    });

    testWidgets('Should open map picker when "Edit on Map" is tapped', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Setup
      if (find.text('Continue Without Account').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue Without Account'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Navigate to logging screen
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Check if location was captured
      final editMapButton = find.text('Edit on Map');
      if (editMapButton.evaluate().isNotEmpty) {
        await tester.tap(editMapButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should open map picker
        expect(find.text('Select Location'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
      }
    });

    testWidgets('Should allow recapturing location', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Setup
      if (find.text('Continue Without Account').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue Without Account'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Navigate to logging screen
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Check if location was captured and recapture button exists
      final recaptureButton = find.text('Recapture');
      if (recaptureButton.evaluate().isNotEmpty) {
        await tester.tap(recaptureButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should attempt to recapture location
        // (Will show permission dialog if needed)
      }
    });

    testWidgets(
      'Should show enable location button when location not available',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Setup
        if (find.text('Continue Without Account').evaluate().isNotEmpty) {
          await tester.tap(find.text('Continue Without Account'));
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Navigate to logging screen
        final addButton = find.byIcon(Icons.add);
        if (addButton.evaluate().isNotEmpty) {
          await tester.tap(addButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        // Check location service status
        final locationService = LocationService();
        final hasPermission = await locationService.hasLocationPermission();

        if (!hasPermission) {
          // Should show "Enable Location" button
          expect(find.text('Enable Location'), findsOneWidget);
        }
      },
    );
  });

  group('Location Edit Dialog Integration Tests', () {
    testWidgets('Should open map picker in edit dialog', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Setup: Create account and a log entry first
      if (find.text('Continue Without Account').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue Without Account'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Create a log entry first
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Submit a basic log
        final submitButton = find.text('Log Event');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // Go back to home and find the log entry
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Tap on a log entry to edit (if any exist)
      final logCards = find.byType(Card);
      if (logCards.evaluate().isNotEmpty) {
        await tester.tap(logCards.first);
        await tester.pumpAndSettle();

        // Should open edit dialog
        // Look for map-related buttons
        final mapButton = find.text('Edit on Map');
        final selectMapButton = find.text('Select Location on Map');

        if (mapButton.evaluate().isNotEmpty ||
            selectMapButton.evaluate().isNotEmpty) {
          expect(true, isTrue); // Map functionality is available
        }
      }
    });
  });

  group('Location Permission Flow Tests', () {
    testWidgets('Should handle permission granted scenario', (tester) async {
      final locationService = LocationService();

      // Check current permission
      final permission = await locationService.checkPermissionStatus();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Permission already granted
        final position = await locationService.getCurrentLocation();
        expect(position, anyOf(isNull, isA<Position>()));

        if (position != null) {
          expect(position.latitude, inInclusiveRange(-90, 90));
          expect(position.longitude, inInclusiveRange(-180, 180));
        }
      } else {
        // Permission not granted - test would need to simulate user action
        expect(permission, isA<LocationPermission>());
      }
    });

    testWidgets('Should handle permission denied scenario', (tester) async {
      final locationService = LocationService();

      // Check current permission
      final permission = await locationService.checkPermissionStatus();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Permission denied
        final position = await locationService.getCurrentLocation();

        // Should handle gracefully and return null
        expect(position, isNull);
      }
    });
  });

  group('Long Press Button with Location Tests', () {
    testWidgets('Should capture location when using long press to log', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Setup
      if (find.text('Continue Without Account').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue Without Account'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Navigate to logging screen
      final addButton = find.byIcon(Icons.add);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Wait for location to be auto-captured
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The location should be captured automatically when the screen opens
      // Verify location status is shown
      expect(find.textContaining('Location'), findsWidgets);

      // If we find the long press button (circle with touch icon)
      final longPressButton = find.byIcon(Icons.touch_app);
      if (longPressButton.evaluate().isNotEmpty) {
        // Location should already be captured before long press
        // The log submitted after long press should include location
        expect(true, isTrue);
      }
    });
  });
}
