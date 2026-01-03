import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ash_trail/providers/auth_provider.dart';
import 'package:ash_trail/services/auth_service.dart';

/// Fake User for testing without Firebase dependency
class FakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  FakeUser({required this.uid, this.email, this.displayName});

  // Required User interface implementations - not used in tests
  @override
  bool get emailVerified => true;
  @override
  bool get isAnonymous => false;
  @override
  UserMetadata get metadata => throw UnimplementedError();
  @override
  List<UserInfo> get providerData => [];
  @override
  String? get phoneNumber => null;
  @override
  String? get photoURL => null;
  @override
  String? get refreshToken => 'fake-refresh-token';
  @override
  String? get tenantId => null;
  @override
  Future<void> delete() async {}
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async => 'fake-token';
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) =>
      throw UnimplementedError();
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) =>
      throw UnimplementedError();
  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) =>
      throw UnimplementedError();
  @override
  Future<ConfirmationResult> linkWithPhoneNumber(
    String phoneNumber, [
    RecaptchaVerifier? verifier,
  ]) => throw UnimplementedError();
  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) => throw UnimplementedError();
  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) =>
      throw UnimplementedError();
  @override
  Future<void> reload() async {}
  @override
  Future<void> sendEmailVerification([
    ActionCodeSettings? actionCodeSettings,
  ]) async {}
  @override
  Future<User> unlink(String providerId) => throw UnimplementedError();
  @override
  Future<void> updateDisplayName(String? displayName) async {}
  @override
  Future<void> updateEmail(String newEmail) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {}
  @override
  Future<void> updatePhotoURL(String? photoURL) async {}
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}
  @override
  Future<void> verifyBeforeUpdateEmail(
    String newEmail, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {}
  @override
  MultiFactor get multiFactor => throw UnimplementedError();
  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) =>
      throw UnimplementedError();
  @override
  Future<void> linkWithRedirect(AuthProvider provider) =>
      throw UnimplementedError();
  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) =>
      throw UnimplementedError();
  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) =>
      throw UnimplementedError();
}

/// Fake UserCredential for testing
class FakeUserCredential implements UserCredential {
  @override
  final User? user;
  @override
  final AdditionalUserInfo? additionalUserInfo = null;
  @override
  final AuthCredential? credential = null;

  FakeUserCredential({this.user});
}

/// Mock AuthService for testing
/// Only implements what's needed for testing the providers
class MockAuthService implements AuthService {
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();
  User? _currentUser;
  bool throwOnSignIn = false;
  bool throwOnSignOut = false;
  int authStateChangesAccessCount = 0;

  @override
  Stream<User?> get authStateChanges {
    authStateChangesAccessCount++;
    return _authStateController.stream;
  }

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  void emitUser(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  void emitError(Object error) {
    _authStateController.addError(error);
  }

  void dispose() {
    _authStateController.close();
  }

  // Required AuthService interface implementations
  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (throwOnSignIn) throw Exception('Mock sign-in error');
    final user = FakeUser(uid: 'signed-in-user', email: email);
    emitUser(user);
    return FakeUserCredential(user: user);
  }

