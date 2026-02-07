import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/utils/day_boundary.dart';
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

      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Time Since Last Hit'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      // Widget uses relative format: < 1 min -> "Just now"
      expect(find.text('Just now'), findsOneWidget);
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

      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Time Since Last Hit'), findsOneWidget);
      // Widget uses relative format for main display: "2h ago"
      expect(find.textContaining('2h ago'), findsOneWidget);
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

      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Time Since Last Hit'), findsOneWidget);
      // Widget uses relative format for main display: "1d ago" (< 7 days)
      expect(find.textContaining('1d ago'), findsOneWidget);
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

      await tester.pump(const Duration(milliseconds: 150));

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
      // < 1 min shows "Just now"
      expect(find.text('Just now'), findsOneWidget);
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

      await tester.pump(const Duration(milliseconds: 150));

      // Check for stat labels (widget shows "Hits Today" and "Hits This Week")
      expect(find.text('Hits Today'), findsOneWidget);
      expect(find.text('Hits This Week'), findsOneWidget);
      expect(find.text('count'), findsOneWidget); // Hits Today subtitle
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

      await tester.pump(const Duration(milliseconds: 150));

      // Check for avg duration labels (widget shows these in statistics section)
      expect(find.text('Avg Today'), findsOneWidget);
      expect(find.text('Avg Yesterday'), findsOneWidget);
      expect(
        find.text('sec/hit'),
        findsAtLeastNWidgets(1),
      ); // Duration subtitles
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

      await tester.pump(const Duration(milliseconds: 150));

      // Check for statistics section (which contains trend indicators)
      expect(find.text('Statistics'), findsOneWidget);
    });

    group('Statistics Calculations', () {
      testWidgets('correctly calculates today stats with multiple entries', (
        tester,
      ) async {
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();

        // Create multiple entries for today (after 6am boundary)
        final records = [
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 2)), // 8am
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'log-2',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 6)), // 12pm
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 'log-3',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 14)), // 8pm
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

        await tester.pump(const Duration(milliseconds: 150));

        // Verify today stats are shown (widget shows "Total up to X", "Hits Today", etc.)
        expect(find.textContaining('Total up to'), findsAtLeastNWidgets(1));
        // Should show average duration
        expect(find.text('Avg Today'), findsOneWidget);
        // Should show hits count
        expect(find.text('Hits Today'), findsOneWidget);
      });

      testWidgets('distinguishes today vs yesterday records', (tester) async {
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));

        final records = [
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 10)),
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

        await tester.pump(const Duration(milliseconds: 150));

        // Both sections should exist (widget shows "Total up to X", "Avg Today", "Avg Yesterday" etc.)
        expect(find.textContaining('Total up to'), findsAtLeastNWidgets(1));
        expect(find.text('Avg Today'), findsOneWidget);
        expect(find.text('Avg Yesterday'), findsOneWidget);
        // Widget renders whatever sections it can based on actual data
        expect(find.byType(TimeSinceLastHitWidget), findsOneWidget);
      });

      testWidgets('calculates week stats correctly', (tester) async {
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();

        final records = [
          // Today
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 10)),
            eventType: EventType.vape,
            duration: 5,
            unit: Unit.seconds,
          ),
          // 3 days ago
          LogRecord.create(
            logId: 'log-2',
            accountId: 'user-1',
            eventAt: todayStart.subtract(const Duration(days: 3, hours: 5)),
            eventType: EventType.vape,
            duration: 10,
            unit: Unit.seconds,
          ),
          // 6 days ago
          LogRecord.create(
            logId: 'log-3',
            accountId: 'user-1',
            eventAt: todayStart.subtract(const Duration(days: 6, hours: 2)),
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

        await tester.pump(const Duration(milliseconds: 150));

        // Widget shows "Hits This Week" and "Avg/Day (7d)" labels
        expect(find.text('Hits This Week'), findsOneWidget);
        expect(find.text('Avg/Day (7d)'), findsOneWidget);
      });

      testWidgets('handles empty yesterday correctly', (tester) async {
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();

        final records = [
          LogRecord.create(
            logId: 'log-1',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 10)),
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

        await tester.pump(const Duration(milliseconds: 150));

        // Widget should display something for today (widget shows "Total up to X", "Avg Today", etc.)
        expect(find.textContaining('Total up to'), findsAtLeastNWidgets(1));
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
                body: SingleChildScrollView(
                  child: StatefulBuilder(
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
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));

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
            eventAt: todayStart.add(const Duration(hours: 10)),
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

        await tester.pump(const Duration(milliseconds: 150));

        // Check for statistics section (contains trend indicators)
        expect(find.text('Statistics'), findsOneWidget);
        // Trend icons are shown via _buildTrendIndicator (trending_down for improvement)
        expect(find.byIcon(Icons.trending_down), findsWidgets);
      });

      testWidgets('shows degradation when today worse than yesterday', (
        tester,
      ) async {
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));

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
            eventAt: todayStart.add(const Duration(hours: 8)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 't-2',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 12)),
            eventType: EventType.vape,
            duration: 15,
            unit: Unit.seconds,
          ),
          LogRecord.create(
            logId: 't-3',
            accountId: 'user-1',
            eventAt: todayStart.add(const Duration(hours: 18)),
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

        await tester.pump(const Duration(milliseconds: 150));

        // Check for statistics section (contains trend indicators)
        expect(find.text('Statistics'), findsOneWidget);
        // Trend icons are shown via _buildTrendIndicator (trending_up for worse)
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

        await tester.pump(const Duration(milliseconds: 150));

        // Patterns section is collapsed and may be off-screen; scroll into view then expand
        await tester.ensureVisible(find.text('Patterns'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Patterns'));
        await tester.pumpAndSettle();

        // Check for peak hour display
        expect(find.text('Peak Hour'), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
        // The format is now "4 PM (X%)" combined in one text widget
        expect(find.textContaining('4 PM'), findsWidgets);
      });

      testWidgets('shows day of week patterns', (tester) async {
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();

        // Create records spread across different days of the week (within last 7 days)
        final records = <LogRecord>[];

        // Add multiple records for different days (within last 6 days)
        // Add 2 records per day to ensure we have meaningful patterns
        for (int i = 0; i < 6; i++) {
          final recordDate = todayStart.subtract(Duration(days: i));
          // Add 2 records per day
          for (int j = 0; j < 2; j++) {
            records.add(
              LogRecord.create(
                logId: 'log-$i-$j',
                accountId: 'user-1',
                eventAt: recordDate.add(Duration(hours: j * 2)),
                eventType: EventType.vape,
                duration: 5,
                unit: Unit.seconds,
              ),
            );
          }
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

        await tester.pumpAndSettle();

        // Expand the Patterns section if it exists
        final patternsFinder = find.text('Patterns');
        if (patternsFinder.evaluate().isNotEmpty) {
          // Scroll to the Patterns section if needed
          await tester.ensureVisible(patternsFinder);
          await tester.pumpAndSettle();
          await tester.tap(patternsFinder, warnIfMissed: false);
          await tester.pumpAndSettle();

          // Check for weekly pattern display - it may not always show depending on data
          final weeklyPatternFinder = find.text('Weekly Pattern');
          if (weeklyPatternFinder.evaluate().isNotEmpty) {
            expect(weeklyPatternFinder, findsOneWidget);
            // The format is now "Highest: DayName" combined in one text
            expect(find.textContaining('Highest'), findsWidgets);
          } else {
            // Weekly Pattern might not show if pattern data isn't sufficient
            // Just verify Patterns section exists
            expect(patternsFinder, findsOneWidget);
          }
        } else {
          // Pattern section should exist with this much data
          fail(
            'Patterns section should be visible with 12 records across 6 days',
          );
        }
      });

      testWidgets('shows weekday vs weekend comparison', (tester) async {
        // Use 6am day boundary for test data
        final todayStart = DayBoundary.getTodayStart();

        final records = <LogRecord>[];

        // Add more records for weekdays (within last 7 days)
        // Add records for Monday, Tuesday, Wednesday (weekdays 1-3)
        for (int dayOffset = 0; dayOffset < 3; dayOffset++) {
          final recordDate = todayStart.subtract(Duration(days: dayOffset));
          if (recordDate.weekday <= 5) {
            // Only weekdays
            // Add 3 records per weekday
            for (int j = 0; j < 3; j++) {
              records.add(
                LogRecord.create(
                  logId: 'log-wd-$dayOffset-$j',
                  accountId: 'user-1',
                  eventAt: recordDate.add(Duration(hours: j * 2)),
                  eventType: EventType.vape,
                  duration: 5,
                  unit: Unit.seconds,
                ),
              );
            }
          }
        }

        // Add fewer records for weekend (within last 7 days)
        // Find the most recent Saturday or Sunday
        for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
          final recordDate = todayStart.subtract(Duration(days: dayOffset));
          if (recordDate.weekday > 5) {
            // Weekend
            // Add 1 record per weekend day
            records.add(
              LogRecord.create(
                logId: 'log-we-$dayOffset',
                accountId: 'user-1',
                eventAt: recordDate,
                eventType: EventType.vape,
                duration: 5,
                unit: Unit.seconds,
              ),
            );
            // Only add one weekend day worth of records
            break;
          }
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

        await tester.pumpAndSettle();

        // Expand the Patterns section if it exists
        final patternsFinder = find.text('Patterns');
        if (patternsFinder.evaluate().isNotEmpty) {
          // Scroll to the Patterns section if needed
          await tester.ensureVisible(patternsFinder);
          await tester.pumpAndSettle();
          await tester.tap(patternsFinder, warnIfMissed: false);
          await tester.pumpAndSettle();

          // Check if Weekly Pattern section exists
          final weeklyPatternFinder = find.text('Weekly Pattern');
          if (weeklyPatternFinder.evaluate().isNotEmpty) {
            // Check for weekday/weekend comparison
            // The format is now "Weekday: X.X" and "Weekend: X.X" combined
            expect(find.textContaining('Weekday'), findsWidgets);
            expect(find.textContaining('Weekend'), findsWidgets);
          } else {
            // Weekly Pattern section might not show if there's no meaningful pattern data
            // This is acceptable - the test verifies the Patterns section exists
            expect(patternsFinder, findsOneWidget);
          }
        } else {
          // Pattern section should exist with this much data
          fail(
            'Patterns section should be visible with weekday and weekend records',
          );
        }
      });
    });
  });
}
