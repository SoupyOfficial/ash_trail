# GitHub Actions TestFlight CI/CD Setup Guide

This guide walks you through setting up automated TestFlight deployments via GitHub Actions.

## Overview

The workflow triggers on:
- Push to `main` branch (automatic deployment)
- Manual trigger via GitHub Actions UI (workflow_dispatch)

## Prerequisites

1. **Apple Developer Account** with active membership
2. **App Store Connect API Key** (recommended over username/password)
3. **Distribution Certificate** (.p12 file)
4. **App Store Distribution Provisioning Profile**
5. **App already exists in App Store Connect**

---

## Step 1: Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** → **Integrations** → **App Store Connect API**
3. Click **Generate API Key**
4. Give it a name (e.g., "GitHub Actions")
5. Select **App Manager** role
6. Click **Generate**
7. **Download the .p8 file** (you can only download it once!)
8. Note down:
   - **Key ID** (e.g., `ABC123DEF4`)
   - **Issuer ID** (shown at the top of the page)

---

## Step 2: Export Distribution Certificate

### Option A: From Xcode (Easiest)
1. Open **Xcode** → **Settings** → **Accounts**
2. Select your Apple ID
3. Click **Manage Certificates**
4. Right-click your **Apple Distribution** certificate
5. Select **Export Certificate**
6. Set a password and save the `.p12` file

### Option B: From Keychain Access
1. Open **Keychain Access**
2. Find your "Apple Distribution" certificate
3. Right-click → **Export**
4. Save as `.p12` format with a password

---

## Step 3: Download Provisioning Profile

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list)
2. Find or create an **App Store** provisioning profile for `com.soup.smokeLog`
3. Download the `.mobileprovision` file

---

## Step 4: Update ExportOptions.plist

Edit `ios/ExportOptions.plist` and update:

```xml
<key>teamID</key>
<string>YOUR_ACTUAL_TEAM_ID</string>  <!-- Find in Apple Developer Portal -->

<key>provisioningProfiles</key>
<dict>
    <key>com.soup.smokeLog</key>
    <string>YOUR_PROFILE_NAME</string>  <!-- Exact name from Apple Developer Portal -->
</dict>
```

To find your Team ID:
- Go to [Apple Developer Portal](https://developer.apple.com/account)
- Click **Membership Details**
- Copy your **Team ID**

---

## Step 5: Encode Files as Base64

Run these commands in your terminal:

```bash
# Encode the .p12 certificate
base64 -i ~/path/to/YourCertificate.p12 | pbcopy
# Paste this into BUILD_CERTIFICATE_BASE64 secret

# Encode the provisioning profile
base64 -i ~/path/to/YourProfile.mobileprovision | pbcopy
# Paste this into PROVISIONING_PROFILE_BASE64 secret

# Encode the App Store Connect API key (.p8 file)
base64 -i ~/path/to/AuthKey_XXXXXX.p8 | pbcopy
# Paste this into APP_STORE_CONNECT_API_KEY_BASE64 secret
```

---

## Step 6: Add GitHub Secrets

Go to your GitHub repository:
1. Click **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret** and add each of these:

| Secret Name | Description |
|------------|-------------|
| `BUILD_CERTIFICATE_BASE64` | Base64-encoded .p12 distribution certificate |
| `P12_PASSWORD` | Password you set when exporting the .p12 |
| `KEYCHAIN_PASSWORD` | Any secure password (used for temp keychain) |
| `PROVISIONING_PROFILE_BASE64` | Base64-encoded .mobileprovision file |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from App Store Connect (e.g., `ABC123DEF4`) |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from App Store Connect |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64-encoded .p8 API key file |

---

## Step 7: Test the Workflow

### Automatic Trigger
Push to `main` branch:
```bash
git checkout main
git merge mvp
git push origin main
```

### Manual Trigger
1. Go to GitHub → **Actions** → **Deploy to TestFlight**
2. Click **Run workflow**
3. Optionally specify a build number
4. Click **Run workflow**

---

## Workflow File Location

The workflow is located at:
```
.github/workflows/testflight.yml
```

---

## Troubleshooting

### "No signing certificate found"
- Ensure the certificate is a **Distribution** certificate (not Development)
- Verify the base64 encoding is correct
- Check that P12_PASSWORD matches

### "Provisioning profile doesn't match"
- Profile must be **App Store** type (not Ad Hoc or Development)
- Bundle ID must match exactly: `com.soup.smokeLog`
- Profile must include the distribution certificate

### "Invalid API Key"
- Ensure the .p8 file is complete (not truncated)
- Check Key ID and Issuer ID are correct
- API Key must have **App Manager** role

### Build number conflicts
- Use the manual trigger with a specific build number
- Or ensure you're incrementing from the last TestFlight build

### Pod install failures
- The workflow runs `pod install --repo-update`
- If issues persist, check Podfile.lock is committed

---

## Security Notes

- **Never commit** certificates, profiles, or API keys to the repository
- GitHub Secrets are encrypted and masked in logs
- The workflow cleans up sensitive files after completion
- Consider using GitHub Environments for additional protection

---

## Alternative: Using Fastlane (Optional)

For more complex workflows, consider adding Fastlane:

1. Create `ios/Gemfile`:
```ruby
source "https://rubygems.org"
gem "fastlane"
```

2. Initialize Fastlane:
```bash
cd ios
bundle install
bundle exec fastlane init
```

3. Configure match for certificate management (team recommended)

---

## Quick Reference

```bash
# Build IPA locally
flutter build ipa --release

# IPA location
build/ios/ipa/ash_trail.ipa

# Manual upload (if needed)
xcrun altool --upload-app --type ios \
  --file build/ios/ipa/ash_trail.ipa \
  --apiKey "YOUR_KEY_ID" \
  --apiIssuer "YOUR_ISSUER_ID"
```
