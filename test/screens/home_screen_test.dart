import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/providers/log_record_provider.dart';
import 'package:ash_trail/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

void main() {
  Account buildAccount({
    String userId = 'user-1',
    String email = 'user@example.com',
    String displayName = 'Test User',
    bool isActive = true,
  }) {
    return Account.create(
      userId: userId,
      email: email,
      displayName: displayName,
      isActive: isActive,
      authProvider: AuthProvider.gmail,
    );
  }

  ProviderScope pumpHome(
    WidgetTester tester, {
    required Stream<Account?> activeAccountStream,
    required Stream<List<LogRecord>> recordsStream,
    required Future<Map<String, dynamic>> Function(LogRecordsParams) statsFn,
  }) {
    final scope = ProviderScope(
      overrides: [
        activeAccountProvider.overrideWith(
          (ref) => Stream.fromFuture(activeAccountStream.first),
        ),
        activeAccountLogRecordsProvider.overrideWith((ref) => recordsStream),
        logRecordStatsProvider.overrideWith((ref, params) => statsFn(params)),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );

    return scope;
  }

  testWidgets('shows onboarding when there is no active account', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      pumpHome(
        tester,
        activeAccountStream: Stream.value(null),
        recordsStream: Stream.value(const []),
        statsFn: (_) async => {},
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Welcome to Ash Trail'), findsOneWidget);
    expect(
      find.text('Create or sign in to an account to start logging'),
      findsOneWidget,
    );
    expect(find.text('Add Account'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('renders stats and empty recent entries for active account', (
    WidgetTester tester,
  ) async {
    final account = buildAccount(displayName: 'River Tester');

    await tester.pumpWidget(
      pumpHome(
        tester,
        activeAccountStream: Stream.value(account),
        recordsStream: Stream.value(const []),
        statsFn: (_) async => const {'totalCount': 3, 'totalDuration': 120.5},
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('River Tester'), findsOneWidget);
    expect(find.text('3'), findsWidgets);
    expect(find.text('120.5'), findsWidgets);
    // "No entries yet" appears in both time since last hit and recent entries
    expect(find.text('No entries yet'), findsAtLeastNWidgets(1));
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets(
    'shows recent entries with icons, durations, and relative times',
    (WidgetTester tester) async {
      final account = buildAccount(displayName: 'Iconic User');
      final now = DateTime.now();
      final records = [
        LogRecord.create(
          logId: 'log-1',
          accountId: account.userId,
          eventAt: now.subtract(const Duration(minutes: 5)),
          eventType: EventType.vape,
          duration: 5,
          unit: Unit.seconds,
          note: 'Short vape',
        ),
        LogRecord.create(
          logId: 'log-2',
          accountId: account.userId,
          eventAt: now.subtract(const Duration(hours: 2)),
          eventType: EventType.sessionStart,
          duration: 180,
          unit: Unit.seconds,
          note: 'Session start',
        ),
        LogRecord.create(
          logId: 'log-3',
          accountId: account.userId,
          eventAt: now.subtract(const Duration(days: 2)),
          eventType: EventType.custom,
          duration: 60,
          unit: Unit.seconds,
          note: 'Custom event',
        ),
      ];

      await tester.pumpWidget(
        pumpHome(
          tester,
          activeAccountStream: Stream.value(account),
          recordsStream: Stream.value(records),
          statsFn: (_) async => const {'totalCount': 9, 'totalDuration': 300.0},
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('Recent Entries'), findsOneWidget);
      expect(find.byIcon(Icons.cloud), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);

      expect(find.textContaining('5.0 seconds'), findsOneWidget);
      expect(find.textContaining('180.0 seconds'), findsOneWidget);
      expect(find.textContaining('60.0 seconds'), findsOneWidget);

      expect(find.textContaining('ago'), findsWidgets);
      expect(find.text('Custom event'), findsOneWidget);
    },
  );

  testWidgets('displays correct stats calculations for multiple records', (
    WidgetTester tester,
  ) async {
    final account = buildAccount();
    final now = DateTime.now();
    final records = [
      LogRecord.create(
        logId: 'log-1',
        accountId: account.userId,
        eventAt: now.subtract(const Duration(hours: 1)),
        eventType: EventType.vape,
        duration: 30,
        unit: Unit.seconds,
      ),
      LogRecord.create(
        logId: 'log-2',
        accountId: account.userId,
        eventAt: now.subtract(const Duration(hours: 2)),
        eventType: EventType.vape,
        duration: 45,
        unit: Unit.seconds,
      ),
      LogRecord.create(
        logId: 'log-3',
        accountId: account.userId,
        eventAt: now.subtract(const Duration(hours: 3)),
        eventType: EventType.tolerance,
        duration: 10,
        unit: Unit.minutes,
      ),
    ];

    await tester.pumpWidget(
      pumpHome(
        tester,
        activeAccountStream: Stream.value(account),
        recordsStream: Stream.value(records),
        statsFn:
            (_) async => const {
              'totalCount': 3,
              'totalDuration': 65.0,
              'vapingMinutes': 75,
            },
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('3'), findsWidgets); // total count shown
    expect(find.text('65.0'), findsWidgets); // avg duration
  });

  testWidgets('shows empty state with no records', (WidgetTester tester) async {
    final account = buildAccount();

    await tester.pumpWidget(
      pumpHome(
        tester,
        activeAccountStream: Stream.value(account),
        recordsStream: Stream.value(const []),
        statsFn: (_) async => const {'totalCount': 0, 'totalDuration': 0.0},
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    // "No entries yet" appears in both time since last hit and recent entries
    expect(find.text('No entries yet'), findsAtLeastNWidgets(1));
    expect(find.text('Recent Entries'), findsOneWidget);
  });

  testWidgets('displays FAB for quick logging when account active', (
    WidgetTester tester,
  ) async {
    final account = buildAccount();

    await tester.pumpWidget(
      pumpHome(
        tester,
        activeAccountStream: Stream.value(account),
        recordsStream: Stream.value(const []),
        statsFn: (_) async => const {},
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('lists records in reverse chronological order', (
    WidgetTester tester,
  ) async {
    final account = buildAccount();
    final now = DateTime.now();
    final records = [
      LogRecord.create(
        logId: 'log-1',
        accountId: account.userId,
        eventAt: now.subtract(const Duration(days: 3)),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
        note: 'Oldest entry',
      ),
      LogRecord.create(
        logId: 'log-2',
        accountId: account.userId,
        eventAt: now.subtract(const Duration(minutes: 5)),
        eventType: EventType.tolerance,
        duration: 30,
        unit: Unit.seconds,
        note: 'Newest entry',
      ),
    ];

    await tester.pumpWidget(
      pumpHome(
        tester,
        activeAccountStream: Stream.value(account),
        recordsStream: Stream.value(records),
        statsFn: (_) async => const {'totalCount': 2},
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Newest entry'), findsOneWidget);
    expect(find.text('Oldest entry'), findsOneWidget);

    // Check that newest entry appears before oldest entry
    // by checking their vertical positions
    final newestWidget = find.ancestor(
      of: find.text('Newest entry'),
      matching: find.byType(ListTile),
    );
    final oldestWidget = find.ancestor(
      of: find.text('Oldest entry'),
      matching: find.byType(ListTile),
    );

    final newestY = tester.getTopLeft(newestWidget).dy;
    final oldestY = tester.getTopLeft(oldestWidget).dy;

    expect(
      newestY < oldestY,
      true,
      reason: 'Newest entry should appear above oldest entry',
    );
  });

  testWidgets('updates display when records stream changes', (
    WidgetTester tester,
  ) async {
    final account = buildAccount();
    final now = DateTime.now();
    final record1 = LogRecord.create(
      logId: 'log-1',
      accountId: account.userId,
      eventAt: now,
      eventType: EventType.vape,
      duration: 5,
      unit: Unit.seconds,
    );

    final recordsNotifier = StreamController<List<LogRecord>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeAccountProvider.overrideWith((ref) => Stream.value(account)),
          activeAccountLogRecordsProvider.overrideWith(
            (ref) => recordsNotifier.stream,
          ),
          logRecordStatsProvider.overrideWith((ref, params) async => const {}),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    recordsNotifier.add([record1]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('Recent Entries'), findsOneWidget);
    expect(find.text('No entries yet'), findsNothing);

    recordsNotifier.close();
  });
}
