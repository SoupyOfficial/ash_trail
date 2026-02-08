# TestFlight CLI Upload Guide

This guide covers how to set up CLI-based uploads to TestFlight using `xcrun altool`.

---

## Authentication Options

You need **one** of the following:

| Method | Best For | Setup Time |
|--------|----------|------------|
| Apple ID + App-Specific Password | Quick one-off uploads | ~2 minutes |
| App Store Connect API Key | CI/CD and repeated uploads | ~5 minutes |

---

## Option 1: Apple ID + App-Specific Password

### Step 1: Generate an App-Specific Password

1. Go to [https://account.apple.com](https://account.apple.com)
2. Sign in with your Apple ID
3. Navigate to **Sign-In and Security** → **App-Specific Passwords**
4. Click **Generate an app-specific password**
5. Enter a label (e.g., `testflight-cli`)
6. Copy the generated password (format: `xxxx-xxxx-xxxx-xxxx`)

> **Important:** Save this password somewhere secure — you won't be able to see it again.

### Step 2: Upload

```bash
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/ash_trail.ipa \
  --username "your-apple-id@email.com" \
  --password "xxxx-xxxx-xxxx-xxxx"
```

### Step 3 (if needed): Provider Public ID

If your Apple ID belongs to multiple teams, you'll get an error asking for `--provider-public-id`. To find it:

```bash
xcrun altool --list-providers \
  --username "your-apple-id@email.com" \
  --password "xxxx-xxxx-xxxx-xxxx"
```

This prints a table of providers with their **Public ID**. Add it to your upload command:

```bash
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/ash_trail.ipa \
  --username "your-apple-id@email.com" \
  --password "xxxx-xxxx-xxxx-xxxx" \
  --provider-public-id "YOUR_PUBLIC_ID"
```

---

## Option 2: App Store Connect API Key (Recommended)

### Step 1: Generate an API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** → **Integrations** → **App Store Connect API**
3. Click the **+** button to generate a new key
4. Enter a name (e.g., `TestFlight CLI`)
5. Select **Developer** role (minimum required for uploads)
6. Click **Generate**

### Step 2: Download and Note Your Credentials

After generating, you'll see:

- **Issuer ID** — shown at the top of the keys page (shared across all keys)
- **Key ID** — shown in the key list (e.g., `ABC1234DEF`)
- **API Key file** — click **Download** to get the `.p8` file

> **Important:** You can only download the `.p8` file **once**. Save it securely.

### Step 3: Place the `.p8` File

Move the downloaded `.p8` file to one of these directories (create it if it doesn't exist):

```bash
mkdir -p ~/.private_keys
mv ~/Downloads/AuthKey_ABC1234DEF.p8 ~/.private_keys/
```

Supported locations:
- `~/.private_keys/`
- `~/private_keys/`
- `~/.appstoreconnect/private_keys/`

The file **must** be named `AuthKey_<KEY_ID>.p8`.

### Step 4: Upload

```bash
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/ash_trail.ipa \
  --apiKey "ABC1234DEF" \
  --apiIssuer "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Replace:
- `ABC1234DEF` with your **Key ID**
- `xxxxxxxx-...` with your **Issuer ID**

---

## Storing Credentials Securely (Optional)

To avoid pasting credentials every time, store them in your macOS Keychain:

### For Apple ID method:

```bash
xcrun altool --store-password-in-keychain-item "altool-password" \
  -u "your-apple-id@email.com" \
  -p "xxxx-xxxx-xxxx-xxxx"
```

Then reference it with `@keychain:`:

```bash
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/ash_trail.ipa \
  --username "your-apple-id@email.com" \
  --password @keychain:altool-password
```

### For API Key method:

Export environment variables in your `~/.zshrc`:

```bash
export APP_STORE_CONNECT_API_KEY="ABC1234DEF"
export APP_STORE_CONNECT_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Then use:

```bash
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/ash_trail.ipa \
  --apiKey "$APP_STORE_CONNECT_API_KEY" \
  --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID"
```

---

## Full Build + Upload Workflow

```bash
# 1. Clean (removes stale Generated.xcconfig from patrol runs)
flutter clean

# 2. Restore dependencies
flutter pub get

# 3. Build the release IPA
flutter build ipa --release

# 4. Upload to TestFlight
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/ash_trail.ipa \
  --apiKey "$APP_STORE_CONNECT_API_KEY" \
  --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID"
```

> **Why `flutter build ipa` instead of Xcode Archive?**
> Building directly from Xcode UI does not regenerate `ios/Flutter/Generated.xcconfig`. If you've run patrol tests, that file will have `FLUTTER_TARGET` pointing to the test entry point instead of `lib/main.dart`, causing a **white screen** on launch.

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| `Authentication is required` | Provide credentials via one of the methods above |
| `Could not find the private key` | Ensure `.p8` is in `~/.private_keys/` and named `AuthKey_<KEY_ID>.p8` |
| `Multiple providers` | Add `--provider-public-id` (see Option 1, Step 3) |
| `App version already exists` | Bump version in `pubspec.yaml` and rebuild |
| `Invalid signature` | Run `flutter clean` then rebuild — stale code signing artifacts |
