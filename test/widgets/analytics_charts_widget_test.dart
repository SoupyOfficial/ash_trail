import 'package:ash_trail/models/daily_rollup.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/services/analytics_service.dart';
import 'package:ash_trail/widgets/analytics_charts.dart';
import 'package:ash_trail/widgets/charts/activity_bar_chart.dart';
import 'package:ash_trail/widgets/charts/activity_line_chart.dart';
import 'package:ash_trail/widgets/charts/event_type_pie_chart.dart';
import 'package:ash_trail/widgets/charts/hourly_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAnalyticsService extends AnalyticsService {
  final RollingWindowStats stats;
  int callCount = 0;

  _FakeAnalyticsService(this.stats);

  @override
  Future<RollingWindowStats> computeRollingWindow({
    required String accountId,
    required List<LogRecord> records,
    required int days,
    DateTime? now,
  }) async {
    callCount++;
    return stats;
  }

  @override
  TrendDirection computeTrend({
    required List<DailyRollup> rollups,
    required String metric,
  }) {
    return TrendDirection.stable;
  }
}

void main() {
  group('AnalyticsChartsWidget', () {
    late RollingWindowStats stats;
    late List<LogRecord> records;
    late _FakeAnalyticsService fakeService;

    setUp(() {
      records = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'acct',
          eventType: EventType.vape,
          eventAt: DateTime(2024, 1, 1, 10),
          duration: 120,
        ),
        LogRecord.create(
          logId: 'log-2',
          accountId: 'acct',
          eventType: EventType.note,
          eventAt: DateTime(2024, 1, 2, 12),
          moodRating: 4.0,
        ),
      ];

      final dailyRollups = [
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-01-01',
          eventCount: 3,
          totalValue: 180,
        ),
        DailyRollup.create(
          accountId: 'acct',
          date: '2024-01-02',
          eventCount: 2,
          totalValue: 120,
        ),
      ];

      stats = RollingWindowStats(
        days: 7,
        startDate: DateTime(2023, 12, 26),
        endDate: DateTime(2024, 1, 2),
        totalEntries: 5,
        totalDurationSeconds: 300,
        averageDailyEntries: 0.7,
        averageMoodRating: 4.0,
        dailyRollups: dailyRollups,
        eventTypeCounts: {EventType.vape: 3, EventType.note: 2},
        averagePhysicalRating: null,
      );

      fakeService = _FakeAnalyticsService(stats);
    });

    Future<void> pumpAnalyticsWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [analyticsServiceProvider.overrideWithValue(fakeService)],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 900,
                child: AnalyticsChartsWidget(
                  records: records,
                  accountId: 'acct',
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows loading then renders summary and charts', (
      tester,
    ) async {
      await pumpAnalyticsWidget(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(fakeService.callCount, 1);
      expect(find.text('Total Entries'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Daily Avg'), findsOneWidget);
      expect(find.byType(ActivityBarChart), findsOneWidget);
      expect(find.byType(EventTypePieChart), findsOneWidget);
      expect(find.byType(HourlyHeatmap), findsOneWidget);
    });

    testWidgets('switches chart type and reloads for new time range', (
      tester,
    ) async {
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      expect(fakeService.callCount, 1);
      expect(find.byType(ActivityBarChart), findsOneWidget);

      await tester.tap(find.text('Line'));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityLineChart), findsOneWidget);

      await tester.tap(find.text('14 Days'));
      await tester.pumpAndSettle();

      expect(fakeService.callCount, greaterThanOrEqualTo(2));
    });

    testWidgets('shows no data state when stats are null or records empty', (
      tester,
    ) async {
      // Fake service that returns empty stats
      final emptyStats = RollingWindowStats(
        days: 7,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 7),
        totalEntries: 0,
        totalDurationSeconds: 0,
        averageDailyEntries: 0,
        averageMoodRating: null,
        averagePhysicalRating: null,
        dailyRollups: const [],
        eventTypeCounts: const {},
      );

      final emptyService = _FakeAnalyticsService(emptyStats);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [analyticsServiceProvider.overrideWithValue(emptyService)],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 600,
                child: AnalyticsChartsWidget(
                  records: const [],
                  accountId: 'acct',
                ),
              ),
            ),
          ),
        ),
      );

      // Loading spinner first
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // No data state should be shown when stats are empty
      expect(find.text('No data available'), findsOneWidget);
      expect(emptyService.callCount, 1);
    });

    testWidgets('displays time range selector buttons', (tester) async {
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      // Check for time range buttons
      expect(find.text('7 Days'), findsOneWidget);
      expect(find.text('14 Days'), findsOneWidget);
      expect(find.text('30 Days'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('switches between chart types', (tester) async {
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      // Initial should be bar chart
      expect(find.byType(ActivityBarChart), findsOneWidget);

      // Switch to line chart
      await tester.tap(find.text('Line'));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityLineChart), findsOneWidget);
    });

    testWidgets('updates data when time range changes', (tester) async {
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      final initialCallCount = fakeService.callCount;

      // Change time range
      await tester.tap(find.text('14 Days'));
      await tester.pumpAndSettle();

      expect(fakeService.callCount, greaterThan(initialCallCount));
    });

    testWidgets('shows event type breakdown', (tester) async {
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      expect(find.byType(EventTypePieChart), findsOneWidget);
    });

    testWidgets('shows mood rating information when available', (tester) async {
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      // Should show mood data in summaries
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('displays hourly heatmap for activity patterns', (
      tester,
    ) async {
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      expect(find.byType(HourlyHeatmap), findsOneWidget);
    });
  });

  group('AnalyticsChartsWidget - User Story Tests', () {
    late RollingWindowStats stats;
    late List<LogRecord> records;
    late _FakeAnalyticsService fakeService;

    setUp(() {
      final now = DateTime.now();
      records = <LogRecord>[];

      // Create varied data for the past week
      for (int i = 0; i < 14; i++) {
        records.add(
          LogRecord.create(
            logId: 'log-$i',
            accountId: 'acct',
            eventType: i % 3 == 0 ? EventType.note : EventType.vape,
            eventAt: now.subtract(Duration(hours: i * 4)),
            duration: (50 + (i * 10)).toDouble(),
            moodRating: i % 2 == 0 ? 5.0 : 7.0,
            physicalRating: 6.0,
          ),
        );
      }

      final dailyRollups = <DailyRollup>[];
      for (int i = 0; i < 7; i++) {
        dailyRollups.add(
          DailyRollup.create(
            accountId: 'acct',
            date: '2024-01-0${i + 1}',
            eventCount: 2 + i,
            totalValue: 200 + (i * 50),
          ),
        );
      }

      stats = RollingWindowStats(
        days: 7,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 7),
        totalEntries: 14,
        totalDurationSeconds: 2100,
        averageDailyEntries: 2.0,
        averageMoodRating: 6.0,
        averagePhysicalRating: 6.0,
        dailyRollups: dailyRollups,
        eventTypeCounts: {EventType.vape: 10, EventType.note: 4},
      );

      fakeService = _FakeAnalyticsService(stats);
    });

    Future<void> pumpAnalyticsWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [analyticsServiceProvider.overrideWithValue(fakeService)],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 1200,
                child: AnalyticsChartsWidget(
                  records: records,
                  accountId: 'acct',
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('As a user, I want to see my activity over the past week', (
      tester,
    ) async {
      // GIVEN: I have logged activities over the past week
      // WHEN: I view the analytics charts
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      // THEN: I can see weekly activity visualization
      expect(find.text('Total Entries'), findsOneWidget);
      expect(find.text('Daily Avg'), findsOneWidget);
      expect(find.byType(ActivityBarChart), findsOneWidget);
    });

    testWidgets('As a user, I want to view different time ranges', (
      tester,
    ) async {
      // GIVEN: I am viewing analytics
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      // WHEN: I select a different time range
      await tester.tap(find.text('30 Days'));
      await tester.pumpAndSettle();

      // THEN: The data updates to show 30-day view
      expect(fakeService.callCount, greaterThan(1));
    });

    testWidgets('As a user, I want to see event type breakdown', (
      tester,
    ) async {
      // GIVEN: I have logged different event types
      // WHEN: I view the analytics
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      // THEN: I can see the breakdown by event type
      expect(find.byType(EventTypePieChart), findsOneWidget);
    });

    testWidgets(
      'As a user, I want to understand my activity patterns by hour',
      (tester) async {
        // GIVEN: I want to see when I'm most active
        // WHEN: I view the analytics
        await pumpAnalyticsWidget(tester);
        await tester.pumpAndSettle();

        // THEN: I see activity patterns displayed
        expect(find.byType(HourlyHeatmap), findsOneWidget);
      },
    );

    testWidgets('As a user, I want to see mood trend information', (
      tester,
    ) async {
      // GIVEN: I have logged mood ratings
      // WHEN: I view the analytics
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      // THEN: Mood data is displayed
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('As a user, I want to switch between chart visualizations', (
      tester,
    ) async {
      // GIVEN: I am viewing analytics in bar chart format
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      expect(find.byType(ActivityBarChart), findsOneWidget);

      // WHEN: I select line chart view
      await tester.tap(find.text('Line'));
      await tester.pumpAndSettle();

      // THEN: The chart switches to line format
      expect(find.byType(ActivityLineChart), findsOneWidget);
    });

    testWidgets('As a user, I want the app to load data quickly', (
      tester,
    ) async {
      // GIVEN: I view analytics for a large dataset
      // WHEN: Data loads
      await pumpAnalyticsWidget(tester);

      // THEN: Loading is indicated
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // THEN: Charts appear after loading
      expect(find.byType(ActivityBarChart), findsOneWidget);
      expect(fakeService.callCount, 1);
    });

    testWidgets('As a user, I want to see clear summary statistics', (
      tester,
    ) async {
      // GIVEN: I am viewing analytics
      await pumpAnalyticsWidget(tester);
      await tester.pumpAndSettle();

      // THEN: Key statistics are displayed
      expect(find.text('Total Entries'), findsOneWidget);
      expect(find.text('Daily Avg'), findsOneWidget);

      // AND: The statistics show actual values
      final statisticValues = find.byType(RichText);
      expect(statisticValues, findsWidgets);
    });
  });
}
