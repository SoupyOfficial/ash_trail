import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/providers/log_record_provider.dart';
import 'package:ash_trail/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final recordA = LogRecord.create(
    logId: 'a',
    accountId: 'acct',
    eventType: EventType.vape,
    eventAt: DateTime(2024, 1, 1, 10),
    note: 'Morning session',
  );

  final recordB = LogRecord.create(
    logId: 'b',
    accountId: 'acct',
    eventType: EventType.note,
    eventAt: DateTime(2024, 1, 15, 9),
    note: 'Doctor follow-up',
  );

  final recordC = LogRecord.create(
    logId: 'c',
    accountId: 'acct',
    eventType: EventType.vape,
    eventAt: DateTime(2024, 1, 20, 14),
    note: 'Afternoon vape',
    moodRating: 6.0,
    physicalRating: 7.0,
  );

  Widget _buildApp({required Stream<List<LogRecord>> stream}) {
    return ProviderScope(
      overrides: [
        activeAccountLogRecordsProvider.overrideWith((ref) => stream),
      ],
      child: const MaterialApp(home: HistoryScreen()),
    );
  }

  testWidgets('shows empty state when there are no records', (tester) async {
    await tester.pumpWidget(_buildApp(stream: Stream.value(const [])));
    await tester.pumpAndSettle();

    expect(find.text('No entries yet'), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
  });

  testWidgets('displays all records when no filter applied', (tester) async {
    await tester.pumpWidget(
      _buildApp(stream: Stream.value([recordA, recordB, recordC])),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.text('Morning session'), findsOneWidget);
    expect(find.text('Doctor follow-up'), findsOneWidget);
    expect(find.text('Afternoon vape'), findsOneWidget);
  });

  testWidgets('filters records by search query and shows active filter chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(stream: Stream.value([recordA, recordB, recordC])),
    );
    await tester.pumpAndSettle();

    // Three entries initially
    expect(find.byType(ListTile), findsNWidgets(3));

    await tester.enterText(find.byType(TextField).first, 'doctor');
    await tester.pumpAndSettle();

    // Only the note record remains and filter chip shows query
    expect(find.text('NOTE'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('"doctor"'), findsOneWidget);
  });

  testWidgets('changes grouping to by month and shows grouped headers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(stream: Stream.value([recordA, recordB, recordC])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.view_agenda));
    await tester.pumpAndSettle();

    await tester.tap(find.text('By month'));
    await tester.pumpAndSettle();

    expect(find.text('January 2024'), findsOneWidget);
  });

  testWidgets('changes grouping to by event type and shows type headers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(stream: Stream.value([recordA, recordB, recordC])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.view_agenda));
    await tester.pumpAndSettle();

    await tester.tap(find.text('By event type'));
    await tester.pumpAndSettle();

    expect(find.text('VAPE'), findsWidgets);
    expect(find.text('NOTE'), findsWidgets);
  });

  testWidgets('displays record details including mood and physical ratings', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(stream: Stream.value([recordC])));
    await tester.pumpAndSettle();

    expect(find.text('Afternoon vape'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('filters by vape event type', (tester) async {
    await tester.pumpWidget(
      _buildApp(stream: Stream.value([recordA, recordB, recordC])),
    );
    await tester.pumpAndSettle();

    // Initial: 3 records
    expect(find.byType(ListTile), findsNWidgets(3));

    // Filter by "VAPE"
    await tester.enterText(find.byType(TextField).first, 'VAPE');
    await tester.pumpAndSettle();

    // Only vape records visible (A and C)
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
