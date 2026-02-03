# Patrol Test IDs and Semantics

This document lists the **Keys** and **semantics labels** used across the app for Patrol E2E tests. Use these identifiers in Patrol finders for stable, copy-change-resistant selectors.

## Convention

- **Keys:** Use `Key('key_name')` in the app; in tests use `$(Key('key_name'))` or `find.byKey(Key('key_name'))`.
- **Semantics:** Use `Semantics(label: '...')` or `SemanticIconButton(semanticLabel: '...')` in the app; in tests use `$(find.bySemanticsLabel('...'))`.
- Prefer **Keys** for unique interactive elements (buttons, inputs, tabs). Use **semantics** when the same label serves accessibility and testing (e.g. "Accounts", "Hold to record duration").

## Navigation

| Key | Location | Notes |
|-----|----------|--------|
| `nav_home` | MainNavigation | Bottom nav Home destination |
| `nav_analytics` | MainNavigation | Bottom nav Analytics destination |
| `nav_history` | MainNavigation | Bottom nav History destination |
| `nav_log` | MainNavigation | Bottom nav Log destination |

## Home / Welcome

| Key | Location | Notes |
|-----|----------|--------|
| `app_bar_home` | HomeScreen | App bar |
| `app_bar_edit_layout` | HomeScreen | Edit/Done toggle |
| `app_bar_account` | HomeScreen | Account icon (also semantics: "Accounts") |
| `fab_backdate` | HomeScreen | FAB Backdate Entry |
| `add_account_button` | HomeScreen | Add Account (no-account view) |
| `add_widget_button` | HomeScreen | Add Widget (edit mode) |
| `time_since_last_hit` | TimeSinceLastHitWidget | Time-since-last-hit card (empty or with "Just now" / "Xm ago") |
| `sign_in_button` | WelcomeScreen (main.dart) | Sign In button |

## Auth

| Key | Location | Notes |
|-----|----------|--------|
| `email-input` | LoginScreen, SignupScreen | Email field |
| `password-input` | LoginScreen, SignupScreen | Password field |
| `login-button` | LoginScreen | Log In button |
| `username-input` | SignupScreen | Username field |
| `confirm-password-input` | SignupScreen | Confirm password field |
| `signup-button` | SignupScreen | Sign up button |

## Quick Log (home widget)

| Key | Location | Notes |
|-----|----------|--------|
| `quick_log_clear_form` | HomeQuickLogWidget | Clear form button |
| `quick_log_mood_slider` | HomeQuickLogWidget | Mood slider |
| `quick_log_physical_slider` | HomeQuickLogWidget | Physical slider |
| `quick_log_reasons` | HomeQuickLogWidget | Reason chips grid |
| `hold_to_record_button` | HomeQuickLogWidget | Hold-to-record button (also semantics: "Hold to record duration") |

## Logging screen

| Key | Location | Notes |
|-----|----------|--------|
| `app_bar_logging` | LoggingScreen | App bar |
| `tab_detailed` | LoggingScreen | Detailed tab |
| `tab_backdate` | LoggingScreen | Backdate tab |
| `logging_clear_button` | _DetailedLogTab | Clear button |
| `logging_log_event_button` | _DetailedLogTab | Log Event button |

## History

| Key | Location | Notes |
|-----|----------|--------|
| `app_bar_history` | HistoryScreen | App bar |
| `history_search` | HistoryScreen | Search TextField |
| `history_filter_button` | HistoryScreen | Filter icon button |
| `history_group_button` | HistoryScreen | Group-by popup menu |

## Analytics

| Key | Location | Notes |
|-----|----------|--------|
| `app_bar_analytics` | AnalyticsScreen | App bar |

## Accounts

| Key | Location | Notes |
|-----|----------|--------|
| `app_bar_accounts` | AccountsScreen | App bar |
| `accounts_export_button` | AccountsScreen | Import/Export icon |
| `accounts_add_account` | AccountsScreen | Add Another Account ListTile |
| `accounts_add_account_card` | AccountsScreen | Card wrapping add account |
| `account_card_0`, `account_card_1`, ... | AccountsScreen | Logged-in account cards (index-based; use for multi-profile switch) |

## Export

| Key | Location | Notes |
|-----|----------|--------|
| `app_bar_export` | ExportScreen | App bar |

## Dialogs

| Key | Location | Notes |
|-----|----------|--------|
| `edit_dialog_cancel` | EditLogRecordDialog | Cancel button |
| `edit_dialog_update` | EditLogRecordDialog | Update button |
| `backdate_dialog_cancel` | BackdateDialog | CANCEL button |
| `backdate_dialog_create` | BackdateDialog | CREATE LOG button |

## Semantics (findable by `find.bySemanticsLabel`)

| Label | Location | Notes |
|-------|----------|--------|
| Accounts | HomeScreen | App bar account button (SemanticIconButton) |
| Hold to record duration | HomeQuickLogWidget | Hold-to-record gesture target |

## Usage in Patrol tests

```dart
// By Key
await $(Key('nav_home')).tap();
expect($(Key('app_bar_account')).exists, isTrue);

// By semantics (when label is set)
await $(find.bySemanticsLabel('Accounts')).tap();
await $(find.bySemanticsLabel('Hold to record duration')).tap();
```

When adding new screens or primary actions, add a Key (and optionally semantics) and update this file.

## Tags (test filtering)

Patrol tests use tags so you can run subsets. Use them when adding new tests.

| Tag | Meaning |
|-----|---------|
| `smoke` | Critical path (launch, navigation, one key flow) |
| `auth` | Authentication and account navigation |
| `accounts` | Accounts screen |
| `logging` | Logging and quick log |
| `native`, `permissions` | Native dialogs (e.g. location permission) |

Example: `patrolTest('...', tags: ['smoke'], ($) async { ... });`
