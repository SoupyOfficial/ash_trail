import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../logging/app_logger.dart';
import '../models/app_error.dart';
import 'crash_reporting_service.dart';
import 'error_reporting_service.dart';

/// Service for handling authentication with Firebase Auth
/// Supports email/password, Google Sign-In, and Apple Sign-In
class AuthService {
  static final _log = AppLogger.logger('AuthService');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Constructor with optional GoogleSignIn for testing
  AuthService({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            clientId:
                '660497517730-dlv557f6uvb4ccre13gcrpcqf8cgg2r0.apps.googleusercontent.com',
            scopes: ['email', 'profile'],
            signInOption: SignInOption.standard,
            forceCodeForRefreshToken: true,
          );

  // Storage keys
  static const String _keyUserId = 'userId';
  static const String _keyEmail = 'email';
  static const String _keyDisplayName = 'displayName';

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      // Store user info securely
      await _storeUserInfo(userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e, st) {
      throw _toAppError(e, st);
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user info securely
      await _storeUserInfo(userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e, st) {
      throw _toAppError(e, st);
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    final stopwatch = Stopwatch()..start();
    try {
      _log.w('[GOOGLE_SIGN_IN_START] Beginning Google sign-in flow');
      CrashReportingService.logMessage('Starting Google sign-in');

      _log.d(
        '[GOOGLE_SIGN_IN] GoogleSignIn config: clientId=${_googleSignIn.clientId}, '
        'scopes=${_googleSignIn.scopes}',
      );

      try {
        _log.d('[GOOGLE_SIGN_IN] Signing out previous Google session...');
        await _googleSignIn.signOut();
        _log.d('[GOOGLE_SIGN_IN] Previous Google session cleared');
      } catch (e) {
        _log.w(
          '[GOOGLE_SIGN_IN] Could not sign out before sign-in (non-fatal)',
          error: e,
        );
      }

      _log.w('[GOOGLE_SIGN_IN] Presenting Google sign-in UI...');
      CrashReportingService.logMessage('Calling GoogleSignIn.signIn()');

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _log.w('[GOOGLE_SIGN_IN] User cancelled Google sign-in dialog');
        throw AppError.auth(
          message: 'Google sign-in was cancelled.',
          code: 'AUTH_GOOGLE_CANCELLED',
        );
      }

      _log.w(
        '[GOOGLE_SIGN_IN] Google account selected: '
        'email=${googleUser.email}, id=${googleUser.id}, '
        'displayName=${googleUser.displayName}',
      );
      CrashReportingService.logMessage(
        'Google user obtained: ${googleUser.email}',
      );

      // Obtain auth details
      _log.d('[GOOGLE_SIGN_IN] Requesting Google auth tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Validate tokens
      final hasAccessToken = googleAuth.accessToken != null;
      final hasIdToken = googleAuth.idToken != null;
      _log.w(
        '[GOOGLE_SIGN_IN] Token status: '
        'accessToken=${hasAccessToken ? "present (${googleAuth.accessToken!.length} chars)" : "MISSING"}, '
        'idToken=${hasIdToken ? "present (${googleAuth.idToken!.length} chars)" : "MISSING"}',
      );

      if (!hasAccessToken) {
        _log.e('[GOOGLE_SIGN_IN] CRITICAL: No access token from Google');
        throw AppError.auth(
          message: 'Failed to obtain Google access token. Please try again.',
          code: 'AUTH_GOOGLE_NO_TOKEN',
        );
      }

      CrashReportingService.logMessage('Google auth tokens obtained');

      // Create Firebase credential
      _log.d(
        '[GOOGLE_SIGN_IN] Creating Firebase credential from Google tokens...',
      );
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      _log.w(
        '[GOOGLE_SIGN_IN] Signing in to Firebase with Google credential...',
      );
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        _log.e(
          '[GOOGLE_SIGN_IN] Firebase returned null user after credential sign-in',
        );
        throw AppError.auth(
          message: 'Authentication failed. Please try again.',
          code: 'AUTH_FIREBASE_NULL_USER',
        );
      }

      final user = userCredential.user!;
      _log.w(
        '[GOOGLE_SIGN_IN] Firebase auth SUCCESS: '
        'uid=${user.uid}, email=${user.email}, '
        'displayName=${user.displayName}, '
        'isNewUser=${userCredential.additionalUserInfo?.isNewUser}, '
        'providerId=${userCredential.additionalUserInfo?.providerId}, '
        'providerData=${user.providerData.map((p) => p.providerId).toList()}',
      );

      // Store user info securely
      await _storeUserInfo(userCredential.user);

      stopwatch.stop();
      _log.w(
        '[GOOGLE_SIGN_IN_END] Google sign-in completed in ${stopwatch.elapsedMilliseconds}ms',
      );
      CrashReportingService.logMessage('Google sign-in successful');
      return userCredential;
    } on FirebaseAuthException catch (e, st) {
      stopwatch.stop();
      _log.e(
        '[GOOGLE_SIGN_IN] Firebase auth exception after ${stopwatch.elapsedMilliseconds}ms: '
        'code=${e.code}, message=${e.message}',
      );
      final appError = _toAppError(e, st);
      ErrorReportingService.instance.report(
        appError,
        stackTrace: st,
        context: 'AuthService.signInWithGoogle',
      );
      throw appError;
    } on AppError {
      stopwatch.stop();
      rethrow;
    } catch (e, st) {
      stopwatch.stop();
      _log.e(
        '[GOOGLE_SIGN_IN] Error after ${stopwatch.elapsedMilliseconds}ms: '
        'type=${e.runtimeType}, message=$e',
      );
      final appError = AppError.auth(
        message: 'Failed to sign in with Google. Please try again.',
        originalError: e,
        stackTrace: st,
        code: 'AUTH_GOOGLE_FAILED',
      );
      ErrorReportingService.instance.report(
        appError,
        stackTrace: st,
        context: 'AuthService.signInWithGoogle',
      );
      throw appError;
    }
  }

  /// Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential from Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create Firebase credential
      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Update display name if provided and not already set
      if (userCredential.user?.displayName == null &&
          appleCredential.givenName != null) {
        final displayName =
            '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                .trim();
        await userCredential.user?.updateDisplayName(displayName);
      }

      // Store user info securely
      await _storeUserInfo(userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e, st) {
      throw _toAppError(e, st);
    } on SignInWithAppleAuthorizationException catch (e, st) {
      throw AppError.auth(
        message: 'Apple sign-in failed: ${e.message}',
        originalError: e,
        stackTrace: st,
        code: 'AUTH_APPLE_FAILED',
      );
    } catch (e, st) {
      throw AppError.auth(
        message: 'Failed to sign in with Apple. Please try again.',
        originalError: e,
        stackTrace: st,
        code: 'AUTH_APPLE_FAILED',
      );
    }
  }

