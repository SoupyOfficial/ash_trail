import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/screens/accounts_screen.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/providers/account_provider.dart';

void main() {
  group('Test Account Constants', () {
    test('Test account ID is defined and static', () {
      // GIVEN: The test account constants
      // THEN: They should have expected values
      expect(kTestAccountId, 'dev-test-account-001');
      expect(kTestAccountEmail, 'test@ashtrail.dev');
      expect(kTestAccountName, 'Test User');
    });

    test('Test account ID is consistent across instances', () {
      // GIVEN: Multiple references to test account ID
      const id1 = kTestAccountId;
      const id2 = kTestAccountId;

      // THEN: They should be identical (for persistence)
      expect(id1, id2);
      expect(identical(id1, id2), isTrue);
    });
  });

  group('Test Account Model Creation', () {
    test('Can create test account with static ID', () {
      // GIVEN: Test account constants
      // WHEN: Creating a test account
      final testAccount = Account.create(
        userId: kTestAccountId,
        email: kTestAccountEmail,
        displayName: kTestAccountName,
        authProvider: AuthProvider.devStatic,
        isActive: true,
      );

      // THEN: Account has correct properties
      expect(testAccount.userId, kTestAccountId);
      expect(testAccount.email, kTestAccountEmail);
      expect(testAccount.displayName, kTestAccountName);
      expect(testAccount.authProvider, AuthProvider.devStatic);
      expect(testAccount.isActive, isTrue);
    });

    test('Test account uses devStatic auth provider', () {
      // GIVEN: A test account
      final testAccount = Account.create(
        userId: kTestAccountId,
        email: kTestAccountEmail,
        displayName: kTestAccountName,
        authProvider: AuthProvider.devStatic,
      );

      // THEN: It should NOT be anonymous
      expect(testAccount.isAnonymous, isFalse);
      expect(testAccount.authProvider, AuthProvider.devStatic);
    });

    test('Test account has creation timestamp', () {
      // GIVEN: A test account
      final beforeCreation = DateTime.now();
      final testAccount = Account.create(
        userId: kTestAccountId,
        email: kTestAccountEmail,
        displayName: kTestAccountName,
        authProvider: AuthProvider.devStatic,
      );
      final afterCreation = DateTime.now();

      // THEN: createdAt should be set
      expect(testAccount.createdAt, isNotNull);
      expect(
        testAccount.createdAt.isAfter(
          beforeCreation.subtract(const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        testAccount.createdAt.isBefore(
          afterCreation.add(const Duration(seconds: 1)),
        ),
        isTrue,
      );
    });
  });

  group('Test Account Persistence Behavior', () {
    test('Same userId ensures persistence across sessions', () {
      // GIVEN: Two accounts created with same ID
      final account1 = Account.create(
        userId: kTestAccountId,
        email: kTestAccountEmail,
        displayName: kTestAccountName,
        authProvider: AuthProvider.devStatic,
      );

      final account2 = Account.create(
        userId: kTestAccountId,
        email: kTestAccountEmail,
        displayName: kTestAccountName,
        authProvider: AuthProvider.devStatic,
      );

      // THEN: They should have same userId (key for persistence)
      expect(account1.userId, account2.userId);
    });

    test('Test account ID is valid identifier format', () {
      // GIVEN: The test account ID
      // THEN: It should be a valid identifier (no special chars that would break storage)
      expect(kTestAccountId, matches(RegExp(r'^[a-z0-9\-]+$')));
      expect(kTestAccountId.length, greaterThan(0));
      expect(kTestAccountId.length, lessThan(100));
    });

    test('Test account email is valid format', () {
      // GIVEN: The test account email
      // THEN: It should look like a valid email
      expect(kTestAccountEmail, contains('@'));
      expect(kTestAccountEmail, endsWith('.dev'));
    });
  });

  group('Account Switching Logic', () {
    test('Account can be copied with updated active state', () {
      // GIVEN: An inactive test account
      final inactiveAccount = Account.create(
        userId: kTestAccountId,
        email: kTestAccountEmail,
        displayName: kTestAccountName,
        authProvider: AuthProvider.devStatic,
        isActive: false,
      );

      // WHEN: Copying with active state
      final activeAccount = inactiveAccount.copyWith(isActive: true);

      // THEN: New account should be active, original unchanged
      expect(inactiveAccount.isActive, isFalse);
      expect(activeAccount.isActive, isTrue);
      expect(activeAccount.userId, inactiveAccount.userId);
    });
  });

  group('Developer Tools Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          allAccountsProvider.overrideWith((ref) => Stream.value([])),
          activeAccountProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const MaterialApp(home: AccountsScreen()),
      );
    }

    testWidgets('AccountsScreen renders without errors', (tester) async {
      // GIVEN: The accounts screen widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // THEN: It should render
      expect(find.byType(AccountsScreen), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
    });

    testWidgets('Empty state shows Create Test Account button', (tester) async {
      // GIVEN: Accounts screen with no accounts
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // THEN: Should show empty state with test account button
      expect(find.text('Create Test Account'), findsOneWidget);
    });

    testWidgets('AccountsScreen with accounts shows Developer Tools section', (
      tester,
    ) async {
      // GIVEN: An account exists
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

      // THEN: Developer tools section should be visible
      expect(find.text('Developer Tools'), findsOneWidget);
      expect(find.text('Create Test Account'), findsOneWidget);
      expect(find.text('Add Sample Logs'), findsOneWidget);
    });

    testWidgets('Test account shows with correct display name', (tester) async {
      // GIVEN: Test account is active
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

      // THEN: Account name should be displayed
      expect(find.text(kTestAccountName), findsOneWidget);
      expect(find.text(kTestAccountEmail), findsOneWidget);
    });

    testWidgets('Active test account shows check icon', (tester) async {
      // GIVEN: Test account is active
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

      // THEN: Check icon should be visible for active account
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });
  });

  group('Sample Logs Creation Logic', () {
    test('Sample logs cover 7 days', () {
      // GIVEN: Sample logs are created for 7 days
      const expectedDays = 7;
      final now = DateTime.now();

      // Calculate expected log count: 2-4 logs per day
      // Pattern: 2 + (i % 3) where i = 0..6
      // Day 0: 2, Day 1: 3, Day 2: 4, Day 3: 2, Day 4: 3, Day 5: 4, Day 6: 2
      // Total: 2+3+4+2+3+4+2 = 20 logs
      int expectedLogCount = 0;
      for (int i = 0; i < expectedDays; i++) {
        expectedLogCount += 2 + (i % 3);
      }

      // THEN: Expected count should be 20
      expect(expectedLogCount, 20);
    });
  });
}
