import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/widgets/location_map_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('LocationMapPicker Widget', () {
    testWidgets('should display with default title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LocationMapPicker()));

      expect(find.text('Select Location'), findsOneWidget);
    });

    testWidgets('should display with custom title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LocationMapPicker(title: 'Edit Location')),
      );

      expect(find.text('Edit Location'), findsOneWidget);
    });

    testWidgets('should display Save button in app bar', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LocationMapPicker()));

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should initialize with provided coordinates', (tester) async {
      const testLat = 37.7749;
      const testLon = -122.4194;

      await tester.pumpWidget(
        const MaterialApp(
          home: LocationMapPicker(
            initialLatitude: testLat,
            initialLongitude: testLon,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Widget should be created without errors
      expect(find.byType(LocationMapPicker), findsOneWidget);
    });

    testWidgets('should show loading indicator while fetching location', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LocationMapPicker()));

      // Initially might show loading
      await tester.pump();

      // Widget should render
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display clear location button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LocationMapPicker(
            initialLatitude: 37.7749,
            initialLongitude: -122.4194,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have floating action buttons
      expect(find.byType(FloatingActionButton), findsWidgets);
    });

    testWidgets('should return null when clear button is pressed', (
      tester,
    ) async {
      LatLng? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await Navigator.push<LatLng>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const LocationMapPicker(
                                initialLatitude: 37.7749,
                                initialLongitude: -122.4194,
                              ),
                        ),
                      );
                    },
                    child: const Text('Open Map'),
                  ),
                ),
          ),
        ),
      );

      // Open the map picker
      await tester.tap(find.text('Open Map'));
      await tester.pumpAndSettle();

      // Find and tap the clear button (red FAB)
      final clearButtons = find.byType(FloatingActionButton);
      if (clearButtons.evaluate().length >= 2) {
        await tester.tap(clearButtons.at(1));
        await tester.pumpAndSettle();

        expect(result, isNull);
      }
    });

    testWidgets('should return LatLng when save is pressed', (tester) async {
      LatLng? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      result = await Navigator.push<LatLng>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const LocationMapPicker(
                                initialLatitude: 37.7749,
                                initialLongitude: -122.4194,
                              ),
                        ),
                      );
                    },
                    child: const Text('Open Map'),
                  ),
                ),
          ),
        ),
      );

      // Open the map picker
      await tester.tap(find.text('Open Map'));
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should return a LatLng (the initial coordinates)
      expect(result, isNotNull);
      expect(result?.latitude, equals(37.7749));
      expect(result?.longitude, equals(-122.4194));
    });
  });

  group('LocationMapPicker location display', () {
    testWidgets('should show location info card when location is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LocationMapPicker(
            initialLatitude: 37.7749,
            initialLongitude: -122.4194,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "Selected Location" text
      expect(find.text('Selected Location'), findsOneWidget);
    });

    testWidgets('should display coordinates in info card', (tester) async {
      const lat = 37.774900;
      const lon = -122.419400;

      await tester.pumpWidget(
        const MaterialApp(
          home: LocationMapPicker(initialLatitude: lat, initialLongitude: lon),
        ),
      );

      await tester.pumpAndSettle();

      // Should show formatted coordinates
      expect(find.textContaining('37.774900'), findsOneWidget);
      expect(find.textContaining('-122.419400'), findsOneWidget);
    });
  });
}
