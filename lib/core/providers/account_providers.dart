// Phase 1 placeholder account providers for basic home screen integration.
// These provide mock account functionality until full account system is implemented in Phase 2.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/account.dart';

/// Mock active account provider for Phase 1
/// Returns a placeholder account to enable basic home screen functionality
final activeAccountProvider = StateProvider<Account?>((ref) {
  // Phase 1: Mock account for development and basic functionality
  return const Account(
    id: 'phase1-mock-account',
    displayName: 'Development User',
    firstName: 'Dev',
    lastName: 'User',
    email: 'dev@ashtrail.local',
    provider: 'mock',
  );
});

/// Current account ID provider for convenience
/// Returns the active account's ID or null if no account
final currentAccountIdProvider = Provider<String?>((ref) {
  final account = ref.watch(activeAccountProvider);
  return account?.id;
});

/// Account display name provider for UI
/// Returns the display name or a fallback for signed-out state
final accountDisplayNameProvider = Provider<String>((ref) {
  final account = ref.watch(activeAccountProvider);
  return account?.displayName ?? 'Guest User';
});

/// Account signed in status provider
/// Returns true if there's an active account, false otherwise
final isSignedInProvider = Provider<bool>((ref) {
  final account = ref.watch(activeAccountProvider);
  return account != null;
});

/// Mock sign out action for Phase 1
/// Sets the active account to null
class MockAccountController extends StateNotifier<Account?> {
  MockAccountController()
      : super(
          const Account(
            id: 'phase1-mock-account',
            displayName: 'Development User',
            firstName: 'Dev',
            lastName: 'User',
            email: 'dev@ashtrail.local',
            provider: 'mock',
          ),
        );

  void signOut() {
    state = null;
  }

  void signInMock() {
    state = const Account(
      id: 'phase1-mock-account',
      displayName: 'Development User',
      firstName: 'Dev',
      lastName: 'User',
      email: 'dev@ashtrail.local',
      provider: 'mock',
    );
  }

  void switchToSecondaryAccount() {
    state = const Account(
      id: 'phase1-mock-account-2',
      displayName: 'Test User',
      firstName: 'Test',
      lastName: 'User',
      email: 'test@ashtrail.local',
      provider: 'mock',
    );
  }
}

/// Mock account controller provider
final mockAccountControllerProvider =
    StateNotifierProvider<MockAccountController, Account?>((ref) {
  return MockAccountController();
});
