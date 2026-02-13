# Gmail Login Testing Guide for Simulator

## Gmail Auth Persistence (Seed Once, Run Forever)

### How It Works

In default Patrol mode (no `--full-isolation`), Google Sign-In state persists across repeated test runs because:

1. **Firebase Auth** stores its refresh token in the **iOS Keychain** — survives hot-restarts, app reinstalls, and simulator reboots
2. **ASWebAuthenticationSession** shares cookies with the Safari process — persisted at the OS level
3. **Default Patrol mode** hot-restarts the app (resets Dart statics) but does NOT uninstall it

Once you complete Google Sign-In manually **once**, `ensureGmailLoggedIn()` detects the persisted session (app lands on Home) and skips the entire native OAuth flow on all subsequent runs.

### State Persistence Table

| Store | Hot-Restart | App Reinstall | Sim Reboot | Sim Erase | `--full-isolation` |
|-------|:-----------:|:------------:|:----------:|:---------:|:-----------------:|
| iOS Keychain (Firebase token) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Hive local DB (accounts, logs) | ✅ | ❌ | ✅ | ❌ | ❌ |
| Safari cookies (ASWebAuth) | ✅ | ✅ | ✅ | ❌ | ✅ |
| Dart static variables | ❌ | ❌ | ❌ | ❌ | ❌ |

### One-Time Manual Seeding Procedure

1. **Boot the simulator and run the Gmail test suite:**
   ```bash
   open -a Simulator
   patrol test --target integration_test/gmail_multi_account_test.dart \
     --device "iPhone 16 Pro Max"
   ```

2. **Complete manual sign-in when prompted (~15 seconds per account):**
   - The ASWebAuthenticationSession sheet appears in the simulator
   - Tap **Continue**, enter credentials, complete sign-in
   - Account 4: `ashtraildev3@gmail.com`
   - Account 5: `soupsterx@live.com`

3. **All subsequent runs are fully automatic** — no manual interaction needed.

### When Re-Seeding Is Required

| Action | Destroys Auth State? | Re-Seed? |
|--------|:-------------------:|:--------:|
| `patrol test` (default mode) | No | No |
| `xcrun simctl shutdown` + `boot` | No | No |
| Mac reboot / Xcode restart | No | No |
| `xcrun simctl erase <uuid>` | **Yes** | **Yes** |
| `patrol test --full-isolation` | **Yes** | **Yes** |
| Delete simulator in Xcode | **Yes** | **Yes** |
| Xcode version upgrade | Maybe | Check |

### CI / Headless: Firebase Custom Token Bypass

For CI environments where no human is present:
```bash
# Generate a token via the Cloud Function
TOKEN=$(curl -s -X POST \
  https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token \
  -H 'Content-Type: application/json' \
  -d '{"uid": "<FIREBASE_UID>"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['customToken'])")

# Pass to Patrol
patrol test --target integration_test/gmail_multi_account_test.dart \
  --dart-define=FIREBASE_TEST_TOKEN=$TOKEN
```

This uses `signInWithCustomToken()` to bypass the native OAuth flow entirely.

### Why No Framework Can Automate Google Sign-In

`ASWebAuthenticationSession` is a system-level Safari view controller that runs in a separate process. No testing framework (Patrol, Maestro, Appium, raw XCUITest) can reliably interact with Google's dynamic sign-in forms inside it. See the [framework comparison](../../.github/prompts/plan-gmailLoginPersistence.prompt.md#framework-comparison-for-ios-simulator-testing) for details.

### Preflight Check

Run before tests to verify the simulator is ready:
```bash
./scripts/preflight_gmail_check.sh
```

---

## Prerequisites Checklist
- [ ] iOS Simulator running (iPhone 16 Pro Max or iPhone 13 Pro)
- [ ] Flutter app built and deployed on simulator
- [ ] WiFi/Network connection available
- [ ] Test Google account ready (Gmail address)

## Configuration Verification

