import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/validation_service.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('ValidationService', () {
    // ===== VALUE CLAMPING TESTS =====
    group('clampValue', () {
      test('clamps seconds to 0-3600 range', () {
        expect(ValidationService.clampValue(0, Unit.seconds), 0);
        expect(ValidationService.clampValue(1800, Unit.seconds), 1800);
        expect(ValidationService.clampValue(3600, Unit.seconds), 3600);
        expect(ValidationService.clampValue(5000, Unit.seconds), 3600);
        expect(ValidationService.clampValue(-10, Unit.seconds), 0);
      });

      test('clamps minutes to 0-60 range', () {
        expect(ValidationService.clampValue(0, Unit.minutes), 0);
        expect(ValidationService.clampValue(30, Unit.minutes), 30);
        expect(ValidationService.clampValue(60, Unit.minutes), 60);
        expect(ValidationService.clampValue(120, Unit.minutes), 60);
        expect(ValidationService.clampValue(-5, Unit.minutes), 0);
      });

      test('clamps hits to 0-100 range', () {
        expect(ValidationService.clampValue(0, Unit.hits), 0);
        expect(ValidationService.clampValue(50, Unit.hits), 50);
        expect(ValidationService.clampValue(100, Unit.hits), 100);
        expect(ValidationService.clampValue(200, Unit.hits), 100);
      });

      test('clamps mg to 0-10000 range', () {
        expect(ValidationService.clampValue(0, Unit.mg), 0);
        expect(ValidationService.clampValue(5000, Unit.mg), 5000);
        expect(ValidationService.clampValue(10000, Unit.mg), 10000);
        expect(ValidationService.clampValue(20000, Unit.mg), 10000);
      });

      test('clamps grams to 0-1000 range', () {
        expect(ValidationService.clampValue(0, Unit.grams), 0);
        expect(ValidationService.clampValue(500, Unit.grams), 500);
        expect(ValidationService.clampValue(1000, Unit.grams), 1000);
        expect(ValidationService.clampValue(2000, Unit.grams), 1000);
      });

      test('clamps ml to 0-1000 range', () {
        expect(ValidationService.clampValue(0, Unit.ml), 0);
        expect(ValidationService.clampValue(500, Unit.ml), 500);
        expect(ValidationService.clampValue(1000, Unit.ml), 1000);
        expect(ValidationService.clampValue(2000, Unit.ml), 1000);
      });

      test('clamps count to 0-1000 range', () {
        expect(ValidationService.clampValue(0, Unit.count), 0);
        expect(ValidationService.clampValue(500, Unit.count), 500);
        expect(ValidationService.clampValue(1000, Unit.count), 1000);
        expect(ValidationService.clampValue(2000, Unit.count), 1000);
      });

      test('returns value unchanged for Unit.none', () {
        expect(ValidationService.clampValue(999999, Unit.none), 999999);
        expect(ValidationService.clampValue(-999999, Unit.none), -999999);
      });

      test('returns null when input is null', () {
        expect(ValidationService.clampValue(null, Unit.seconds), null);
        expect(ValidationService.clampValue(null, Unit.minutes), null);
      });
    });

    // ===== OUTLIER DETECTION TESTS =====
    group('isOutlier', () {
      test('returns false when value is within threshold', () {
        expect(
          ValidationService.isOutlier(
            value: 100,
            mean: 100,
            standardDeviation: 10,
          ),
          false,
        );
        expect(
          ValidationService.isOutlier(
            value: 120,
            mean: 100,
            standardDeviation: 10,
          ),
          false,
        ); // z-score = 2
      });

      test('returns true when value exceeds threshold', () {
        expect(
          ValidationService.isOutlier(
            value: 140,
            mean: 100,
            standardDeviation: 10,
          ),
          true,
        ); // z-score = 4
        expect(
          ValidationService.isOutlier(
            value: 60,
            mean: 100,
            standardDeviation: 10,
          ),
          true,
        ); // z-score = 4
      });

      test('returns false when standard deviation is 0', () {
        expect(
          ValidationService.isOutlier(
            value: 150,
            mean: 100,
            standardDeviation: 0,
          ),
          false,
        );
      });

      test('respects custom threshold', () {
        expect(
          ValidationService.isOutlier(
            value: 125,
            mean: 100,
            standardDeviation: 10,
            threshold: 2.0,
          ),
          true,
        ); // z-score = 2.5
        expect(
          ValidationService.isOutlier(
            value: 115,
            mean: 100,
            standardDeviation: 10,
            threshold: 2.0,
          ),
          false,
        ); // z-score = 1.5
      });
    });

    group('detectOutliers', () {
      test('returns empty list for small datasets', () {
        expect(ValidationService.detectOutliers([]), []);
        expect(ValidationService.detectOutliers([1]), []);
        expect(ValidationService.detectOutliers([1, 2]), []);
      });

      test('detects outliers in dataset', () {
        // Need more extreme outlier to trigger with default threshold of 3
        final values = [
          10.0,
          10.0,
          10.0,
          10.0,
          10.0,
          500.0,
        ]; // 500 is extreme outlier
        final outliers = ValidationService.detectOutliers(
          values,
          threshold: 2.0,
        );
        expect(outliers, contains(5)); // Index of 500
      });

      test('returns empty for uniform data', () {
        final values = [10.0, 10.0, 10.0, 10.0, 10.0];
        final outliers = ValidationService.detectOutliers(values);
        expect(outliers, isEmpty);
      });

      test('uses custom threshold', () {
        final values = [10.0, 12.0, 11.0, 13.0, 10.0, 20.0];
        // With default threshold (3), 20 might not be outlier
        // With lower threshold (1.5), it should be
        final outliers = ValidationService.detectOutliers(
          values,
          threshold: 1.5,
        );
        expect(outliers.isNotEmpty, true);
      });
    });

    // ===== VALUE VALIDATION TESTS =====
    group('isValidValue', () {
      test('null is always valid', () {
        expect(ValidationService.isValidValue(null, Unit.seconds), true);
        expect(ValidationService.isValidValue(null, Unit.mg), true);
      });

      test('negative values are invalid', () {
        expect(ValidationService.isValidValue(-1, Unit.seconds), false);
        expect(ValidationService.isValidValue(-1, Unit.minutes), false);
        expect(ValidationService.isValidValue(-1, Unit.hits), false);
      });

      test('validates seconds within 86400', () {
        expect(ValidationService.isValidValue(86400, Unit.seconds), true);
        expect(ValidationService.isValidValue(86401, Unit.seconds), false);
      });

      test('validates minutes within 1440', () {
        expect(ValidationService.isValidValue(1440, Unit.minutes), true);
        expect(ValidationService.isValidValue(1441, Unit.minutes), false);
      });

      test('validates hits within 1000', () {
        expect(ValidationService.isValidValue(1000, Unit.hits), true);
        expect(ValidationService.isValidValue(1001, Unit.hits), false);
      });

      test('validates mg within 1000000', () {
        expect(ValidationService.isValidValue(1000000, Unit.mg), true);
        expect(ValidationService.isValidValue(1000001, Unit.mg), false);
      });

      test('validates grams within 10000', () {
        expect(ValidationService.isValidValue(10000, Unit.grams), true);
        expect(ValidationService.isValidValue(10001, Unit.grams), false);
      });

      test('validates ml within 10000', () {
        expect(ValidationService.isValidValue(10000, Unit.ml), true);
        expect(ValidationService.isValidValue(10001, Unit.ml), false);
      });

      test('validates count within 10000', () {
        expect(ValidationService.isValidValue(10000, Unit.count), true);
        expect(ValidationService.isValidValue(10001, Unit.count), false);
      });

      test('Unit.none accepts any positive value', () {
        expect(ValidationService.isValidValue(999999, Unit.none), true);
      });
    });

    // ===== TIME VALIDATION TESTS =====
    group('Time Validation', () {
      test('normalizeToUtc converts to UTC', () {
        final local = DateTime(2024, 6, 15, 10, 30);
        final utc = ValidationService.normalizeToUtc(local);
        expect(utc.isUtc, true);
      });

      test('toLocalTime converts UTC to local', () {
        final utc = DateTime.utc(2024, 6, 15, 10, 30);
        final local = ValidationService.toLocalTime(utc);
        expect(local.isUtc, false);
      });

      test('detectClockSkew returns high for recent events', () {
        final now = DateTime.now();
        expect(ValidationService.detectClockSkew(now), TimeConfidence.high);
        expect(
          ValidationService.detectClockSkew(
            now.subtract(const Duration(hours: 1)),
          ),
          TimeConfidence.high,
        );
      });

      test('detectClockSkew returns low for future events > 5 min', () {
        final future = DateTime.now().add(const Duration(minutes: 10));
        expect(ValidationService.detectClockSkew(future), TimeConfidence.low);
      });

      test('detectClockSkew returns medium for events > 24 hours old', () {
        final old = DateTime.now().subtract(const Duration(hours: 30));
        expect(ValidationService.detectClockSkew(old), TimeConfidence.medium);
      });

      test('isReasonableTimestamp accepts recent timestamps', () {
        final now = DateTime.now();
        expect(ValidationService.isReasonableTimestamp(now), true);
        expect(
          ValidationService.isReasonableTimestamp(
            now.subtract(const Duration(days: 30)),
          ),
          true,
        );
      });

      test('isReasonableTimestamp rejects timestamps > 10 years old', () {
        final ancient = DateTime.now().subtract(const Duration(days: 3700));
        expect(ValidationService.isReasonableTimestamp(ancient), false);
      });

      test('isReasonableTimestamp rejects timestamps > 1 day in future', () {
        final future = DateTime.now().add(const Duration(days: 2));
        expect(ValidationService.isReasonableTimestamp(future), false);
      });

      test('isValidBackdateTime accepts recent past dates', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(ValidationService.isValidBackdateTime(yesterday), true);
      });

      test('isValidBackdateTime rejects future dates', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(ValidationService.isValidBackdateTime(tomorrow), false);
      });

      test('isValidBackdateTime rejects dates > 30 days old', () {
        final tooOld = DateTime.now().subtract(const Duration(days: 31));
        expect(ValidationService.isValidBackdateTime(tooOld), false);
      });
    });

    // ===== TAG VALIDATION TESTS =====
    group('Tag Validation', () {
      test('cleanTags trims and lowercases tags', () {
        final tags = ['  Morning  ', 'EVENING', '  Afternoon  '];
        final cleaned = ValidationService.cleanTags(tags);
        expect(cleaned, contains('morning'));
        expect(cleaned, contains('evening'));
        expect(cleaned, contains('afternoon'));
      });

      test('cleanTags removes empty tags', () {
        final tags = ['valid', '', '  ', 'another'];
        final cleaned = ValidationService.cleanTags(tags);
        expect(cleaned, hasLength(2));
        expect(cleaned, contains('valid'));
        expect(cleaned, contains('another'));
      });

      test('cleanTags removes tags > 50 characters', () {
        final tags = [
          'short',
          'a' * 51, // Too long
        ];
        final cleaned = ValidationService.cleanTags(tags);
        expect(cleaned, hasLength(1));
        expect(cleaned, contains('short'));
      });

      test('cleanTags removes duplicates', () {
        final tags = ['morning', 'Morning', 'MORNING'];
        final cleaned = ValidationService.cleanTags(tags);
        expect(cleaned, hasLength(1));
      });

      test('isValidTag accepts alphanumeric with spaces', () {
        expect(ValidationService.isValidTag('morning routine'), true);
        expect(ValidationService.isValidTag('test-tag'), true);
        expect(ValidationService.isValidTag('test_tag'), true);
        expect(ValidationService.isValidTag('Test123'), true);
      });

      test('isValidTag rejects empty tags', () {
        expect(ValidationService.isValidTag(''), false);
      });

      test('isValidTag rejects tags > 50 characters', () {
        expect(ValidationService.isValidTag('a' * 51), false);
        expect(ValidationService.isValidTag('a' * 50), true);
      });

      test('isValidTag rejects special characters', () {
        expect(ValidationService.isValidTag('test@tag'), false);
        expect(ValidationService.isValidTag('test#tag'), false);
        expect(ValidationService.isValidTag('test!tag'), false);
      });
    });

    // ===== DUPLICATE DETECTION TESTS =====
    group('Duplicate Detection', () {
      test('areTimestampsWithinTolerance detects close times', () {
        final t1 = DateTime(2024, 6, 15, 10, 30, 0);
        final t2 = DateTime(2024, 6, 15, 10, 30, 30);
        expect(ValidationService.areTimestampsWithinTolerance(t1, t2), true);
      });

      test('areTimestampsWithinTolerance rejects distant times', () {
        final t1 = DateTime(2024, 6, 15, 10, 30, 0);
        final t2 = DateTime(2024, 6, 15, 10, 35, 0); // 5 min apart
        expect(ValidationService.areTimestampsWithinTolerance(t1, t2), false);
      });

      test('areTimestampsWithinTolerance uses custom tolerance', () {
        final t1 = DateTime(2024, 6, 15, 10, 30, 0);
        final t2 = DateTime(2024, 6, 15, 10, 35, 0);
        expect(
          ValidationService.areTimestampsWithinTolerance(
            t1,
            t2,
            tolerance: const Duration(minutes: 10),
          ),
          true,
        );
      });

      test('isPotentialDuplicate detects similar entries', () {
        final t1 = DateTime(2024, 6, 15, 10, 30, 0);
        final t2 = DateTime(2024, 6, 15, 10, 30, 30);
        expect(
          ValidationService.isPotentialDuplicate(
            eventAt1: t1,
            eventAt2: t2,
            value1: 30.0,
            value2: 31.0,
            eventType1: 'vape',
            eventType2: 'vape',
          ),
          true,
        );
      });

      test('isPotentialDuplicate rejects different event types', () {
        final t1 = DateTime(2024, 6, 15, 10, 30, 0);
        final t2 = DateTime(2024, 6, 15, 10, 30, 30);
        expect(
          ValidationService.isPotentialDuplicate(
            eventAt1: t1,
            eventAt2: t2,
            value1: 30.0,
            value2: 30.0,
            eventType1: 'vape',
            eventType2: 'inhale',
          ),
          false,
        );
      });

      test('isPotentialDuplicate rejects times outside tolerance', () {
        final t1 = DateTime(2024, 6, 15, 10, 30, 0);
        final t2 = DateTime(2024, 6, 15, 10, 35, 0); // 5 min apart
        expect(
          ValidationService.isPotentialDuplicate(
            eventAt1: t1,
            eventAt2: t2,
            value1: 30.0,
            value2: 30.0,
            eventType1: 'vape',
            eventType2: 'vape',
          ),
          false,
        );
      });

      test('isPotentialDuplicate rejects significantly different values', () {
        final t1 = DateTime(2024, 6, 15, 10, 30, 0);
        final t2 = DateTime(2024, 6, 15, 10, 30, 30);
        expect(
          ValidationService.isPotentialDuplicate(
            eventAt1: t1,
            eventAt2: t2,
            value1: 30.0,
            value2: 100.0, // Very different
            eventType1: 'vape',
            eventType2: 'vape',
          ),
          false,
        );
      });
    });

    // ===== BATCH VALIDATION TESTS =====
    group('validateBatch', () {
      test('returns empty for valid batch', () {
        final timestamps = [DateTime.now(), DateTime.now()];
        final values = [30.0, 45.0];
        final units = [Unit.seconds, Unit.seconds];

        final issues = ValidationService.validateBatch(
          timestamps: timestamps,
          values: values,
          units: units,
        );

        expect(issues, isEmpty);
      });

      test('detects invalid timestamps', () {
        final ancient = DateTime.now().subtract(const Duration(days: 4000));
        final timestamps = [DateTime.now(), ancient];
        final values = [30.0, 45.0];
        final units = [Unit.seconds, Unit.seconds];

        final issues = ValidationService.validateBatch(
          timestamps: timestamps,
          values: values,
          units: units,
        );

        expect(issues.containsKey('Entry 1'), true);
        expect(issues['Entry 1'], contains('Invalid timestamp'));
      });

      test('detects invalid values for unit', () {
        final timestamps = [DateTime.now(), DateTime.now()];
        final values = [30.0, 100000.0]; // 100000 invalid for seconds
        final units = [Unit.seconds, Unit.seconds];

        final issues = ValidationService.validateBatch(
          timestamps: timestamps,
          values: values,
          units: units,
        );

        expect(issues.containsKey('Entry 1'), true);
        expect(issues['Entry 1'], contains('Invalid value for unit'));
      });
    });

    // ===== DATA QUALITY SCORE TESTS =====
    group('calculateDataQualityScore', () {
      test('returns max score for complete high-quality data', () {
        final score = ValidationService.calculateDataQualityScore(
          hasValidTimestamp: true,
          hasValidValue: true,
          timeConfidence: TimeConfidence.high,
          hasTags: true,
          hasNotes: true,
          hasLocation: true,
        );

        expect(score, 100.0);
      });

      test('returns minimum for invalid required fields', () {
        final score = ValidationService.calculateDataQualityScore(
          hasValidTimestamp: false,
          hasValidValue: false,
          timeConfidence: TimeConfidence.low,
          hasTags: false,
          hasNotes: false,
          hasLocation: false,
        );

        expect(score, 0.0);
      });

      test('gives partial score for medium time confidence', () {
        final score = ValidationService.calculateDataQualityScore(
          hasValidTimestamp: true,
          hasValidValue: true,
          timeConfidence: TimeConfidence.medium,
          hasTags: false,
          hasNotes: false,
          hasLocation: false,
        );

        expect(score, 70.0); // 30 + 30 + 10
      });

      test('adds points for optional enrichment', () {
        final withoutEnrichment = ValidationService.calculateDataQualityScore(
          hasValidTimestamp: true,
          hasValidValue: true,
          timeConfidence: TimeConfidence.high,
          hasTags: false,
          hasNotes: false,
          hasLocation: false,
        );

        final withEnrichment = ValidationService.calculateDataQualityScore(
          hasValidTimestamp: true,
          hasValidValue: true,
          timeConfidence: TimeConfidence.high,
          hasTags: true,
          hasNotes: true,
          hasLocation: true,
        );

        expect(withEnrichment, greaterThan(withoutEnrichment));
        expect(withEnrichment - withoutEnrichment, 20.0); // 7 + 7 + 6
      });
    });

    // ===== LOCATION VALIDATION TESTS =====
    group('isValidLocation', () {
      test('accepts null or empty location', () {
        expect(ValidationService.isValidLocation(null), true);
        expect(ValidationService.isValidLocation(''), true);
      });

      test('accepts valid location strings', () {
        expect(ValidationService.isValidLocation('San Francisco'), true);
        expect(ValidationService.isValidLocation('Home'), true);
      });

      test('rejects locations over 100 characters', () {
        expect(ValidationService.isValidLocation('a' * 101), false);
        expect(ValidationService.isValidLocation('a' * 100), true);
      });
    });

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
