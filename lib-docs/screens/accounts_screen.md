# accounts_screen

> **Source:** `lib/screens/accounts_screen.dart`

## Purpose

Displays and manages all user accounts in the app. Allows switching between logged-in accounts, signing out individual or all accounts, deleting accounts, navigating to profile/export/diagnostics screens, and adding new accounts via the login screen.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management (ConsumerWidget, WidgetRef)
- `../logging/app_logger.dart` — Structured logging via `AppLogger`
- `../providers/account_provider.dart` — Provides `allAccountsProvider`, `activeAccountProvider`, `loggedInAccountsProvider`, `accountSwitcherProvider`
- `../models/account.dart` — `Account` model (userId, email, displayName, photoUrl, authProvider, isLoggedIn)
- `../services/account_integration_service.dart` — `accountIntegrationServiceProvider` for sign-out
- `profile_screen.dart` — Navigation target for profile editing
- `export_screen.dart` — Navigation target for import/export
- `login_screen.dart` — Navigation target for adding/re-signing-in accounts
- `multi_account_diagnostics_screen.dart` — Navigation target for diagnostics
- `../utils/design_constants.dart` — Design tokens (`Spacing`, `ElevationLevel`, `BorderRadii`, `Paddings`, `IconSize`)

## Constants

- `kTestAccountId = 'dev-test-account-001'` — Static test account ID for persistence testing
- `kTestAccountEmail = 'test@ashtrail.dev'`
- `kTestAccountName = 'Test User'`

## Pseudo-Code

### Class: AccountsScreen (ConsumerWidget)

```
STATIC _log = AppLogger.logger('AccountsScreen')

METHOD build(context, ref) -> Widget:
    accountsAsync = ref.watch(allAccountsProvider)
    activeAccountAsync = ref.watch(activeAccountProvider)
    loggedInAccountsAsync = ref.watch(loggedInAccountsProvider)

    RETURN Scaffold:
        appBar = AppBar(title: 'Accounts'):
            actions:
                IconButton(export icon) -> Navigator.push(ExportScreen)
                IconButton(person icon) -> Navigator.push(ProfileScreen)
                PopupMenuButton:
                    'diagnostics' -> Navigator.push(MultiAccountDiagnosticsScreen)
                    'sign_out_all' ->
                        SHOW AlertDialog "Sign Out All Accounts"
                        IF confirmed:
                            TRY:
                                integrationService = ref.read(accountIntegrationServiceProvider)
                                AWAIT integrationService.signOut()
                            CATCH e:
                                SHOW SnackBar("Error signing out: $e")

        body = accountsAsync.when:
            data(accounts):
                activeAccount = activeAccountAsync.data OR null
                loggedInAccounts = loggedInAccountsAsync.data OR []

                RETURN ListView(padding: 16):
                    // Section 1: Logged-in accounts
                    IF loggedInAccounts.isNotEmpty:
                        Text("Logged In ({count})")
                        FOR EACH (index, account) IN loggedInAccounts:
                            isActive = account.userId == activeAccount?.userId
                            _buildAccountCard(context, ref, account, isActive, true, cardIndex: index)

                    // Section 2: Other accounts (logged out, data preserved)
                    otherAccounts = accounts.where(a => !a.isLoggedIn)
                    IF otherAccounts.isNotEmpty:
                        Text("Other Accounts")
                        FOR EACH account IN otherAccounts:
                            _buildAccountCard(context, ref, account, false, false)

                    // Section 3: Add account card
                    Card > ListTile("Add Another Account"):
                        onTap -> Navigator.push(LoginScreen)

                    // Section 4: Empty state (if no accounts at all)
                    IF accounts.isEmpty:
                        _buildEmptyState(context, ref)

            loading: Center(CircularProgressIndicator)
            error(error, stack):
                _log.e('AccountsScreen error')
                Center(Text("Error: $error"))
```

### Method: _buildAccountCard(context, ref, account, isActive, isLoggedIn, {cardIndex})

```
RETURN Card(elevation based on isActive, border if isActive):
    InkWell:
        onTap:
            IF isActive: null (no action)
            ELSE IF isLoggedIn:
                AWAIT ref.read(accountSwitcherProvider).switchAccount(account.userId)
                SHOW SnackBar("Switched to {name}")
            ELSE (logged out):
                Navigator.push(LoginScreen) // re-sign in

        child = Row:
            // Avatar with photo or initial letter
            Stack:
                CircleAvatar(radius: 24, photo OR first-letter)
                IF isLoggedIn: green status dot at bottom-right

            // Account info column
            Column:
                Text(displayName OR email, bold if active)
                Text("Active • {email}" / "Tap to switch • {email}" / "Tap to sign in • {email}")
                IF authProvider != anonymous:
                    Row(provider icon + provider name)

            // Trailing action
            IF isActive: check_circle icon (primary color)
            ELSE IF isLoggedIn:
                PopupMenuButton:
                    'sign_out' -> _signOutSingleAccount(account)
                    'delete' -> _deleteAccount(account)
            ELSE: chevron_right icon
```

### Method: _getProviderIcon(authProvider) -> IconData

```
SWITCH authProvider.toString():
    'AuthProvider.gmail' -> Icons.g_mobiledata
    'AuthProvider.apple' -> Icons.apple
    'AuthProvider.email' -> Icons.email
    default -> Icons.person
```

### Method: _getProviderName(authProvider) -> String

```
SWITCH authProvider.toString():
    'AuthProvider.gmail' -> 'Google'
    'AuthProvider.apple' -> 'Apple'
    'AuthProvider.email' -> 'Email'
    'AuthProvider.devStatic' -> 'Dev'
    default -> 'Unknown'
```

### Method: _signOutSingleAccount(context, ref, account) -> Future<void>

```
confirmed = SHOW AlertDialog("Sign Out of {name}? Data will be preserved.")
IF confirmed AND context.mounted:
    TRY:
        AWAIT ref.read(accountSwitcherProvider).signOutAccount(account.userId)
        SHOW SnackBar("Signed out of {name}")
    CATCH e:
        SHOW SnackBar("Error signing out: $e")
```

### Method: _deleteAccount(context, ref, account) -> Future<void>

```
confirmed = SHOW AlertDialog("Delete {name}? Permanently deletes all data. Cannot be undone.")
IF confirmed AND context.mounted:
    TRY:
        AWAIT ref.read(accountSwitcherProvider).deleteAccount(account.userId)
        SHOW SnackBar("Account deleted")
    CATCH e:
        SHOW SnackBar("Error deleting account: $e")
```

### Method: _buildEmptyState(context, ref) -> Widget

```
RETURN Center > Column:
    Icon(account_circle_outlined, xxxl, semi-transparent)
    Text("No Accounts", headlineSmall bold)
    Text("Sign in to start tracking")
    FilledButton.icon("Add Account") -> Navigator.push(LoginScreen)
```
