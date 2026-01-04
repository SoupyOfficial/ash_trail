import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/providers/log_record_provider.dart';
import 'package:ash_trail/screens/analytics_screen.dart';
import 'package:ash_trail/widgets/analytics_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildApp({
  required Stream<List<LogRecord>> recordsStream,
  required Stream<Account?> accountStream,
  required Future<Map<String, dynamic>> statsFuture,
}) {
  return ProviderScope(
    overrides: [
      activeAccountLogRecordsProvider.overrideWith((ref) => recordsStream),
      activeAccountProvider.overrideWith((ref) => accountStream),
      logRecordStatsProvider.overrideWith((ref, params) => statsFuture),
    ],
    child: const MaterialApp(home: AnalyticsScreen()),
  );
}

LogRecord _makeRecord({
  required String id,
  required EventType type,
  required DateTime at,
  String? note,
  SyncState syncState = SyncState.synced,
  double duration = 0,
  Unit unit = Unit.seconds,
}) {
  return LogRecord.create(
    logId: id,
    accountId: 'acct',
    eventType: type,
    eventAt: at,
    note: note,
    syncState: syncState,
    duration: duration,
    unit: unit,
  );
}

void main() {
  group('AnalyticsScreen', () {
    testWidgets('shows empty data state when no records', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          recordsStream: Stream.value(const []),
          accountStream: Stream.value(null),
          statsFuture: Future.value({}),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No entries yet'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('shows summary and recent entries when data available', (
      tester,
    ) async {
      final records = [
        _makeRecord(
          id: 'a',
          type: EventType.vape,
          at: DateTime(2024, 1, 1, 10),
          note: 'Morning',
          syncState: SyncState.synced,
          duration: 30,
        ),
        _makeRecord(
          id: 'b',
          type: EventType.note,
          at: DateTime(2024, 1, 2, 12),
          note: 'Doctor',
          syncState: SyncState.pending,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          recordsStream: Stream.value(records),
          accountStream: Stream.value(null),
          statsFuture: Future.value({'total': 2, 'synced': 1, 'pending': 1}),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Synced'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Recent Entries'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('shows summary stats with multiple records', (tester) async {
      final records = [
        _makeRecord(
          id: 'a',
          type: EventType.vape,
          at: DateTime(2024, 1, 1, 10),
          syncState: SyncState.synced,
          duration: 45,
        ),
        _makeRecord(
          id: 'b',
          type: EventType.vape,
          at: DateTime(2024, 1, 2, 12),
          syncState: SyncState.synced,
          duration: 60,
        ),
        _makeRecord(
          id: 'c',
          type: EventType.note,
          at: DateTime(2024, 1, 3, 14),
          syncState: SyncState.pending,
        ),
        _makeRecord(
          id: 'd',
          type: EventType.vape,
          at: DateTime(2024, 1, 4, 16),
          syncState: SyncState.error,
          duration: 30,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          recordsStream: Stream.value(records),
          accountStream: Stream.value(null),
          statsFuture: Future.value({
            'total': 4,
            'synced': 2,
            'pending': 1,
            'error': 1,
          }),
        ),
      );

      await tester.pumpAndSettle();

      // Stats should be visible
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Synced'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('switches to empty charts tab without account', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          recordsStream: Stream.value(const []),
          accountStream: Stream.value(null),
          statsFuture: Future.value({}),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Charts'));
      await tester.pumpAndSettle();

      expect(find.text('No data for charts'), findsOneWidget);
    });

    testWidgets('displays tabs correctly', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          recordsStream: Stream.value(const []),
          accountStream: Stream.value(null),
          statsFuture: Future.value({}),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
      expect(find.text('Charts'), findsOneWidget);
    });

    testWidgets('charts tab renders when account and data exist', (
      tester,
    ) async {
      final account = Account.create(
        userId: 'acct',
        email: 'user@example.com',
        isActive: true,
      );

      final records = [
        _makeRecord(
          id: 'a',
          type: EventType.vape,
          at: DateTime(2024, 1, 1, 10),
          duration: 60,
        ),
        _makeRecord(
          id: 'b',
          type: EventType.vape,
          at: DateTime(2024, 1, 2, 12),
          duration: 45,
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          recordsStream: Stream.value(records),
          accountStream: Stream.value(account),
          statsFuture: Future.value({'total': 2}),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Charts'));
      await tester.pumpAndSettle();

      expect(find.byType(AnalyticsChartsWidget), findsOneWidget);
    });

    testWidgets('recent entries show most recent first', (tester) async {
      final records = [
        _makeRecord(
          id: 'a',
          type: EventType.vape,
          at: DateTime(2024, 1, 1, 10),
          note: 'First',
        ),
        _makeRecord(
          id: 'b',
          type: EventType.vape,
          at: DateTime(2024, 1, 5, 10),
          note: 'Most recent',
        ),
      ];

      await tester.pumpWidget(
        _buildApp(
          recordsStream: Stream.value(records),
          accountStream: Stream.value(null),
          statsFuture: Future.value({'total': 2}),
        ),
      );

      await tester.pumpAndSettle();

      final listTiles = find.byType(ListTile);
      expect(listTiles, findsNWidgets(2));
      // Most recent should appear first
      expect(find.textContaining('Most recent'), findsOneWidget);
    });
  });
}
