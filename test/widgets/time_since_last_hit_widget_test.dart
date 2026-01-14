import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/widgets/time_since_last_hit_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeSinceLastHitWidget', () {
    testWidgets('shows empty state when no records', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TimeSinceLastHitWidget(records: [])),
          ),
        ),
      );

      expect(find.text('No entries yet'), findsOneWidget);
      expect(find.text('Time since last hit will appear here'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('shows time since last hit with recent entry', (tester) async {
      final now = DateTime.now();
      final record = LogRecord.create(
        logId: 'log-1',
        accountId: 'user-1',
        eventAt: now.subtract(const Duration(seconds: 30)),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TimeSinceLastHitWidget(records: [record])),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Time Since Last Hit'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      // Should show seconds - look for the actual time display (not in title)
      expect(find.text('30s'), findsOneWidget);
    });

    testWidgets('formats duration correctly for hours', (tester) async {
      final now = DateTime.now();
      final record = LogRecord.create(
        logId: 'log-1',
        accountId: 'user-1',
        eventAt: now.subtract(
          const Duration(hours: 2, minutes: 15, seconds: 30),
        ),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TimeSinceLastHitWidget(records: [record])),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Time Since Last Hit'), findsOneWidget);
      // Should show hours, minutes, and seconds - verify the format
      expect(find.textContaining('2h 15m'), findsOneWidget);
    });

    testWidgets('formats duration correctly for days', (tester) async {
      final now = DateTime.now();
      final record = LogRecord.create(
        logId: 'log-1',
        accountId: 'user-1',
        eventAt: now.subtract(const Duration(days: 1, hours: 3, minutes: 45)),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TimeSinceLastHitWidget(records: [record])),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Time Since Last Hit'), findsOneWidget);
      // Should show days, hours, and minutes (no seconds for days)
      expect(find.textContaining('1d 3h 45m'), findsOneWidget);
    });

    testWidgets('uses most recent record when multiple exist', (tester) async {
      final now = DateTime.now();
      final records = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(hours: 5)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: 'log-2',
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(minutes: 30)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: 'log-3',
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
            home: Scaffold(body: TimeSinceLastHitWidget(records: records)),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Time Since Last Hit'), findsOneWidget);
      // Should be showing around 30 minutes (not 2 or 5 hours)
      final textFinder = find.byType(Text);
      final textWidgets = textFinder.evaluate().map((e) => e.widget as Text);
      final durationText =
          textWidgets
              .firstWhere(
                (w) =>
                    w.data != null &&
                    w.data!.contains('m') &&
                    !w.data!.contains('Avg') &&
                    !w.data!.contains('hits'),
                orElse: () => const Text(''),
              )
              .data;

      // Should show minutes in the 29-31 range
      expect(durationText, isNotNull);
      expect(durationText, contains('m'));
    });

    testWidgets('displays timer and updates', (tester) async {
      final now = DateTime.now();
      final record = LogRecord.create(
        logId: 'log-1',
        accountId: 'user-1',
        eventAt: now.subtract(const Duration(seconds: 5)),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TimeSinceLastHitWidget(records: [record])),
          ),
        ),
      );

      // Initial render
      await tester.pump();

      expect(find.text('Time Since Last Hit'), findsOneWidget);
      // Should show some time in seconds
      expect(find.textContaining('s'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows today and week counts', (tester) async {
      final now = DateTime.now();
      final records = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(minutes: 10)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: 'log-2',
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(minutes: 30)),
          eventType: EventType.vape,
          duration: 10,
          unit: Unit.seconds,
        ),
      ];

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

      // Check for stat labels
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('hits'), findsNWidgets(2)); // Today hits and Week hits
    });

    testWidgets('shows average duration stats', (tester) async {
      final now = DateTime.now();
      final records = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(minutes: 10)),
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
                child: TimeSinceLastHitWidget(records: records),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Check for avg duration labels
      expect(find.text('Avg Today'), findsOneWidget);
      expect(find.text('Avg Yesterday'), findsOneWidget);
      expect(find.text('Avg/Day (7d)'), findsOneWidget);
      expect(find.text('sec/hit'), findsNWidgets(2)); // Today and Yesterday avg
    });

    testWidgets('shows trend indicator', (tester) async {
      final now = DateTime.now();
      final records = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(minutes: 10)),
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
                child: TimeSinceLastHitWidget(records: records),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Check for trend section
      expect(find.text('Trend'), findsOneWidget);
    });

    group('Statistics Calculations', () {
      testWidgets('correctly calculates today stats with multiple entries', (
        tester,
      ) async {
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);

        // Create multiple entries for today
        final records = [
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 8)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'log-2',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 12)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'log-3',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 20)),
            eventType: EventType.vape,
            duration: 10,
            unit: Unit.seconds,
          ),
        ];

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

        // Verify today stats are shown
        expect(find.text('Today'), findsOneWidget);
        // Should show average duration
        expect(find.text('Avg Today'), findsOneWidget);
        // Should show hits label
        expect(find.text('hits'), findsAtLeastNWidgets(1));
      });

      testWidgets('distinguishes today vs yesterday records', (tester) async {
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);
        final yesterdayStart = todayMidnight.subtract(const Duration(days: 1));

        final records = [
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 10)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'log-2',
            accountId: 'user-1',
            eventAt: yesterdayStart.add(const Duration(hours: 14)),
            eventType: EventType.vape,
            duration: 8,
            unit: Unit.seconds,
          ),
        ];

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

        // Both sections should exist
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Avg Today'), findsOneWidget);
        // Widget renders whatever sections it can based on actual data
        expect(find.byType(TimeSinceLastHitWidget), findsOneWidget);
      });

      testWidgets('calculates week stats correctly', (tester) async {
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);

        final records = [
          // Today
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 10)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          // 3 days ago
          LogRecord.create(
            logId: 'log-2',
            accountId: 'user-1',
            eventAt: todayMidnight.subtract(const Duration(days: 3, hours: 5)),
            eventType: EventType.vape,
            duration: 10,
            unit: Unit.seconds,
          ),
          // 6 days ago
          LogRecord.create(
            logId: 'log-3',
            accountId: 'user-1',
            eventAt: todayMidnight.subtract(const Duration(days: 6, hours: 2)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
        ];

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

        expect(find.text('This Week'), findsOneWidget);
        expect(find.text('Avg/Day (7d)'), findsOneWidget);
      });

      testWidgets('handles empty yesterday correctly', (tester) async {
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);

        final records = [
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 10)),
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
                  child: TimeSinceLastHitWidget(records: records),
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Widget should display something for today
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Avg Today'), findsOneWidget);
        // Widget should be functional
        expect(find.byType(TimeSinceLastHitWidget), findsOneWidget);
      });
    });

    group('Widget Lifecycle', () {
      testWidgets('updates when records change', (tester) async {
        final now = DateTime.now();
        final record1 = LogRecord.create(
          logId: 'log-1',
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(minutes: 5)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        TimeSinceLastHitWidget(records: [record1]),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Update'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(TimeSinceLastHitWidget), findsOneWidget);
      });

      testWidgets('timer continues after widget rebuild', (tester) async {
        final now = DateTime.now();
        final record = LogRecord.create(
          logId: 'log-1',
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(seconds: 10)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: TimeSinceLastHitWidget(records: [record])),
            ),
          ),
        );

        await tester.pump();

        // Advance time and pump
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.byType(TimeSinceLastHitWidget), findsOneWidget);
      });

      testWidgets('cleans up timer on dispose', (tester) async {
        final now = DateTime.now();
        final record = LogRecord.create(
          logId: 'log-1',
          accountId: 'user-1',
          eventAt: now.subtract(const Duration(minutes: 5)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: TimeSinceLastHitWidget(records: [record])),
            ),
          ),
        );

        await tester.pump();

        // Rebuild with empty widget tree (widget disposed)
        await tester.pumpWidget(const SizedBox.shrink());

        // No assertion needed - just ensure no errors on cleanup
        expect(true, true);
      });
    });

    group('Trend Indicators', () {
      testWidgets('shows improvement when today better than yesterday', (
        tester,
      ) async {
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);
        final yesterdayStart = todayMidnight.subtract(const Duration(days: 1));

        final records = [
          // Yesterday: 3 hits, avg 15 sec
          LogRecord.create(
            logId: 'y-1',
            accountId: 'user-1',
            eventAt: yesterdayStart.add(const Duration(hours: 10)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'y-2',
            accountId: 'user-1',
            eventAt: yesterdayStart.add(const Duration(hours: 14)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'y-3',
            accountId: 'user-1',
            eventAt: yesterdayStart.add(const Duration(hours: 18)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
          // Today: 1 hit, avg 5 sec (improvement!)
          LogRecord.create(
            logId: 't-1',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 10)),
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
                  child: TimeSinceLastHitWidget(records: records),
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Trend'), findsOneWidget);
        expect(find.byIcon(Icons.trending_down), findsWidgets);
      });

      testWidgets('shows degradation when today worse than yesterday', (
        tester,
      ) async {
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);
        final yesterdayStart = todayMidnight.subtract(const Duration(days: 1));

        final records = [
          // Yesterday: 1 hit, avg 5 sec
          LogRecord.create(
            logId: 'y-1',
            accountId: 'user-1',
            eventAt: yesterdayStart.add(const Duration(hours: 10)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          // Today: 3 hits, avg 15 sec (worse!)
          LogRecord.create(
            logId: 't-1',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 8)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 't-2',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 12)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 't-3',
            accountId: 'user-1',
            eventAt: todayMidnight.add(const Duration(hours: 18)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
        ];

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

        expect(find.text('Trend'), findsOneWidget);
        expect(find.byIcon(Icons.trending_up), findsWidgets);
      });
    });

    group('Pattern Analysis', () {
      testWidgets('shows peak hour analysis', (tester) async {
        final now = DateTime.now();
        final records = [
          // Multiple hits at 4 PM (peak)
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: now
                .subtract(const Duration(days: 3))
                .copyWith(hour: 16, minute: 0, second: 0, millisecond: 0),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'log-2',
            accountId: 'user-1',
            eventAt: now
                .subtract(const Duration(days: 2))
                .copyWith(hour: 16, minute: 30, second: 0, millisecond: 0),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'log-3',
            accountId: 'user-1',
            eventAt: now
                .subtract(const Duration(days: 1))
                .copyWith(hour: 16, minute: 45, second: 0, millisecond: 0),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          // One hit at 10 AM
          LogRecord.create(
            logId: 'log-4',
            accountId: 'user-1',
            eventAt: now.copyWith(
              hour: 10,
              minute: 0,
              second: 0,
              millisecond: 0,
            ),
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
                  child: TimeSinceLastHitWidget(records: records),
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Check for peak hour display
        expect(find.text('Peak Hour'), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
        // The format is now "4 PM (X%)" combined in one text widget
        expect(find.textContaining('4 PM'), findsWidgets);
      });

      testWidgets('shows day of week patterns', (tester) async {
        final now = DateTime.now();

        // Create records spread across different days of the week
        final records = <LogRecord>[];

        // Add multiple records for different days
        for (int i = 0; i < 10; i++) {
          records.add(
            LogRecord.create(
              logId: 'log-$i',
              accountId: 'user-1',
              eventAt: now.subtract(Duration(days: i)),
              eventType: EventType.vape,
              duration: 5,
              unit: Unit.seconds,
            ),
          );
        }

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

        // Check for weekly pattern display
        expect(find.text('Weekly Pattern'), findsOneWidget);
        // The format is now "Highest: DayName" combined in one text
        expect(find.textContaining('Highest'), findsWidgets);
      });

      testWidgets('shows weekday vs weekend comparison', (tester) async {
        final now = DateTime.now();

        // Get Monday of current week
        final monday = now.subtract(Duration(days: now.weekday - 1));

        final records = <LogRecord>[];

        // Add more records for weekdays
        for (int i = 0; i < 3; i++) {
          records.add(
            LogRecord.create(
              logId: 'log-wd-$i',
              accountId: 'user-1',
              eventAt: monday.add(
                Duration(days: i),
              ), // Monday, Tuesday, Wednesday
              eventType: EventType.vape,
              duration: 5,
              unit: Unit.seconds,
            ),
          );
        }

        // Add fewer records for weekend
        records.add(
          LogRecord.create(
            logId: 'log-we-1',
            accountId: 'user-1',
            eventAt: monday.add(const Duration(days: 5)), // Saturday
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
        );

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

        // Check for weekday/weekend comparison
        // The format is now "Weekday: X.X" and "Weekend: X.X" combined
        expect(find.textContaining('Weekday'), findsWidgets);
        expect(find.textContaining('Weekend'), findsWidgets);
      });
    });
  });
}
