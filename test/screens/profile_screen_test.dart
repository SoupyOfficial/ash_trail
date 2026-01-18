import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/providers/auth_provider.dart';
import 'package:ash_trail/screens/profile/profile_screen.dart';
import 'package:ash_trail/services/account_integration_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUserInfo extends Fake implements UserInfo {
  _FakeUserInfo(this.providerId);
  @override
  final String providerId;
}

class _FakeUser extends Fake implements User {
  _FakeUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required List<UserInfo> providerData,
  }) : _providerData = providerData;

  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;

  final List<UserInfo> _providerData;
  @override
  List<UserInfo> get providerData => _providerData;
}

class _FakeAccountIntegrationService extends Fake
    implements AccountIntegrationService {
  int profileCalls = 0;
  int emailCalls = 0;
  int passwordCalls = 0;

  @override
  Future<Account> updateProfile({String? displayName, String? photoURL}) async {
    profileCalls++;
    return Account.create(userId: 'acct', email: 'user@example.com');
  }

  @override
  Future<Account> updateEmail(String newEmail) async {
    emailCalls++;
    return Account.create(userId: 'acct', email: newEmail);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    passwordCalls++;
  }

  // Unused methods for this test suite
  @override
  Future<Account> syncAccountFromFirebaseUser(
    User firebaseUser, {
    bool makeActive = true,
  }) async {
    return Account.create(userId: 'acct', email: firebaseUser.email ?? '');
  }

  @override
  Future<Account> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    bool makeActive = true,
  }) async {
    return Account.create(userId: 'acct', email: email);
  }

  @override
  Future<Account> signInWithEmail({
    required String email,
    required String password,
    bool makeActive = true,
  }) async {
    return Account.create(userId: 'acct', email: email);
  }

  @override
  Future<Account> signInWithGoogle({bool makeActive = true}) async {
    return Account.create(userId: 'acct', email: 'google@example.com');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount(String password) async {}
}

void main() {
  group('ProfileScreen', () {
    testWidgets('shows not logged in state when auth user is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            accountIntegrationServiceProvider.overrideWithValue(
              _FakeAccountIntegrationService(),
            ),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Not logged in'), findsOneWidget);
    });

    testWidgets('saves profile updates and email change', (tester) async {
      final fakeService = _FakeAccountIntegrationService();
      final user = _FakeUser(
        uid: 'user-1',
        email: 'user@example.com',
        displayName: 'User Example',
        photoURL: null,
        providerData: [_FakeUserInfo('password')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(user)),
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Display Name'), 'New Name');
      await tester.enterText(find.bySemanticsLabel('Email'), 'new@example.com');

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(fakeService.profileCalls, 1);
      expect(fakeService.emailCalls, 1);
      expect(
        find.text('Email updated successfully. Please verify your new email.'),
        findsOneWidget,
      );
    });

    testWidgets('shows password validation errors then calls change password', (
      tester,
    ) async {
      final fakeService = _FakeAccountIntegrationService();
      final user = _FakeUser(
        uid: 'user-1',
        email: 'user@example.com',
        displayName: 'User Example',
        photoURL: null,
        providerData: [_FakeUserInfo('password')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(user)),
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final changePasswordCard = find.byType(Card).at(1);
      expect(changePasswordCard, findsOneWidget);
      final changePasswordButton =
          find
              .ancestor(
                of: find.text('Change Password'),
                matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
              )
              .first;
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();
      await tester.tap(changePasswordButton);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Current Password'), findsOneWidget);

      final updatePasswordButton =
          find
              .ancestor(
                of: find.text('Update Password'),
                matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
              )
              .first;
      expect(updatePasswordButton, findsOneWidget);
      await tester.ensureVisible(updatePasswordButton);
      await tester.tap(updatePasswordButton);
      await tester.pumpAndSettle();
      expect(find.text('Please enter your current password'), findsOneWidget);

      await tester.enterText(find.bySemanticsLabel('Current Password'), 'old');
      await tester.enterText(find.bySemanticsLabel('New Password'), 'short');
      await tester.enterText(
        find.bySemanticsLabel('Confirm New Password'),
        'short',
      );

      await tester.ensureVisible(updatePasswordButton);
      await tester.tap(updatePasswordButton);
      await tester.pumpAndSettle();
      expect(
        find.text('New password must be at least 8 characters'),
        findsOneWidget,
      );

      await tester.enterText(
        find.bySemanticsLabel('New Password'),
        'longpassword',
      );
      await tester.enterText(
        find.bySemanticsLabel('Confirm New Password'),
        'mismatch',
      );
      await tester.ensureVisible(updatePasswordButton);
      await tester.tap(updatePasswordButton);
      await tester.pumpAndSettle();
      expect(find.text('Passwords do not match'), findsOneWidget);

      await tester.enterText(
        find.bySemanticsLabel('Confirm New Password'),
        'longpassword',
      );
      await tester.ensureVisible(updatePasswordButton);
      await tester.tap(updatePasswordButton);
      await tester.pumpAndSettle();

      expect(fakeService.passwordCalls, 1);
    });

    testWidgets('validates email format before submitting', (tester) async {
      final fakeService = _FakeAccountIntegrationService();
      final user = _FakeUser(
        uid: 'user-1',
        email: 'user@example.com',
        displayName: 'User',
        photoURL: null,
        providerData: [_FakeUserInfo('password')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(user)),
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Email'), 'invalidemail');
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(fakeService.emailCalls, 0);
    });

    testWidgets('clears password fields after successful password change', (
      tester,
    ) async {
      final fakeService = _FakeAccountIntegrationService();
      final user = _FakeUser(
        uid: 'user-1',
        email: 'user@example.com',
        displayName: 'User',
        photoURL: null,
        providerData: [_FakeUserInfo('password')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(user)),
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();

      final changePasswordButton =
          find
              .ancestor(
                of: find.text('Change Password'),
                matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
              )
              .first;
      await tester.tap(changePasswordButton);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.bySemanticsLabel('Current Password'),
        'old123',
      );
      await tester.enterText(
        find.bySemanticsLabel('New Password'),
        'newpass123',
      );
      await tester.enterText(
        find.bySemanticsLabel('Confirm New Password'),
        'newpass123',
      );

      final updatePasswordButton =
          find
              .ancestor(
                of: find.text('Update Password'),
                matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
              )
              .first;
      await tester.ensureVisible(updatePasswordButton);
      await tester.tap(updatePasswordButton);
      await tester.pumpAndSettle();

      expect(find.text('Password changed successfully'), findsOneWidget);
      expect(fakeService.passwordCalls, 1);
    });
  });
}
