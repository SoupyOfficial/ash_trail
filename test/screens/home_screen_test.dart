import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/providers/home_widget_config_provider.dart';
import 'package:ash_trail/providers/log_record_provider.dart'
    show activeAccountLogRecordsProvider;
import 'package:ash_trail/providers/sync_provider.dart';
import 'package:ash_trail/screens/home_screen.dart';
import 'package:ash_trail/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Account _buildAccount({
  String userId = 'casual-user-1',
  String? displayName = 'Casual Tracker',
  String? firstName,
  String email = 'casual@example.com',
}) {
  return Account.create(
    userId: userId,
    displayName: displayName,
    firstName: firstName,
    email: email,
  );
}

/// A minimal fake SyncService that does nothing, avoiding Firebase/Firestore
/// dependencies during widget tests.
class _FakeSyncService extends Fake implements SyncService {
  @override
  @override
  Future<void> startAccountSync({
    required String accountId,
    Duration interval = const Duration(seconds: 30),
  }) async {}

  @override
  void startAutoSync({
    String? accountId,
    Duration pushInterval = const Duration(seconds: 30),
    Duration pullInterval = const Duration(seconds: 30),
  }) {}

  @override
  void stopAutoSync() {}

  @override
  void dispose() {}
}

/// Build a [ProviderScope]-wrapped [HomeScreen] with the given [account].
///
/// Uses pre-set [SharedPreferences] so no real Firebase, Firestore, or Hive
/// access is needed.
Future<Widget> _buildHomeScreenAsync({Account? account}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [
      activeAccountProvider.overrideWith(
        (ref) => Stream.value(account),
      ),
      activeAccountLogRecordsProvider.overrideWith(
        (ref) => Stream.value(<LogRecord>[]),
      ),
      syncServiceProvider.overrideWithValue(_FakeSyncService()),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // -- Welcome greeting / banner in the AppBar --

  group('HomeScreen - Welcome greeting', () {
    testWidgets('shows "Welcome, displayName" when account has displayName', (
      tester,
    ) async {
      final widget = await _buildHomeScreenAsync(
        account: _buildAccount(displayName: 'Alex'),
      );
      await tester.pumpWidget(widget);
      // Let providers emit
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Welcome, Alex'), findsOneWidget);
    });

    testWidgets('falls back to firstName when displayName is null', (
      tester,
    ) async {
      final widget = await _buildHomeScreenAsync(
        account: _buildAccount(
          displayName: null,
          firstName: 'Jordan',
        ),
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Welcome, Jordan'), findsOneWidget);
    });

    testWidgets(
      'falls back to email prefix when displayName and firstName are null',
      (tester) async {
        final widget = await _buildHomeScreenAsync(
          account: _buildAccount(
            displayName: null,
            firstName: null,
            email: 'smoker42@example.com',
          ),
        );
        await tester.pumpWidget(widget);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Welcome, smoker42'), findsOneWidget);
      },
    );

    testWidgets('shows "Edit Home" in app bar when edit mode is active', (
      tester,
    ) async {
      final widget = await _buildHomeScreenAsync(
        account: _buildAccount(displayName: 'Alex'),
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the edit button to enter edit mode
      await tester.tap(find.byKey(const Key('app_bar_edit_layout')));
      await tester.pump();

      expect(find.text('Edit Home'), findsOneWidget);
      expect(find.text('Welcome, Alex'), findsNothing);
    });

    testWidgets('returns to greeting after exiting edit mode', (
      tester,
    ) async {
      final widget = await _buildHomeScreenAsync(
        account: _buildAccount(displayName: 'Alex'),
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Enter edit mode
      await tester.tap(find.byKey(const Key('app_bar_edit_layout')));
      await tester.pump();
      expect(find.text('Edit Home'), findsOneWidget);

      // Exit edit mode (button becomes a Done icon)
      await tester.tap(find.byKey(const Key('app_bar_edit_layout')));
      await tester.pump();

      expect(find.text('Welcome, Alex'), findsOneWidget);
      expect(find.text('Edit Home'), findsNothing);
    });
  });

  // -- No-account (unauthenticated fallback) view --

  group('HomeScreen - No account view', () {
    testWidgets('shows "Welcome to Ash Trail" banner when account is null', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final widget = await _buildHomeScreenAsync(account: null);
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Welcome to Ash Trail'), findsOneWidget);
      expect(
        find.text('Create or sign in to an account to start logging'),
        findsOneWidget,
      );
    });

    testWidgets('shows Add Account button when no account', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final widget = await _buildHomeScreenAsync(account: null);
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('add_account_button')), findsOneWidget);
      expect(find.text('Add Account'), findsOneWidget);
    });

    testWidgets('shows account icon in no-account view', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final widget = await _buildHomeScreenAsync(account: null);
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byIcon(Icons.account_circle_outlined),
        findsOneWidget,
      );
    });

    testWidgets('app bar says "Home" when account is null', (tester) async {
      final widget = await _buildHomeScreenAsync(account: null);
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // _buildGreeting returns 'Home' for null account
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('does not show edit layout button when no account', (
      tester,
    ) async {
      final widget = await _buildHomeScreenAsync(account: null);
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('app_bar_edit_layout')),
        findsNothing,
      );
    });
  });

  // -- AppBar actions --

  group('HomeScreen - AppBar actions', () {
    testWidgets('shows accounts icon in app bar', (tester) async {
      final widget = await _buildHomeScreenAsync(
        account: _buildAccount(),
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('app_bar_account')),
        findsOneWidget,
      );
    });

    testWidgets('shows edit layout button when account exists', (
      tester,
    ) async {
      final widget = await _buildHomeScreenAsync(
        account: _buildAccount(),
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('app_bar_edit_layout')),
        findsOneWidget,
      );
    });

    testWidgets('shows FAB backdate button when account exists', (
      tester,
    ) async {
      final widget = await _buildHomeScreenAsync(
        account: _buildAccount(),
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('fab_backdate')),
        findsOneWidget,
      );
    });

    testWidgets('does not show FAB when no account', (tester) async {
      final widget = await _buildHomeScreenAsync(account: null);
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('fab_backdate')), findsNothing);
    });
  });

  // -- Casual Tracker User Persona (model-level) --

  group('Casual Tracker User - Minimal Friction Logging', () {
    test('creates minimal log entry with just event type and duration', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final minimalRecord = LogRecord.create(
        logId: 'minimal-1',
        accountId: account.userId,
        eventAt: now,
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
      );

      expect(minimalRecord.logId, 'minimal-1');
      expect(minimalRecord.eventType, EventType.vape);
      expect(minimalRecord.duration, 5);
      expect(minimalRecord.note, isNull);
      expect(minimalRecord.moodRating, isNull);
      expect(minimalRecord.physicalRating, isNull);
    });

    test('supports quick entry without notes or tags', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final quickRecord = LogRecord.create(
        logId: 'quick-1',
        accountId: account.userId,
        eventAt: now,
        eventType: EventType.vape,
        duration: 10,
        unit: Unit.seconds,
        note: '', // explicitly empty
      );

      expect(quickRecord.note, '');
      expect(quickRecord.reasons, isNull);
    });

    test('marks new entries as pending sync initially', () {
      final account = _buildAccount();

      final record = LogRecord.create(
        logId: 'pending-1',
        accountId: account.userId,
        eventAt: DateTime.now(),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
      );

      // Default sync state should be pending
      expect(record.syncState, SyncState.pending);
    });

    test('handles sync state transitions correctly', () {
      final account = _buildAccount();
      final record = LogRecord.create(
        logId: 'sync-test-1',
        accountId: account.userId,
        eventAt: DateTime.now(),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
        syncState: SyncState.pending,
      );

      // Should be able to mark as synced
      expect(record.syncState, SyncState.pending);

      // Copy with updated sync state
      final syncedRecord = record.copyWith(syncState: SyncState.synced);
      expect(syncedRecord.syncState, SyncState.synced);
    });

    test('supports multiple quick consecutive logs', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final logs = List.generate(
        5,
        (i) => LogRecord.create(
          logId: 'consecutive-$i',
          accountId: account.userId,
          eventAt: now.subtract(Duration(minutes: i)),
          eventType: EventType.vape,
          duration: (5 + i).toDouble(),
          unit: Unit.seconds,
        ),
      );

      expect(logs, hasLength(5));
      expect(logs.map((l) => l.logId).toList(), [
        'consecutive-0',
        'consecutive-1',
        'consecutive-2',
        'consecutive-3',
        'consecutive-4',
      ]);
      expect(logs.map((l) => l.duration).toList(), [5.0, 6.0, 7.0, 8.0, 9.0]);
    });

    test('displays sync status for recent entries', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final syncedRecord = LogRecord.create(
        logId: 'synced-1',
        accountId: account.userId,
        eventAt: now,
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
        syncState: SyncState.synced,
      );

      final pendingRecord = LogRecord.create(
        logId: 'pending-1',
        accountId: account.userId,
        eventAt: now.subtract(const Duration(hours: 1)),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
        syncState: SyncState.pending,
      );

      expect(syncedRecord.syncState, SyncState.synced);
      expect(pendingRecord.syncState, SyncState.pending);
    });

    test('preserves entry data through creation and copies', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final original = LogRecord.create(
        logId: 'preserve-1',
        accountId: account.userId,
        eventAt: now,
        eventType: EventType.vape,
        duration: 15,
        unit: Unit.seconds,
      );

      final copy = original.copyWith();

      expect(copy.logId, original.logId);
      expect(copy.accountId, original.accountId);
      expect(copy.eventAt, original.eventAt);
      expect(copy.eventType, original.eventType);
      expect(copy.duration, original.duration);
      expect(copy.unit, original.unit);
    });
  });
}
