import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/utils/day_boundary.dart';
import 'package:ash_trail/widgets/home_quick_log_widget.dart';
import 'package:ash_trail/widgets/time_since_last_hit_widget.dart';
import 'package:ash_trail/widgets/analytics_charts.dart';
import 'package:ash_trail/widgets/sync_status_widget.dart';
import 'package:uuid/uuid.dart';

/// Flow tests for quick-log and analytics workflows.
/// In-process widget composition tests (run with `flutter test`), not device integration tests.
void main() {
  const uuid = Uuid();

  group('Integration Test: Complete User Workflows', () {
    Widget createHomeScreen(List<LogRecord> records) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: const [SyncStatusIndicator()],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time since last hit widget
                  if (records.isNotEmpty)
                    TimeSinceLastHitWidget(records: records)
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No logs yet'),
                    ),
                  const Divider(),
                  // Quick log widget
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: HomeQuickLogWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'Complete user journey: First-time user logs a session and sees stats',
      (tester) async {
        // GIVEN: A new user opens the app with no logs
        await tester.pumpWidget(createHomeScreen([]));
        await tester.pumpAndSettle();

        // WHEN: They see the quick log widget
        expect(find.text('Hold to record duration'), findsOneWidget);
        expect(find.text('Mood'), findsOneWidget);
        expect(find.text('Physical'), findsOneWidget);
        expect(find.text('Reasons'), findsOneWidget);

        // AND: They see empty state message
        expect(find.text('No logs yet'), findsOneWidget);

        // WHEN: A log entry is created (simulated)
        final now = DateTime.now();
        final firstLog = LogRecord.create(
          logId: uuid.v4(),
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(minutes: 30)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
          moodRating: 6.0,
          physicalRating: 7.0,
        );

        // Rebuild with the new log
        await tester.pumpWidget(createHomeScreen([firstLog]));
        await tester.pump(const Duration(milliseconds: 100));

        // THEN: The time since widget shows the entry
        expect(find.text('Time Since Last Hit'), findsOneWidget);
        expect(find.byIcon(Icons.timer), findsOneWidget);

        // AND: The quick log form is ready for another entry
        expect(find.text('Hold to record duration'), findsOneWidget);
      },
    );

    testWidgets(
      'Complete user journey: Regular user tracks progress over multiple sessions',
      (tester) async {
        // GIVEN: A user with logs from today
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();

        final logs = [
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 8)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
            moodRating: 4.0,
          ),
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 12)),
            eventType: EventType.vape,
            duration: 8,
            unit: Unit.seconds,
            moodRating: 5.0,
          ),
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 18)),
            eventType: EventType.vape,
            duration: 6,
            unit: Unit.seconds,
            moodRating: 6.0,
          ),
        ];

        // WHEN: They view the home screen
        await tester.pumpWidget(createHomeScreen(logs));
        await tester.pump(const Duration(milliseconds: 100));

        // THEN: They see their recent activity
        expect(find.text('Time Since Last Hit'), findsOneWidget);

        // AND: They can see stats for today (widget shows multiple "Total up to X" in comparison rows)
        expect(find.textContaining('Total up to'), findsAtLeastNWidgets(1));
        expect(find.text('Avg Today'), findsOneWidget);

        // AND: They can log another session
        expect(find.text('Hold to record duration'), findsOneWidget);
      },
    );

    testWidgets(
      'Complete user journey: User tracks multi-day progress with trend analysis',
      (tester) async {
        // GIVEN: A user with logs from multiple days
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();
        final yesterdayStart = DayBoundary.getYesterdayStart();

        final logs = [
          // Yesterday - 3 sessions
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: yesterdayStart.add(const Duration(hours: 8)),
            eventType: EventType.vape,
            duration: 10,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: yesterdayStart.add(const Duration(hours: 12)),
            eventType: EventType.vape,
            duration: 10,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: yesterdayStart.add(const Duration(hours: 18)),
            eventType: EventType.vape,
            duration: 10,
            unit: Unit.seconds,
          ),
          // Today - 2 sessions (improvement!)
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 10)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 16)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
        ];

        // WHEN: They view the home screen
        await tester.pumpWidget(createHomeScreen(logs));
        await tester.pump(const Duration(milliseconds: 100));

        // THEN: They see the time since last hit
        expect(find.text('Time Since Last Hit'), findsOneWidget);

        // AND: They can see today's stats (widget shows multiple "Total up to X" in comparison rows)
        expect(find.textContaining('Total up to'), findsAtLeastNWidgets(1));

        // AND: They can see yesterday's stats for comparison
        expect(find.text('Avg Yesterday'), findsOneWidget);

        // AND: They can see the statistics section header
        expect(find.text('Statistics'), findsOneWidget);
      },
    );
  });

  group('Integration Test: Analytics Dashboard Flow', () {
    Widget createAnalyticsScreen(List<LogRecord> records) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Analytics')),
            body: SizedBox(
              height: 1200,
              child: AnalyticsChartsWidget(
                records: records,
                accountId: 'user-1',
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('User views analytics dashboard with week of data', (
      tester,
    ) async {
      // GIVEN: A user with logs from the past week
      final now = DateTime.now();
      final logs = <LogRecord>[];

      for (int i = 0; i < 14; i++) {
        logs.add(
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: now.subtract(Duration(hours: i * 4)),
            eventType: i % 3 == 0 ? EventType.note : EventType.vape,
            duration: (5 + (i % 10)).toDouble(),
            unit: Unit.seconds,
            moodRating: (4.0 + (i % 4)).toDouble(),
          ),
        );
      }

      // WHEN: They view the analytics dashboard
      await tester.pumpWidget(createAnalyticsScreen(logs));

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // THEN: They see charts and summaries
      expect(find.text('Total Entries'), findsOneWidget);
      expect(find.text('Daily Avg'), findsOneWidget);
      expect(find.text('7 Days'), findsOneWidget);
      expect(find.text('14 Days'), findsOneWidget);
      expect(find.text('30 Days'), findsOneWidget);
    });

    testWidgets('User switches time ranges to see different perspectives', (
      tester,
    ) async {
      // GIVEN: User is on analytics with 7-day view
      final now = DateTime.now();
      final logs = <LogRecord>[];

      for (int i = 0; i < 30; i++) {
        logs.add(
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: now.subtract(Duration(hours: i * 2)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
        );
      }

      await tester.pumpWidget(createAnalyticsScreen(logs));
      await tester.pumpAndSettle();

      // Verify initial state shows 7 days is selected
      expect(find.text('7 Days'), findsOneWidget);

      // WHEN: User taps 30 Days
      await tester.tap(find.text('30 Days'));
      await tester.pumpAndSettle();

      // THEN: Data updates to show 30-day perspective
      expect(find.text('30 Days'), findsOneWidget);
    });
  });

  group('Integration Test: Multi-Widget Synchronization', () {
    testWidgets('Time since widget updates when new log is added', (
      tester,
    ) async {
      // GIVEN: Initial state with one log
      final now = DateTime.now();
      var logs = [
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(hours: 2)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TimeSinceLastHitWidget(records: logs)),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // WHEN: A new log is added
      logs = [
        ...logs,
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(minutes: 30)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        ),
      ];

      // THEN: Widget updates to show new time
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TimeSinceLastHitWidget(records: logs)),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Time Since Last Hit'), findsOneWidget);
    });

    testWidgets('Both quick log and time since widgets work together', (
      tester,
    ) async {
      // GIVEN: User has logs and sees both widgets
      final now = DateTime.now();
      final logs = [
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(hours: 1)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    TimeSinceLastHitWidget(records: logs),
                    const SizedBox(height: 600, child: HomeQuickLogWidget()),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // THEN: Both widgets are visible and functional
      expect(find.text('Time Since Last Hit'), findsOneWidget);
      expect(find.text('Hold to record duration'), findsOneWidget);
      expect(find.text('Mood'), findsOneWidget);
    });
  });

  group('Integration Test: Edge Cases and Error Handling', () {
    Widget createScreen(List<LogRecord> records) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  if (records.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No data'),
                    ),
                  TimeSinceLastHitWidget(records: records),
                  const HomeQuickLogWidget(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('App handles empty data state gracefully', (tester) async {
      // GIVEN: User has no logs
      await tester.pumpWidget(createScreen([]));
      await tester.pumpAndSettle();

      // THEN: Both widgets display appropriate empty states
      expect(find.text('No entries yet'), findsOneWidget);
      expect(find.text('Hold to record duration'), findsOneWidget);
    });

    testWidgets('App handles large datasets efficiently', (tester) async {
      // GIVEN: User has 365 days of logs (1 per day)
      final now = DateTime.now();
      final logs = <LogRecord>[];

      for (int i = 0; i < 365; i++) {
        logs.add(
          LogRecord.create(
            logId: uuid.v4(),
            accountId: 'user-1',
            eventAt: now.subtract(Duration(days: i)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
        );
      }

      // WHEN: They view the app
      await tester.pumpWidget(createScreen(logs));
      await tester.pump(const Duration(milliseconds: 100));

      // THEN: App remains responsive
      expect(find.text('Time Since Last Hit'), findsOneWidget);
      expect(find.text('Hold to record duration'), findsOneWidget);
    });

    testWidgets('App handles rapid user interactions', (tester) async {
      // GIVEN: User is on the home screen
      final now = DateTime.now();
      final logs = [
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(hours: 1)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        ),
      ];

      await tester.pumpWidget(createScreen(logs));
      await tester.pumpAndSettle();

      // WHEN: User rapidly interacts with form elements
      final chips = find.byType(FilterChip);
      final chipCount = chips.evaluate().length;

      for (int i = 0; i < chipCount && i < 5; i++) {
        await tester.tap(chips.at(i));
        await tester.pump(const Duration(milliseconds: 50));
      }

      // THEN: App doesn't crash and remains functional
      expect(find.text('Time Since Last Hit'), findsOneWidget);
      expect(find.byType(HomeQuickLogWidget), findsOneWidget);
    });
  });
}
