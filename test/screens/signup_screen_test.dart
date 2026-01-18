import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/screens/auth/signup_screen.dart';
import 'package:ash_trail/services/account_integration_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountIntegrationService extends Fake
    implements AccountIntegrationService {
  bool shouldThrowOnSignUp = false;
  bool shouldThrowOnGoogle = false;
  int signUpCalls = 0;
  int googleCalls = 0;
  String? lastEmail;
  String? lastDisplayName;

  @override
  Future<Account> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    bool makeActive = true,
  }) async {
    signUpCalls++;
    lastEmail = email;
    lastDisplayName = displayName;
    if (shouldThrowOnSignUp) {
      throw Exception('Email already in use');
    }
    return Account.create(userId: 'user-1', email: email);
  }

  @override
  Future<Account> signInWithGoogle({bool makeActive = true}) async {
    googleCalls++;
    if (shouldThrowOnGoogle) {
      throw Exception('Google sign-in failed');
    }
    return Account.create(userId: 'user-1', email: 'user@gmail.com');
  }

  @override
  Future<Account> signInWithEmail({
    required String email,
    required String password,
    bool makeActive = true,
  }) async {
    return Account.create(userId: 'user-1', email: email);
  }

  @override
  Future<Account> syncAccountFromFirebaseUser(
    firebaseUser, {
    bool makeActive = true,
  }) async {
    return Account.create(userId: 'user-1', email: 'user@example.com');
  }

  @override
  Future<Account> updateProfile({String? displayName, String? photoURL}) async {
    return Account.create(userId: 'user-1', email: 'user@example.com');
  }

  @override
  Future<Account> updateEmail(String newEmail) async {
    return Account.create(userId: 'user-1', email: newEmail);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount(String password) async {}
}

void main() {
  group('SignupScreen', () {
    testWidgets('renders signup screen UI', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeAccountIntegrationService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Join Ash Trail'), findsOneWidget);
      expect(find.byKey(const Key('email-input')), findsOneWidget);
      expect(find.byKey(const Key('username-input')), findsOneWidget);
      expect(find.byKey(const Key('password-input')), findsOneWidget);
      expect(find.byKey(const Key('confirm-password-input')), findsOneWidget);
      expect(find.byKey(const Key('signup-button')), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeAccountIntegrationService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('signup-button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(fakeService.signUpCalls, 0);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeAccountIntegrationService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email-input')),
        'notanemail',
      );
      await tester.enterText(
        find.byKey(const Key('password-input')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('confirm-password-input')),
        'password123',
      );

      await tester.tap(find.byKey(const Key('signup-button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(fakeService.signUpCalls, 0);
    });

    testWidgets('shows error for short password', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeAccountIntegrationService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email-input')),
        'test@example.com',
      );
      await tester.enterText(find.byKey(const Key('password-input')), 'short');
      await tester.enterText(
        find.byKey(const Key('confirm-password-input')),
        'short',
      );

      await tester.tap(find.byKey(const Key('signup-button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
      expect(fakeService.signUpCalls, 0);
    });

    testWidgets('shows error for mismatched passwords', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeAccountIntegrationService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email-input')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password-input')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('confirm-password-input')),
        'different',
      );

      await tester.tap(find.byKey(const Key('signup-button')));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(fakeService.signUpCalls, 0);
    });

    testWidgets('calls signUpWithEmail on valid submission', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeAccountIntegrationService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email-input')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('username-input')),
        'TestUser',
      );
      await tester.enterText(
        find.byKey(const Key('password-input')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('confirm-password-input')),
        'password123',
      );

      await tester.tap(find.byKey(const Key('signup-button')));
      await tester.pump();

      expect(fakeService.signUpCalls, 1);
      expect(fakeService.lastEmail, 'test@example.com');
      expect(fakeService.lastDisplayName, 'TestUser');
    });

    testWidgets('displays error message on signup failure', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService =
          _FakeAccountIntegrationService()..shouldThrowOnSignUp = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email-input')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password-input')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('confirm-password-input')),
        'password123',
      );

      await tester.tap(find.byKey(const Key('signup-button')));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Email already in use'), findsOneWidget);
      expect(fakeService.signUpCalls, 1);
    });

    testWidgets('toggles password visibility', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeAccountIntegrationService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
