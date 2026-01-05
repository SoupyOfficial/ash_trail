import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/screens/auth/login_screen.dart';
import 'package:ash_trail/screens/auth/signup_screen.dart';
import 'package:ash_trail/services/account_integration_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountIntegrationService extends Fake
    implements AccountIntegrationService {
  bool shouldThrowOnSignIn = false;
  bool shouldThrowOnGoogle = false;
  int signInCalls = 0;
  int googleCalls = 0;

  @override
  Future<Account> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (shouldThrowOnSignIn) {
      throw Exception('Invalid credentials');
    }
    return Account.create(userId: 'user-1', email: email);
  }

  @override
  Future<Account> signInWithGoogle() async {
    googleCalls++;
    if (shouldThrowOnGoogle) {
      throw Exception('Google sign-in failed');
    }
    return Account.create(userId: 'user-1', email: 'user@gmail.com');
  }

  @override
  Future<Account> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return Account.create(userId: 'user-1', email: email);
  }

  @override
  Future<Account> syncAccountFromFirebaseUser(firebaseUser) async {
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
  group('LoginScreen', () {
    testWidgets('renders login screen UI', (tester) async {
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
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ash Trail'), findsOneWidget);
      expect(find.text('Track your journey'), findsOneWidget);
      expect(find.byKey(const Key('email-input')), findsOneWidget);
      expect(find.byKey(const Key('password-input')), findsOneWidget);
      expect(find.byKey(const Key('login-button')), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
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
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(fakeService.signInCalls, 0);
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
          child: const MaterialApp(home: LoginScreen()),
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

      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(fakeService.signInCalls, 0);
    });

    testWidgets('calls signInWithEmail on valid submission', (tester) async {
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
          child: const MaterialApp(home: LoginScreen()),
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

      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pump();

      expect(fakeService.signInCalls, 1);
    });

    testWidgets('displays error message on sign-in failure', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService =
          _FakeAccountIntegrationService()..shouldThrowOnSignIn = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountIntegrationServiceProvider.overrideWithValue(fakeService),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email-input')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password-input')),
        'wrongpassword',
      );

      await tester.tap(find.byKey(const Key('login-button')));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Invalid credentials'), findsOneWidget);
      expect(fakeService.signInCalls, 1);
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
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('calls signInWithGoogle', (tester) async {
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
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pump();

      expect(fakeService.googleCalls, 1);
    });

    testWidgets('navigates to signup screen', (tester) async {
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
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupScreen), findsOneWidget);
    });
  });
}