  /// Generate a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the sha256 hash of [input] in hex notation
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Clear stored user info
      await _clearUserInfo();
    } catch (e, st) {
      throw AppError.auth(
        message: 'Failed to sign out. Please try again.',
        originalError: e,
        stackTrace: st,
        code: 'AUTH_SIGNOUT_FAILED',
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, st) {
      throw _toAppError(e, st);
    }
  }

  /// Update user profile (display name, photo URL)
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AppError.auth(
          message: 'No user currently signed in.',
          code: 'AUTH_NO_USER',
        );
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Reload user to get updated info
      await user.reload();

      // Update stored info
      await _storeUserInfo(_auth.currentUser);
    } on FirebaseAuthException catch (e, st) {
      throw _toAppError(e, st);
    } catch (e, st) {
      throw AppError.auth(
        message: 'Failed to update profile.',
        originalError: e,
        stackTrace: st,
        code: 'AUTH_PROFILE_UPDATE_FAILED',
      );
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AppError.auth(
          message: 'No user currently signed in.',
          code: 'AUTH_NO_USER',
        );
      }

      await user.verifyBeforeUpdateEmail(newEmail);

      // Update stored info
      await _storeUserInfo(_auth.currentUser);
    } on FirebaseAuthException catch (e, st) {
      throw _toAppError(e, st);
    } catch (e, st) {
      throw AppError.auth(
        message: 'Failed to update email.',
        originalError: e,
        stackTrace: st,
        code: 'AUTH_EMAIL_UPDATE_FAILED',
      );
    }
  }

  /// Change password (requires current password for re-authentication)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AppError.auth(
          message: 'No user currently signed in.',
          code: 'AUTH_NO_USER',
        );
      }

      if (user.email == null) {
        throw AppError.auth(
          message: 'Email is required to change password.',
          code: 'AUTH_NO_EMAIL',
        );
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e, st) {
      throw _toAppError(e, st);
    } catch (e, st) {
      throw AppError.auth(
        message: 'Failed to change password.',
        originalError: e,
        stackTrace: st,
        code: 'AUTH_PASSWORD_CHANGE_FAILED',
      );
    }
  }

  /// Delete user account (requires password for re-authentication)
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AppError.auth(
          message: 'No user currently signed in.',
          code: 'AUTH_NO_USER',
        );
      }

      // Re-authenticate for security
      if (user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Delete the user account
      await user.delete();

      // Clear stored user info
      await _clearUserInfo();
    } on FirebaseAuthException catch (e, st) {
      throw _toAppError(e, st);
    } catch (e, st) {
      throw AppError.auth(
        message: 'Failed to delete account.',
        originalError: e,
        stackTrace: st,
        code: 'AUTH_DELETE_FAILED',
      );
    }
  }

  /// Re-authenticate user (for sensitive operations)
  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw AppError.auth(
          message: 'User not signed in or email not available.',
          code: 'AUTH_NO_USER',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e, st) {
      throw _toAppError(e, st);
    }
  }

  /// Store user info securely
  Future<void> _storeUserInfo(User? user) async {
    if (user != null) {
      await _secureStorage.write(key: _keyUserId, value: user.uid);
      await _secureStorage.write(key: _keyEmail, value: user.email ?? '');
      await _secureStorage.write(
        key: _keyDisplayName,
        value: user.displayName ?? '',
      );
    }
  }

  /// Clear stored user info
  Future<void> _clearUserInfo() async {
    await _secureStorage.delete(key: _keyUserId);
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyDisplayName);
  }

  /// Get stored user ID
  Future<String?> getStoredUserId() async {
    return await _secureStorage.read(key: _keyUserId);
  }

  /// Get stored email
  Future<String?> getStoredEmail() async {
    return await _secureStorage.read(key: _keyEmail);
  }

  /// Get stored display name
  Future<String?> getStoredDisplayName() async {
    return await _secureStorage.read(key: _keyDisplayName);
  }

  /// Convert a [FirebaseAuthException] into a typed [AppError].
  AppError _toAppError(FirebaseAuthException e, [StackTrace? st]) {
    final String message;
    final String code;

    switch (e.code) {
      case 'weak-password':
        message = 'The password provided is too weak.';
        code = 'AUTH_WEAK_PASSWORD';
      case 'email-already-in-use':
        message = 'An account already exists for that email.';
        code = 'AUTH_EMAIL_IN_USE';
      case 'user-not-found':
        message = 'No user found for that email.';
        code = 'AUTH_USER_NOT_FOUND';
      case 'wrong-password':
        message = 'Wrong password provided.';
        code = 'AUTH_WRONG_PASSWORD';
      case 'invalid-email':
        message = 'The email address is not valid.';
        code = 'AUTH_INVALID_EMAIL';
      case 'user-disabled':
        message = 'This user account has been disabled.';
        code = 'AUTH_USER_DISABLED';
      case 'too-many-requests':
        message = 'Too many requests. Please try again later.';
        code = 'AUTH_RATE_LIMITED';
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled.';
        code = 'AUTH_METHOD_DISABLED';
      case 'network-request-failed':
        message = 'Network error. Please check your connection.';
        code = 'AUTH_NETWORK';
      default:
        message = e.message ?? 'An authentication error occurred.';
        code = 'AUTH_${e.code.toUpperCase()}';
    }

    return AppError.auth(
      message: message,
      originalError: e,
      stackTrace: st,
      code: code,
    );
  }
}
