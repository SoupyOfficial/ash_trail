# TestFlight CI/CD Fixes

## Issues Addressed

### 1. Deprecated Upload Method
**Problem**: The workflow was using `xcrun altool --upload-app` which is deprecated and may not work reliably.

**Solution**: Switched to Fastlane's `upload_to_testflight` action which uses the modern App Store Connect API.

### 2. Automatic vs Manual Signing
**Problem**: The Xcode project is configured for automatic signing, which works locally but won't work on GitHub Actions runners that don't have your Apple ID configured.

**Solution**: 
- Added `--no-codesign` flag to `flutter build ios` to prevent automatic signing
- Explicitly set `CODE_SIGN_STYLE=Manual` in xcodebuild commands
- Use the provisioning profile UUID directly instead of relying on automatic profile selection
- Reference the manually installed certificate via keychain path

### 3. Provisioning Profile Reference
**Problem**: The ExportOptions.plist was using a profile name that might not match what's actually installed.

**Solution**: Extract the UUID from the installed provisioning profile and use it directly in both xcodebuild and ExportOptions.plist.

## Changes Made

### Files Created
- `ios/Gemfile` - Fastlane dependencies
- `ios/fastlane/Fastfile` - Fastlane configuration for TestFlight uploads
- `scripts/testflight_deploy_local.sh` - Local test script matching GitHub Actions
- `scripts/testflight_simple.sh` - Simplified test script using `flutter build ipa`

### Files Modified
- `.github/workflows/testflight.yml` - Updated to use Fastlane and proper manual signing

## Key Configuration Points

### Manual Signing Setup
1. Certificate is imported to a temporary keychain
2. Provisioning profile is installed with UUID as filename
3. Flutter build uses `--no-codesign` to prevent auto-signing
4. xcodebuild explicitly uses:
   - `CODE_SIGN_STYLE=Manual`
   - `CODE_SIGN_IDENTITY="Apple Distribution"`
   - `PROVISIONING_PROFILE_SPECIFIER` with UUID
   - `CODE_SIGN_KEYCHAIN` pointing to temp keychain

### Fastlane Upload
- Uses App Store Connect API key authentication
- No longer requires deprecated `xcrun altool`
- More reliable and better error messages

## Testing Locally

### Option 1: Full Workflow Test
```bash
SKIP_TESTS=1 ./scripts/testflight_deploy_local.sh
```

This mimics the full GitHub Actions workflow including:
- Manual certificate installation
- Manual provisioning profile installation
- Manual signing with xcodebuild

### Option 2: Simplified Test
```bash
./scripts/testflight_simple.sh
```

This uses `flutter build ipa` which handles signing automatically (good for local testing, but won't match CI exactly).

## Required GitHub Secrets

The workflow requires these secrets to be configured:
- `BUILD_CERTIFICATE_BASE64` - Base64-encoded .p12 certificate
- `P12_PASSWORD` - Password for the .p12 file
- `KEYCHAIN_PASSWORD` - Password for temporary keychain
- `PROVISIONING_PROFILE_BASE64` - Base64-encoded .mobileprovision file
- `APP_STORE_CONNECT_API_KEY_ID` - App Store Connect API key ID
- `APP_STORE_CONNECT_API_ISSUER_ID` - App Store Connect issuer ID
- `APP_STORE_CONNECT_API_KEY_BASE64` - Base64-encoded .p8 API key file

## Verification Steps

Before deploying, verify:
1. Certificate is valid and not expired
2. Provisioning profile matches bundle ID (`com.soup.smokeLog`)
3. Provisioning profile is for App Store distribution (not Ad Hoc or Development)
4. API key has App Manager or Admin role in App Store Connect
5. Build number is incremented from last TestFlight build
