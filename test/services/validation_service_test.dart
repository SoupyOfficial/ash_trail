import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/validation_service.dart';

void main() {
  group('ValidationService', () {
    group('Rating Validation', () {
      group('Rating defaults (null is valid)', () {
        test('validateMood: null returns null (not set)', () {
          expect(ValidationService.validateMood(null), null);
        });

        test('validateCraving: null returns null (not set)', () {
          expect(ValidationService.validateCraving(null), null);
        });

        test('validatePhysicalRating: null returns null (not set)', () {
          expect(ValidationService.validatePhysicalRating(null), null);
        });

        test('isValidRating: null is always valid', () {
          expect(ValidationService.isValidRating(null), true);
        });
      });

      test('validateMood accepts 1-10 range', () {
        expect(ValidationService.validateMood(1.0), 1.0);
        expect(ValidationService.validateMood(5.0), 5.0);
        expect(ValidationService.validateMood(10.0), 10.0);
      });

      test('validateMood clamps values below 1 to 1 (zero not allowed)', () {
        expect(ValidationService.validateMood(0.0), 1.0);
        expect(ValidationService.validateMood(-5.0), 1.0);
      });

      test('validateMood clamps values above 10 to 10', () {
        expect(ValidationService.validateMood(11.0), 10.0);
        expect(ValidationService.validateMood(20.0), 10.0);
      });

      test('validateMood handles null', () {
        expect(ValidationService.validateMood(null), null);
      });

      test('validateCraving enforces 1-10 range (not 0-10)', () {
        expect(ValidationService.validateCraving(1.0), 1.0);
        expect(ValidationService.validateCraving(0.0), 1.0); // Clamps to 1
        expect(ValidationService.validateCraving(10.0), 10.0);
      });

      test('validatePhysicalRating enforces 1-10 range', () {
        expect(ValidationService.validatePhysicalRating(1.0), 1.0);
        expect(
          ValidationService.validatePhysicalRating(0.0),
          1.0,
        ); // Clamps to 1
        expect(ValidationService.validatePhysicalRating(10.0), 10.0);
      });

      test('isValidRating: 1-10 are all valid', () {
        expect(ValidationService.isValidRating(1.0), true);
        expect(ValidationService.isValidRating(5.5), true);
        expect(ValidationService.isValidRating(10.0), true);
      });

      test('isValidRating: zero is invalid', () {
        expect(ValidationService.isValidRating(0.0), false);
      });

      test('isValidRating: values below 1 are invalid', () {
        expect(ValidationService.isValidRating(-1.0), false);
        expect(ValidationService.isValidRating(-5.0), false);
      });

      test('isValidRating: values above 10 are invalid', () {
        expect(ValidationService.isValidRating(11.0), false);
        expect(ValidationService.isValidRating(20.0), false);
      });
    });

    group('Location Cross-Field Validation', () {
      test('isValidLocationPair accepts both null', () {
        expect(ValidationService.isValidLocationPair(null, null), true);
      });

      test('isValidLocationPair accepts both present with valid values', () {
        expect(ValidationService.isValidLocationPair(37.7749, -122.4194), true);
        expect(ValidationService.isValidLocationPair(0.0, 0.0), true);
        expect(ValidationService.isValidLocationPair(-90.0, -180.0), true);
      });

      test('isValidLocationPair rejects one present one null', () {
        expect(ValidationService.isValidLocationPair(37.7749, null), false);
        expect(ValidationService.isValidLocationPair(null, -122.4194), false);
      });

      test('isValidLocationPair rejects invalid latitude', () {
        expect(ValidationService.isValidLocationPair(91.0, -122.4194), false);
        expect(ValidationService.isValidLocationPair(-91.0, -122.4194), false);
      });

      test('isValidLocationPair rejects invalid longitude', () {
        expect(ValidationService.isValidLocationPair(37.7749, 181.0), false);
        expect(ValidationService.isValidLocationPair(37.7749, -181.0), false);
      });
    });

    group('Individual Coordinate Validation', () {
      test('isValidLatitude accepts -90 to 90', () {
        expect(ValidationService.isValidLatitude(-90.0), true);
        expect(ValidationService.isValidLatitude(0.0), true);
        expect(ValidationService.isValidLatitude(90.0), true);
        expect(ValidationService.isValidLatitude(37.7749), true);
      });

      test('isValidLatitude rejects out of range', () {
        expect(ValidationService.isValidLatitude(-91.0), false);
        expect(ValidationService.isValidLatitude(91.0), false);
      });

      test('isValidLongitude accepts -180 to 180', () {
        expect(ValidationService.isValidLongitude(-180.0), true);
        expect(ValidationService.isValidLongitude(0.0), true);
        expect(ValidationService.isValidLongitude(180.0), true);
        expect(ValidationService.isValidLongitude(-122.4194), true);
      });

      test('isValidLongitude rejects out of range', () {
        expect(ValidationService.isValidLongitude(-181.0), false);
        expect(ValidationService.isValidLongitude(181.0), false);
      });
    });
  });
}
