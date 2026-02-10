# account_integration_service

> **Source:** `lib/services/account_integration_service.dart`

## Purpose

Integrates Firebase Auth with local Account management for multi-account support. Orchestrates sign-in/sign-up flows across email, Google, and Apple providers, automatically creating or updating local Account records when a user authenticates. Also generates and stores custom Firebase tokens to enable seamless account switching without re-authentication.

## Dependencies

- `package:firebase_auth/firebase_auth.dart` — Firebase User and UserCredential types
- `package:flutter_riverpod/flutter_riverpod.dart` — Provider-based dependency injection
- `../logging/app_logger.dart` — Structured logging via `AppLogger`
- `../services/auth_service.dart` — Firebase Auth operations (sign-in/sign-up/sign-out)
- `../services/account_service.dart` — Local account CRUD via repository
- `../services/account_session_manager.dart` — Multi-account session and token management
- `../services/crash_reporting_service.dart` — Crashlytics error/message recording
- `../services/token_service.dart` — Cloud Function calls for custom token generation
- `../providers/auth_provider.dart` — Provides `authServiceProvider` for DI
- `../models/account.dart` — Account model
- `../models/enums.dart` — `AuthProvider` enum (email, gmail, apple)

## Pseudo-Code

### Provider: `accountIntegrationServiceProvider`

```
PROVIDER accountIntegrationServiceProvider:
  accountService = new AccountService()
  sessionManager = new AccountSessionManager(accountService)
  tokenService = new TokenService()
  RETURN new AccountIntegrationService(
    authService = ref.watch(authServiceProvider),
    accountService, sessionManager, tokenService
  )
```

### Class: AccountIntegrationService

#### Fields
- `_log` — static logger tagged `'AccountIntegrationService'`
- `authService` — handles Firebase Auth operations
- `accountService` — local account CRUD
- `sessionManager` — multi-account session/token management
- `tokenService` — custom token generation via Cloud Function

#### Constructor
```
AccountIntegrationService({authService, accountService, sessionManager, tokenService}):
  ASSIGN all fields from named params
```

---

#### `syncAccountFromFirebaseUser(User firebaseUser, {bool makeActive = true}) → Future<Account>`

```
LOG [SYNC_ACCOUNT] uid, email, displayName, makeActive, providers

existingAccount = AWAIT accountService.getAccountByUserId(firebaseUser.uid)

// Determine auth provider from Firebase providerData
authProvider = AuthProvider.email   // default
FOR EACH providerData IN firebaseUser.providerData:
  IF providerId == 'google.com' → authProvider = gmail, BREAK
  IF providerId == 'apple.com'  → authProvider = apple, BREAK

IF existingAccount != null:
  UPDATE existingAccount fields: email, displayName, photoUrl, authProvider
  SET isLoggedIn = true
  SET lastSyncedAt = NOW, lastAccessedAt = NOW
  AWAIT accountService.saveAccount(existingAccount)
  IF makeActive → AWAIT sessionManager.setActiveAccount(uid)
  LOG [SYNC_ACCOUNT] Updated EXISTING account
  resultAccount = existingAccount
ELSE:
  newAccount = Account.create(
    userId, email (fallback 'no-email@ashtrail.app'), displayName,
    photoUrl, authProvider, isActive=makeActive, isLoggedIn=true,
    createdAt=NOW, lastAccessedAt=NOW
  )
  AWAIT accountService.saveAccount(newAccount)
  IF makeActive → AWAIT sessionManager.setActiveAccount(uid)
  LOG [SYNC_ACCOUNT] Created NEW account
  resultAccount = newAccount

AWAIT _generateAndStoreCustomToken(firebaseUser.uid)
RETURN resultAccount
```

---

#### `_generateAndStoreCustomToken(String uid) → Future<void>`

```
TRY:
  LOG [CUSTOM_TOKEN] Generating custom token for uid
  tokenData = AWAIT tokenService.generateCustomToken(uid)
  customToken = tokenData['customToken']
  expiresIn = tokenData['expiresIn']
  AWAIT sessionManager.storeCustomToken(uid, customToken)
  LOG [CUSTOM_TOKEN] Token stored: length, expiresIn
CATCH e:
  LOG ERROR [CUSTOM_TOKEN] FAILED — account switching may require re-auth
```

