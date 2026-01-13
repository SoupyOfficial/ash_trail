import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/account.dart';
import 'package:flutter_test/flutter_test.dart';

/// Data-Driven User Persona Tests
/// Tests focused on analytics, aggregations, and trend detection

Account _buildAccount({
  String userId = 'data-user-1',
  String displayName = 'Data-Driven User',
}) {
  return Account.create(
    userId: userId,
    displayName: displayName,
    email: 'data@example.com',
  );
}

List<LogRecord> _makeRecords({
  required Account account,
  required DateTime startDate,
  int count = 5,
  double? moodRating,
  double? physicalRating,
}) {
  return List.generate(
    count,
    (i) => LogRecord.create(
      logId: 'record-$i',
      accountId: account.userId,
      eventAt: startDate.subtract(Duration(hours: i)),
      eventType: EventType.vape,
      duration: 60 + (i * 15), // 60, 75, 90, 105, 120
      unit: Unit.seconds,
      moodRating: moodRating,
      physicalRating: physicalRating,
    ),
  );
}

void main() {
  group('Data-Driven User - Analytics and Aggregation', () {
    test('calculates total duration from multiple records', () {
      final account = _buildAccount();
      final now = DateTime.now();
      final records = _makeRecords(account: account, startDate: now, count: 4);

      final totalDuration = records.fold<double>(
        0,
        (sum, record) => sum + record.duration,
      );

      // 60 + 75 + 90 + 105 = 330
      expect(totalDuration, 330.0);
    });

    test('counts total number of log entries', () {
      final account = _buildAccount();
      final now = DateTime.now();
      final records = _makeRecords(account: account, startDate: now, count: 7);

      expect(records.length, 7);
      expect(records.where((r) => r.accountId == account.userId).length, 7);
    });

    test('aggregates mood ratings across records', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final moodRecords = [
        LogRecord.create(
          logId: 'mood-1',
          accountId: account.userId,
          eventAt: now,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
          moodRating: 7.0,
        ),
        LogRecord.create(
          logId: 'mood-2',
          accountId: account.userId,
          eventAt: now,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
          moodRating: 5.0,
        ),
        LogRecord.create(
          logId: 'mood-3',
          accountId: account.userId,
          eventAt: now,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
          moodRating: 8.0,
        ),
      ];

      final moodRatings =
          moodRecords
              .where((r) => r.moodRating != null)
              .map((r) => r.moodRating!)
              .toList();

      final avgMood =
          moodRatings.isNotEmpty
              ? moodRatings.reduce((a, b) => a + b) / moodRatings.length
              : 0.0;

      expect(moodRatings, [7.0, 5.0, 8.0]);
      expect(avgMood, closeTo(6.67, 0.01));
    });

    test('aggregates physical ratings across records', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final physicalRecords = [
        LogRecord.create(
          logId: 'phys-1',
          accountId: account.userId,
          eventAt: now,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
          physicalRating: 6.0,
        ),
        LogRecord.create(
          logId: 'phys-2',
          accountId: account.userId,
          eventAt: now,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
          physicalRating: 7.0,
        ),
        LogRecord.create(
          logId: 'phys-3',
          accountId: account.userId,
          eventAt: now,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
          physicalRating: 8.0,
        ),
      ];

      final physicalRatings =
          physicalRecords
              .where((r) => r.physicalRating != null)
              .map((r) => r.physicalRating!)
              .toList();

      final avgPhysical =
          physicalRatings.isNotEmpty
              ? physicalRatings.reduce((a, b) => a + b) / physicalRatings.length
              : 0.0;

      expect(physicalRatings, [6.0, 7.0, 8.0]);
      expect(avgPhysical, 7.0);
    });

    test('filters records by event type', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final mixedRecords = [
        LogRecord.create(
          logId: 'vape-1',
          accountId: account.userId,
          eventAt: now,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: 'inhale-1',
          accountId: account.userId,
          eventAt: now,
          eventType: EventType.inhale,
          duration: 5,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: 'vape-2',
          accountId: account.userId,
          eventAt: now,
          eventType: EventType.vape,
          duration: 8,
          unit: Unit.seconds,
        ),
      ];

      final vapeOnly =
          mixedRecords.where((r) => r.eventType == EventType.vape).toList();

      expect(vapeOnly, hasLength(2));
      expect(vapeOnly.map((r) => r.logId).toList(), ['vape-1', 'vape-2']);
    });

    test('supports date range filtering', () {
      final account = _buildAccount();
      final today = DateTime(2024, 1, 15);
      final yesterday = DateTime(2024, 1, 14);
      final lastWeek = DateTime(2024, 1, 8);

      final records = [
        LogRecord.create(
          logId: 'today-1',
          accountId: account.userId,
          eventAt: today,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: 'yesterday-1',
          accountId: account.userId,
          eventAt: yesterday,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: 'lastweek-1',
          accountId: account.userId,
          eventAt: lastWeek,
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
        ),
      ];

      final todayOnly =
          records.where((r) => r.eventAt.day == today.day).toList();

      expect(todayOnly, hasLength(1));
      expect(todayOnly.first.logId, 'today-1');
    });

    test('calculates statistics for empty record sets', () {
      final emptyRecords = <LogRecord>[];

      final totalDuration = emptyRecords.fold<double>(
        0,
        (sum, record) => sum + record.duration,
      );

      expect(totalDuration, 0.0);
      expect(emptyRecords.length, 0);
    });

    test('handles edge case with midnight boundary', () {
      final account = _buildAccount();
      final midnight = DateTime(2024, 1, 15, 0, 0, 0);
      final oneSecondBefore = midnight.subtract(const Duration(seconds: 1));
      final oneSecondAfter = midnight.add(const Duration(seconds: 1));

      final beforeRecord = LogRecord.create(
        logId: 'before',
        accountId: account.userId,
        eventAt: oneSecondBefore,
        eventType: EventType.vape,
        duration: 10,
        unit: Unit.seconds,
      );

      final afterRecord = LogRecord.create(
        logId: 'after',
        accountId: account.userId,
        eventAt: oneSecondAfter,
        eventType: EventType.vape,
        duration: 10,
        unit: Unit.seconds,
      );

      expect(beforeRecord.eventAt.isBefore(midnight), true);
      expect(afterRecord.eventAt.isAfter(midnight), true);
    });
  });
}
