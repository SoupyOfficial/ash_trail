# Test Accounts Setup Guide

> **Last Updated**: February 9, 2026
> **Status**: 🔧 In Progress
> **Firebase Project**: `smokelog-17303`

## Overview

AshTrail uses dedicated Gmail accounts for multi-account integration testing with Google Sign-In. This guide covers creating and configuring test accounts 4 and 5.

## Existing Test Accounts

| # | Email | Auth Method | Purpose |
|---|-------|-------------|---------|
| 1 | `test1@ashtrail.dev` | Email/Password | Integration test account 1 |
| 2 | `test2@ashtrail.dev` | Email/Password | Integration test account 2 |
| 3 | `test3@ashtrail.dev` | Email/Password | Unit test account 3 |
| **4** | `ashtraildev3@gmail.com` | **Google Sign-In** | Multi-account auth testing |
| **5** | `ashtraildev4@gmail.com` | **Google Sign-In** | Multi-account auth testing |

## Step 1: Create Gmail Accounts

### Account 4: `ashtraildev3@gmail.com`

1. Go to [https://accounts.google.com/signup](https://accounts.google.com/signup)
2. Fill in:
   - **First name**: AshTrail
   - **Last name**: Dev Three
   - **Email**: `ashtraildev3@gmail.com`
   - **Password**: `AshTestPass123!`
3. Complete phone verification if prompted
4. Skip optional profile setup

### Account 5: `ashtraildev4@gmail.com`

1. Go to [https://accounts.google.com/signup](https://accounts.google.com/signup)
2. Fill in:
   - **First name**: AshTrail
   - **Last name**: Dev Four
   - **Email**: `ashtraildev4@gmail.com`
   - **Password**: `AshTestPass456!`
3. Complete phone verification if prompted
4. Skip optional profile setup

> **Tip**: Use a different phone number for each account, or use Google Voice. Google may require phone verification and limits how many accounts can be created per phone number.

## Step 2: Register Accounts in Firebase

After creating the Gmail accounts, they will auto-register in Firebase when they first sign in via Google Sign-In in the app. However, you can also pre-register them:

1. Go to [Firebase Console → Authentication → Users](https://console.firebase.google.com/project/smokelog-17303/authentication/users)
2. Click **Add user**
3. Add each account:
   - Email: `ashtraildev3@gmail.com` / Password: `AshTestPass123!`
   - Email: `ashtraildev4@gmail.com` / Password: `AshTestPass456!`

> **Note**: For Google Sign-In testing, the accounts will be auto-created in Firebase Auth the first time they authenticate via the Google Sign-In flow. Manual creation is only needed for email/password fallback testing.

## Step 3: Test Google Sign-In Flow

### On iOS Simulator

```bash
flutter run -d <simulator-id>
```

1. Tap **"Continue with Google"** on the login screen
2. Sign in with `ashtraildev3@gmail.com`
3. Verify account appears in the Accounts screen
4. Tap **"Add Account"**
5. Sign in with `ashtraildev4@gmail.com`
6. Verify both accounts appear and switching works

### On Android Emulator

```bash
flutter run -d <emulator-id>
```

Same steps as iOS above.

## Step 4: Verify Multi-Account Switching

After both accounts are signed in:

1. Open the **Accounts** screen
2. Verify both accounts are listed
3. Switch from account 4 → account 5
4. Create a log entry under account 5
5. Switch back to account 4
6. Verify account 4's data is intact (no cross-contamination)
7. Switch to account 5 again
8. Verify the log entry from step 4 is still there

## Integration Test Configuration

Test accounts 4 and 5 are configured in:

- `integration_test/helpers/config.dart` — credentials constants
- `integration_test/multi_account_test.dart` — test prerequisites
- `test/providers/multi_account_realistic_test.dart` — unit test constants

## Security Notes

- **Never** commit real Gmail passwords to the repository
- Store passwords in a secure password manager shared with the team
- These accounts should only be used for testing — never for personal use
- Consider enabling 2FA on these accounts and using App Passwords if needed for CI

## Troubleshooting

### "This account already exists"
The Gmail address is already taken. Try variations like `ashtrail.test4@gmail.com` (Gmail ignores dots).

### Google Sign-In fails on simulator
- Ensure `GoogleService-Info.plist` is properly configured
- Check that the OAuth client ID matches the bundle ID (`com.soup.smokeLog`)
- See [GMAIL_LOGIN_TEST_READY.md](../deployment/GMAIL_LOGIN_TEST_READY.md)

### Firebase doesn't show the account
The account will appear in Firebase Auth after the first successful Google Sign-In. If using email/password, you must manually add the user in the Firebase Console.

### Rate limiting on account creation
Google limits account creation per IP/phone number. Wait 24 hours or use a different network if you hit limits.
