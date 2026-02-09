# account_provider

> **Source:** `lib/providers/account_provider.dart`

## Purpose

Riverpod providers for account management: service/session manager singletons, active/all/logged-in account state, and an `AccountSwitcher` StateNotifier for switching, adding, signing out, and deleting accounts. Account switching uses Firebase Custom Tokens for seamless auth handoff.

## Dependencies

- `package:firebase_auth/firebase_auth.dart` — FirebaseAuth for custom token sign-in
- `package:flutter_riverpod/flutter_riverpod.dart` — Provider, StreamProvider, FutureProvider, StateNotifierProvider
- `../logging/app_logger.dart` — Structured logging
- `../models/account.dart` — Account model
- `../services/account_service.dart` — AccountService for CRUD
- `../services/account_session_manager.dart` — AccountSessionManager for session ops
- `../services/token_service.dart` — TokenService for custom token generation
- `log_record_provider.dart` — logDraftProvider, activeAccountLogRecordsProvider

## Pseudo-Code

### Service Providers

```
PROVIDER tokenServiceProvider -> TokenService
  RETURN new TokenService()
END

PROVIDER accountServiceProvider -> AccountService
  RETURN new AccountService()
END

PROVIDER accountSessionManagerProvider -> AccountSessionManager
  READ accountService from accountServiceProvider
  RETURN new AccountSessionManager(accountService)
END
```

### Account State Providers

```
STREAM_PROVIDER activeAccountProvider -> Account?
  READ service from accountServiceProvider
  SUBSCRIBE to service.watchActiveAccount()
  MAP each emission:
    LOG "[PROVIDER_EMIT] activeAccountProvider → {email}"
  HANDLE errors: LOG and rethrow
  RETURN stream of Account?
END

FUTURE_PROVIDER allAccountsProvider -> List<Account>
  WATCH activeAccountProvider (triggers refresh on account change)
  READ service from accountServiceProvider
  TRY
    accounts = AWAIT service.getAllAccounts()
    LOG loaded count
    RETURN accounts
  CATCH: LOG and rethrow
END

FUTURE_PROVIDER loggedInAccountsProvider -> List<Account>
  WATCH activeAccountProvider (triggers refresh)
  READ sessionManager from accountSessionManagerProvider
  TRY
    accounts = AWAIT sessionManager.getLoggedInAccounts()
    RETURN accounts
  CATCH: LOG and rethrow
END

FUTURE_PROVIDER hasLoggedInAccountsProvider -> bool
  READ sessionManager
  RETURN AWAIT sessionManager.hasLoggedInAccounts()
END
```

### Class: AccountSwitcher (StateNotifier\<AsyncValue\<void\>\>)

```
CLASS AccountSwitcher EXTENDS StateNotifier<AsyncValue<void>>

  FIELDS:
    _ref: Ref

  CONSTRUCTOR(ref)
    INITIAL STATE = AsyncValue.data(null)
  END

  // ── Switch Account ──

  ASYNC FUNCTION switchAccount(userId: String) -> void
    LOG "[SWITCH_START]"
    START stopwatch
    SET state = loading

    TRY
      READ sessionManager, tokenService
      GET currentAuthUid from FirebaseAuth.instance.currentUser

      // Step 1: Re-authenticate if needed
      IF currentAuthUid != userId THEN
        // Try cached custom token
        customToken = AWAIT sessionManager.getValidCustomToken(userId)

        IF customToken IS null THEN
          TRY
            // Generate new token via Cloud Function
            tokenData = AWAIT tokenService.generateCustomToken(userId)
            customToken = tokenData['customToken']
            AWAIT sessionManager.storeCustomToken(userId, customToken)
          CATCH: LOG error
          END TRY
        END IF

        IF customToken != null THEN
          TRY
            AWAIT auth.signInWithCustomToken(customToken)
            LOG "signIn SUCCESS"
          CATCH
            // Token may be expired — retry with fresh token
            AWAIT sessionManager.removeCustomToken(userId)
            TRY
              tokenData = AWAIT tokenService.generateCustomToken(userId)
              customToken = tokenData['customToken']
              AWAIT sessionManager.storeCustomToken(userId, customToken)
              AWAIT auth.signInWithCustomToken(customToken)
              LOG "Retry signIn SUCCESS"
            CATCH retryError
              LOG "Retry signIn FAILED"
            END TRY
          END TRY
        ELSE
          LOG "No custom token available — Firebase auth NOT updated"
        END IF
      END IF

      // Step 2: Update active account in Hive
      AWAIT sessionManager.setActiveAccount(userId)

      // Step 3: Reset UI state
      READ logDraftProvider.notifier -> reset()
      CALL _invalidateProviders()

      LOG "[SWITCH_END] completed in {ms}ms"
      SET state = data(null)

    CATCH error
      LOG "[SWITCH_END] ERROR"
      SET state = error
    END TRY
  END FUNCTION

  // ── Invalidate Providers ──

  PRIVATE FUNCTION _invalidateProviders()
    INVALIDATE activeAccountProvider
    INVALIDATE allAccountsProvider
    INVALIDATE loggedInAccountsProvider
    INVALIDATE activeAccountLogRecordsProvider
  END FUNCTION

  // ── Add Account ──

  ASYNC FUNCTION addAccount(account: Account) -> void
    SET state = loading
    TRY
      READ service = accountServiceProvider
      SET account.isLoggedIn = true
      SET account.lastAccessedAt = now
      AWAIT service.saveAccount(account)
      INVALIDATE allAccountsProvider, loggedInAccountsProvider
      SET state = data(null)
    CATCH: SET state = error
  END FUNCTION

  // ── Sign Out Account ──

  ASYNC FUNCTION signOutAccount(userId: String) -> void
    SET state = loading
    TRY
      READ sessionManager
      AWAIT sessionManager.removeAccountSession(userId, deleteData: false)
      INVALIDATE all account providers
      SET state = data(null)
    CATCH: SET state = error
  END FUNCTION

  // ── Delete Account ──

  ASYNC FUNCTION deleteAccount(userId: String) -> void
    SET state = loading
    TRY
      READ sessionManager
      AWAIT sessionManager.removeAccountSession(userId, deleteData: true)
      INVALIDATE all account providers
      SET state = data(null)
    CATCH: SET state = error
  END FUNCTION

END CLASS
```
