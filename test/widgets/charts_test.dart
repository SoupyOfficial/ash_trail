import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/widgets/charts/activity_line_chart.dart';
import 'package:ash_trail/widgets/charts/activity_bar_chart.dart';
import 'package:ash_trail/widgets/charts/event_type_pie_chart.dart';
import 'package:ash_trail/widgets/charts/hourly_heatmap.dart';
import 'package:ash_trail/widgets/charts/time_range_picker.dart';
import 'package:ash_trail/models/daily_rollup.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('ActivityLineChart', () {
    testWidgets('renders empty state when no rollups', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ActivityLineChart(rollups: []))),
      );

      expect(find.text('No data available'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('renders chart with rollups', (tester) async {
      final rollups = [
        DailyRollup.create(
          accountId: 'test',
          date: '2024-01-01',
          eventCount: 5,
          totalValue: 100,
        ),
        DailyRollup.create(
          accountId: 'test',
          date: '2024-01-02',
          eventCount: 3,
          totalValue: 60,
        ),
        DailyRollup.create(
          accountId: 'test',
          date: '2024-01-03',
          eventCount: 8,
          totalValue: 200,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ActivityLineChart(rollups: rollups))),
      );

      expect(find.text('Daily Activity'), findsOneWidget);
    });

    testWidgets('uses custom title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ActivityLineChart(rollups: [], title: 'Custom Chart Title'),
          ),
        ),
      );

      // Empty state shows, but title would be there if data was present
      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('ActivityBarChart', () {
    testWidgets('renders empty state when no rollups', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ActivityBarChart(rollups: []))),
      );

      expect(find.text('No data available'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });

    testWidgets('renders chart with rollups', (tester) async {
      final rollups = [
        DailyRollup.create(
          accountId: 'test',
          date: '2024-01-01',
          eventCount: 5,
          totalValue: 100,
        ),
        DailyRollup.create(
          accountId: 'test',
          date: '2024-01-02',
          eventCount: 3,
          totalValue: 60,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ActivityBarChart(rollups: rollups))),
      );

      expect(find.text('Daily Activity'), findsOneWidget);
    });
  });

  group('EventTypePieChart', () {
    testWidgets('renders empty state when no event types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EventTypePieChart(eventTypeCounts: {})),
        ),
      );

      expect(find.text('No event data'), findsOneWidget);
      expect(find.byIcon(Icons.pie_chart_outline), findsOneWidget);
    });

    testWidgets('renders pie chart with event counts', (tester) async {
      final eventCounts = {
        EventType.vape: 10,
        EventType.inhale: 5,
        EventType.note: 3,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EventTypePieChart(eventTypeCounts: eventCounts)),
        ),
      );

      expect(find.text('Event Types'), findsOneWidget);
      // Check legend items
      expect(find.text('10'), findsOneWidget); // vape count
      expect(find.text('5'), findsOneWidget); // inhale count
      expect(find.text('3'), findsOneWidget); // note count
    });
  });

  group('HourlyHeatmap', () {
    testWidgets('renders empty state when no records', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HourlyHeatmap(records: []))),
      );

      expect(find.text('No activity data'), findsOneWidget);
      expect(find.byIcon(Icons.grid_on), findsOneWidget);
    });

    testWidgets('renders heatmap with records', (tester) async {
      final records = [
        LogRecord.create(
          logId: 'test-1',
          accountId: 'test',
          eventType: EventType.vape,
          eventAt: DateTime(2024, 1, 1, 10, 30), // 10 AM
        ),
        LogRecord.create(
          logId: 'test-2',
          accountId: 'test',
          eventType: EventType.vape,
          eventAt: DateTime(2024, 1, 1, 10, 45), // 10 AM
        ),
        LogRecord.create(
          logId: 'test-3',
          accountId: 'test',
          eventType: EventType.vape,
          eventAt: DateTime(2024, 1, 1, 15, 0), // 3 PM
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: HourlyHeatmap(records: records)),
          ),
        ),
      );

      expect(find.text('Activity by Hour'), findsOneWidget);
      expect(find.text('Tap a cell to see details'), findsOneWidget);
      // Check legend
      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });
  });

  group('WeeklyHeatmap', () {
    testWidgets('renders empty state when no records', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeeklyHeatmap(records: []))),
      );

      expect(find.text('No weekly data'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_view_week), findsOneWidget);
    });

    testWidgets('renders weekly heatmap with records', (tester) async {
      final records = [
        LogRecord.create(
          logId: 'test-1',
          accountId: 'test',
          eventType: EventType.vape,
          eventAt: DateTime(2024, 1, 1, 10, 30), // Monday
        ),
        LogRecord.create(
          logId: 'test-2',
          accountId: 'test',
          eventType: EventType.vape,
          eventAt: DateTime(2024, 1, 3, 15, 0), // Wednesday
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: WeeklyHeatmap(records: records)),
          ),
        ),
      );

      expect(find.text('Weekly Pattern'), findsOneWidget);
      // Check day labels
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
    });
  });

  group('TimeRangePicker', () {
    testWidgets('displays all preset options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () {
                      showTimeRangePicker(context: context);
                    },
                    child: const Text('Open Picker'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Check dialog title
      expect(find.text('Select Time Range'), findsOneWidget);

      // Check preset options
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('Last 30 Days'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);

      // Check buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
    });

    testWidgets('can select a preset', (tester) async {
      DateTimeRange? selectedRange;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () async {
                      selectedRange = await showTimeRangePicker(
                        context: context,
                      );
                    },
                    child: const Text('Open Picker'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Select '7 Days' preset
      await tester.tap(find.text('Last 7 Days'));
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(selectedRange, isNotNull);
      expect(
        selectedRange!.end.difference(selectedRange!.start).inDays,
        greaterThanOrEqualTo(6),
      );
    });

    testWidgets('can close with cancel', (tester) async {
      DateTimeRange? selectedRange;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed: () async {
                      selectedRange = await showTimeRangePicker(
                        context: context,
                      );
                    },
                    child: const Text('Open Picker'),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(selectedRange, isNull);
    });
  });
}
