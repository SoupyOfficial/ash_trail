import 'dart:math' as math;
import '../models/enums.dart';

/// Data validation and quality checking utilities
class ValidationService {
  // ===== VALUE VALIDATION =====

  /// Clamp a value to reasonable bounds based on unit type
  static double? clampValue(double? value, Unit unit) {
    if (value == null) return null;

    switch (unit) {
      case Unit.seconds:
        // 0 to 3600 seconds (1 hour max for a single event)
        return value.clamp(0, 3600);
      case Unit.minutes:
        // 0 to 60 minutes
        return value.clamp(0, 60);
      case Unit.hits:
        // 0 to 100 hits (reasonable max for a single event)
        return value.clamp(0, 100);
      case Unit.mg:
        // 0 to 10000 mg (10 grams)
        return value.clamp(0, 10000);
      case Unit.grams:
        // 0 to 1000 grams
        return value.clamp(0, 1000);
      case Unit.ml:
        // 0 to 1000 ml
        return value.clamp(0, 1000);
      case Unit.count:
        // 0 to 1000 (generic count)
        return value.clamp(0, 1000);
      case Unit.none:
        return value;
    }
  }

  /// Check if a value is an outlier (more than 3 standard deviations from mean)
  /// Returns true if the value is likely an outlier
  static bool isOutlier({
    required double value,
    required double mean,
    required double standardDeviation,
    double threshold = 3.0,
  }) {
    if (standardDeviation == 0) return false;
    final zScore = (value - mean).abs() / standardDeviation;
    return zScore > threshold;
  }

  /// Detect outliers in a list of values
  static List<int> detectOutliers(
    List<double> values, {
    double threshold = 3.0,
  }) {
    if (values.length < 3) return [];

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
        values.length;
    final stdDev = math.sqrt(variance.abs());

    final outlierIndices = <int>[];
    for (int i = 0; i < values.length; i++) {
      if (isOutlier(
        value: values[i],
        mean: mean,
        standardDeviation: stdDev,
        threshold: threshold,
      )) {
        outlierIndices.add(i);
      }
    }

    return outlierIndices;
  }

  /// Validate that a value is reasonable for its unit
  static bool isValidValue(double? value, Unit unit) {
    if (value == null) return true; // Null is valid

    // Check for negative values (most units shouldn't be negative)
    if (value < 0) return false;

    // Check for unreasonably large values
    switch (unit) {
      case Unit.seconds:
        return value <= 86400; // 24 hours
      case Unit.minutes:
        return value <= 1440; // 24 hours
      case Unit.hits:
        return value <= 1000;
      case Unit.mg:
        return value <= 1000000; // 1 kg
      case Unit.grams:
        return value <= 10000; // 10 kg
      case Unit.ml:
        return value <= 10000; // 10 liters
      case Unit.count:
        return value <= 10000;
      case Unit.none:
        return true;
    }
  }

  // ===== TIME VALIDATION =====

  /// Normalize time to UTC
  static DateTime normalizeToUtc(DateTime dateTime) {
    return dateTime.toUtc();
  }

  /// Convert UTC time to local time
  static DateTime toLocalTime(DateTime utcTime) {
    return utcTime.toLocal();
  }

  /// Detect clock skew by comparing event time with current time
  /// Returns TimeConfidence level
  static TimeConfidence detectClockSkew(DateTime eventAt) {
    final now = DateTime.now();
    final difference = eventAt.difference(now).abs();

    // Event is in the future by more than 5 minutes - significant skew
    if (eventAt.isAfter(now) && difference.inMinutes > 5) {
      return TimeConfidence.low;
    }

    // Event is more than 24 hours old but was just created - might be backdated
    if (difference.inHours > 24) {
      return TimeConfidence.medium;
    }

    // Event time is within reasonable bounds
    return TimeConfidence.high;
  }

  /// Check if a timestamp is reasonable (not too far in past or future)
  static bool isReasonableTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = timestamp.difference(now);

    // Not more than 10 years in the past
    if (difference.inDays < -3650) return false;

    // Not more than 1 day (24 hours) in the future
    if (difference.inHours > 24) return false;

