import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import '../models/log_record.dart';
import '../models/daily_rollup.dart';
import '../models/range_query_spec.dart';
import '../models/enums.dart';
import 'isar_service.dart';
import 'log_record_service.dart';

/// AnalyticsService handles aggregation, rollups, and analytics queries
class AnalyticsService {
  final Isar _isar = IsarService.instance;
  final LogRecordService _logRecordService = LogRecordService();

  /// Query log records with a range specification
  Future<List<LogRecord>> queryWithSpec(
    RangeQuerySpec spec,
    String accountId,
  ) async {
    return await _logRecordService.getLogRecords(
      accountId: accountId,
      profileId: spec.profileId,
      startDate: spec.startAt,
      endDate: spec.endAt,
      eventTypes: spec.eventTypes,
      includeDeleted: spec.includeDeleted,
    );
  }

  /// Aggregate log records by the specified grouping
  Future<List<AggregatedData>> aggregateBySpec(
    RangeQuerySpec spec,
    String accountId,
  ) async {
    final records = await queryWithSpec(spec, accountId);

    // Group records by the specified groupBy
    final grouped = <String, List<LogRecord>>{};

    for (final record in records) {
      final key = _getGroupKey(record.eventAt, spec.groupBy);
      grouped.putIfAbsent(key, () => []).add(record);
    }

    // Convert to aggregated data
    final result = <AggregatedData>[];

    for (final entry in grouped.entries) {
      final aggregated = _aggregateRecords(
        entry.key,
        entry.value,
        spec.groupBy,
      );
      result.add(aggregated);
    }

    // Sort by timestamp
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return result;
  }

  /// Get or compute daily rollup
  Future<DailyRollup> getDailyRollup({
    required String accountId,
    String? profileId,
    required DateTime date,
    bool forceRecompute = false,
  }) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    // Try to find existing rollup
    final existing =
        await _isar.dailyRollups
            .filter()
            .accountIdEqualTo(accountId)
            .and()
            .dateEqualTo(dateString)
            .findFirst();

    if (existing != null && !forceRecompute) {
      // Check if it's stale
      final currentHash = await _computeRollupHash(accountId, profileId, date);
      if (!existing.isStale(currentHash)) {
        return existing;
      }
    }

