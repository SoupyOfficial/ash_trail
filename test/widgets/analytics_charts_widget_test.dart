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

    Future<void> _pumpAnalyticsWidget(WidgetTester tester) async {
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
      await _pumpAnalyticsWidget(tester);

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
      await _pumpAnalyticsWidget(tester);
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
  });
}
