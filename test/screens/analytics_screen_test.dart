import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/screens/analytics_screen.dart';
import 'package:ash_trail/models/log_entry.dart';
import 'package:ash_trail/providers/logging_provider.dart';

void main() {
  group('AnalyticsScreen Widget Tests', () {
    testWidgets('AnalyticsScreen shows tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logEntriesProvider.overrideWith((ref) => Stream.value([])),
            statisticsProvider.overrideWith(
              (ref) => Future.value({
                'totalEntries': 0,
                'totalAmount': 0.0,
                'firstEntry': null,
                'lastEntry': null,
              }),
            ),
          ],
          child: const MaterialApp(home: AnalyticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
      expect(find.text('Charts'), findsOneWidget);
    });

    testWidgets('AnalyticsScreen shows empty state when no entries', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logEntriesProvider.overrideWith((ref) => Stream.value([])),
            statisticsProvider.overrideWith(
              (ref) => Future.value({
                'totalEntries': 0,
                'totalAmount': 0.0,
                'firstEntry': null,
                'lastEntry': null,
              }),
            ),
          ],
          child: const MaterialApp(home: AnalyticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No entries yet'), findsOneWidget);
    });

    testWidgets('AnalyticsScreen shows entry list', (
      WidgetTester tester,
    ) async {
      final entry1 = LogEntry.create(
        entryId: 'entry1',
        userId: 'user1',
        notes: 'Test entry 1',
        amount: 1.5,
      );
      final entry2 = LogEntry.create(
        entryId: 'entry2',
        userId: 'user1',
        notes: 'Test entry 2',
        amount: 2.5,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logEntriesProvider.overrideWith(
              (ref) => Stream.value([entry1, entry2]),
            ),
            statisticsProvider.overrideWith(
              (ref) => Future.value({
                'totalEntries': 2,
                'totalAmount': 4.0,
                'firstEntry': entry1.timestamp,
                'lastEntry': entry2.timestamp,
              }),
            ),
          ],
          child: const MaterialApp(home: AnalyticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test entry 1'), findsOneWidget);
      expect(find.text('Test entry 2'), findsOneWidget);
    });

    testWidgets('AnalyticsScreen shows sync state icons', (
      WidgetTester tester,
    ) async {
      final entry1 = LogEntry.create(entryId: 'entry1', userId: 'user1');
      entry1.syncState = SyncState.synced;

      final entry2 = LogEntry.create(entryId: 'entry2', userId: 'user1');
      entry2.syncState = SyncState.pending;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logEntriesProvider.overrideWith(
              (ref) => Stream.value([entry1, entry2]),
            ),
            statisticsProvider.overrideWith(
              (ref) => Future.value({
                'totalEntries': 2,
                'totalAmount': 0.0,
                'firstEntry': entry1.timestamp,
                'lastEntry': entry2.timestamp,
              }),
            ),
          ],
          child: const MaterialApp(home: AnalyticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
    });

    testWidgets('AnalyticsScreen charts tab shows placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logEntriesProvider.overrideWith((ref) => Stream.value([])),
            statisticsProvider.overrideWith(
              (ref) => Future.value({
                'totalEntries': 0,
                'totalAmount': 0.0,
                'firstEntry': null,
                'lastEntry': null,
              }),
            ),
          ],
          child: const MaterialApp(home: AnalyticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Charts tab
      await tester.tap(find.text('Charts'));
      await tester.pumpAndSettle();

      expect(find.text('Charts Coming Soon'), findsOneWidget);
    });

    testWidgets('AnalyticsScreen shows statistics on Charts tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logEntriesProvider.overrideWith((ref) => Stream.value([])),
            statisticsProvider.overrideWith(
              (ref) => Future.value({
                'totalEntries': 10,
                'totalAmount': 25.50,
                'firstEntry': DateTime(2025, 1, 1),
                'lastEntry': DateTime(2025, 1, 15),
              }),
            ),
          ],
          child: const MaterialApp(home: AnalyticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Charts tab
      await tester.tap(find.text('Charts'));
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('25.50'), findsOneWidget);
    });
  });
}
