# multi_account_diagnostics_screen

> **Source:** `lib/screens/multi_account_diagnostics_screen.dart`

## Purpose

A diagnostics screen for TestFlight/debug builds that surfaces the full multi-account state: Firebase Auth info, logged-in accounts and active user, custom token validity and expiry, cloud function endpoint reachability, and logging configuration. Provides copy-to-clipboard and refresh actions. Accessible from the Accounts screen overflow menu.

## Dependencies

- `package:firebase_auth/firebase_auth.dart` — `FirebaseAuth.instance.currentUser` for Firebase Auth state
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter/services.dart` — `Clipboard` for copy-to-clipboard
- `package:flutter_riverpod/flutter_riverpod.dart` — Riverpod state management
- `../logging/app_logger.dart` — Structured logging
- `../providers/account_provider.dart` — `accountSessionManagerProvider`
- `../services/token_service.dart` — `tokenServiceProvider` for endpoint health check

## Pseudo-Code

### Class: MultiAccountDiagnosticsScreen (ConsumerStatefulWidget)

Creates `_MultiAccountDiagnosticsScreenState`.

### Class: _MultiAccountDiagnosticsScreenState (ConsumerState)

#### State

```
_log:                 AppLogger('Diagnostics')
_diagnostics:         Map<String, dynamic>? = null
_isLoading:           bool = true
_isCheckingEndpoint:  bool = false
_endpointReachable:   bool? = null
_error:               String? = null
```

#### Lifecycle: initState()

```
super.initState()
_loadDiagnostics()
```

#### Method: _loadDiagnostics() -> Future<void>

```
SET _isLoading = true, _error = null

TRY:
  sessionManager = ref.read(accountSessionManagerProvider)
  diagnostics = AWAIT sessionManager.getDiagnosticSummary()

  // Augment with Firebase Auth info
  firebaseUser = FirebaseAuth.instance.currentUser
  diagnostics['firebaseAuth'] = {
    uid, email, displayName, isAnonymous,
    providers (list of providerId), emailVerified,
    creationTime (ISO8601), lastSignInTime (ISO8601)
  }

  SET _diagnostics = diagnostics, _isLoading = false
  LOG summary
CATCH:
  LOG error
  SET _error = e.toString(), _isLoading = false
```

#### Method: _checkEndpoint() -> Future<void>

```
SET _isCheckingEndpoint = true
TRY:
  tokenService = ref.read(tokenServiceProvider)
  reachable = AWAIT tokenService.isEndpointReachable()
  SET _endpointReachable = reachable
CATCH:
  SET _endpointReachable = false
FINALLY:
  SET _isCheckingEndpoint = false
```

#### Method: _formatDiagnostics() -> String

```
BUILD multi-line text summary:
  "=== Multi-Account Diagnostics ==="
  Timestamp

  --- Firebase Auth ---
  UID, Email, DisplayName, Providers, Last Sign-In

  --- Logged-In Accounts ({count}) ---
  Active User ID
  FOR EACH account: email (provider) uid=...

  --- Token Status ---
  FOR EACH token entry:
    email, Valid, Age (hours), Remaining (hours), Provider, Active

  --- Logging ---
  Verbose, Debug Mode, Level, Active Loggers count

  --- Cloud Function ---
  Reachable: true/false (if checked)

RETURN formatted string
```

#### Method: build(context) -> Widget

```
RETURN Scaffold:
  appBar = AppBar(title: "Multi-Account Diagnostics"):
    actions:
      [1] IconButton (copy) -> Clipboard.setData(_formatDiagnostics()), SnackBar
      [2] IconButton (refresh) -> _loadDiagnostics()

  body:
    IF _isLoading -> CircularProgressIndicator
    IF _error     -> "Error: $_error"
    ELSE -> ListView (padding 16):
      [1] _buildSection("Firebase Auth",        security icon,  _buildFirebaseAuthInfo())
      [2] _buildSection("Logged-In Accounts (N)", people icon,   _buildAccountsList())
      [3] _buildSection("Custom Token Status",   vpn_key icon,  _buildTokenStatus())
      [4] _buildSection("Cloud Function Health", cloud icon,    _buildCloudFunctionHealth())
      [5] _buildSection("Logging Configuration", bug_report icon, _buildLoggingInfo())
```

#### Method: _buildSection(context, title, icon, content) -> Widget

```
Card (padding 16):
  Row: Icon + Text(title, titleMedium bold)
  Divider
  content widget
```

#### Method: _buildFirebaseAuthInfo(theme) -> Widget

```
EXTRACT fb = _diagnostics['firebaseAuth']
IF null -> "No Firebase Auth data"

Column of _infoRow pairs:
  UID, Email, Display Name, Providers, Email Verified, Last Sign-In
```

#### Method: _buildAccountsList(theme) -> Widget

```
EXTRACT accounts = _diagnostics['loggedInAccounts']
IF empty -> "No accounts logged in" (error color)

activeUserId = _diagnostics['activeUserId']

FOR EACH account:
  Container with left green border if active:
    Row: email (bold if active) + "ACTIVE" chip if active
    Text: "{provider} · {userId}" (faded)
```

#### Method: _buildTokenStatus(theme) -> Widget

```
EXTRACT tokens = _diagnostics['tokenStatus']
IF empty -> "No token data" (error color)

FOR EACH token entry:
  Container (green or red tinted):
    Row: check/error icon + email (bold)
    _infoRow: Valid, Age, Remaining
```

#### Method: _buildCloudFunctionHealth(theme) -> Widget

```
Column:
  Text: "Token generation endpoint (Cloud Function)"
  Row:
    IF checking -> 16x16 CircularProgressIndicator
    ELSE IF checked -> check/error icon + "REACHABLE"/"UNREACHABLE"
    ELSE -> "Not checked"
    Spacer
    FilledButton.tonal "Test" -> _checkEndpoint()
```

#### Method: _buildLoggingInfo(theme) -> Widget

```
EXTRACT logging = _diagnostics['logging']
IF null -> "No logging data"

Column of _infoRow:
  Verbose Logging, Debug Mode, Log Level, Active Loggers count
```

#### Method: _infoRow(label, value) -> Widget

```
Row:
  SizedBox(120): Text(label, w500, 13px)
  Expanded: Text(value, 13px, faded)
```
