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
    /// and verifies the "No Accounts" message and "Create Test Account" button appear.
    ///
    /// **How it works:** Overrides allAccountsProvider with empty stream,
    /// activeAccountProvider with null, pumps widget, waits for animations,
    /// then asserts expected text elements are found.
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

    /// **Purpose:** Verify account list displays all accounts correctly.
    ///
    /// **What it does:** Renders AccountsScreen with two mock accounts
    /// and verifies both display names and emails appear in the list.
    ///
    /// **How it works:** Creates two Account instances with different
    /// userIds, overrides providers to return them as a list, pumps
    /// the widget, then searches for each account's name and email text.
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

    /// **Purpose:** Verify active account has visual indicator.
    ///
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

    /// **Purpose:** Verify Developer Tools section appears when accounts exist.
    ///
    /// **What it does:** Renders AccountsScreen with the test account and
    /// verifies the Developer Tools section header and both action buttons.
    ///
    /// **How it works:** Creates an account using test account constants,
    /// overrides providers, pumps widget, then searches for "Developer Tools"
    /// header, "Create Test Account" button, and "Add Sample Logs" button.
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

    /// **Purpose:** Verify app bar contains expected action buttons.
    ///
    /// **What it does:** Renders AccountsScreen and checks that the
    /// import/export, profile, and logout icons are present in the app bar.
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
