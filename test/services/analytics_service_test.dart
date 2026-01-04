import 'dart:convert';

import 'package:ash_trail/models/daily_rollup.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = AnalyticsService();

  group('computeDailyRollup', () {
    test(
      'aggregates records for a single day and ignores deleted/out-of-range',
      () async {
        final date = DateTime(2024, 1, 1);
        final records = [
          LogRecord.create(
            logId: 'a',
            accountId: 'acct',
            eventAt: DateTime(2024, 1, 1, 10),
            eventType: EventType.vape,
            duration: 60,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'b',
            accountId: 'acct',
            eventAt: DateTime(2024, 1, 1, 15),
            eventType: EventType.note,
            duration: 2,
            unit: Unit.minutes,
          ),
          LogRecord.create(
            logId: 'c',
            accountId: 'acct',
            eventAt: DateTime(2024, 1, 1, 23, 30),
            eventType: EventType.inhale,
            duration: 30,
          ),
          // Outside day window
          LogRecord.create(
            logId: 'd',
            accountId: 'acct',
            eventAt: DateTime(2024, 1, 2, 1),
            eventType: EventType.vape,
          ),
          // Deleted within day
          LogRecord.create(
            logId: 'e',
            accountId: 'acct',
            eventAt: DateTime(2024, 1, 1, 9),
            eventType: EventType.vape,
            isDeleted: true,
          ),
        ];

        final rollup = await service.computeDailyRollup(
          accountId: 'acct',
          date: date,
          records: records,
        );

        expect(rollup.date, '2024-01-01');
        expect(rollup.eventCount, 3);
        expect(rollup.totalValue, 210); // 60s + 2m (120s) + 30s
        expect(rollup.firstEventAt, DateTime(2024, 1, 1, 10));
        expect(rollup.lastEventAt, DateTime(2024, 1, 1, 23, 30));

        final breakdown = jsonDecode(rollup.eventTypeBreakdownJson!);
        expect(breakdown['vape'], 1);
        expect(breakdown['note'], 1);
        expect(breakdown['inhale'], 1);
      },
    );

    test('returns empty aggregates when no records in range', () async {
      final date = DateTime(2024, 1, 1);
      final records = [
        LogRecord.create(
          logId: 'ignored',
          accountId: 'acct',
          eventAt: DateTime(2024, 1, 2, 1),
          eventType: EventType.vape,
        ),
        LogRecord.create(
          logId: 'deleted',
          accountId: 'acct',
          eventAt: DateTime(2024, 1, 1, 9),
          eventType: EventType.vape,
          isDeleted: true,
        ),
      ];

      final rollup = await service.computeDailyRollup(
        accountId: 'acct',
        date: date,
        records: records,
      );

      expect(rollup.eventCount, 0);
      expect(rollup.totalValue, 0);
      expect(rollup.firstEventAt, isNull);
      expect(rollup.lastEventAt, isNull);

      final breakdown = jsonDecode(rollup.eventTypeBreakdownJson!);
      expect(breakdown, isEmpty);
    });
  });

  group('computeRollingWindow', () {
    test(
      'uses provided reference date and filters records within window',
      () async {
        final now = DateTime(2024, 1, 10, 12);
        final records = [
          LogRecord.create(
            logId: 'r1',
            accountId: 'acct',
            eventAt: DateTime(2024, 1, 3, 8),
            eventType: EventType.vape,
            duration: 60,
          ),
          LogRecord.create(
            logId: 'r2',
            accountId: 'acct',
            eventAt: DateTime(2024, 1, 5, 12),
            eventType: EventType.note,
            duration: 120,
          ),
          LogRecord.create(
            logId: 'r3',
            accountId: 'acct',
            eventAt: DateTime(2024, 1, 9, 18),
            eventType: EventType.inhale,
            duration: 240,
          ),
          LogRecord.create(
            logId: 'old',
            accountId: 'acct',
            eventAt: DateTime(2023, 12, 30),
            eventType: EventType.vape,
          ),
          LogRecord.create(
            logId: 'deleted',
            accountId: 'acct',
            eventAt: DateTime(2024, 1, 4),
            eventType: EventType.vape,
            isDeleted: true,
          ),
        ];

        final stats = await service.computeRollingWindow(
          accountId: 'acct',
          records: records,
          days: 7,
          now: now,
        );

        expect(stats.days, 7);
        expect(stats.startDate, DateTime(2024, 1, 3));
        expect(stats.endDate, now);
        expect(stats.totalEntries, 3);
        expect(stats.totalDurationSeconds, 420);
        expect(stats.averageDailyEntries, closeTo(0.42, 0.01));
        expect(stats.eventTypeCounts[EventType.vape], 1);
        expect(stats.eventTypeCounts[EventType.note], 1);
        expect(stats.eventTypeCounts[EventType.inhale], 1);
        expect(stats.dailyRollups, hasLength(7));
        expect(stats.dailyRollups.first.date, '2024-01-03');
        expect(stats.dailyRollups.last.date, '2024-01-09');
      },
    );

    test('handles empty input gracefully', () async {
      final now = DateTime(2024, 1, 10);

      final stats = await service.computeRollingWindow(
        accountId: 'acct',
        records: const [],
        days: 7,
        now: now,
      );

      expect(stats.totalEntries, 0);
      expect(stats.totalDurationSeconds, 0);
      expect(stats.averageDailyEntries, 0);
      expect(stats.averageMoodRating, isNull);
      expect(stats.averagePhysicalRating, isNull);
      expect(stats.dailyRollups, hasLength(7));
      expect(stats.eventTypeCounts, isEmpty);
      expect(stats.startDate, DateTime(2024, 1, 3));
      expect(stats.endDate, now);
    });
  });

  group('last stats helpers', () {
    test('getLast7DaysStats delegates to rolling window with 7 days', () async {
      var calledDays = 0;

      final service = _SpyAnalyticsService(
        onCompute: (days) {
          calledDays = days;
          return Future.value(
            RollingWindowStats(
              days: days,
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 1, 7),
              totalEntries: 0,
              totalDurationSeconds: 0,
              averageDailyEntries: 0,
              averageMoodRating: null,
              averagePhysicalRating: null,
              dailyRollups: const [],
              eventTypeCounts: const {},
            ),
          );
        },
      );

      await service.getLast7DaysStats(accountId: 'acct', records: const []);

      expect(calledDays, 7);
    });

    test(
      'getLast30DaysStats delegates to rolling window with 30 days',
      () async {
        var calledDays = 0;

        final service = _SpyAnalyticsService(
          onCompute: (days) {
            calledDays = days;
            return Future.value(
              RollingWindowStats(
                days: days,
                startDate: DateTime(2024, 1, 1),
                endDate: DateTime(2024, 1, 30),
                totalEntries: 0,
                totalDurationSeconds: 0,
                averageDailyEntries: 0,
                averageMoodRating: null,
                averagePhysicalRating: null,
                dailyRollups: const [],
                eventTypeCounts: const {},
              ),
            );
          },
        );

        await service.getLast30DaysStats(accountId: 'acct', records: const []);

        expect(calledDays, 30);
      },
    );
  });

  group('computeTrend', () {
    test('detects up, down, and stable trends', () {
      final up = [
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-01-01',
          eventCount: 1,
          totalValue: 10,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-01-02',
          eventCount: 3,
          totalValue: 30,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-01-03',
          eventCount: 5,
          totalValue: 50,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-01-04',
          eventCount: 6,
          totalValue: 60,
        ),
      ];

      final down = [
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-02-01',
          eventCount: 8,
          totalValue: 80,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-02-02',
          eventCount: 7,
          totalValue: 70,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-02-03',
          eventCount: 3,
          totalValue: 30,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-02-04',
          eventCount: 1,
          totalValue: 10,
        ),
      ];

      final stable = [
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-03-01',
          eventCount: 2,
          totalValue: 20,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-03-02',
          eventCount: 2,
          totalValue: 22,
        ),
      ];

      expect(
        service.computeTrend(rollups: up, metric: 'entries'),
        TrendDirection.up,
      );
      expect(
        service.computeTrend(rollups: down, metric: 'duration'),
        TrendDirection.down,
      );
      expect(
        service.computeTrend(rollups: stable, metric: 'entries'),
        TrendDirection.stable,
      );
      expect(
        service.computeTrend(
          rollups: stable.take(1).toList(),
          metric: 'entries',
        ),
        TrendDirection.stable,
      );
    });

    test('returns stable for mood metric and single rollup', () {
      final single = [
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-04-01',
          eventCount: 2,
          totalValue: 20,
        ),
      ];

      expect(
        service.computeTrend(rollups: single, metric: 'entries'),
        TrendDirection.stable,
      );

      expect(
        service.computeTrend(rollups: single, metric: 'mood'),
        TrendDirection.stable,
      );
    });

    test('treats small percent changes as stable', () {
      final slightChange = [
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-05-01',
          eventCount: 10,
          totalValue: 100,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-05-02',
          eventCount: 10,
          totalValue: 105,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-05-03',
          eventCount: 11,
          totalValue: 102,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-05-04',
          eventCount: 10,
          totalValue: 101,
        ),
      ];

      expect(
        service.computeTrend(rollups: slightChange, metric: 'entries'),
        TrendDirection.stable,
      );
    });
  });
}

class _SpyAnalyticsService extends AnalyticsService {
  _SpyAnalyticsService({required this.onCompute});

  final Future<RollingWindowStats> Function(int days) onCompute;

  @override
  Future<RollingWindowStats> computeRollingWindow({
    required String accountId,
    required List<LogRecord> records,
    required int days,
    DateTime? now,
  }) {
    return onCompute(days);
  }
}