    return true;
  }

  /// Validate that a timestamp is within a reasonable range for backdating
  static bool isValidBackdateTime(DateTime backdateTime) {
    final now = DateTime.now();
    final difference = now.difference(backdateTime);

    // Must be in the past
    if (difference.isNegative) return false;

    // Not more than 30 days old for backdating
    if (difference.inDays > 30) return false;

    return true;
  }

  // ===== CONTEXT VALIDATION =====

  /// Validate mood rating
  /// Null values are valid and represent "not set" state (per design)
  /// Non-null values MUST be between 1-10 inclusive (zero not allowed)
  /// Values outside range are clamped to nearest boundary
  static double? validateMood(double? mood) {
    if (mood == null) return null;
    // Per design doc: 1-10 inclusive, zero is NOT a valid rating value
    return mood.clamp(1, 10);
  }

  /// Validate craving rating
  /// Null values are valid and represent "not set" state (per design)
  /// Non-null values MUST be between 1-10 inclusive (zero not allowed)
  /// Values outside range are clamped to nearest boundary
  static double? validateCraving(double? craving) {
    if (craving == null) return null;
    // Per design doc: 1-10 inclusive, zero is NOT a valid rating value
    return craving.clamp(1, 10);
  }

  /// Validate physical rating
  /// Null values are valid and represent "not set" state (per design)
  /// Non-null values MUST be between 1-10 inclusive (zero not allowed)
  /// Values outside range are clamped to nearest boundary
  static double? validatePhysicalRating(double? rating) {
    if (rating == null) return null;
    // Per design doc: 1-10 inclusive, zero is NOT a valid rating value
    return rating.clamp(1, 10);
  }

  /// Check if a rating value is valid (null or 1-10)
  /// Returns true for null (valid unset state) or values in 1-10 range
  /// Returns false for zero or values outside 1-10 range
  static bool isValidRating(double? rating) {
    if (rating == null) return true; // Null is valid
    return rating >= 1 && rating <= 10; // Non-null must be 1-10
  }

  /// Validate location string
  static bool isValidLocation(String? location) {
    if (location == null || location.isEmpty) return true;
    return location.length <= 100; // Max length
  }

  /// Validate latitude/longitude pair - both must be present or both null
  /// This enforces the cross-field constraint from design doc 5.4.2
  static bool isValidLocationPair(double? latitude, double? longitude) {
    // Both null is valid
    if (latitude == null && longitude == null) return true;

    // Both present is valid (if in correct ranges)
    if (latitude != null && longitude != null) {
      return isValidLatitude(latitude) && isValidLongitude(longitude);
    }

    // One present, one null is INVALID (cross-field validation failure)
    return false;
  }

  /// Validate latitude value (-90 to 90)
  static bool isValidLatitude(double latitude) {
    return latitude >= -90 && latitude <= 90;
  }

  /// Validate longitude value (-180 to 180)
  static bool isValidLongitude(double longitude) {
    return longitude >= -180 && longitude <= 180;
  }

  // ===== TAG VALIDATION =====

  /// Validate and clean tags
  static List<String> cleanTags(List<String> tags) {
    return tags
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty && tag.length <= 50)
        .toSet()
        .toList();
  }

  /// Validate tag string
  static bool isValidTag(String tag) {
    if (tag.isEmpty || tag.length > 50) return false;
    // Only alphanumeric, spaces, hyphens, underscores
    return RegExp(r'^[a-zA-Z0-9 _-]+$').hasMatch(tag);
  }

  // ===== DUPLICATE DETECTION =====

  /// Check if two timestamps are within tolerance (for duplicate detection)
  static bool areTimestampsWithinTolerance(
    DateTime time1,
    DateTime time2, {
    Duration tolerance = const Duration(minutes: 1),
  }) {
    return time1.difference(time2).abs() <= tolerance;
  }

  /// Simple duplicate check based on time, value, and event type
  static bool isPotentialDuplicate({
    required DateTime eventAt1,
    required DateTime eventAt2,
    double? value1,
    double? value2,
    required String eventType1,
    required String eventType2,
    Duration timeTolerance = const Duration(minutes: 1),
  }) {
    // Different event types - not a duplicate
    if (eventType1 != eventType2) return false;

    // Times not within tolerance - not a duplicate
    if (!areTimestampsWithinTolerance(
      eventAt1,
      eventAt2,
      tolerance: timeTolerance,
    )) {
      return false;
    }

    // If both have values, they should be similar
    if (value1 != null && value2 != null) {
      final diff = (value1 - value2).abs();
      final avg = (value1 + value2) / 2;
      // Values within 10% of average are considered similar
      if (avg > 0 && diff / avg > 0.1) {
        return false;
      }
    }

    // Likely a duplicate
    return true;
  }

  // ===== BATCH VALIDATION =====

  /// Validate a batch of values and return any issues
  static Map<String, List<String>> validateBatch({
    required List<DateTime> timestamps,
    required List<double?> values,
    required List<Unit> units,
  }) {
    final issues = <String, List<String>>{};

    for (int i = 0; i < timestamps.length; i++) {
      final errors = <String>[];

      if (!isReasonableTimestamp(timestamps[i])) {
        errors.add('Invalid timestamp');
      }

      if (values[i] != null && !isValidValue(values[i], units[i])) {
        errors.add('Invalid value for unit');
      }

      if (errors.isNotEmpty) {
        issues['Entry $i'] = errors;
      }
    }

    return issues;
  }

  // ===== DATA QUALITY METRICS =====

  /// Calculate data quality score (0-100)
  static double calculateDataQualityScore({
    required bool hasValidTimestamp,
    required bool hasValidValue,
    required TimeConfidence timeConfidence,
    required bool hasTags,
    required bool hasNotes,
    required bool hasLocation,
  }) {
    double score = 0;

    // Required fields (60 points)
    if (hasValidTimestamp) score += 30;
    if (hasValidValue) score += 30;

    // Time confidence (20 points)
    switch (timeConfidence) {
      case TimeConfidence.high:
        score += 20;
        break;
      case TimeConfidence.medium:
        score += 10;
        break;
      case TimeConfidence.low:
        score += 0;
        break;
    }

    // Optional enrichment (20 points total)
    if (hasTags) score += 7;
    if (hasNotes) score += 7;
    if (hasLocation) score += 6;

    return score;
  }
}
