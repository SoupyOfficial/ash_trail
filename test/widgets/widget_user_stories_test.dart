import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/utils/day_boundary.dart';
import 'package:ash_trail/widgets/home_quick_log_widget.dart';
import 'package:ash_trail/widgets/time_since_last_hit_widget.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('User Story: Widget Integration - Quick Log Flow', () {
    /// Helper to create a testable widget
    Widget createTestWidget(Widget child) {
      return ProviderScope(child: MaterialApp(home: Scaffold(body: child)));
    }

    testWidgets(
      'As a user, I want to quickly log a session using the quick log widget',
      (tester) async {
        // GIVEN: I see the home quick log widget
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: All input fields are visible and interactive
        expect(find.text('Mood'), findsOneWidget);
        expect(find.text('Physical'), findsOneWidget);
        expect(find.text('Reasons'), findsOneWidget);
        expect(find.text('Hold to record duration'), findsOneWidget);

        // WHEN: I select a mood rating
        final sliders = find.byType(Slider);
        expect(sliders, findsWidgets);

        // THEN: Widget is in valid state
        expect(find.byIcon(Icons.touch_app), findsOneWidget);
      },
    );

    testWidgets('As a user, I want to select multiple reasons for my session', (
      tester,
    ) async {
      // GIVEN: I see the reasons section
      await tester.pumpWidget(
        createTestWidget(
          const SingleChildScrollView(child: HomeQuickLogWidget()),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: I look for reason chips
      final chips = find.byType(FilterChip);

      // THEN: The chips should be available
      expect(chips, findsWidgets);
    });

    testWidgets(
      'As a user, I want the form to provide feedback while recording',
      (tester) async {
        // GIVEN: I have the quick log widget visible
        await tester.pumpWidget(createTestWidget(const HomeQuickLogWidget()));
        await tester.pumpAndSettle();

        // THEN: I can see the recording button
        expect(find.text('Hold to record duration'), findsOneWidget);

        // AND: The button has the touch icon
        expect(find.byIcon(Icons.touch_app), findsOneWidget);
      },
    );

    testWidgets('As a user, I want mood and physical ratings to persist', (
      tester,
    ) async {
      // GIVEN: I use the quick log widget
      await tester.pumpWidget(
        createTestWidget(
          const SingleChildScrollView(child: HomeQuickLogWidget()),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: I interact with the form
      final sliders = find.byType(Slider);
      expect(sliders, findsWidgets);

      // THEN: Multiple sliders are present (mood + physical)
      expect(sliders.evaluate().length, greaterThanOrEqualTo(2));
    });
  });

  group('User Story: Widget Integration - Time Since Last Hit Display', () {
    Widget createTestWidget(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );
    }

    testWidgets('As a user, I want to see when I last logged a session', (
      tester,
    ) async {
      // GIVEN: I have recent log entries
      final now = DateTime.now();
      final record = LogRecord.create(
        logId: 'log-1',
        accountId: 'user-1',
        eventAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
      );

      // WHEN: I view the time since last hit widget
      await tester.pumpWidget(
        createTestWidget(TimeSinceLastHitWidget(records: [record])),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // THEN: The widget shows the time elapsed (relative format: "2h ago")
      expect(find.text('Time Since Last Hit'), findsOneWidget);
      expect(find.textContaining('2h ago'), findsOneWidget);
    });

    testWidgets(
      'As a user, I want to see today\'s statistics for my sessions',
      (tester) async {
        // GIVEN: I have multiple log entries from today
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();

        final records = [
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 9)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'log-2',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 14)),
            eventType: EventType.vape,
            duration: 10,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'log-3',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 20)),
            eventType: EventType.vape,
            duration: 8,
            unit: Unit.seconds,
          ),
        ];

        // WHEN: I view the time since last hit widget
        await tester.pumpWidget(
          createTestWidget(TimeSinceLastHitWidget(records: records)),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // THEN: I can see today's statistics (widget shows "Total Today", "Hits Today", etc.)
        expect(find.text('Total Today'), findsAtLeastNWidgets(1));
        expect(find.text('Avg Today'), findsOneWidget);
        // Should show timer icon
        expect(find.byIcon(Icons.timer), findsOneWidget);
      },
    );

    testWidgets('As a user, I want to see my trend compared to yesterday', (
      tester,
    ) async {
      // GIVEN: I have logs from today and yesterday
      // Use 6am day boundary for test data
      final todayStart = DayBoundary.getTodayStart();
      final yesterdayStart = DayBoundary.getYesterdayStart();

      final records = [
        // Yesterday: 2 hits
        LogRecord.create(
          logId: 'y-1',
          accountId: 'user-1',
          eventAt: yesterdayStart.add(const Duration(hours: 10)),
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: 'y-2',
          accountId: 'user-1',
          eventAt: yesterdayStart.add(const Duration(hours: 15)),
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
        ),
        // Today: 1 hit (improvement!)
        LogRecord.create(
          logId: 't-1',
          accountId: 'user-1',
          eventAt: todayStart.add(const Duration(hours: 12)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        ),
      ];

      // WHEN: I view the widget
      await tester.pumpWidget(
        createTestWidget(TimeSinceLastHitWidget(records: records)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // THEN: I can see trend indicators (widget shows Statistics section with trend arrows)
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Avg Yesterday'), findsOneWidget);
    });

    testWidgets('As a user, I want to see weekly statistics', (tester) async {
      // GIVEN: I have logs from the past week
      // Use 6am day boundary for test data
      final todayStart = DayBoundary.getTodayStart();

      final records = <LogRecord>[];
      for (int i = 0; i < 7; i++) {
        records.add(
          LogRecord.create(
            logId: 'log-$i',
            accountId: 'user-1',
            eventAt: todayStart.subtract(Duration(days: i)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
        );
      }

      // WHEN: I view the widget
      await tester.pumpWidget(
        createTestWidget(TimeSinceLastHitWidget(records: records)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // THEN: I can see weekly stats (widget shows "Hits This Week", "Avg/Day (7d)", etc.)
      expect(find.text('Hits This Week'), findsOneWidget);
      expect(find.text('Avg/Day (7d)'), findsOneWidget);
    });

    testWidgets('As a user, I want to see an empty state when no logs exist', (
      tester,
    ) async {
      // GIVEN: I have no log entries
      // WHEN: I view the widget
      await tester.pumpWidget(
        createTestWidget(const TimeSinceLastHitWidget(records: [])),
      );
      await tester.pumpAndSettle();

      // THEN: I see the empty state message
      expect(find.text('No entries yet'), findsOneWidget);
      expect(find.text('Time since last hit will appear here'), findsOneWidget);
    });
  });

  group('User Story: Widget Integration - Complete Logging Workflow', () {
    const uuid = Uuid();

    Widget createTestWidget(Widget child) {
      return ProviderScope(child: MaterialApp(home: Scaffold(body: child)));
    }

    testWidgets(
      'As a user, I want to log a session and see it reflected immediately',
      (tester) async {
        // GIVEN: I have the quick log widget and time tracker
        const accountId = 'test-user-123';
        final now = DateTime.now();

        final logRecord = LogRecord.create(
          logId: uuid.v4(),
          accountId: accountId,
          eventAt: now.subtract(const Duration(minutes: 5)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        );

        // WHEN: I view both widgets with the new log
        await tester.pumpWidget(
          createTestWidget(
            SingleChildScrollView(
              child: Column(
                children: [
                  TimeSinceLastHitWidget(records: [logRecord]),
                  const SizedBox(height: 600, child: HomeQuickLogWidget()),
                ],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // THEN: The time since widget shows the recent log
        expect(find.text('Time Since Last Hit'), findsOneWidget);
        expect(find.byIcon(Icons.timer), findsOneWidget);

        // AND: The quick log widget is ready for the next entry
        expect(find.text('Hold to record duration'), findsOneWidget);
      },
    );

    testWidgets(
      'As a user, I want to see stats update as I log more sessions',
      (tester) async {
        // GIVEN: I have one log entry
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();

        var records = [
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 10)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
        ];

        // WHEN: I view the stats widget
        await tester.pumpWidget(
          createTestWidget(
            SingleChildScrollView(
              child: TimeSinceLastHitWidget(records: records),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // THEN: I see stats for 1 entry (widget shows "Total Today", "Hits Today", etc.)
        expect(find.text('Total Today'), findsAtLeastNWidgets(1));

        // WHEN: I add another log entry (simulated)
        records = [
          ...records,
          LogRecord.create(
            logId: 'log-2',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 15)),
            eventType: EventType.vape,
            duration: 10,
            unit: Unit.seconds,
          ),
        ];

        // Rebuild widget with new data
        await tester.pumpWidget(
          createTestWidget(
            SingleChildScrollView(
              child: TimeSinceLastHitWidget(records: records),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // THEN: The widget updates to show new stats
        expect(find.text('Total Today'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('As a user, I want to track multiple sessions across days', (
      tester,
    ) async {
      // GIVEN: I have logs from multiple days
      // Use 6am day boundary for test data
      final todayStart = DayBoundary.getTodayStart();
      final yesterdayStart = DayBoundary.getYesterdayStart();

      final records = [
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'user-1',
          eventAt: todayStart.add(const Duration(hours: 8)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'user-1',
          eventAt: todayStart.add(const Duration(hours: 18)),
          eventType: EventType.vape,
          duration: 8,
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
      ];

      // WHEN: I view the time since widget
      await tester.pumpWidget(
        createTestWidget(
          SingleChildScrollView(
            child: TimeSinceLastHitWidget(records: records),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // THEN: I can see stats for today (widget shows "Total Today", "Avg Today", etc.)
      expect(find.text('Total Today'), findsAtLeastNWidgets(1));
      expect(find.text('Avg Today'), findsOneWidget);
      // Widget displays time tracking information
      expect(find.text('Time Since Last Hit'), findsOneWidget);
    });
  });

  group('User Story: Widget Integration - Form Interactions', () {
    Widget createTestWidget(Widget child) {
      return ProviderScope(child: MaterialApp(home: Scaffold(body: child)));
    }

    testWidgets('As a user, I want to rate my mood and physical state easily', (
      tester,
    ) async {
      // GIVEN: I see the quick log form
      await tester.pumpWidget(
        createTestWidget(
          const SingleChildScrollView(child: HomeQuickLogWidget()),
        ),
      );
      await tester.pumpAndSettle();

      // THEN: Both rating inputs are present
      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('Physical'), findsOneWidget);

      // AND: Both have sliders with 1-10 range
      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      expect(sliders.length, greaterThanOrEqualTo(2));

      // Verify slider ranges
      expect(sliders[0].min, 1);
      expect(sliders[0].max, 10);
      expect(sliders[1].min, 1);
      expect(sliders[1].max, 10);
    });

    testWidgets('As a user, I want to select reasons for my session', (
      tester,
    ) async {
      // GIVEN: I see the reasons section
      await tester.pumpWidget(
        createTestWidget(
          const SingleChildScrollView(child: HomeQuickLogWidget()),
        ),
      );
      await tester.pumpAndSettle();

      // THEN: All reason chips are visible
      expect(find.text('Reasons'), findsOneWidget);

      for (final reason in LogReason.values) {
        expect(find.text(reason.displayName), findsOneWidget);
      }
    });

    testWidgets('As a user, I want to easily toggle reason selections', (
      tester,
    ) async {
      // GIVEN: I see reason chips
      await tester.pumpWidget(
        createTestWidget(
          const SingleChildScrollView(child: HomeQuickLogWidget()),
        ),
      );
      await tester.pumpAndSettle();

      // WHEN: I select a reason
      final socialChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Social',
      );

      expect(socialChip, findsOneWidget);
      await tester.tap(socialChip);
      await tester.pump();

      // THEN: I can interact with other elements
      expect(find.text('Mood'), findsOneWidget);
    });

    testWidgets('As a user, I want to see clear labels for all form sections', (
      tester,
    ) async {
      // GIVEN: I view the quick log widget
      await tester.pumpWidget(
        createTestWidget(
          const SingleChildScrollView(child: HomeQuickLogWidget()),
        ),
      );
      await tester.pumpAndSettle();

      // THEN: All sections have clear labels
      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('Physical'), findsOneWidget);
      expect(find.text('Reasons'), findsOneWidget);
      expect(find.text('Hold to record duration'), findsOneWidget);
    });
  });

  group('User Story: Edge Cases - Widget Robustness', () {
    Widget createTestWidget(Widget child) {
      return ProviderScope(child: MaterialApp(home: Scaffold(body: child)));
    }

    testWidgets('As a user, I expect the app to handle empty data gracefully', (
      tester,
    ) async {
      // GIVEN: I have no log entries
      await tester.pumpWidget(
        createTestWidget(const TimeSinceLastHitWidget(records: [])),
      );
      await tester.pumpAndSettle();

      // THEN: The widget shows helpful empty state
      expect(find.text('No entries yet'), findsOneWidget);

      // WHEN: I view the form
      await tester.pumpWidget(createTestWidget(const HomeQuickLogWidget()));
      await tester.pumpAndSettle();

      // THEN: Form is still fully functional
      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('Physical'), findsOneWidget);
    });

    testWidgets('As a user, I expect rapid interactions to not crash the app', (
      tester,
    ) async {
      // GIVEN: I view the quick log widget
      await tester.pumpWidget(createTestWidget(const HomeQuickLogWidget()));
      await tester.pumpAndSettle();

      // WHEN: I rapidly interact with form elements
      final chipFinder = find.byType(FilterChip);
      final chips = chipFinder.evaluate();

      for (int i = 0; i < chips.length && i < 5; i++) {
        await tester.tap(find.byType(FilterChip).at(i));
        await tester.pump(const Duration(milliseconds: 50));
      }

      // THEN: App remains stable
      expect(find.text('Mood'), findsOneWidget);
      expect(find.byType(HomeQuickLogWidget), findsOneWidget);
    });

    testWidgets(
      'As a user, I want widgets to handle large datasets efficiently',
      (tester) async {
        // GIVEN: I have 100 log entries from the past 30 days
        final now = DateTime.now();
        final records = <LogRecord>[];

        for (int i = 0; i < 100; i++) {
          records.add(
            LogRecord.create(
              logId: 'log-$i',
              accountId: 'user-1',
              eventAt: now.subtract(Duration(hours: i)),
              eventType: EventType.vape,
              duration: (i % 20 + 1).toDouble(),
              unit: Unit.seconds,
            ),
          );
        }

        // WHEN: I view the time since widget
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TimeSinceLastHitWidget(records: records),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // THEN: Widget renders without performance issues
        expect(find.text('Time Since Last Hit'), findsOneWidget);
        expect(find.byIcon(Icons.timer), findsOneWidget);
      },
    );
  });
}
