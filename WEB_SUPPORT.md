# Web Support for AshTrail

## Current Status: ❌ Web Not Supported

The AshTrail app currently **cannot run on web browsers** due to the use of Isar database.

## Why Web Doesn't Work

### The Problem

Isar generates Dart code with large integer literals that cannot be represented in JavaScript:

```
Error: The integer literal 6646797162501847804 can't be represented exactly in JavaScript.
```

JavaScript's `Number` type can only safely represent integers up to `2^53 - 1` (9,007,199,254,740,991). Isar uses larger integers for its schema IDs, which breaks web compilation.

### What Doesn't Work

```bash
# These commands WILL FAIL:
flutter run -d chrome
flutter build web
flutter test --platform chrome
```

## Solutions to Enable Web Support

### Option 1: Use Firestore Only on Web (Recommended)

Remove local database for web builds, rely entirely on Firestore.

**Pros:**
- Minimal code changes
- No additional dependencies
- Cloud-first approach

**Cons:**
- Requires internet connection
- No offline support on web
- Higher Firebase costs

**Implementation:**
1. Conditionally skip Isar initialization on web
2. Update services to use Firestore directly when Isar is unavailable
3. Keep existing code for native platforms

### Option 2: Switch to Hive Database

Replace Isar with Hive, which supports web.

**Pros:**
- Works on all platforms
- Offline support on web
- Similar API to Isar

**Cons:**
- Less performant than Isar
- Requires rewriting all database code
- Different query syntax

**Steps:**
```bash
# Remove Isar
flutter pub remove isar isar_flutter_libs isar_generator

# Add Hive
flutter pub add hive hive_flutter
flutter pub add --dev hive_generator build_runner

# Rewrite models to use Hive annotations
# Rewrite all database queries
```

### Option 3: Keep App Native-Only (Current Approach)

Accept that the app only runs on native platforms.

**Pros:**
- Best performance
- No compromises
- Current code works perfectly

**Cons:**
- No web version
- Can't use Playwright for E2E tests
- Limited deployment options

## Recommended Approach

**For now: Keep the app native-only** ✅

The app is designed for mobile/desktop with offline-first capabilities. Isar provides excellent performance for this use case. Web support would require significant architectural changes and compromises.

**If web is needed later:**
1. Create a web-specific version using Hive or Firestore-only
2. Share business logic but separate data layers
3. Use feature flags to toggle implementations

## Testing Strategy

Since web doesn't work:

- ✅ **Unit tests**: Run on native (all 29 passing)
- ✅ **Integration tests**: Run on iOS/Android/macOS
- ❌ **Playwright E2E**: Cannot test Flutter web app
- ✅ **Manual testing**: Use iOS simulator or Android emulator

## Running the App

```bash
# ✅ Works - macOS desktop
flutter run -d macos

# ✅ Works - iOS simulator
flutter run -d ios

# ✅ Works - Android emulator
flutter run -d android

# ❌ FAILS - Chrome
flutter run -d chrome  # Will not compile
```

## Alternative: Mock API for Playwright

If you want to test UI flows with Playwright:

1. Create a simple web server that serves mock data
2. Build a minimal web UI (without database)
3. Test that UI with Playwright

This would be a separate project from the main Flutter app.

## Summary

- **Current architecture**: Isar (native-only) + Firestore (cloud sync)
- **Web status**: Not supported (by design)
- **Recommendation**: Keep native-only for best performance
- **Future option**: Add web support with Hive if needed

The choice of Isar was deliberate for performance. If web is a requirement, the entire data layer needs redesign.
