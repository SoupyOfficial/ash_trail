# Google Maps API Key Setup

The Google Maps API key is no longer hardcoded in the source code. It must be configured via build settings or environment variables.

## Setup Methods

### Method 1: Xcode Build Settings (Recommended for Local Development)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the `Runner` project in the navigator
3. Select the `Runner` target
4. Go to the "Build Settings" tab
5. Search for "GOOGLE_MAPS_API_KEY"
6. Add a new User-Defined Setting:
   - Key: `GOOGLE_MAPS_API_KEY`
   - Value: Your Google Maps API key

### Method 2: xcconfig File (Recommended for CI/CD)

Create a local xcconfig file (gitignored) that includes your API key:

1. Create `ios/Flutter/GoogleMaps.xcconfig` (add to `.gitignore`)
2. Add the following:
   ```
   GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
   ```
3. Include it in `ios/Flutter/Debug.xcconfig` and `ios/Flutter/Release.xcconfig`:
   ```
   #include "GoogleMaps.xcconfig"
   ```

### Method 3: Environment Variable (For CI/CD)

Set the environment variable before building:
```bash
export GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
flutter build ios
```

## Security Notes

- **Never commit the API key to version control**
- The API key should be restricted in Google Cloud Console to:
  - iOS bundle ID: `com.soup.smokeLog`
  - Specific API restrictions (Maps SDK for iOS)
- Use different keys for development and production if needed

## Verification

The app will print a warning if the API key is not found:
```
⚠️ Warning: Google Maps API key not found. Maps functionality may be limited.
```

If you see this warning, check your build configuration.