    // Compute new rollup
    return await _computeDailyRollup(
      accountId: accountId,
      profileId: profileId,
      date: date,
    );
  }

  /// Compute daily rollup from scratch
  Future<DailyRollup> _computeDailyRollup({
    required String accountId,
    String? profileId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final records = await _logRecordService.getLogRecords(
      accountId: accountId,
      profileId: profileId,
      startDate: startOfDay,
      endDate: endOfDay,
      includeDeleted: false,
    );

    double totalValue = 0;
    DateTime? firstEventAt;
    DateTime? lastEventAt;
    final eventTypeCounts = <String, int>{};

    for (final record in records) {
      totalValue += record.value ?? 0;

      if (firstEventAt == null || record.eventAt.isBefore(firstEventAt)) {
        firstEventAt = record.eventAt;
      }

      if (lastEventAt == null || record.eventAt.isAfter(lastEventAt)) {
        lastEventAt = record.eventAt;
      }

      final eventTypeKey = record.eventType.name;
      eventTypeCounts[eventTypeKey] = (eventTypeCounts[eventTypeKey] ?? 0) + 1;
    }

    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final hash = await _computeRollupHash(accountId, profileId, date);

    final rollup = DailyRollup.create(
      accountId: accountId,
      profileId: profileId,
      date: dateString,
      totalValue: totalValue,
      eventCount: records.length,
      firstEventAt: firstEventAt,
      lastEventAt: lastEventAt,
      sourceRangeHash: hash,
      eventTypeBreakdownJson: jsonEncode(eventTypeCounts),
    );

    // Save rollup
    await _isar.writeTxn(() async {
      await _isar.dailyRollups.put(rollup);
    });

    return rollup;
  }

  /// Compute hash for rollup validation
  Future<String> _computeRollupHash(
    String accountId,
    String? profileId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final records = await _logRecordService.getLogRecords(
      accountId: accountId,
      profileId: profileId,
      startDate: startOfDay,
      endDate: endOfDay,
      includeDeleted: false,
    );

    final hashInput = records
        .map((r) => '${r.logId}:${r.updatedAt.millisecondsSinceEpoch}')
        .join('|');

    final bytes = utf8.encode(hashInput);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Get group key for a timestamp based on grouping type
  String _getGroupKey(DateTime timestamp, GroupBy groupBy) {
    switch (groupBy) {
      case GroupBy.hour:
        return DateFormat('yyyy-MM-dd HH:00').format(timestamp);
      case GroupBy.day:
        return DateFormat('yyyy-MM-dd').format(timestamp);
      case GroupBy.week:
        final weekStart = timestamp.subtract(
          Duration(days: timestamp.weekday - 1),
        );
        return DateFormat('yyyy-MM-dd').format(weekStart);
      case GroupBy.month:
        return DateFormat('yyyy-MM').format(timestamp);
      case GroupBy.quarter:
        final quarter = ((timestamp.month - 1) ~/ 3) + 1;
        return '${timestamp.year}-Q$quarter';
      case GroupBy.year:
        return '${timestamp.year}';
    }
  }

  /// Aggregate a list of records into a single data point
  AggregatedData _aggregateRecords(
    String key,
    List<LogRecord> records,
    GroupBy groupBy,
  ) {
    double totalValue = 0;
    int count = records.length;
    final eventTypeCounts = <EventType, int>{};

    for (final record in records) {
      totalValue += record.value ?? 0;
      eventTypeCounts[record.eventType] =
          (eventTypeCounts[record.eventType] ?? 0) + 1;
    }

    // Parse the timestamp from the key
    final timestamp = _parseGroupKey(key, groupBy);

    return AggregatedData(
      groupKey: key,
      timestamp: timestamp,
      totalValue: totalValue,
      count: count,
      averageValue: count > 0 ? totalValue / count : 0,
      eventTypeCounts: eventTypeCounts,
    );
  }

  /// Parse group key back to timestamp
  DateTime _parseGroupKey(String key, GroupBy groupBy) {
    switch (groupBy) {
      case GroupBy.hour:
        return DateFormat('yyyy-MM-dd HH:00').parse(key);
      case GroupBy.day:
        return DateFormat('yyyy-MM-dd').parse(key);
      case GroupBy.week:
        return DateFormat('yyyy-MM-dd').parse(key);
      case GroupBy.month:
        return DateFormat('yyyy-MM').parse(key);
      case GroupBy.quarter:
        final parts = key.split('-Q');
        final year = int.parse(parts[0]);
        final quarter = int.parse(parts[1]);
        final month = ((quarter - 1) * 3) + 1;
        return DateTime(year, month, 1);
      case GroupBy.year:
        return DateTime(int.parse(key), 1, 1);
    }
  }

  /// Get time series data for charting
  Future<List<TimeSeriesPoint>> getTimeSeries({
    required String accountId,
    required RangeQuerySpec spec,
  }) async {
    final aggregated = await aggregateBySpec(spec, accountId);

    return aggregated.map((data) {
      return TimeSeriesPoint(
        timestamp: data.timestamp,
        value: data.totalValue,
        count: data.count,
      );
    }).toList();
  }

  /// Get event type breakdown for a period
  Future<Map<EventType, EventTypeStats>> getEventTypeBreakdown({
    required String accountId,
    String? profileId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final records = await _logRecordService.getLogRecords(
      accountId: accountId,
      profileId: profileId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: false,
    );

    final stats = <EventType, EventTypeStats>{};

    for (final record in records) {
      final existing = stats[record.eventType];

      if (existing == null) {
        stats[record.eventType] = EventTypeStats(
          eventType: record.eventType,
          count: 1,
          totalValue: record.value ?? 0,
        );
      } else {
        stats[record.eventType] = EventTypeStats(
          eventType: record.eventType,
          count: existing.count + 1,
          totalValue: existing.totalValue + (record.value ?? 0),
        );
      }
    }

    return stats;
  }

  /// Get summary statistics for a period
  Future<PeriodSummary> getPeriodSummary({
    required String accountId,
    String? profileId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final records = await _logRecordService.getLogRecords(
      accountId: accountId,
      profileId: profileId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: false,
    );

    if (records.isEmpty) {
      return PeriodSummary.empty();
    }

    double totalValue = 0;
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;

    for (final record in records) {
      final value = record.value ?? 0;
      totalValue += value;

      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
    }

    return PeriodSummary(
      totalCount: records.length,
      totalValue: totalValue,
      averageValue: totalValue / records.length,
      minValue: minValue == double.infinity ? 0 : minValue,
      maxValue: maxValue == double.negativeInfinity ? 0 : maxValue,
      firstEvent: records.first.eventAt,
      lastEvent: records.last.eventAt,
    );
  }

  /// Invalidate rollup cache for a date range
  Future<void> invalidateRollups({
    required String accountId,
    String? profileId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final dates = <String>[];
    var currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dates.add(DateFormat('yyyy-MM-dd').format(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    await _isar.writeTxn(() async {
      for (final dateString in dates) {
        final rollup =
            await _isar.dailyRollups
                .filter()
                .accountIdEqualTo(accountId)
                .and()
                .dateEqualTo(dateString)
                .findFirst();

        if (rollup != null) {
          await _isar.dailyRollups.delete(rollup.id);
        }
      }
    });
  }
}

/// Aggregated data point
class AggregatedData {
  final String groupKey;
  final DateTime timestamp;
  final double totalValue;
  final int count;
  final double averageValue;
  final Map<EventType, int> eventTypeCounts;

  AggregatedData({
    required this.groupKey,
    required this.timestamp,
    required this.totalValue,
    required this.count,
    required this.averageValue,
    required this.eventTypeCounts,
  });

  @override
  String toString() {
    return 'AggregatedData(key: $groupKey, count: $count, total: $totalValue, avg: $averageValue)';
  }
}

/// Time series data point for charting
class TimeSeriesPoint {
  final DateTime timestamp;
  final double value;
  final int count;

  TimeSeriesPoint({
    required this.timestamp,
    required this.value,
    required this.count,
  });
}

/// Event type statistics
class EventTypeStats {
  final EventType eventType;
  final int count;
  final double totalValue;

  EventTypeStats({
    required this.eventType,
    required this.count,
    required this.totalValue,
  });

  double get averageValue => count > 0 ? totalValue / count : 0;
}

/// Period summary statistics
class PeriodSummary {
  final int totalCount;
  final double totalValue;
  final double averageValue;
  final double minValue;
  final double maxValue;
  final DateTime? firstEvent;
  final DateTime? lastEvent;

  PeriodSummary({
    required this.totalCount,
    required this.totalValue,
    required this.averageValue,
    required this.minValue,
    required this.maxValue,
    this.firstEvent,
    this.lastEvent,
  });

  factory PeriodSummary.empty() {
    return PeriodSummary(
      totalCount: 0,
      totalValue: 0,
      averageValue: 0,
      minValue: 0,
      maxValue: 0,
    );
  }

  Duration? get duration {
    if (firstEvent == null || lastEvent == null) return null;
    return lastEvent!.difference(firstEvent!);
  }
}
