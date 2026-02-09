# account

> **Source:** `lib/models/account.dart`

## Purpose

Core domain model representing a user identity in the multi-account system. Supports simultaneous login of multiple accounts with one active account for data viewing/logging. Contains identity, authentication, session management, and profile fields.

## Dependencies

- `enums.dart` — AuthProvider enum

## Pseudo-Code

### Class: Account

```
CLASS Account

  FIELDS:
    id: int = 0                          // local database ID
    userId: String (late)                // Firebase UID or custom identifier
    remoteId: String?                    // Firestore document ID for cloud sync
    email: String (late)
    displayName: String?
    firstName: String?                   // per design doc 4.2.1
    lastName: String?                    // per design doc 4.2.1
    photoUrl: String?
    authProvider: AuthProvider (late)     // gmail, apple, email, devStatic
    isActive: bool (late)                // currently selected for viewing/logging
    isLoggedIn: bool (late)              // has valid authenticated session
    createdAt: DateTime (late)
    lastModifiedAt: DateTime?            // per design doc 4.2.1
    lastSyncedAt: DateTime?
    lastAccessedAt: DateTime?            // for session ordering
    activeProfileId: String?             // multi-profile support
    accessToken: String?                 // session token
    refreshToken: String?                // session refresh token
    tokenExpiresAt: DateTime?            // token expiration

  // ── Default Constructor ──

  CONSTRUCTOR Account()
    SET userId = ''
    SET email = ''
    SET authProvider = AuthProvider.email
    SET isActive = false
    SET isLoggedIn = false
    SET createdAt = DateTime.now()
  END CONSTRUCTOR

  // ── Named Constructor ──

  CONSTRUCTOR Account.create({required userId, required email, ...optional fields})
    ASSIGN all provided fields directly
    SET createdAt = provided createdAt OR DateTime.now()
  END CONSTRUCTOR

  // ── Copy With ──

  FUNCTION copyWith({...all fields optional}) -> Account
    CREATE new Account.create using:
      FOR EACH field: use provided value OR fallback to this.field
    SET new account.id = this.id    // preserve local DB id
    RETURN new account
  END FUNCTION

  // ── Computed Properties ──

  GETTER hasValidSession -> bool
    IF refreshToken IS null THEN RETURN false
    IF tokenExpiresAt IS null THEN RETURN true  // no expiry = assume valid
    RETURN tokenExpiresAt > now
  END GETTER

  GETTER fullName -> String?
    IF firstName IS null AND lastName IS null THEN RETURN null
    RETURN join [firstName, lastName] filtered non-null, trimmed
  END GETTER

END CLASS
```
