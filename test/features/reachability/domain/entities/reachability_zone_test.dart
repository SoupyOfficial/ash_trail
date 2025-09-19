// Unit tests for ReachabilityZone entity
// Tests business logic and zone calculations

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';

void main() {
  group('ReachabilityZone', () {
    late ReachabilityZone testZone;

    setUp(() {
      testZone = const ReachabilityZone(
        id: 'test_zone',
        name: 'Test Zone',
        bounds: Rect.fromLTWH(0, 100, 400, 300),
        level: ReachabilityLevel.easy,
        description: 'Test zone description',
      );
    });

    group('containsPoint', () {
      test('should return true for point within bounds', () {
        // arrange
        const point = Offset(200, 250);

        // act
        final result = testZone.containsPoint(point);

        // assert
        expect(result, isTrue);
      });

      test('should return false for point outside bounds', () {
        // arrange
        const point = Offset(500, 250);

        // act
        final result = testZone.containsPoint(point);

        // assert
        expect(result, isFalse);
      });

      test('should return true for point on boundary', () {
        // arrange
        const point = Offset(0, 100); // top-left corner

        // act
        final result = testZone.containsPoint(point);

        // assert
        expect(result, isTrue);
      });
    });

    group('overlapsRect', () {
      test('should return true for overlapping rectangles', () {
        // arrange
        const rect = Rect.fromLTWH(50, 150, 100, 100);

        // act
        final result = testZone.overlapsRect(rect);

        // assert
        expect(result, isTrue);
      });

      test('should return false for non-overlapping rectangles', () {
        // arrange
        const rect = Rect.fromLTWH(500, 150, 100, 100);

        // act
        final result = testZone.overlapsRect(rect);

        // assert
        expect(result, isFalse);
      });

      test('should return true for rect completely inside zone', () {
        // arrange
        const rect = Rect.fromLTWH(100, 200, 50, 50);

        // act
        final result = testZone.overlapsRect(rect);

        // assert
        expect(result, isTrue);
      });

      test('should return true for rect completely containing zone', () {
        // arrange
        const rect = Rect.fromLTWH(-50, 50, 500, 400);

        // act
        final result = testZone.overlapsRect(rect);

        // assert
        expect(result, isTrue);
      });
    });

    group('coveragePercentage', () {
      test('should return 1.0 for rect completely within zone', () {
        // arrange
        const rect = Rect.fromLTWH(100, 200, 100, 100);

        // act
        final result = testZone.coveragePercentage(rect);

        // assert
        expect(result, equals(1.0));
      });

      test('should return 0.0 for non-overlapping rect', () {
        // arrange
        const rect = Rect.fromLTWH(500, 500, 100, 100);

        // act
        final result = testZone.coveragePercentage(rect);

        // assert
        expect(result, equals(0.0));
      });

      test('should return correct percentage for partial overlap', () {
        // arrange
        // Rectangle that overlaps 50% with zone
        const rect = Rect.fromLTWH(300, 200, 200, 100); // Half outside zone

        // act
        final result = testZone.coveragePercentage(rect);

        // assert
        expect(result, equals(0.5));
      });

      test('should return 0.0 for zero-area rectangle', () {
        // arrange
        const rect = Rect.fromLTWH(100, 200, 0, 0);

        // act
        final result = testZone.coveragePercentage(rect);

        // assert
        expect(result, equals(0.0));
      });

      test('should handle edge case where zone is partially outside rect', () {
        // arrange
        const smallRect = Rect.fromLTWH(350, 350, 100, 100);

        // act
        final result = testZone.coveragePercentage(smallRect);

        // assert
        expect(
            result,
            equals(
                0.25)); // 50x50 intersection out of 100x100 rect = 2500/10000 = 0.25
      });
    });

    test('should create zone with correct properties', () {
      // assert
      expect(testZone.id, equals('test_zone'));
      expect(testZone.name, equals('Test Zone'));
      expect(testZone.bounds, equals(const Rect.fromLTWH(0, 100, 400, 300)));
      expect(testZone.level, equals(ReachabilityLevel.easy));
      expect(testZone.description, equals('Test zone description'));
    });
  });

  group('ReachabilityLevel', () {
    test('should have correct display names', () {
      expect(ReachabilityLevel.easy.displayName, equals('Easy to Reach'));
      expect(ReachabilityLevel.moderate.displayName, equals('Moderate'));
      expect(ReachabilityLevel.difficult.displayName, equals('Difficult'));
      expect(ReachabilityLevel.unreachable.displayName, equals('Unreachable'));
    });

    test('should have correct descriptions', () {
      expect(ReachabilityLevel.easy.description,
          equals('Comfortable thumb zone for primary actions'));
      expect(ReachabilityLevel.moderate.description,
          equals('Reachable with slight thumb stretch'));
      expect(ReachabilityLevel.difficult.description,
          equals('Requires thumb extension or two-handed use'));
      expect(ReachabilityLevel.unreachable.description,
          equals('Outside natural thumb reach'));
    });

    test('should have distinct color values', () {
      final colors =
          ReachabilityLevel.values.map((level) => level.colorValue).toSet();
      expect(colors.length, equals(ReachabilityLevel.values.length));
    });

    test('should have reasonable color values', () {
      // Test that color values are valid ARGB colors
      for (final level in ReachabilityLevel.values) {
        expect(level.colorValue, greaterThan(0x00000000));
        expect(level.colorValue, lessThanOrEqualTo(0xFFFFFFFF));
      }
    });
  });
}
