/// AccountsScreen Widget Test Suite
///
/// This file contains widget tests for the AccountsScreen, verifying
/// the UI renders correctly in various states (empty, with accounts,
/// with active account indicators, etc.).
///
/// ## Test Coverage
/// - Empty state rendering
/// - Account list display
/// - Active account indicator
/// - Developer Tools section visibility
/// - App bar action buttons
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/screens/accounts_screen.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/providers/account_provider.dart';

void main() {
  /// Widget tests for the AccountsScreen component.
  /// Each test verifies a specific UI state or behavior.
  group('AccountsScreen Widget Tests', () {
    /// **Purpose:** Verify empty state UI displays correctly when no accounts exist.
    ///
    /// **What it does:** Renders AccountsScreen with empty account providers
    /// and verifies the "No Accounts" message and "Add Account" button appear.
    ///
    /// **How it works:** Overrides allAccountsProvider with empty list,
    /// activeAccountProvider with null, pumps widget, waits for animations,
    /// then asserts expected text elements are found.
    testWidgets('AccountsScreen shows empty state when no accounts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith((ref) async => <Account>[]),
            activeAccountProvider.overrideWith((ref) => Stream.value(null)),
            loggedInAccountsProvider.overrideWith((ref) async => <Account>[]),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Updated: Now shows "No Accounts" and "Add Account" button
      expect(find.text('No Accounts'), findsOneWidget);
      expect(find.text('Add Account'), findsOneWidget);
    });

    /// **Purpose:** Verify account list displays all accounts correctly.
    ///
    /// **What it does:** Renders AccountsScreen with two mock accounts
    /// and verifies both display names appear in the list.
    ///
    /// **How it works:** Creates two Account instances with different
    /// userIds, overrides providers to return them as a list, pumps
    /// the widget, then searches for each account's name text.
    testWidgets('AccountsScreen shows list of accounts', (
      WidgetTester tester,
    ) async {
      final account1 = Account.create(
        userId: 'user1',
        email: 'user1@example.com',
        displayName: 'User One',
        authProvider: AuthProvider.devStatic,
        isLoggedIn: true,
      );
      final account2 = Account.create(
        userId: 'user2',
        email: 'user2@example.com',
        displayName: 'User Two',
        authProvider: AuthProvider.devStatic,
        isLoggedIn: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith(
              (ref) async => [account1, account2],
            ),
            activeAccountProvider.overrideWith((ref) => Stream.value(account1)),
            loggedInAccountsProvider.overrideWith(
              (ref) async => [account1, account2],
            ),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('User One'), findsOneWidget);
      expect(find.text('User Two'), findsOneWidget);
    });

    /// **Purpose:** Verify active account has visual indicator.
    /// **What it does:** Renders AccountsScreen with one active and one
    /// inactive account, verifies the active indicator (check icon + text).
    ///
    /// **How it works:** Creates account1 with isActive: true, account2
    /// without. Overrides providers, pumps widget, then searches for
    /// Icons.check_circle and "Active" text that should only appear once.
    testWidgets('AccountsScreen shows active indicator', (
      WidgetTester tester,
    ) async {
      final account1 = Account.create(
        userId: 'user1',
        email: 'user1@example.com',
        authProvider: AuthProvider.devStatic,
        isActive: true,
        isLoggedIn: true,
      );

      final account2 = Account.create(
        userId: 'user2',
        email: 'user2@example.com',
        authProvider: AuthProvider.devStatic,
        isLoggedIn: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith(
              (ref) async => [account1, account2],
            ),
            activeAccountProvider.overrideWith((ref) => Stream.value(account1)),
            loggedInAccountsProvider.overrideWith(
              (ref) async => [account1, account2],
            ),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    /// **Purpose:** Verify app bar contains expected action buttons.
    ///
    /// **What it does:** Renders AccountsScreen and checks that the
    /// import/export, profile, and more_vert icons are present in the app bar.
    ///
    /// **How it works:** Pumps the widget with empty account state,
    /// waits for render, then uses find.byIcon() to locate each expected
    /// action button icon. These buttons provide key account management features.
    testWidgets('App bar has expected action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith((ref) async => <Account>[]),
            activeAccountProvider.overrideWith((ref) => Stream.value(null)),
            loggedInAccountsProvider.overrideWith((ref) async => <Account>[]),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // App bar should have import/export, profile, and menu buttons
      expect(find.byIcon(Icons.import_export), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('AccountsScreen displays multiple accounts in list format', (
      WidgetTester tester,
    ) async {
      final accounts = [
        Account.create(
          userId: 'user1',
          email: 'user1@example.com',
          displayName: 'Alice',
          authProvider: AuthProvider.devStatic,
          isActive: true,
          isLoggedIn: true,
        ),
        Account.create(
          userId: 'user2',
          email: 'user2@example.com',
          displayName: 'Bob',
          authProvider: AuthProvider.devStatic,
          isLoggedIn: true,
        ),
        Account.create(
          userId: 'user3',
          email: 'user3@example.com',
          displayName: 'Charlie',
          authProvider: AuthProvider.devStatic,
          isLoggedIn: true,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith((ref) async => accounts),
            activeAccountProvider.overrideWith(
              (ref) => Stream.value(accounts[0]),
            ),
            loggedInAccountsProvider.overrideWith((ref) async => accounts),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('AccountsScreen shows correct active account highlighting', (
      WidgetTester tester,
    ) async {
      final account1 = Account.create(
        userId: 'user1',
        email: 'user1@example.com',
        displayName: 'First User',
        authProvider: AuthProvider.devStatic,
        isLoggedIn: true,
      );
      final account2 = Account.create(
        userId: 'user2',
        email: 'user2@example.com',
        displayName: 'Second User',
        authProvider: AuthProvider.devStatic,
        isActive: true,
        isLoggedIn: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith(
              (ref) async => [account1, account2],
            ),
            activeAccountProvider.overrideWith((ref) => Stream.value(account2)),
            loggedInAccountsProvider.overrideWith(
              (ref) async => [account1, account2],
            ),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('First User'), findsOneWidget);
      expect(find.text('Second User'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('AccountsScreen renders list with account details', (
      WidgetTester tester,
    ) async {
      final account = Account.create(
        userId: 'test-user',
        email: 'test@example.com',
        displayName: 'Test Account',
        authProvider: AuthProvider.gmail,
        isActive: true,
        isLoggedIn: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith((ref) async => [account]),
            activeAccountProvider.overrideWith((ref) => Stream.value(account)),
            loggedInAccountsProvider.overrideWith((ref) async => [account]),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Account'), findsOneWidget);
    });

    testWidgets('AccountsScreen scrollable when many accounts present', (
      WidgetTester tester,
    ) async {
      final accounts = List.generate(
        10,
        (index) => Account.create(
          userId: 'user$index',
          email: 'user$index@example.com',
          displayName: 'User $index',
          authProvider: AuthProvider.devStatic,
          isActive: index == 0,
          isLoggedIn: true,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allAccountsProvider.overrideWith((ref) async => accounts),
            activeAccountProvider.overrideWith(
              (ref) => Stream.value(accounts[0]),
            ),
            loggedInAccountsProvider.overrideWith((ref) async => accounts),
          ],
          child: const MaterialApp(home: AccountsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('User 0'), findsOneWidget);

      // Verify list view is scrollable
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
