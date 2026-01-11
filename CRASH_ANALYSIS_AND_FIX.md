# Gmail Login Crash Issue - Root Cause Analysis

## Crash Found ⚠️

**Date:** January 5, 2026 @ 21:14:18
**Crash Type:** Segmentation Fault (SIGSEGV) in native iOS code
**File:** FLTGoogleSignInPlugin.m (line 171)
**Method:** `-[FLTGoogleSignInPlugin signInWithCompletion:]`

### Crash Stack Trace Summary
```
Thread 0 (Main - crashed):
  -[FLTGoogleSignInPlugin signInWithCompletion:]  [FLTGoogleSignInPlugin.m:171]
    ↓ (called via platform channel)
    -[FlutterBasicMessageChannel setMessageHandler:]
    ↓
  EXC_BAD_ACCESS (SIGSEGV)
```

### Root Cause

The Google Sign-In native iOS plugin (`google_sign_in_ios`) was crashing because the `clientId` was not explicitly provided during initialization. The Dart GoogleSignIn class wasn't passing the OAuth client ID to the native iOS layer, causing the native code to receive nil/invalid parameters.

## The Fix

### Change Made

Updated [lib/services/auth_service.dart](lib/services/auth_service.dart) to explicitly provide the clientId when initializing GoogleSignIn:

```dart
GoogleSignIn(
  clientId: '660497517730-dlv557f6uvb4ccre13gcrpcqf8cgg2r0.apps.googleusercontent.com',
  scopes: ['email', 'profile'],
  signInOption: SignInOption.standard,
  forceCodeForRefreshToken: true,
)
```

### Additional Improvements

Also added:
1. **Better error logging** - Added debug messages at each step of the sign-in flow
2. **Defensive clean state** - Call `signOut()` before `signIn()` to ensure clean state
3. **Enhanced error handling** - Better error type reporting and crash reporting

### Why This Works

The iOS native GoogleSignIn plugin requires the `clientId` to be explicitly provided. Without it, the native layer can't initialize properly, leading to a crash when attempting authentication. The `clientId` should match the one in:
- GoogleService-Info.plist (REVERSED_CLIENT_ID)
- Firebase Project Console
- Google Cloud Console

## Files Modified

- [lib/services/auth_service.dart](lib/services/auth_service.dart)
  - Added explicit `clientId` parameter
  - Enhanced error logging throughout sign-in flow
  - Added pre-sign-in cleanup (signOut)

## Build Status

- [x] Code changes applied
- [x] Xcode cache cleared
- [ ] Fresh build in progress
- [ ] Test on simulator pending

## Next Steps

1. Complete fresh build
2. Test Gmail login on simulator
3. Verify no crash occurs
4. Confirm successful authentication
5. Test account persistence

## Reference

**Crash Report Location:**
```
~/Library/Logs/DiagnosticReports/Runner-2026-01-05-211418.ips
```

**Configuration Files:**
- GoogleService-Info.plist ✅ (properly configured)
- Info.plist (CFBundleURLSchemes) ✅ (properly configured)
- firebase_options.dart ✅ (properly configured)

All other configurations were correct - the issue was purely with the missing `clientId` in the Dart initialization.
