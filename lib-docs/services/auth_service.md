# auth_service

> **Source:** `lib/services/auth_service.dart`

## Purpose

Handles all Firebase Authentication operations including email/password sign-in/sign-up, Google Sign-In, Apple Sign-In, profile management, and password changes. Stores user credentials securely in `FlutterSecureStorage`. Provides comprehensive structured logging and crash reporting for the Google Sign-In flow.

## Dependencies

- `package:firebase_auth/firebase_auth.dart` — Firebase Auth SDK (User, UserCredential, providers)
- `package:google_sign_in/google_sign_in.dart` — Native Google Sign-In flow
- `package:sign_in_with_apple/sign_in_with_apple.dart` — Apple Sign-In
- `package:flutter_secure_storage/flutter_secure_storage.dart` — Encrypted local key-value store
- `package:crypto/crypto.dart` — SHA-256 hashing for Apple Sign-In nonce
- `dart:convert` — UTF-8 encoding
- `dart:math` — Secure random nonce generation
- `../logging/app_logger.dart` — Structured logging via `AppLogger`
- `crash_reporting_service.dart` — Crashlytics integration

## Pseudo-Code

### Class: AuthService

#### Fields
- `_log` — static logger tagged `'AuthService'`
- `_auth` — `FirebaseAuth.instance`
- `_googleSignIn` — `GoogleSignIn` (injected or default with clientId, scopes=[email, profile])
- `_secureStorage` — `FlutterSecureStorage`
- Storage keys: `_keyUserId`, `_keyEmail`, `_keyDisplayName`

#### Constructor

```
AuthService({googleSignIn?}):
  _googleSignIn = googleSignIn ?? GoogleSignIn(
    clientId = '660497...apps.googleusercontent.com',
    scopes = ['email', 'profile'],
    signInOption = standard,
    forceCodeForRefreshToken = true
  )
```

#### Properties
- `currentUser → User?` — `_auth.currentUser`
- `authStateChanges → Stream<User?>` — `_auth.authStateChanges()`
- `isAuthenticated → bool` — `currentUser != null`

---

#### `signUpWithEmail({email, password, displayName?}) → Future<UserCredential>`

```
TRY:
  userCredential = AWAIT _auth.createUserWithEmailAndPassword(email, password)
  IF displayName != null AND not empty:
    AWAIT userCredential.user.updateDisplayName(displayName)
  AWAIT _storeUserInfo(userCredential.user)
  RETURN userCredential
CATCH FirebaseAuthException e:
  THROW _handleAuthException(e)
```

---

#### `signInWithEmail({email, password}) → Future<UserCredential>`

```
TRY:
  userCredential = AWAIT _auth.signInWithEmailAndPassword(email, password)
  AWAIT _storeUserInfo(userCredential.user)
  RETURN userCredential
CATCH FirebaseAuthException e:
  THROW _handleAuthException(e)
```

---

#### `signInWithGoogle() → Future<UserCredential>`

```
stopwatch.start()
TRY:
  LOG [GOOGLE_SIGN_IN_START]
  CrashReportingService.logMessage('Starting Google sign-in')
  LOG GoogleSignIn config (clientId, scopes)

  // Clear previous session (non-fatal if fails)
  TRY: AWAIT _googleSignIn.signOut()
  CATCH: LOG warning (non-fatal)

  LOG 'Presenting Google sign-in UI...'
  googleUser = AWAIT _googleSignIn.signIn()

  IF googleUser == null:
    LOG 'User cancelled'
    THROW 'Google sign-in was cancelled by user'

  LOG Google account selected: email, id, displayName

  // Get auth tokens
  googleAuth = AWAIT googleUser.authentication
  hasAccessToken = googleAuth.accessToken != null
  hasIdToken    = googleAuth.idToken != null
  LOG Token status: accessToken present/MISSING, idToken present/MISSING

  IF !hasAccessToken:
    LOG CRITICAL: No access token
    THROW 'Failed to obtain Google access token'

  // Create Firebase credential and sign in
  credential = GoogleAuthProvider.credential(accessToken, idToken)
  LOG 'Signing in to Firebase...'
  userCredential = AWAIT _auth.signInWithCredential(credential)

  IF userCredential.user == null:
    THROW 'Firebase authentication failed'

  LOG Firebase auth SUCCESS: uid, email, isNewUser, providerData
  AWAIT _storeUserInfo(userCredential.user)
  stopwatch.stop()
  LOG [GOOGLE_SIGN_IN_END] completed in {ms}ms
  RETURN userCredential

CATCH FirebaseAuthException e:
  LOG Firebase auth exception: code, message, elapsed ms
  CrashReportingService.recordError(...)
  THROW _handleAuthException(e)
CATCH e:
  LOG Error: type, message, elapsed ms
  CrashReportingService.recordError(...)
  THROW 'Failed to sign in with Google: $e'
```

---

#### `signInWithApple() → Future<UserCredential>`

