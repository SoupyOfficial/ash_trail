# account_session_manager

> **Source:** `lib/services/account_session_manager.dart`

## Purpose

Manages multiple authenticated sessions for multi-account support. Since Firebase Auth only supports one active user at a time, this service stores custom Firebase tokens in secure storage, tracks which accounts have valid sessions, and enables seamless switching between accounts using `signInWithCustomToken()`. Custom tokens are valid for 48 hours (with a 47-hour safety buffer).

## Dependencies

- `package:flutter_secure_storage/flutter_secure_storage.dart` — Encrypted key-value storage for tokens/sessions
- `../logging/app_logger.dart` — Structured logging via `AppLogger`
- `dart:convert` — JSON encoding/decoding for session data
- `../models/account.dart` — Account model
- `../models/enums.dart` — `AuthProvider` enum
- `account_service.dart` — Local account CRUD operations

## Pseudo-Code

### Class: AccountSessionManager

#### Fields
- `_log` — static logger tagged `'AccountSessionManager'`
- `_secureStorage` — `FlutterSecureStorage` instance
- `_accountService` — `AccountService` for account lookups/updates

#### Storage Key Constants
- `_sessionPrefix` = `'session_'`
- `_activeSessionKey` = `'active_session_user_id'`
- `_loggedInAccountsKey` = `'logged_in_accounts'`
- `_customTokenPrefix` = `'custom_token_'`
- `_customTokenTimestampPrefix` = `'custom_token_timestamp_'`

#### Constructor

```
AccountSessionManager({required accountService, secureStorage?}):
  _accountService = accountService
  _secureStorage = secureStorage ?? const FlutterSecureStorage()
```

---

#### `getLoggedInAccounts() → Future<List<Account>>`

```
LOG getLoggedInAccounts()
allAccounts = AWAIT _accountService.getAllAccounts()
loggedInAccounts = allAccounts.WHERE(a → a.isLoggedIn).toList()
LOG 'Found {count} logged-in accounts'
RETURN loggedInAccounts
```

---

#### `storeSession({userId, refreshToken?, accessToken?, tokenExpiresAt?}) → Future<void>`

```
LOG storeSession(userId)
sessionData = {userId, refreshToken, accessToken, tokenExpiresAt ISO, storedAt ISO}
AWAIT _secureStorage.write(key='session_{userId}', value=JSON(sessionData))

account = AWAIT _accountService.getAccountByUserId(userId)
IF account != null:
  SET account.isLoggedIn=true, refreshToken, accessToken, tokenExpiresAt, lastAccessedAt=NOW
  AWAIT _accountService.saveAccount(account)

AWAIT _addToLoggedInList(userId)
LOG 'Session stored for userId'
```

---

#### `getSession(String userId) → Future<Map<String,dynamic>?>`

```
sessionJson = AWAIT _secureStorage.read(key='session_{userId}')
IF null → RETURN null
TRY: RETURN jsonDecode(sessionJson)
CATCH: LOG error, RETURN null
```

---

#### `storeCustomToken(String uid, String customToken) → Future<void>`

```
TRY:
  LOG [TOKEN_STORE] Storing custom token for uid (length chars)
  AWAIT _secureStorage.write(key='custom_token_{uid}', value=customToken)
  timestamp = NOW.millisecondsSinceEpoch.toString()
  AWAIT _secureStorage.write(key='custom_token_timestamp_{uid}', value=timestamp)
  LOG [TOKEN_STORE] stored at ISO timestamp
CATCH e:
  LOG ERROR [TOKEN_STORE]
  RETHROW
```

---

#### `getValidCustomToken(String uid) → Future<String?>`

```
TRY:
  customToken = AWAIT _secureStorage.read(key='custom_token_{uid}')
  IF null → LOG [TOKEN_GET] No token found, RETURN null

  timestampStr = AWAIT _secureStorage.read(key='custom_token_timestamp_{uid}')
  IF null → LOG [TOKEN_GET] No timestamp (orphaned token), RETURN null

  tokenAge = NOW.ms - timestamp
  maxAge = 47 * 60 * 60 * 1000   // 47 hours in ms

  IF tokenAge > maxAge:
    LOG [TOKEN_GET] Token EXPIRED (age hours, max 47h)
    AWAIT removeCustomToken(uid)
    RETURN null

  LOG [TOKEN_GET] Valid token (age, remaining hours)
  RETURN customToken
CATCH e:
  LOG ERROR [TOKEN_GET]
  RETURN null
```

---

#### `removeCustomToken(String uid) → Future<void>`

```
TRY:
  AWAIT _secureStorage.delete(key='custom_token_{uid}')
  AWAIT _secureStorage.delete(key='custom_token_timestamp_{uid}')
  LOG 'Removed custom token for uid'
CATCH: LOG error
```

---

#### `hasValidCustomToken(String uid) → Future<bool>`

```
token = AWAIT getValidCustomToken(uid)
RETURN token != null
```

---

#### `getDiagnosticSummary() → Future<Map<String,dynamic>>`