### 1. Check GoogleService-Info.plist
```bash
ls -la ios/Runner/GoogleService-Info.plist
plutil -p ios/Runner/GoogleService-Info.plist | head -20
```

Should show:
- `BUNDLE_ID`: `com.soup.smokeLog`
- `CLIENT_ID`: Contains `660497517730`
- `REVERSED_CLIENT_ID`: `com.googleusercontent.apps.660497517730-...`

### 2. Verify Info.plist URL Scheme
```bash
plutil -p ios/Runner/Info.plist | grep -A 10 CFBundleURLTypes
```

Should show:
```
CFBundleURLSchemes: com.googleusercontent.apps.660497517730-dlv557f6uvb4ccre13gcrpcqf8cgg2r0
```

### 3. Check Firebase Configuration
Run this in Dart to verify Firebase initialization:
```dart
// In lib/main.dart, add debug logging after Firebase.initializeApp()
import 'package:firebase_auth/firebase_auth.dart';
print('Firebase Auth ready: ${FirebaseAuth.instance}');
```

### 4. Check Google Sign-In Configuration
```dart
// In lib/services/auth_service.dart, verify GoogleSignIn setup
GoogleSignIn(
  scopes: ['email', 'profile'],
  signInOption: SignInOption.standard,
  forceCodeForRefreshToken: true,
);
```

## Test Procedure

### Step 1: Build and Deploy
```bash
cd /Volumes/Jacob-SSD/Projects/ash_trail

# Clean build
flutter clean
flutter pub get

# Build for iOS simulator
flutter run -d 0A875592-129B-40B6-A072-A0C0CA94AED3 -v
```

### Step 2: Manual Testing on Simulator

1. **Launch App**
   - Open the deployed app on simulator
   - Should see Login screen with email/password fields and auth buttons

2. **Click "Continue with Google"**
   - Should open Google Sign-In web view or system dialog
   - On simulator: May open browser or in-app webview

3. **Enter Test Google Account**
   - Email: `your-test-google@gmail.com`
   - Password: `your-test-password`

4. **Grant Permissions**
   - You may see prompts to access basic profile info
   - Click "Allow" or "Continue"

5. **Expected Result**
   - Should redirect to home/dashboard screen
   - Should create account in local database
   - Should show logged-in state

### Step 3: Capture Logs
While testing, capture logs with:
```bash
# In another terminal
flutter logs
```

Look for messages:
- `Google sign-in successful` ✅
- `Failed to obtain Google access token` ❌
- `Firebase authentication failed` ❌
- `Google sign-in was cancelled by user` ℹ️

## Common Issues & Solutions

### Issue 1: Web View Doesn't Open
**Symptoms:**
- Clicking "Continue with Google" does nothing
- No error message shown
- App remains on login screen

**Causes:**
- URL scheme not configured in Info.plist
- GoogleService-Info.plist missing or invalid
- Network connectivity issue on simulator

**Solutions:**
```bash
# 1. Verify URL schemes
plutil -p ios/Runner/Info.plist | grep -A 5 CFBundleURLTypes

# 2. Check if file exists
ls -la ios/Runner/GoogleService-Info.plist

# 3. Test network in simulator
# Open Safari in simulator and navigate to google.com
```

### Issue 2: "Access Denied" or "Invalid Client"
**Symptoms:**
- Web view opens but shows OAuth error
- Message like "The OAuth client was not found"
- Error code: `invalid_client` or `access_denied`

**Causes:**
- Bundle ID mismatch
- Google OAuth config doesn't match app's bundle ID
- Firebase project not properly configured

**Solutions:**
```bash
# 1. Check bundle ID in Xcode
open ios/Runner.xcworkspace

# 2. Verify bundle ID matches Firebase project:
# - Bundle ID: com.soup.smokeLog
# - Firebase Project: smokelog-17303

# 3. Check GoogleService-Info.plist BUNDLE_ID field
plutil -p ios/Runner/GoogleService-Info.plist | grep BUNDLE_ID
```

