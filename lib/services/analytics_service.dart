import 'dart:convert';
import '../models/log_record.dart';
import '../models/daily_rollup.dart';
import '../models/enums.dart';
import '../utils/day_boundary.dart';

/// Analytics service per design doc 10. Analytics & Aggregation
/// Provides client-side computation of aggregated metrics
class AnalyticsService {
  /// Compute daily aggregation per design doc 10.4.1
  /// Uses 6am day boundary to group late-night activity with previous day
  Future<DailyRollup> computeDailyRollup({
    required String accountId,
    required DateTime date,
    required List<LogRecord> records,
  }) async {
    // Filter records for the specific day (using 6am day boundary)
    final dayStart = DayBoundary.getDayStart(date);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final dayRecords =
        records.where((r) {
          return r.eventAt.isAfter(dayStart) &&
              r.eventAt.isBefore(dayEnd) &&
              !r.isDeleted;
        }).toList();

    // Compute aggregates
    final totalValue = _computeTotalDuration(dayRecords).toDouble();
    final eventCount = dayRecords.length;
    final eventTypeCounts = _computeEventTypeCounts(dayRecords);

    // Find first and last events
    DateTime? firstEvent;
    DateTime? lastEvent;
    if (dayRecords.isNotEmpty) {
      final sorted =
          dayRecords.toList()..sort((a, b) => a.eventAt.compareTo(b.eventAt));
      firstEvent = sorted.first.eventAt;
      lastEvent = sorted.last.eventAt;
    }

    // Date string in YYYY-MM-DD format
    final dateStr =
        '${dayStart.year}-${dayStart.month.toString().padLeft(2, '0')}-${dayStart.day.toString().padLeft(2, '0')}';

    return DailyRollup.create(
      accountId: accountId,
      date: dateStr,
      totalValue: totalValue,
      eventCount: eventCount,
      firstEventAt: firstEvent,
      lastEventAt: lastEvent,
      eventTypeBreakdownJson: jsonEncode(
        eventTypeCounts.map((k, v) => MapEntry(k.name, v)),
      ),
    );
  }

  /// Compute rolling window aggregates per design doc 10.4.2
  /// Returns aggregated data for last N days (using 6am day boundary)
  Future<RollingWindowStats> computeRollingWindow({
    required String accountId,
    required List<LogRecord> records,
    required int days,
    DateTime? now,
  }) async {
    final referenceNow = now ?? DateTime.now();
    // Use 6am day boundary for more natural grouping of late-night activity
    final today = DayBoundary.getDayStart(referenceNow);
    final windowStart = today.subtract(Duration(days: days));

    final windowRecords =
        records.where((r) {
          return r.eventAt.isAfter(windowStart) && !r.isDeleted;
        }).toList();

    // Compute daily rollups for each day in window
    final dailyRollups = <DailyRollup>[];
    for (var i = 0; i < days; i++) {
      final date = windowStart.add(Duration(days: i));
      final rollup = await computeDailyRollup(
        accountId: accountId,
        date: date,
        records: windowRecords,
      );
      dailyRollups.add(rollup);
    }

    return RollingWindowStats(
      days: days,
      startDate: windowStart,
      endDate: referenceNow,
      totalEntries: windowRecords.length,
      totalDurationSeconds: _computeTotalDuration(windowRecords),
      averageDailyEntries: windowRecords.length / days,
      averageMoodRating: _computeAverageMood(windowRecords),
      averagePhysicalRating: _computeAveragePhysical(windowRecords),
      dailyRollups: dailyRollups,
      eventTypeCounts: _computeEventTypeCounts(windowRecords),
    );
  }

  /// Get last 7 days statistics
  Future<RollingWindowStats> getLast7DaysStats({
    required String accountId,
    required List<LogRecord> records,
  }) async {
    return computeRollingWindow(
      accountId: accountId,
      records: records,
      days: 7,
    );
  }

