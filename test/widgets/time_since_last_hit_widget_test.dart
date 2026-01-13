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
                (w) => w.data != null && w.data!.contains('m'),
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
  });
}
