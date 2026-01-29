import 'enums.dart';
import '../utils/day_boundary.dart';

/// RangeQuerySpec defines parameters for querying and aggregating log records
/// This is typically used as a transient object for UI state, not persisted
class RangeQuerySpec {
  /// Type of time range
  final RangeType rangeType;

  /// Start of the range (inclusive)
  final DateTime startAt;

  /// End of the range (inclusive)
  final DateTime endAt;

  /// How to group the results
  final GroupBy groupBy;

  /// Filter by specific event types
  final List<EventType>? eventTypes;

  /// Filter by tags
  final List<String>? tags;

  /// Minimum value filter
  final double? minValue;

  /// Maximum value filter
  final double? maxValue;

  /// Filter by profile ID
  final String? profileId;

  /// Whether to include deleted records
  final bool includeDeleted;

  const RangeQuerySpec({
    required this.rangeType,
    required this.startAt,
    required this.endAt,
    this.groupBy = GroupBy.day,
    this.eventTypes,
    this.tags,
    this.minValue,
    this.maxValue,
    this.profileId,
    this.includeDeleted = false,
  });

  /// Create a range spec for today (using 6am day boundary)
  factory RangeQuerySpec.today({GroupBy? groupBy}) {
    // Use 6am day boundary for more natural grouping of late-night activity
    final startOfDay = DayBoundary.getTodayStart();
    final endOfDay = DayBoundary.getTodayEnd();

    return RangeQuerySpec(
      rangeType: RangeType.today,
      startAt: startOfDay,
      endAt: endOfDay,
      groupBy: groupBy ?? GroupBy.hour,
    );
  }

  /// Create a range spec for this week (using 6am day boundary)
  factory RangeQuerySpec.week({GroupBy? groupBy}) {
    final now = DateTime.now();
    // Use 6am day boundary for week start
    final startOfWeek = DayBoundary.getWeekStart(now);

    return RangeQuerySpec(
      rangeType: RangeType.week,
      startAt: startOfWeek,
      endAt: now,
      groupBy: groupBy ?? GroupBy.day,
    );
  }

  /// Create a range spec for this month
  factory RangeQuerySpec.month({GroupBy? groupBy}) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return RangeQuerySpec(
      rangeType: RangeType.month,
      startAt: startOfMonth,
      endAt: now,
      groupBy: groupBy ?? GroupBy.day,
    );
  }

  /// Create a range spec for this year
  factory RangeQuerySpec.year({GroupBy? groupBy}) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    return RangeQuerySpec(
      rangeType: RangeType.year,
      startAt: startOfYear,
      endAt: now,
      groupBy: groupBy ?? GroupBy.month,
    );
  }

  /// Create a range spec for year to date
  factory RangeQuerySpec.ytd({GroupBy? groupBy}) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);

    return RangeQuerySpec(
      rangeType: RangeType.ytd,
      startAt: startOfYear,
      endAt: now,
      groupBy: groupBy ?? GroupBy.month,
    );
  }

  /// Create a custom range spec
  factory RangeQuerySpec.custom({
    required DateTime startAt,
    required DateTime endAt,
    GroupBy? groupBy,
    List<EventType>? eventTypes,
    List<String>? tags,
    double? minValue,
    double? maxValue,
    String? profileId,
    bool includeDeleted = false,
  }) {
    return RangeQuerySpec(
      rangeType: RangeType.custom,
      startAt: startAt,
      endAt: endAt,
      groupBy: groupBy ?? GroupBy.day,
      eventTypes: eventTypes,
      tags: tags,
      minValue: minValue,
      maxValue: maxValue,
      profileId: profileId,
      includeDeleted: includeDeleted,
    );
  }

  /// Copy with method
  RangeQuerySpec copyWith({
    RangeType? rangeType,
    DateTime? startAt,
    DateTime? endAt,
    GroupBy? groupBy,
    List<EventType>? eventTypes,
    List<String>? tags,
    double? minValue,
    double? maxValue,
    String? profileId,
    bool? includeDeleted,
  }) {
    return RangeQuerySpec(
      rangeType: rangeType ?? this.rangeType,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      groupBy: groupBy ?? this.groupBy,
      eventTypes: eventTypes ?? this.eventTypes,
      tags: tags ?? this.tags,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      profileId: profileId ?? this.profileId,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  /// Get duration in days
  int get durationInDays {
    return endAt.difference(startAt).inDays;
  }

  /// Check if a date falls within this range
  bool containsDate(DateTime date) {
    return date.isAfter(startAt.subtract(const Duration(seconds: 1))) &&
        date.isBefore(endAt.add(const Duration(seconds: 1)));
  }

  @override
  String toString() {
    return 'RangeQuerySpec(type: $rangeType, start: $startAt, end: $endAt, groupBy: $groupBy)';
  }
}
