# Gmail Login Testing - iOS Simulator

## Status
Ready to test Gmail login on iOS simulator (iPhone 16 Pro Max, iOS 26.2)

## Configuration Verified ✅
- [x] GoogleService-Info.plist - Properly configured
  - BUNDLE_ID: com.soup.smokeLog
  - CLIENT_ID: 660497517730-dlv557f6uvb4ccre13gcrpcqf8cgg2r0.apps.googleusercontent.com
  - REVERSED_CLIENT_ID: com.googleusercontent.apps.660497517730-dlv557f6uvb4ccre13gcrpcqf8cgg2r0

- [x] Info.plist - URL schemes configured
  - CFBundleURLSchemes: com.googleusercontent.apps.660497517730-dlv557f6uvb4ccre13gcrpcqf8cgg2r0

- [x] Firebase Configuration - Set up correctly
  - Project: smokelog-17303
  - Web API Key: AIzaSyBSc89SEMjq4XD3HluQX06OJoGmjzZpg3I

- [x] Google Sign-In Configuration - Enabled
  - Scopes: email, profile
  - Sign-in option: standard (webview)

## Simulator Status ✅
- Device: iPhone 16 Pro Max (0A875592-129B-40B6-A072-A0C0CA94AED3)
- OS: iOS 26.2
- State: Booted and running

## How to Test

### Option 1: Direct App Deployment (Fastest)
```bash
cd /Volumes/Jacob-SSD/Projects/ash_trail

# Deploy to running simulator
flutter run -d 0A875592-129B-40B6-A072-A0C0CA94AED3

# In another terminal, watch logs:
flutter logs | grep -E "Google|Firebase|sign|error|token"
```

### Option 2: Watch Logs in Real-time
```bash
# Terminal 1: Deploy app
flutter run -d 0A875592-129B-40B6-A072-A0C0CA94AED3

# Terminal 2: Monitor logs
flutter logs
```

## Manual Test Steps

1. **App launches** → Should see login screen
   - Email/password login fields visible ✓
   - "Continue with Google" button visible ✓
   - "Continue with Apple" button visible ✓

2. **Click "Continue with Google"**
   - Button should become loading state
   - Should trigger Google Sign-In flow

3. **Expected Behavior**
   - Browser/webview opens with Google Sign-In page
   - Or "Sign in with Google" dialog appears
   - Enter Gmail credentials

4. **After Authentication**
   - Should see account created in Hive database
   - Should navigate to home/dashboard screen
   - Should see logged-in user info

5. **Success Indicators**
   - No error messages
   - Navigation to home screen succeeds
   - User email appears in app

## Troubleshooting

### If Google Sign-In Button Does Nothing
1. Check logs: `flutter logs | grep -i google`
2. Look for: "Starting Google sign-in" message
3. Verify network: Open Safari in simulator, go to google.com
4. Check Info.plist: `plutil -p ios/Runner/Info.plist | grep -A 5 CFBundleURLTypes`

### If "Access Denied" Error
1. Verify BUNDLE_ID matches Firebase project
2. Check GoogleService-Info.plist is loaded
3. Verify CLIENT_ID in plist matches Firebase

### If App Stays on Login Screen
1. Check: `flutter logs | grep -i "firebase\|account"`
2. Check local database saved account
3. Verify auth state change propagated

## Key Log Messages to Look For

```
✅ Successful Flow:
   "Starting Google sign-in"
   "Google sign-in successful"
   "User signed in: <email>"

❌ Error Signs:
   "Google sign-in failed"
   "Failed to obtain Google access token"
   "Firebase authentication failed"
   "Failed to sign in with Google and sync account"
```

## Files Involved
- [lib/services/auth_service.dart](lib/services/auth_service.dart) - Google Sign-In logic
- [lib/services/account_integration_service.dart](lib/services/account_integration_service.dart) - Account sync
- [lib/screens/auth/login_screen.dart](lib/screens/auth/login_screen.dart) - UI
- [ios/Runner/GoogleService-Info.plist](ios/Runner/GoogleService-Info.plist) - Firebase config
- [ios/Runner/Info.plist](ios/Runner/Info.plist) - URL schemes
- [lib/firebase_options.dart](lib/firebase_options.dart) - Firebase setup

## Next Steps After Testing
1. Record any error messages
2. Check crash reporting logs
3. Verify account creation in local database
4. Test account persistence (close/reopen app)
5. Test logout functionality