```
LOG [DIAGNOSTICS] Generating multi-account diagnostic summary
TRY:
  activeUserId = AWAIT getActiveUserId()
  loggedInAccounts = AWAIT getLoggedInAccounts()
  tokenStatus = {}

  FOR EACH account IN loggedInAccounts:
    hasToken = AWAIT hasValidCustomToken(account.userId)
    READ timestamp from secure storage
    COMPUTE ageHours, remainingHours if timestamp exists
    tokenStatus[userId] = {email, hasValidToken, ageHours, remainingHours, provider, isActive, lastAccessed}

  summary = {activeUserId, loggedInCount, loggedInAccounts list, tokenStatus, timestamp, logging diagnostics}
  LOG [DIAGNOSTICS] summary
  RETURN summary
CATCH e:
  LOG ERROR
  RETURN {error, timestamp}
```

---

#### `clearSession(String userId) → Future<void>`

```
LOG clearSession(userId)
AWAIT _secureStorage.delete(key='session_{userId}')
AWAIT removeCustomToken(userId)

account = AWAIT _accountService.getAccountByUserId(userId)
IF account != null:
  SET isLoggedIn=false, refreshToken=null, accessToken=null, tokenExpiresAt=null
  AWAIT _accountService.saveAccount(account)

AWAIT _removeFromLoggedInList(userId)
LOG 'Session cleared for userId'
```

---

#### `clearAllSessions() → Future<void>`

```
LOG clearAllSessions()
loggedInUserIds = AWAIT _getLoggedInList()
FOR EACH userId IN loggedInUserIds:
  AWAIT _secureStorage.delete(key='session_{userId}')
  AWAIT removeCustomToken(userId)
  account = AWAIT _accountService.getAccountByUserId(userId)
  IF account != null:
    SET isLoggedIn=false, tokens=null
    AWAIT _accountService.saveAccount(account)

AWAIT _secureStorage.delete(key=_loggedInAccountsKey)
AWAIT _secureStorage.delete(key=_activeSessionKey)
LOG 'All sessions cleared'
```

---

#### `setActiveAccount(String userId) → Future<void>`

```
LOG setActiveAccount(userId)
AWAIT _secureStorage.write(key=_activeSessionKey, value=userId)
AWAIT _accountService.setActiveAccount(userId)

account = AWAIT _accountService.getAccountByUserId(userId)
IF account != null:
  account.lastAccessedAt = NOW
  AWAIT _accountService.saveAccount(account)

LOG 'Active account set to userId'
```

---

#### `getActiveUserId() → Future<String?>`

```
RETURN AWAIT _secureStorage.read(key=_activeSessionKey)
```

---

#### `addAccountSession({userId, email, displayName?, photoUrl?, authProvider, refreshToken?, accessToken?, tokenExpiresAt?}) → Future<Account>`

```
LOG addAccountSession(userId)
account = AWAIT _accountService.getAccountByUserId(userId)

IF account != null:
  UPDATE email, displayName, photoUrl, authProvider
  SET isLoggedIn=true, lastAccessedAt=NOW, tokens
ELSE:
  account = Account.create(userId, email, displayName, photoUrl, authProvider,
    isActive=false, isLoggedIn=true, lastAccessedAt=NOW, tokens)

AWAIT _accountService.saveAccount(account)
AWAIT storeSession(userId, refreshToken, accessToken, tokenExpiresAt)
LOG 'Account session added'
RETURN account
```

---

#### `removeAccountSession(String userId, {deleteData = false}) → Future<void>`

```
LOG removeAccountSession(userId, deleteData)
AWAIT clearSession(userId)

IF deleteData:
  AWAIT _accountService.deleteAccount(userId)
  LOG 'Account data deleted'

activeUserId = AWAIT getActiveUserId()
IF activeUserId == userId:
  loggedInAccounts = AWAIT getLoggedInAccounts()
  IF loggedInAccounts.isNotEmpty:
    AWAIT setActiveAccount(loggedInAccounts.first.userId)
  ELSE:
    AWAIT _secureStorage.delete(key=_activeSessionKey)

LOG 'Account session removed'
```

---

#### `hasLoggedInAccounts() → Future<bool>`

```
accounts = AWAIT getLoggedInAccounts()
RETURN accounts.isNotEmpty
```

---

#### `getLoggedInCount() → Future<int>`

```
accounts = AWAIT getLoggedInAccounts()
RETURN accounts.length
```

---

#### `_getLoggedInList() → Future<List<String>>` (private)

```
listJson = AWAIT _secureStorage.read(key=_loggedInAccountsKey)
IF null → RETURN []
TRY: RETURN jsonDecode(listJson).cast<String>()
CATCH: RETURN []
```

---

#### `_addToLoggedInList(String userId) → Future<void>` (private)

```
list = AWAIT _getLoggedInList()
IF !list.contains(userId):
  list.add(userId)
  AWAIT _secureStorage.write(key=_loggedInAccountsKey, value=JSON(list))
```

---

#### `_removeFromLoggedInList(String userId) → Future<void>` (private)

```
list = AWAIT _getLoggedInList()
list.remove(userId)
AWAIT _secureStorage.write(key=_loggedInAccountsKey, value=JSON(list))
```
