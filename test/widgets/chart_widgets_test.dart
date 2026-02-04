import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/widgets/charts/activity_bar_chart.dart';
import 'package:ash_trail/widgets/charts/event_type_pie_chart.dart';
import 'package:ash_trail/widgets/charts/hourly_heatmap.dart';
import 'package:ash_trail/models/daily_rollup.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  /// Helper to create test DailyRollup with required fields
  DailyRollup createTestRollup({
    String accountId = 'test-account',
    required String date,
    int eventCount = 0,
    double totalValue = 0,
  }) {
    return DailyRollup.create(
      accountId: accountId,
      date: date,
      eventCount: eventCount,
      totalValue: totalValue,
    );
  }

  /// Helper to create test LogRecord
  LogRecord createTestLogRecord({
    required String logId,
    String accountId = 'test-account',
    required DateTime eventAt,
    EventType eventType = EventType.vape,
  }) {
    return LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventAt: eventAt,
      eventType: eventType,
    );
  }

  group('ActivityBarChart', () {
    testWidgets('renders empty state when no rollups', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ActivityBarChart(rollups: []),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('renders chart with data', (tester) async {
      final List<DailyRollup> rollups = [
        createTestRollup(date: '2024-06-01', eventCount: 5, totalValue: 100),
        createTestRollup(date: '2024-06-02', eventCount: 3, totalValue: 60),
        createTestRollup(date: '2024-06-03', eventCount: 8, totalValue: 150),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityBarChart(rollups: rollups),
          ),
        ),
      );

      expect(find.byType(ActivityBarChart), findsOneWidget);
      expect(find.text('No data available'), findsNothing);
    });

    testWidgets('displays chart title', (tester) async {
      final List<DailyRollup> rollups = [
        createTestRollup(date: '2024-06-01', eventCount: 5, totalValue: 100),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityBarChart(rollups: rollups),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles single day of data', (tester) async {
      final List<DailyRollup> rollups = [
        createTestRollup(date: '2024-06-01', eventCount: 10, totalValue: 200),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityBarChart(rollups: rollups),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles large dataset', (tester) async {
      final List<DailyRollup> rollups = List.generate(
        30,
        (i) => createTestRollup(
          date: '2024-06-${(i + 1).toString().padLeft(2, '0')}',
          eventCount: (i + 1) * 2,
          totalValue: (i + 1) * 50.0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ActivityBarChart(rollups: rollups),
            ),
          ),
        ),
      );

      expect(find.byType(ActivityBarChart), findsOneWidget);
    });

    testWidgets('handles zero values in data', (tester) async {
      final List<DailyRollup> rollups = [
        createTestRollup(date: '2024-06-01', eventCount: 0, totalValue: 0),
        createTestRollup(date: '2024-06-02', eventCount: 5, totalValue: 100),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityBarChart(rollups: rollups),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('EventTypePieChart', () {
    testWidgets('renders empty state when no data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EventTypePieChart(eventTypeCounts: {}),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('No event data'), findsOneWidget);
    });

    testWidgets('renders pie chart with data', (tester) async {
      const eventTypeCounts = {
        EventType.vape: 10,
        EventType.inhale: 5,
        EventType.note: 3,
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EventTypePieChart(eventTypeCounts: eventTypeCounts),
          ),
        ),
      );

      expect(find.byType(EventTypePieChart), findsOneWidget);
      expect(find.text('No data available'), findsNothing);
    });

    testWidgets('handles single event type', (tester) async {
      const eventTypeCounts = {
        EventType.vape: 15,
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EventTypePieChart(eventTypeCounts: eventTypeCounts),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles many event types', (tester) async {
      const eventTypeCounts = {
        EventType.vape: 10,
        EventType.inhale: 8,
        EventType.sessionStart: 5,
        EventType.sessionEnd: 5,
        EventType.note: 3,
        EventType.purchase: 2,
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EventTypePieChart(eventTypeCounts: eventTypeCounts),
          ),
        ),
      );

      expect(find.byType(EventTypePieChart), findsOneWidget);
    });

    testWidgets('handles zero counts', (tester) async {
      const eventTypeCounts = {
        EventType.vape: 10,
        EventType.inhale: 0,
        EventType.note: 5,
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EventTypePieChart(eventTypeCounts: eventTypeCounts),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('HourlyHeatmap', () {
    testWidgets('renders empty state when no records', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HourlyHeatmap(records: []),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('No activity data'), findsOneWidget);
    });

    testWidgets('renders heatmap with data', (tester) async {
      final records = [
        createTestLogRecord(
          logId: 'log-1',
          eventAt: DateTime(2024, 6, 1, 9, 30), // 9:30 AM
        ),
        createTestLogRecord(
          logId: 'log-2',
          eventAt: DateTime(2024, 6, 1, 14, 0), // 2:00 PM
        ),
        createTestLogRecord(
          logId: 'log-3',
          eventAt: DateTime(2024, 6, 1, 21, 15), // 9:15 PM
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HourlyHeatmap(records: records),
          ),
        ),
      );

      expect(find.byType(HourlyHeatmap), findsOneWidget);
      expect(find.text('No data available'), findsNothing);
    });

    testWidgets('handles single record', (tester) async {
      final records = [
        createTestLogRecord(
          logId: 'log-1',
          eventAt: DateTime(2024, 6, 1, 12, 0),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HourlyHeatmap(records: records),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles records at different hours', (tester) async {
      final records = List.generate(
        24,
        (hour) => createTestLogRecord(
          logId: 'log-$hour',
          eventAt: DateTime(2024, 6, 1, hour, 0),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HourlyHeatmap(records: records),
            ),
          ),
        ),
      );

      expect(find.byType(HourlyHeatmap), findsOneWidget);
    });

    testWidgets('handles multiple records in same hour', (tester) async {
      final records = [
        createTestLogRecord(
          logId: 'log-1',
          eventAt: DateTime(2024, 6, 1, 14, 0),
        ),
        createTestLogRecord(
          logId: 'log-2',
          eventAt: DateTime(2024, 6, 1, 14, 15),
        ),
        createTestLogRecord(
          logId: 'log-3',
          eventAt: DateTime(2024, 6, 1, 14, 45),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HourlyHeatmap(records: records),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles records at midnight boundary', (tester) async {
      final records = [
        createTestLogRecord(
          logId: 'log-1',
          eventAt: DateTime(2024, 6, 1, 0, 0),
        ),
        createTestLogRecord(
          logId: 'log-2',
          eventAt: DateTime(2024, 6, 1, 23, 59),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HourlyHeatmap(records: records),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('Chart Integration', () {
    testWidgets('multiple charts render in same page', (tester) async {
      final List<DailyRollup> rollups = [
        createTestRollup(date: '2024-06-01', eventCount: 5, totalValue: 100),
      ];

      const eventTypeCounts = {
        EventType.vape: 10,
        EventType.inhale: 5,
      };

      final records = [
        createTestLogRecord(
          logId: 'log-1',
          eventAt: DateTime(2024, 6, 1, 9, 0),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ActivityBarChart(rollups: rollups),
                  const EventTypePieChart(eventTypeCounts: eventTypeCounts),
                  HourlyHeatmap(records: records),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ActivityBarChart), findsOneWidget);
      expect(find.byType(EventTypePieChart), findsOneWidget);
      expect(find.byType(HourlyHeatmap), findsOneWidget);
    });
  });

  group('Chart Edge Cases', () {
    testWidgets('ActivityBarChart handles very large values', (tester) async {
      final List<DailyRollup> rollups = [
        createTestRollup(date: '2024-06-01', eventCount: 1000000, totalValue: 99999999),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityBarChart(rollups: rollups),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('EventTypePieChart handles large counts', (tester) async {
      const eventTypeCounts = {
        EventType.vape: 999999,
        EventType.inhale: 888888,
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EventTypePieChart(eventTypeCounts: eventTypeCounts),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('HourlyHeatmap handles many records', (tester) async {
      final records = List.generate(
        100,
        (i) => createTestLogRecord(
          logId: 'log-$i',
          eventAt: DateTime(2024, 6, 1, i % 24, (i * 7) % 60),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HourlyHeatmap(records: records),
            ),
          ),
        ),
      );

      expect(find.byType(HourlyHeatmap), findsOneWidget);
    });
  });
}