  @override
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (throwOnSignIn) throw Exception('Mock sign-up error');
    final user = FakeUser(
      uid: 'new-user',
      email: email,
      displayName: displayName,
    );
    emitUser(user);
    return FakeUserCredential(user: user);
  }

  @override
  Future<void> signOut() async {
    if (throwOnSignOut) throw Exception('Mock sign-out error');
    emitUser(null);
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    if (throwOnSignIn) throw Exception('Mock Google sign-in error');
    final user = FakeUser(uid: 'google-user', email: 'google@example.com');
    emitUser(user);
    return FakeUserCredential(user: user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> deleteAccount(String password) async {
    emitUser(null);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}

  @override
  Future<void> updateEmail(String newEmail) async {}

  @override
  Future<void> reauthenticate(String password) async {}

  @override
  Future<String?> getStoredUserId() async => _currentUser?.uid;

  @override
  Future<String?> getStoredEmail() async => _currentUser?.email;

  @override
  Future<String?> getStoredDisplayName() async => _currentUser?.displayName;
}

void main() {
  group('Auth Provider Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    tearDown(() {
      mockAuthService.dispose();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(mockAuthService)],
      );
    }

    group('authStateProvider', () {
      test('emits null when no user is authenticated', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Listen to the provider
        final subscription = container.listen(
          authStateProvider,
          (previous, next) {},
        );

        // Wait for initial loading state
        await Future.delayed(Duration.zero);

        // Emit null user
        mockAuthService.emitUser(null);
        await Future.delayed(Duration.zero);

        final state = subscription.read();
        expect(state.value, isNull);
      });

      test('emits User when authenticated', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fakeUser = FakeUser(
          uid: 'test-uid-123',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        // Listen to the provider
        final subscription = container.listen(
          authStateProvider,
          (previous, next) {},
        );

        await Future.delayed(Duration.zero);

        // Emit authenticated user
        mockAuthService.emitUser(fakeUser);
        await Future.delayed(Duration.zero);

        final state = subscription.read();
        expect(state.value?.uid, equals('test-uid-123'));
        expect(state.value?.email, equals('test@example.com'));
      });

      test('handles auth state transitions', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fakeUser = FakeUser(uid: 'uid-transition');

        final uids = <String?>[];
        container.listen(authStateProvider, (previous, next) {
          if (next.hasValue) {
            uids.add(next.value?.uid);
          }
        });

        await Future.delayed(Duration.zero);

        // Emit: null -> user -> null (login then logout)
        mockAuthService.emitUser(null);
        await Future.delayed(Duration.zero);
        mockAuthService.emitUser(fakeUser);
        await Future.delayed(Duration.zero);
        mockAuthService.emitUser(null);
        await Future.delayed(Duration.zero);

        expect(uids, [null, 'uid-transition', null]);
      });

      test('handles stream errors gracefully', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          authStateProvider,
          (previous, next) {},
        );

        await Future.delayed(Duration.zero);

        // Emit an error
        mockAuthService.emitError(Exception('Auth error'));
        await Future.delayed(Duration.zero);

        final state = subscription.read();
        expect(state.hasError, isTrue);
      });
    });

    group('isAuthenticatedProvider', () {
      test('returns false when user is null', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Listen to trigger evaluation
        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(null);
        await Future.delayed(Duration.zero);

        final isAuthenticated = container.read(isAuthenticatedProvider);
        expect(isAuthenticated, isFalse);
      });

      test('returns true when user is authenticated', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fakeUser = FakeUser(uid: 'auth-user');

        // Listen to trigger evaluation
        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(fakeUser);
        await Future.delayed(Duration.zero);

        final isAuthenticated = container.read(isAuthenticatedProvider);
        expect(isAuthenticated, isTrue);
      });

      test('returns false during loading state', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Don't emit anything - still in loading state
        final isAuthenticated = container.read(isAuthenticatedProvider);
        expect(isAuthenticated, isFalse);
      });
    });

    group('currentUserIdProvider', () {
      test('returns null when not authenticated', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(null);
        await Future.delayed(Duration.zero);

        final userId = container.read(currentUserIdProvider);
        expect(userId, isNull);
      });

      test('returns uid when authenticated', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fakeUser = FakeUser(uid: 'user-id-abc');

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(fakeUser);
        await Future.delayed(Duration.zero);

        final userId = container.read(currentUserIdProvider);
        expect(userId, equals('user-id-abc'));
      });
    });

    group('currentUserEmailProvider', () {
      test('returns null when not authenticated', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(null);
        await Future.delayed(Duration.zero);

        final email = container.read(currentUserEmailProvider);
        expect(email, isNull);
      });

      test('returns email when authenticated', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fakeUser = FakeUser(uid: 'user', email: 'test@example.com');

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(fakeUser);
        await Future.delayed(Duration.zero);

        final email = container.read(currentUserEmailProvider);
        expect(email, equals('test@example.com'));
      });

      test('returns null for OAuth users without email', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fakeUser = FakeUser(uid: 'oauth-user', email: null);

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(fakeUser);
        await Future.delayed(Duration.zero);

        final email = container.read(currentUserEmailProvider);
        expect(email, isNull);
      });
    });

    group('currentUserDisplayNameProvider', () {
      test('returns null when not authenticated', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(null);
        await Future.delayed(Duration.zero);

        final displayName = container.read(currentUserDisplayNameProvider);
        expect(displayName, isNull);
      });

      test('returns displayName when set', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fakeUser = FakeUser(uid: 'user', displayName: 'John Doe');

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(fakeUser);
        await Future.delayed(Duration.zero);

        final displayName = container.read(currentUserDisplayNameProvider);
        expect(displayName, equals('John Doe'));
      });

      test('returns null when displayName not set', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fakeUser = FakeUser(uid: 'user', displayName: null);

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(fakeUser);
        await Future.delayed(Duration.zero);

        final displayName = container.read(currentUserDisplayNameProvider);
        expect(displayName, isNull);
      });
    });

    group('Edge Cases', () {
      test('handles rapid auth state changes', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fakeUser1 = FakeUser(uid: 'user-1');
        final fakeUser2 = FakeUser(uid: 'user-2');

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        // Rapid transitions
        mockAuthService.emitUser(fakeUser1);
        mockAuthService.emitUser(fakeUser2);
        mockAuthService.emitUser(null);
        mockAuthService.emitUser(fakeUser1);
        await Future.delayed(Duration.zero);

        // Should settle on the last emitted value
        final state = container.read(authStateProvider);
        expect(state.value?.uid, equals('user-1'));
      });

      test('provider properly watches authService', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Reset count
        mockAuthService.authStateChangesAccessCount = 0;

        // Access authStateProvider triggers watch of authService
        container.read(authStateProvider);

        // Verify authStateChanges was accessed
        expect(
          mockAuthService.authStateChangesAccessCount,
          greaterThanOrEqualTo(1),
        );
      });

      test('handles user with all fields populated', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final fullUser = FakeUser(
          uid: 'full-user-id',
          email: 'full@example.com',
          displayName: 'Full User',
        );

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(fullUser);
        await Future.delayed(Duration.zero);

        expect(container.read(currentUserIdProvider), equals('full-user-id'));
        expect(
          container.read(currentUserEmailProvider),
          equals('full@example.com'),
        );
        expect(
          container.read(currentUserDisplayNameProvider),
          equals('Full User'),
        );
        expect(container.read(isAuthenticatedProvider), isTrue);
      });

      test('handles empty string values', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final userWithEmptyStrings = FakeUser(
          uid: '',
          email: '',
          displayName: '',
        );

        container.listen(authStateProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAuthService.emitUser(userWithEmptyStrings);
        await Future.delayed(Duration.zero);

        expect(container.read(currentUserIdProvider), equals(''));
        expect(container.read(currentUserEmailProvider), equals(''));
        expect(container.read(currentUserDisplayNameProvider), equals(''));
        // Still considered authenticated since user object exists
        expect(container.read(isAuthenticatedProvider), isTrue);
      });
    });
  });
}