### Issue 3: Login Works but Account Not Created
**Symptoms:**
- Google Sign-In web flow completes
- But app redirects to login screen instead of home
- Error message about account sync

**Causes:**
- FirebaseAuth successful but account sync failed
- Local database error when saving account
- Auth state change not propagating

**Solutions:**
```bash
# 1. Check error logs in flutter logs output

# 2. Verify Firebase Auth in console:
# https://console.firebase.google.com/project/smokelog-17303/authentication

# 3. Check local database initialization:
flutter run -d <device-id> --verbose 2>&1 | grep -i hive
```

### Issue 4: "Waiting for Chromium..." Message
**Symptoms:**
- Shows "Waiting for Chromium" dialog in simulator
- Takes very long to proceed
- Eventually times out

**Causes:**
- Google Sign-In plugin trying to use system browser
- iOS simulator doesn't have full Chrome support
- Network latency

**Solutions:**
```bash
# 1. Check Google Sign-In configuration uses webview
# In lib/services/auth_service.dart:
GoogleSignIn(
  signInOption: SignInOption.standard, // Use standard webview
  forceCodeForRefreshToken: true,
)

# 2. Increase timeout in auth_service.dart
# Add custom error handling with longer timeout
```

## Debug Logging Strategy

### Enable Verbose Logging
```bash
# Method 1: Firebase logging
flutter run -d <device-id> -v 2>&1 | tee google_signin.log

# Method 2: Grep for key messages
flutter logs | grep -E "Google|Firebase|sign|error|token"

# Method 3: Crash reporting
# Check CrashReportingService logs in:
flutter logs | grep "CrashReportingService"
```

### Key Log Messages to Monitor
```
✅ "Starting Google sign-in"
✅ "Google sign-in successful"
❌ "Google sign-in failed"
❌ "Failed to obtain Google access token"
❌ "Firebase authentication failed"
❌ "Failed to sign in with Google and sync account"
```

## Testing Checklist

- [ ] Firebase initialized successfully
- [ ] GoogleService-Info.plist loaded
- [ ] Info.plist URL schemes configured
- [ ] Google Sign-In button visible on login screen
- [ ] Clicking button opens auth flow
- [ ] Can authenticate with test Google account
- [ ] Account created in local database
- [ ] Navigation to home screen works
- [ ] User remains logged in after app restart
- [ ] Logout works and returns to login screen

## Manual Test Execution Steps

```bash
cd /Volumes/Jacob-SSD/Projects/ash_trail

# 1. Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get

# 2. Ensure simulator is running
xcrun simctl list devices | grep "Booted"

# 3. Build app
flutter run -d 0A875592-129B-40B6-A072-A0C0CA94AED3 -v

# 4. In simulator:
#    - Click "Continue with Google"
#    - Enter test Gmail credentials
#    - Grant permissions
#    - Should see home screen

# 5. In another terminal, watch logs
flutter logs
```

## Next Steps if Issues Occur

1. **Capture full error output**
   ```bash
   flutter run -d 0A875592-129B-40B6-A072-A0C0CA94AED3 -v 2>&1 | tee gmail_test.log
   ```

2. **Check Firebase Console**
   - https://console.firebase.google.com/project/smokelog-17303
   - Authentication tab
   - Google provider settings

3. **Verify iOS Configuration**
   - Xcode: `open ios/Runner.xcworkspace`
   - Check bundle identifier
   - Check signing certificates

4. **Review Auth Service Code**
   - [lib/services/auth_service.dart](lib/services/auth_service.dart)
   - [lib/services/account_integration_service.dart](lib/services/account_integration_service.dart)

## Success Criteria

Gmail login is working when:
1. ✅ Clicking "Continue with Google" opens OAuth flow
2. ✅ Can authenticate with test Google account
3. ✅ No error messages during authentication
4. ✅ Account created in local database
5. ✅ Navigation to home/dashboard succeeds
6. ✅ User info (email, display name) appears in account
7. ✅ Subsequent app launches show logged-in state
8. ✅ Logout clears auth state
