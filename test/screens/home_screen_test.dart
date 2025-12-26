import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/screens/home_screen.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/providers/logging_provider.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen shows no account message when no active account', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Active Account'), findsOneWidget);
      expect(find.text('Add an account to start logging'), findsOneWidget);
      expect(find.widgetWithIcon(FilledButton, Icons.add), findsOneWidget);
    });

    testWidgets('HomeScreen shows account info when account is active', (
      WidgetTester tester,
    ) async {
      final testAccount = Account.create(
        userId: 'test_user',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      testAccount.isActive = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) => Stream.value(testAccount),
            ),
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
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Active Account'), findsOneWidget);
    });

    testWidgets('HomeScreen shows quick log FAB when account is active', (
      WidgetTester tester,
    ) async {
      final testAccount = Account.create(
        userId: 'test_user',
        email: 'test@example.com',
      );
      testAccount.isActive = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) => Stream.value(testAccount),
            ),
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
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(FloatingActionButton, 'Quick Log'),
        findsOneWidget,
      );
    });

    testWidgets('HomeScreen shows empty state when no entries', (
      WidgetTester tester,
    ) async {
      final testAccount = Account.create(
        userId: 'test_user',
        email: 'test@example.com',
      );
      testAccount.isActive = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) => Stream.value(testAccount),
            ),
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
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No entries yet'), findsOneWidget);
      expect(find.text('Tap the Quick Log button to start'), findsOneWidget);
    });

    testWidgets('HomeScreen shows statistics cards', (
      WidgetTester tester,
    ) async {
      final testAccount = Account.create(
        userId: 'test_user',
        email: 'test@example.com',
      );
      testAccount.isActive = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) => Stream.value(testAccount),
            ),
            logEntriesProvider.overrideWith((ref) => Stream.value([])),
            statisticsProvider.overrideWith(
              (ref) => Future.value({
                'totalEntries': 42,
                'totalAmount': 123.5,
                'firstEntry': DateTime(2025, 1, 1),
                'lastEntry': DateTime(2025, 1, 15),
              }),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('42'), findsOneWidget);
      expect(find.text('Total Entries'), findsOneWidget);
      expect(find.text('123.5'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
    });

    testWidgets('Quick log dialog appears on FAB tap', (
      WidgetTester tester,
    ) async {
      final testAccount = Account.create(
        userId: 'test_user',
        email: 'test@example.com',
      );
      testAccount.isActive = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) => Stream.value(testAccount),
            ),
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
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the Quick Log FAB
      await tester.tap(find.text('Quick Log'));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Amount (optional)'), findsOneWidget);
      expect(find.text('Notes (optional)'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Log'), findsOneWidget);
    });
  });
}