```
TRY:
  rawNonce = _generateNonce()
  nonce = _sha256ofString(rawNonce)

  appleCredential = AWAIT SignInWithApple.getAppleIDCredential(
    scopes=[email, fullName], nonce=nonce
  )

  oauthCredential = OAuthProvider('apple.com').credential(
    idToken=appleCredential.identityToken, rawNonce=rawNonce
  )

  userCredential = AWAIT _auth.signInWithCredential(oauthCredential)

  // Update display name if not set and Apple provided one
  IF user.displayName == null AND appleCredential.givenName != null:
    displayName = '{givenName} {familyName}'.trim()
    AWAIT user.updateDisplayName(displayName)

  AWAIT _storeUserInfo(userCredential.user)
  RETURN userCredential
CATCH FirebaseAuthException → THROW _handleAuthException
CATCH SignInWithAppleAuthorizationException → THROW message
CATCH e → THROW 'Failed to sign in with Apple: $e'
```

---

#### `_generateNonce([length=32]) → String` (private)

```
charset = '0123456789ABCDEF...xyz-._'
random = Random.secure()
RETURN List.generate(length, _ → charset[random.nextInt(charset.length)]).join()
```

---

#### `_sha256ofString(String input) → String` (private)

```
bytes = utf8.encode(input)
digest = sha256.convert(bytes)
RETURN digest.toString()   // hex string
```

---

#### `signOut() → Future<void>`

```
TRY:
  IF AWAIT _googleSignIn.isSignedIn():
    AWAIT _googleSignIn.signOut()
  AWAIT _auth.signOut()
  AWAIT _clearUserInfo()
CATCH e → THROW 'Failed to sign out: $e'
```

---

#### `sendPasswordResetEmail(String email) → Future<void>`

```
TRY: AWAIT _auth.sendPasswordResetEmail(email)
CATCH FirebaseAuthException → THROW _handleAuthException
```

---

#### `updateProfile({displayName?, photoURL?}) → Future<void>`

```
TRY:
  user = _auth.currentUser
  IF user == null → THROW 'No user signed in'
  IF displayName != null → AWAIT user.updateDisplayName(displayName)
  IF photoURL != null    → AWAIT user.updatePhotoURL(photoURL)
  AWAIT user.reload()
  AWAIT _storeUserInfo(_auth.currentUser)
CATCH FirebaseAuthException → THROW _handleAuthException
CATCH e → THROW 'Failed to update profile: $e'
```

---

#### `updateEmail(String newEmail) → Future<void>`

```
TRY:
  user = _auth.currentUser
  IF user == null → THROW 'No user signed in'
  AWAIT user.verifyBeforeUpdateEmail(newEmail)
  AWAIT _storeUserInfo(_auth.currentUser)
CATCH FirebaseAuthException → THROW _handleAuthException
```

---

#### `changePassword({currentPassword, newPassword}) → Future<void>`

```
TRY:
  user = _auth.currentUser
  IF user == null → THROW 'No user signed in'
  IF user.email == null → THROW 'Email required to change password'
  credential = EmailAuthProvider.credential(email, currentPassword)
  AWAIT user.reauthenticateWithCredential(credential)
  AWAIT user.updatePassword(newPassword)
CATCH FirebaseAuthException → THROW _handleAuthException
```

---

#### `deleteAccount(String password) → Future<void>`

```
TRY:
  user = _auth.currentUser
  IF user == null → THROW 'No user signed in'
  IF user.email != null:
    credential = EmailAuthProvider.credential(user.email, password)
    AWAIT user.reauthenticateWithCredential(credential)
  AWAIT user.delete()
  AWAIT _clearUserInfo()
CATCH FirebaseAuthException → THROW _handleAuthException
```

---

#### `reauthenticate(String password) → Future<void>`

```
TRY:
  user = _auth.currentUser
  IF user == null OR user.email == null → THROW
  credential = EmailAuthProvider.credential(user.email, password)
  AWAIT user.reauthenticateWithCredential(credential)
CATCH FirebaseAuthException → THROW _handleAuthException
```

---

#### `_storeUserInfo(User? user) → Future<void>` (private)

```
IF user != null:
  AWAIT _secureStorage.write('userId', user.uid)
  AWAIT _secureStorage.write('email', user.email ?? '')
  AWAIT _secureStorage.write('displayName', user.displayName ?? '')
```

---

#### `_clearUserInfo() → Future<void>` (private)

```
AWAIT _secureStorage.delete('userId')
AWAIT _secureStorage.delete('email')
AWAIT _secureStorage.delete('displayName')
```

---

#### `getStoredUserId() / getStoredEmail() / getStoredDisplayName() → Future<String?>`

```
RETURN AWAIT _secureStorage.read(key)
```

---

#### `_handleAuthException(FirebaseAuthException e) → String` (private)

```
SWITCH e.code:
  'weak-password'        → 'The password provided is too weak.'
  'email-already-in-use' → 'An account already exists for that email.'
  'user-not-found'       → 'No user found for that email.'
  'wrong-password'       → 'Wrong password provided.'
  'invalid-email'        → 'The email address is not valid.'
  'user-disabled'        → 'This user account has been disabled.'
  'too-many-requests'    → 'Too many requests. Please try again later.'
  'operation-not-allowed'→ 'This sign-in method is not enabled.'
  'network-request-failed'→ 'Network error. Please check your connection.'
  DEFAULT                → e.message ?? 'An authentication error occurred.'
```
