import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/screens/accounts_screen.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
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

      // Updated: Now shows "No Accounts" and "Create Test Account" button
      expect(find.text('No Accounts'), findsOneWidget);
      expect(find.text('Create Test Account'), findsOneWidget);
    });

    testWidgets('AccountsScreen shows list of accounts', (
      WidgetTester tester,
    ) async {
      final account1 = Account.create(
        userId: 'user1',
        email: 'user1@example.com',
        displayName: 'User One',
        authProvider: AuthProvider.devStatic,
      );
      final account2 = Account.create(
        userId: 'user2',
        email: 'user2@example.com',
        displayName: 'User Two',
        authProvider: AuthProvider.devStatic,
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
        authProvider: AuthProvider.devStatic,
        isActive: true,
      );

      final account2 = Account.create(
        userId: 'user2',
        email: 'user2@example.com',
        authProvider: AuthProvider.devStatic,
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

    testWidgets('Developer Tools section is visible with accounts', (
      WidgetTester tester,
    ) async {
      final account = Account.create(
        userId: kTestAccountId,
        email: kTestAccountEmail,
        displayName: kTestAccountName,
        authProvider: AuthProvider.devStatic,
        isActive: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith((ref) => Stream.value([account])),
            activeAccountProvider.overrideWith((ref) => Stream.value(account)),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Developer Tools section should be visible
      expect(find.text('Developer Tools'), findsOneWidget);
      expect(find.text('Create Test Account'), findsOneWidget);
      expect(find.text('Add Sample Logs'), findsOneWidget);
    });

    testWidgets('App bar has expected action buttons', (
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

      // App bar should have import/export, profile, and logout buttons
      expect(find.byIcon(Icons.import_export), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });
}
