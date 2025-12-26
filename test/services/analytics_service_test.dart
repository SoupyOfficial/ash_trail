import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/user_account.dart';
import 'package:ash_trail/models/profile.dart';
import 'package:ash_trail/models/daily_rollup.dart';
import 'package:ash_trail/models/range_query_spec.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/services/analytics_service.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'dart:io';

void main() {
  // Skip all tests on unsupported platforms (Isar requires native platform)
  if (!Platform.isAndroid &&
      !Platform.isIOS &&
      !Platform.isMacOS &&
      !Platform.isLinux &&
      !Platform.isWindows) {
    test('⚠️ Service tests skipped - Isar not supported on this platform', () {
      print('Isar database only supports: iOS, Android, macOS, Linux, Windows');
      print('Current platform does not support these tests.');
    });
    return;
  }

  late Isar isar;
  late AnalyticsService analyticsService;
  late LogRecordService logRecordService;

  setUp(() async {
    isar = await Isar.open(
      [LogRecordSchema, UserAccountSchema, ProfileSchema, DailyRollupSchema],
      directory: '',
      name: 'test_analytics_${DateTime.now().millisecondsSinceEpoch}',
    );

    analyticsService = AnalyticsService();
    logRecordService = LogRecordService();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('AnalyticsService - Time Series', () {
    test('generates time series with daily grouping', () async {
      // Create records over 3 days
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 0),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 2.0,
        eventAt: DateTime(2025, 1, 1, 15, 0),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 3.0,
        eventAt: DateTime(2025, 1, 2, 10, 0),
      );

      final spec = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 1, 3),
        groupBy: GroupBy.day,
      );

      final timeSeries = await analyticsService.getTimeSeries(
        accountId: 'test-account',
        spec: spec,
      );

      expect(timeSeries.length, 2);
      expect(timeSeries[0].count, 2);
      expect(timeSeries[0].value, 3.0);
      expect(timeSeries[1].count, 1);
      expect(timeSeries[1].value, 3.0);
    });

    test('generates time series with hourly grouping', () async {
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 15),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 45),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 11, 15),
      );

      final spec = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 1, 2),
        groupBy: GroupBy.hour,
      );

      final timeSeries = await analyticsService.getTimeSeries(
        accountId: 'test-account',
        spec: spec,
      );

      expect(timeSeries.length, 2);
      expect(timeSeries[0].count, 2); // 10:00 hour
      expect(timeSeries[1].count, 1); // 11:00 hour
    });
  });

  group('AnalyticsService - Aggregations', () {
    test('aggregates by day correctly', () async {
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 5.0,
        eventAt: DateTime(2025, 1, 1, 10, 0),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 10.0,
        eventAt: DateTime(2025, 1, 1, 15, 0),
      );

      final spec = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 1, 2),
        groupBy: GroupBy.day,
      );

      final aggregated = await analyticsService.aggregateBySpec(
        spec,
        'test-account',
      );

      expect(aggregated.length, 1);
      expect(aggregated[0].count, 2);
      expect(aggregated[0].totalValue, 15.0);
      expect(aggregated[0].averageValue, 7.5);
    });

    test('aggregates with event type breakdown', () async {
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 0),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 11, 0),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
        eventAt: DateTime(2025, 1, 1, 12, 0),
      );

      final spec = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 1, 2),
        groupBy: GroupBy.day,
      );

      final aggregated = await analyticsService.aggregateBySpec(
        spec,
        'test-account',
      );

      expect(aggregated[0].eventTypeCounts[EventType.inhale], 2);
      expect(aggregated[0].eventTypeCounts[EventType.note], 1);
    });
  });

  group('AnalyticsService - Event Type Breakdown', () {
    test('computes event type breakdown correctly', () async {
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 2.0,
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
        value: 0.0,
      );

      final breakdown = await analyticsService.getEventTypeBreakdown(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2026, 1, 1),
      );

      expect(breakdown[EventType.inhale]!.count, 2);
      expect(breakdown[EventType.inhale]!.totalValue, 3.0);
      expect(breakdown[EventType.inhale]!.averageValue, 1.5);
      expect(breakdown[EventType.note]!.count, 1);
    });
  });

  group('AnalyticsService - Period Summary', () {
    test('computes period summary correctly', () async {
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 0),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 5.0,
        eventAt: DateTime(2025, 1, 1, 12, 0),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 3.0,
        eventAt: DateTime(2025, 1, 1, 14, 0),
      );

      final summary = await analyticsService.getPeriodSummary(
        accountId: 'test-account',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 2),
      );

      expect(summary.totalCount, 3);
      expect(summary.totalValue, 9.0);
      expect(summary.averageValue, 3.0);
      expect(summary.minValue, 1.0);
      expect(summary.maxValue, 5.0);
      expect(summary.firstEvent, DateTime(2025, 1, 1, 10, 0));
      expect(summary.lastEvent, DateTime(2025, 1, 1, 14, 0));
    });

    test('returns empty summary for no records', () async {
      final summary = await analyticsService.getPeriodSummary(
        accountId: 'non-existent-account',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 2),
      );

      expect(summary.totalCount, 0);
      expect(summary.totalValue, 0);
      expect(summary.averageValue, 0);
    });
  });

  group('AnalyticsService - Daily Rollup', () {
    test('computes daily rollup correctly', () async {
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 0),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 2.0,
        eventAt: DateTime(2025, 1, 1, 15, 0),
      );

      final rollup = await analyticsService.getDailyRollup(
        accountId: 'test-account',
        date: DateTime(2025, 1, 1),
      );

      expect(rollup.totalValue, 3.0);
      expect(rollup.eventCount, 2);
      expect(rollup.date, '2025-01-01');
      expect(rollup.firstEventAt, DateTime(2025, 1, 1, 10, 0));
      expect(rollup.lastEventAt, DateTime(2025, 1, 1, 15, 0));
    });

    test('caches and reuses daily rollup', () async {
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 0),
      );

      // First call computes
      final rollup1 = await analyticsService.getDailyRollup(
        accountId: 'test-account',
        date: DateTime(2025, 1, 1),
      );

      // Second call should use cache
      final rollup2 = await analyticsService.getDailyRollup(
        accountId: 'test-account',
        date: DateTime(2025, 1, 1),
      );

      expect(rollup1.id, rollup2.id);
      expect(rollup1.sourceRangeHash, rollup2.sourceRangeHash);
    });

    test('recomputes rollup when forced', () async {
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 0),
      );

      final rollup1 = await analyticsService.getDailyRollup(
        accountId: 'test-account',
        date: DateTime(2025, 1, 1),
      );

      // Add more data
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 2.0,
        eventAt: DateTime(2025, 1, 1, 15, 0),
      );

      // Force recompute
      final rollup2 = await analyticsService.getDailyRollup(
        accountId: 'test-account',
        date: DateTime(2025, 1, 1),
        forceRecompute: true,
      );

      expect(rollup2.eventCount, 2);
      expect(rollup2.totalValue, 3.0);
    });
  });

  group('AnalyticsService - RangeQuerySpec', () {
    test('creates today range correctly', () {
      final spec = RangeQuerySpec.today();

      final now = DateTime.now();
      expect(spec.startAt.year, now.year);
      expect(spec.startAt.month, now.month);
      expect(spec.startAt.day, now.day);
      expect(spec.startAt.hour, 0);
      expect(spec.rangeType, RangeType.today);
      expect(spec.groupBy, GroupBy.hour);
    });

    test('creates week range correctly', () {
      final spec = RangeQuerySpec.week();

      expect(spec.rangeType, RangeType.week);
      expect(spec.groupBy, GroupBy.day);
      expect(spec.durationInDays, greaterThanOrEqualTo(6));
    });

    test('creates custom range correctly', () {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 31);

      final spec = RangeQuerySpec.custom(
        startAt: start,
        endAt: end,
        groupBy: GroupBy.week,
        eventTypes: [EventType.inhale],
        minValue: 1.0,
        maxValue: 10.0,
      );

      expect(spec.startAt, start);
      expect(spec.endAt, end);
      expect(spec.groupBy, GroupBy.week);
      expect(spec.eventTypes, [EventType.inhale]);
      expect(spec.minValue, 1.0);
      expect(spec.maxValue, 10.0);
      expect(spec.durationInDays, 30);
    });

    test('checks if date is within range', () {
      final spec = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 1, 31),
      );

      expect(spec.containsDate(DateTime(2025, 1, 15)), true);
      expect(spec.containsDate(DateTime(2024, 12, 31)), false);
      expect(spec.containsDate(DateTime(2025, 2, 1)), false);
    });
  });
}
