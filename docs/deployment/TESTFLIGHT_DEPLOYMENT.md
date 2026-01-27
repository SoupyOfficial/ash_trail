# TestFlight Deployment Guide for Ash Trail

## Current Configuration
- **Bundle ID**: `com.soup.smokeLog`
- **Version**: `1.0.0+1`
- **App Name**: Ash Trail

## Prerequisites Checklist
- [ ] Apple Developer Account with active membership
- [ ] App Store Connect access
- [ ] Signing certificates and provisioning profiles configured in Xcode
- [ ] Existing app in App Store Connect (since deploying to same TestFlight as old project)

## Deployment Steps

### 1. Update Version/Build Number
If the old project already uses version `1.0.0+1`, increment the build number:

```bash
# Update to next build number (e.g., 1.0.0+2)
# Edit pubspec.yaml and change:
version: 1.0.0+2
```

### 2. Open Project in Xcode
```bash
cd ios
open Runner.xcworkspace
```

### 3. Configure Signing in Xcode
1. Select **Runner** project in the left panel
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Select your Team
5. Ensure **Automatically manage signing** is checked
6. Verify the Bundle Identifier is `com.soup.smokeLog`

### 4. Archive the App
In Xcode:
1. Select **Any iOS Device (arm64)** as the build target (not a simulator)
2. Go to **Product** → **Archive**
3. Wait for the archive to complete

### 5. Upload to TestFlight
1. When archive completes, the **Organizer** window opens
2. Select your archive
3. Click **Distribute App**
4. Select **App Store Connect**
5. Click **Upload**
6. Follow the prompts to complete upload

### 6. Manage in App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **TestFlight** tab
4. Wait for processing to complete (~5-15 minutes)
5. Add test information and submit for beta review if needed
6. Invite testers or add to existing test groups

## Alternative: Command Line Deployment

### Build and Archive via CLI
```bash
# Build the iOS app
flutter build ipa --release

# The .ipa file will be at:
# build/ios/ipa/ash_trail.ipa
```

### Upload with Transporter or xcrun
```bash
# Option 1: Use Apple's Transporter app (recommended)
# Download from Mac App Store, then drag the .ipa file to upload

# Option 2: Use xcrun altool (requires app-specific password)
xcrun altool --upload-app --type ios \
  --file build/ios/ipa/ash_trail.ipa \
  --username "your-apple-id@example.com" \
  --password "@keychain:AC_PASSWORD"
```

## Troubleshooting

### Version Already Exists
If you get "version already exists" error:
```bash
# Increment build number in pubspec.yaml
version: 1.0.0+2  # or higher
```

### Signing Issues
- Ensure your Apple Developer account has valid certificates
- Check that provisioning profiles are not expired
- Try toggling "Automatically manage signing" off and back on

### Missing Compliance
If you get export compliance warnings, you may need to add to Info.plist:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

## Quick Command Reference

```bash
# Check current version
grep "version:" pubspec.yaml

# Clean build
flutter clean
flutter pub get

# Build for iOS
flutter build ios --release

# Build IPA for distribution
flutter build ipa --release

# Open in Xcode
open ios/Runner.xcworkspace
```

## Post-Deployment
1. Monitor App Store Connect for processing status
2. Test the build on TestFlight before wider distribution
3. Update version numbers for next release
4. Tag the release in Git:
   ```bash
   git tag -a v1.0.0-build2 -m "TestFlight release"
   git push origin v1.0.0-build2
   ```