  /// Get last 30 days statistics
  Future<RollingWindowStats> getLast30DaysStats({
    required String accountId,
    required List<LogRecord> records,
  }) async {
    return computeRollingWindow(
      accountId: accountId,
      records: records,
      days: 30,
    );
  }

  /// Compute trend direction (up, down, stable)
  TrendDirection computeTrend({
    required List<DailyRollup> rollups,
    required String metric,
  }) {
    if (rollups.length < 2) return TrendDirection.stable;

    // Compare first half to second half of rollups
    final midpoint = rollups.length ~/ 2;
    final firstHalf = rollups.sublist(0, midpoint);
    final secondHalf = rollups.sublist(midpoint);

    double firstAvg = 0;
    double secondAvg = 0;

    switch (metric) {
      case 'entries':
        firstAvg =
            firstHalf.map((r) => r.eventCount).fold<int>(0, (a, b) => a + b) /
            firstHalf.length;
        secondAvg =
            secondHalf.map((r) => r.eventCount).fold<int>(0, (a, b) => a + b) /
            secondHalf.length;
        break;
      case 'duration':
        firstAvg =
            firstHalf
                .map((r) => r.totalValue)
                .fold<double>(0, (a, b) => a + b) /
            firstHalf.length;
        secondAvg =
            secondHalf
                .map((r) => r.totalValue)
                .fold<double>(0, (a, b) => a + b) /
            secondHalf.length;
        break;
      case 'mood':
        // Mood trends not available from DailyRollup
        // Would need to be computed from raw records
        return TrendDirection.stable;
    }

    final percentChange = firstAvg > 0 ? (secondAvg - firstAvg) / firstAvg : 0;

    if (percentChange > 0.1) return TrendDirection.up;
    if (percentChange < -0.1) return TrendDirection.down;
    return TrendDirection.stable;
  }

  // Private helper methods

  int _computeTotalDuration(List<LogRecord> records) {
    return records.fold(0, (total, record) {
      if (record.unit == Unit.seconds) {
        return total + record.duration.toInt();
      }
      if (record.unit == Unit.minutes) {
        return total + (record.duration * 60).toInt();
      }
      return total;
    });
  }

  double? _computeAverageMood(List<LogRecord> records) {
    final withMood = records.where((r) => r.moodRating != null).toList();
    if (withMood.isEmpty) return null;
    return withMood.map((r) => r.moodRating!).fold(0.0, (a, b) => a + b) /
        withMood.length;
  }

  double? _computeAveragePhysical(List<LogRecord> records) {
    final withPhysical =
        records.where((r) => r.physicalRating != null).toList();
    if (withPhysical.isEmpty) return null;
    return withPhysical
            .map((r) => r.physicalRating!)
            .fold(0.0, (a, b) => a + b) /
        withPhysical.length;
  }

  Map<EventType, int> _computeEventTypeCounts(List<LogRecord> records) {
    final counts = <EventType, int>{};
    for (final record in records) {
      counts[record.eventType] = (counts[record.eventType] ?? 0) + 1;
    }
    return counts;
  }
}

/// Statistics for a rolling window of days
class RollingWindowStats {
  final int days;
  final DateTime startDate;
  final DateTime endDate;
  final int totalEntries;
  final int totalDurationSeconds;
  final double averageDailyEntries;
  final double? averageMoodRating;
  final double? averagePhysicalRating;
  final List<DailyRollup> dailyRollups;
  final Map<EventType, int> eventTypeCounts;

  RollingWindowStats({
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.totalEntries,
    required this.totalDurationSeconds,
    required this.averageDailyEntries,
    this.averageMoodRating,
    this.averagePhysicalRating,
    required this.dailyRollups,
    required this.eventTypeCounts,
  });

  /// Get total duration as formatted string
  String get formattedDuration {
    final hours = totalDurationSeconds ~/ 3600;
    final minutes = (totalDurationSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Trend direction indicator
enum TrendDirection { up, down, stable }

/// Chart data point for visualization
class ChartDataPoint {
  final DateTime date;
  final double value;
  final String? label;

  ChartDataPoint({required this.date, required this.value, this.label});
}
