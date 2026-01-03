import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/providers/log_record_provider.dart';
import 'package:ash_trail/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Account _buildAccount({
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

  ProviderScope _pumpHome(
    WidgetTester tester, {
    required Stream<Account?> activeAccountStream,
    required Stream<List<LogRecord>> recordsStream,
    required Future<Map<String, dynamic>> Function(LogRecordsParams) statsFn,
  }) {
    final scope = ProviderScope(
      overrides: [
        activeAccountProvider.overrideWith((ref) => activeAccountStream),
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
      _pumpHome(
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
    final account = _buildAccount(displayName: 'River Tester');

    await tester.pumpWidget(
      _pumpHome(
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
    expect(find.text('No entries yet'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets(
    'shows recent entries with icons, durations, and relative times',
    (WidgetTester tester) async {
      final account = _buildAccount(displayName: 'Iconic User');
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
        _pumpHome(
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
}
