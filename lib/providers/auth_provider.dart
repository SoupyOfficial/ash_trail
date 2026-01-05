import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Provider for AuthService instance (singleton)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for current Firebase user
/// Returns null if not authenticated, User object if authenticated
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (user) => user != null, orElse: () => false);
});

/// Provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (user) => user?.uid, orElse: () => null);
});

/// Provider for current user email
final currentUserEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (user) => user?.email, orElse: () => null);
});

/// Provider for current user display name
final currentUserDisplayNameProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user?.displayName,
    orElse: () => null,
  );
});
