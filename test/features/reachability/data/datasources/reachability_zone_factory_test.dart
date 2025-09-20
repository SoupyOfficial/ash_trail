// Unit tests for ReachabilityZoneFactory
// Tests zone generation logic and ergonomic calculations

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:ash_trail/features/reachability/data/datasources/reachability_zone_factory.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';

void main() {
  group('ReachabilityZoneFactory', () {
    late ReachabilityZoneFactory factory;

    setUp(() {
      factory = const ReachabilityZoneFactory();
    });

    group('createZonesForScreen', () {
      test('should create zones for portrait phone screen', () async {
        // arrange - typical phone portrait
        const screenSize = Size(400, 800);

        // act
        final zones = factory.createZonesForScreen(screenSize);

        // assert
        expect(zones, isNotEmpty);
        expect(zones.any((z) => z.level == ReachabilityLevel.easy), isTrue);

        // Easy zone should be in lower portion of screen
        final easyZone =
            zones.firstWhere((z) => z.level == ReachabilityLevel.easy);
        expect(easyZone.bounds.top,
            greaterThan(screenSize.height * 0.3)); // Below 30%
      });

      test('should create zones for landscape tablet screen', () async {
        // arrange - tablet landscape
        const screenSize = Size(1200, 800);

        // act
        final zones = factory.createZonesForScreen(screenSize);

        // assert
        expect(zones, isNotEmpty);
        expect(zones.any((z) => z.level == ReachabilityLevel.easy), isTrue);

        // Should have zones that account for landscape ergonomics
        final easyZones =
            zones.where((z) => z.level == ReachabilityLevel.easy).toList();
        expect(easyZones, isNotEmpty);
      });

      test('should create zones for square screen', () async {
        // arrange - square aspect ratio
        const screenSize = Size(600, 600);

        // act
        final zones = factory.createZonesForScreen(screenSize);

        // assert
        expect(zones, isNotEmpty);
        expect(zones.any((z) => z.level == ReachabilityLevel.easy), isTrue);
      });

      test('should handle very small screen sizes', () async {
        // arrange - very small screen
        const screenSize = Size(200, 300);

        // act
        final zones = factory.createZonesForScreen(screenSize);

        // assert
        expect(zones, isNotEmpty);
        // Even small screens should have at least one easy zone
        expect(zones.any((z) => z.level == ReachabilityLevel.easy), isTrue);
      });

      test('should handle very large screen sizes', () async {
        // arrange - very large screen
        const screenSize = Size(2000, 3000);

        // act
        final zones = factory.createZonesForScreen(screenSize);

        // assert
        expect(zones, isNotEmpty);
        expect(zones.any((z) => z.level == ReachabilityLevel.easy), isTrue);
        expect(
            zones.any((z) => z.level == ReachabilityLevel.difficult), isTrue);
      });

      test('should create non-overlapping zones', () async {
        // arrange
        const screenSize = Size(400, 800);

        // act
        final zones = factory.createZonesForScreen(screenSize);

        // assert
        for (int i = 0; i < zones.length; i++) {
          for (int j = i + 1; j < zones.length; j++) {
            final zone1 = zones[i];
            final zone2 = zones[j];

            // Zones should not overlap significantly
            expect(zone1.bounds.overlaps(zone2.bounds), isFalse,
                reason: 'Zone ${zone1.id} overlaps with ${zone2.id}');
          }
        }
      });

      test('should cover entire screen area', () async {
        // arrange
        const screenSize = Size(400, 800);

        // act
        final zones = factory.createZonesForScreen(screenSize);

        // assert
        // Test that key points of the screen are covered by at least one zone
        final testPoints = [
          const Offset(200, 100), // top center
          const Offset(200, 400), // middle center
          const Offset(200, 700), // bottom center
          const Offset(100, 400), // left center
          const Offset(300, 400), // right center
        ];

        for (final point in testPoints) {
          final coveredByZone = zones.any((zone) => zone.containsPoint(point));
          expect(coveredByZone, isTrue,
              reason: 'Point $point is not covered by any zone');
        }
      });

      test('should assign appropriate reachability levels', () async {
        // arrange
        const screenSize = Size(400, 800);

        // act
        final zones = factory.createZonesForScreen(screenSize);

        // assert
        // Should have a distribution of difficulty levels
        final easyZones =
            zones.where((z) => z.level == ReachabilityLevel.easy).toList();
        final difficultZones =
            zones.where((z) => z.level == ReachabilityLevel.difficult).toList();

        expect(easyZones, isNotEmpty, reason: 'Should have easy reach zones');

        // Easy zones should be in bottom portion (thumb-friendly area)
        for (final zone in easyZones) {
          expect(zone.bounds.center.dy, greaterThan(screenSize.height * 0.4),
              reason: 'Easy zone should be in lower portion of screen');
        }

        // Difficult zones should be in upper portion
        for (final zone in difficultZones) {
          expect(zone.bounds.center.dy, lessThan(screenSize.height * 0.6),
              reason: 'Difficult zone should be in upper portion of screen');
        }
      });

      test('should generate zones with valid properties', () async {
        // arrange
        const screenSize = Size(400, 800);

        // act
        final zones = factory.createZonesForScreen(screenSize);

        // assert
        for (final zone in zones) {
          // All zones should have valid properties
          expect(zone.id, isNotEmpty, reason: 'Zone should have valid ID');
          expect(zone.name, isNotEmpty, reason: 'Zone should have valid name');
          expect(zone.description, isNotEmpty,
              reason: 'Zone should have description');

          // Bounds should be within screen area
          expect(zone.bounds.left, greaterThanOrEqualTo(0));
          expect(zone.bounds.top, greaterThanOrEqualTo(0));
          expect(zone.bounds.right, lessThanOrEqualTo(screenSize.width));
          expect(zone.bounds.bottom, lessThanOrEqualTo(screenSize.height));

          // Bounds should have positive dimensions
          expect(zone.bounds.width, greaterThan(0));
          expect(zone.bounds.height, greaterThan(0));
        }
      });

      test('should generate consistent zones for same screen size', () async {
        // arrange
        const screenSize = Size(400, 800);

        // act
        final zones1 = factory.createZonesForScreen(screenSize);
        final zones2 = factory.createZonesForScreen(screenSize);

        // assert
        expect(zones1.length, equals(zones2.length));

        for (int i = 0; i < zones1.length; i++) {
          expect(zones1[i].id, equals(zones2[i].id));
          expect(zones1[i].bounds, equals(zones2[i].bounds));
          expect(zones1[i].level, equals(zones2[i].level));
        }
      });
    });
  });
}
