# iOS Deployment Target Fix

## Issue
GoogleMaps 8.4.0 requires iOS 14.0+ but the project was set to iOS 13.0, causing CocoaPods installation to fail.

## Solution Applied

### 1. Updated Podfile
- Changed `platform :ios, '13.0'` to `platform :ios, '14.0'`
- Updated post_install script to set deployment target to 14.0 for all pods

### 2. Updated Xcode Project
- Changed `IPHONEOS_DEPLOYMENT_TARGET = 13.0` to `14.0` in project.pbxproj

### 3. Cleaned and Reinstalled
- Removed Pods and Podfile.lock
- Ran `flutter clean`
- Ran `flutter pub get`
- Ran `pod install` (successful)

## Verification

CocoaPods installation now completes successfully:
```
Pod installation complete! There are 17 dependencies from the Podfile and 50 total pods installed.
```

## Next Steps

The app should now build and run properly. To test screenshot capture:

1. **Build and run the app:**
   ```bash
   flutter run -d <device-id>
   ```

2. **Wait for app to fully load** (45+ seconds)

3. **Verify app is visible** (not home screen)

4. **Capture screenshots:**
   ```bash
   ./scripts/capture_app_screens.sh
   ```

## Files Modified

- `ios/Podfile` - Updated platform and deployment target
- `ios/Runner.xcodeproj/project.pbxproj` - Updated deployment target settings
