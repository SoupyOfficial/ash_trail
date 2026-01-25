# Multi-Account Implementation Guide

## Quick Reference

This document provides a quick reference for developers working with the multi-account feature.

## Key Files

| File | Purpose |
|------|---------|
| `lib/services/token_service.dart` | Generates Firebase Custom Tokens via Cloud Function |
| `lib/services/account_session_manager.dart` | Manages custom token storage and expiration |
| `lib/services/account_integration_service.dart` | Handles account creation and token generation on sign-in |
| `lib/providers/account_provider.dart` | Account switching logic with seamless authentication |
| `lib/services/sync_service.dart` | Syncs data with account-scoped filtering |
| `lib/services/log_record_service.dart` | Account-scoped data queries |

## Common Tasks

### Adding a New Account

```dart
// User signs in via AccountIntegrationService
final account = await accountIntegrationService.signInWithGoogle();
// Custom token is automatically generated and stored
```

### Switching Accounts

```dart
// Use AccountSwitcher provider
await ref.read(accountSwitcherProvider.notifier).switchAccount(userId);
// Firebase Auth switches instantly, no UI interaction required
```

### Checking Active Account

```dart
// Watch active account
final activeAccount = ref.watch(activeAccountProvider);
activeAccount.whenData((account) {
  print('Active account: ${account?.email}');
});
```

### Syncing Data

```dart
// Sync automatically filters by authenticated user
final syncService = ref.read(syncServiceProvider);
await syncService.syncPendingRecords();
// Only syncs records where record.accountId == FirebaseAuth.currentUser.uid
```

## Testing

### Mock TokenService

```dart
class MockTokenService extends TokenService {
  final Map<String, String> _tokens = {};
  
  @override
  Future<Map<String, dynamic>> generateCustomToken(String uid) async {
    if (!_tokens.containsKey(uid)) {
      _tokens[uid] = 'mock-token-$uid';
    }
    return {
      'customToken': _tokens[uid]!,
      'expiresIn': 172800,
    };
  }
}
```

### Mock AccountSessionManager

See `test/providers/account_provider_test.dart` for example mock implementation.

## Troubleshooting

### Issue: Records stay pending after account switch

**Cause**: Firebase Auth user doesn't match record's accountId

**Solution**: Ensure `switchAccount()` successfully calls `signInWithCustomToken()`

### Issue: Token generation fails

**Cause**: Cloud Function unavailable or network error

**Solution**: App continues to work locally, but sync will fail until token can be generated

### Issue: Token expired

**Cause**: Token older than 47 hours

**Solution**: Token is automatically regenerated on next account switch

## Architecture Reference

See [Multi-Account Architecture Documentation](MULTI_ACCOUNT_ARCHITECTURE.md) for complete architecture details.
