# user_account

> **Source:** `lib/models/user_account.dart`

## Purpose

Top-level user identity model that can own multiple profiles. Similar to `Account` but focused on the user-facing identity layer with support for multiple profiles via `activeProfileId`. Contains authentication, session management, and sync fields.

## Dependencies

- `enums.dart` — AuthProvider enum

## Pseudo-Code

### Class: UserAccount

```
CLASS UserAccount

  FIELDS:
    id: int = 0                          // local database ID
    accountId: String (late)             // UUID or Firebase UID
    displayName: String (late)           // user display name
    email: String?                       // email address
    authProvider: AuthProvider (late)     // gmail, apple, email, devStatic
    photoUrl: String?                    // profile photo URL
    createdAt: DateTime (late)           // account creation time
    updatedAt: DateTime?                 // last update time
    activeProfileId: String?             // currently active profile
    isActive: bool (late)                // currently selected for logging
    lastSyncedAt: DateTime?              // last Firestore sync time
    accessToken: String?                 // session token
    refreshToken: String?                // session refresh token
    tokenExpiresAt: DateTime?            // token expiry

  // ── Default Constructor ──

  CONSTRUCTOR UserAccount()
    // leaves late fields uninitialized
  END CONSTRUCTOR

  // ── Named Constructor ──

  CONSTRUCTOR UserAccount.create({required accountId, required displayName, required authProvider, ...})
    ASSIGN all fields
    SET createdAt = provided OR DateTime.now()
    SET isActive default false
  END CONSTRUCTOR

  // ── Copy With ──

  FUNCTION copyWith({...all fields optional}) -> UserAccount
    CREATE UserAccount.create with fallback-to-this pattern
    PRESERVE id from original
    RETURN new account
  END FUNCTION

END CLASS
```
