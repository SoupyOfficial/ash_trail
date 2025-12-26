import 'package:isar/isar.dart';

part 'daily_rollup.g.dart';

/// DailyRollup represents aggregated data for a specific day
/// Used for performance optimization in analytics
@collection
class DailyRollup {
  Id id = Isar.autoIncrement;

  /// Account this rollup belongs to
  @Index(composite: [CompositeIndex('date')])
  late String accountId;

  /// Optional profile ID
  String? profileId;

  /// Date in YYYY-MM-DD format
  @Index()
  late String date;

  /// Total aggregated value for the day
  late double totalValue;

  /// Number of events in this day
  late int eventCount;

  /// First event time of the day
  DateTime? firstEventAt;

  /// Last event time of the day
  DateTime? lastEventAt;

  /// When this rollup was computed
  late DateTime updatedAt;

  /// Hash of source data range for cache validation
  String? sourceRangeHash;

  /// Breakdown by event type (stored as JSON string)
  String? eventTypeBreakdownJson;

  DailyRollup();

  DailyRollup.create({
    required this.accountId,
    this.profileId,
    required this.date,
    this.totalValue = 0,
    this.eventCount = 0,
    this.firstEventAt,
    this.lastEventAt,
    DateTime? updatedAt,
    this.sourceRangeHash,
    this.eventTypeBreakdownJson,
  }) {
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  /// Check if this rollup is stale (needs recomputation)
  bool isStale(String currentHash) {
    return sourceRangeHash != currentHash;
  }

  /// Copy with method
  DailyRollup copyWith({
    String? accountId,
    String? profileId,
    String? date,
    double? totalValue,
    int? eventCount,
    DateTime? firstEventAt,
    DateTime? lastEventAt,
    DateTime? updatedAt,
    String? sourceRangeHash,
    String? eventTypeBreakdownJson,
  }) {
    return DailyRollup.create(
      accountId: accountId ?? this.accountId,
      profileId: profileId ?? this.profileId,
      date: date ?? this.date,
      totalValue: totalValue ?? this.totalValue,
      eventCount: eventCount ?? this.eventCount,
      firstEventAt: firstEventAt ?? this.firstEventAt,
      lastEventAt: lastEventAt ?? this.lastEventAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceRangeHash: sourceRangeHash ?? this.sourceRangeHash,
      eventTypeBreakdownJson:
          eventTypeBreakdownJson ?? this.eventTypeBreakdownJson,
    )..id = id;
  }
}
