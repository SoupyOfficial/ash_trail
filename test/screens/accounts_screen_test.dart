import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/screens/accounts_screen.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/providers/account_provider.dart';

void main() {
  group('AccountsScreen Widget Tests', () {
    testWidgets('AccountsScreen shows empty state when no accounts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith((ref) => Stream.value([])),
            activeAccountProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Accounts'), findsOneWidget);
      expect(find.text('Add an account to get started'), findsOneWidget);
    });

    testWidgets('AccountsScreen shows list of accounts', (
      WidgetTester tester,
    ) async {
      final account1 = Account.create(
        userId: 'user1',
        email: 'user1@example.com',
        displayName: 'User One',
      );
      final account2 = Account.create(
        userId: 'user2',
        email: 'user2@example.com',
        displayName: 'User Two',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith(
              (ref) => Stream.value([account1, account2]),
            ),
            activeAccountProvider.overrideWith((ref) => Stream.value(account1)),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('User One'), findsOneWidget);
      expect(find.text('User Two'), findsOneWidget);
      expect(find.text('user1@example.com'), findsOneWidget);
      expect(find.text('user2@example.com'), findsOneWidget);
    });

    testWidgets('AccountsScreen shows active indicator', (
      WidgetTester tester,
    ) async {
      final account1 = Account.create(
        userId: 'user1',
        email: 'user1@example.com',
      );
      account1.isActive = true;

      final account2 = Account.create(
        userId: 'user2',
        email: 'user2@example.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith(
              (ref) => Stream.value([account1, account2]),
            ),
            activeAccountProvider.overrideWith((ref) => Stream.value(account1)),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Add account FAB is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith((ref) => Stream.value([])),
            activeAccountProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(FloatingActionButton, 'Add Account'),
        findsOneWidget,
      );
    });

    testWidgets('Add account dialog appears on FAB tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith((ref) => Stream.value([])),
            activeAccountProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();

      expect(find.text('User ID'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Display Name (optional)'), findsOneWidget);
    });
  });
}