---

#### `signUpWithEmail({email, password, displayName?, makeActive}) → Future<Account>`

```
userCredential = AWAIT authService.signUpWithEmail(email, password, displayName)
IF userCredential.user == null → THROW 'Failed to create user'
RETURN AWAIT syncAccountFromFirebaseUser(userCredential.user, makeActive)
```

---

#### `signInWithEmail({email, password, makeActive}) → Future<Account>`

```
LOG signInWithEmail
userCredential = AWAIT authService.signInWithEmail(email, password)
IF userCredential.user == null → THROW 'Failed to sign in'
RETURN AWAIT syncAccountFromFirebaseUser(userCredential.user, makeActive)
```

---

#### `signInWithGoogle({makeActive}) → Future<Account>`

```
TRY:
  LOG [GMAIL_FLOW_START]
  CrashReportingService.logMessage('Starting Google sign-in')
  userCredential = AWAIT authService.signInWithGoogle()
  IF user == null → THROW 'Failed to sign in with Google'
  LOG [GMAIL_FLOW] Firebase user obtained
  account = AWAIT syncAccountFromFirebaseUser(user, makeActive)
  AWAIT CrashReportingService.setUserId(account.userId)
  CrashReportingService.logMessage('User signed in: email')
  LOG [GMAIL_FLOW_END] complete
  RETURN account
CATCH e:
  LOG [GMAIL_FLOW_FAIL]
  CrashReportingService.recordError(e, stackTrace, reason)
  RETHROW
```

---

#### `signInWithApple({makeActive}) → Future<Account>`

```
LOG signInWithApple
userCredential = AWAIT authService.signInWithApple()
IF user == null → THROW 'Failed to sign in with Apple'
RETURN AWAIT syncAccountFromFirebaseUser(user, makeActive)
```

---

#### `signOut() → Future<void>`

```
LOG signOut (all accounts)
AWAIT authService.signOut()
AWAIT sessionManager.clearAllSessions()
AWAIT accountService.deactivateAllAccounts()
LOG All accounts signed out
```

---

#### `signOutAccount(String userId) → Future<void>`

```
LOG signOutAccount(userId)
IF authService.currentUser?.uid == userId:
  AWAIT authService.signOut()

AWAIT sessionManager.clearSession(userId)

account = AWAIT accountService.getAccountByUserId(userId)
IF account != null:
  SET account.isLoggedIn = false, isActive = false
  AWAIT accountService.saveAccount(account)

activeAccount = AWAIT accountService.getActiveAccount()
IF activeAccount == null OR activeAccount.userId == userId:
  loggedInAccounts = AWAIT sessionManager.getLoggedInAccounts()
  IF loggedInAccounts.isNotEmpty:
    AWAIT sessionManager.setActiveAccount(loggedInAccounts.first.userId)

LOG Account signed out: userId
```

---

#### `updateProfile({displayName?, photoURL?}) → Future<Account>`

```
AWAIT authService.updateProfile(displayName, photoURL)
user = authService.currentUser
IF user == null → THROW 'User not authenticated'
RETURN AWAIT syncAccountFromFirebaseUser(user)
```

---

#### `updateEmail(String newEmail) → Future<Account>`

```
AWAIT authService.updateEmail(newEmail)
user = authService.currentUser
IF user == null → THROW 'User not authenticated'
RETURN AWAIT syncAccountFromFirebaseUser(user)
```

---

#### `changePassword({currentPassword, newPassword}) → Future<void>`

```
AWAIT authService.changePassword(currentPassword, newPassword)
```

---

#### `deleteAccount(String password) → Future<void>`

```
user = authService.currentUser
IF user == null → THROW 'User not authenticated'
userId = user.uid
AWAIT authService.deleteAccount(password)
AWAIT accountService.deleteAccount(userId)
```
