# Quick Reference: Running Ash Trail

## One Command for All Platforms! 🎉

```bash
flutter run
```

That's it! Flutter automatically detects your platform and uses the right implementation.

## Platform Selection

When you run `flutter run`, you'll see available devices:

```
[1]: Chrome (web)
[2]: macOS (desktop)
[3]: iPhone Simulator (iOS)
```

Choose the number for your desired platform.

## Direct Platform Launch

```bash
# Web
flutter run -d chrome

# macOS
flutter run -d macos

# iOS Simulator  
flutter run -d ios

# Android Emulator
flutter run -d android
```

## What Happens Behind the Scenes

### For Web (Chrome)
1. `lib/main.dart` detects web platform
2. Conditionally imports `lib/main_web.dart`
3. Uses **Hive** database (IndexedDB)
4. Shows simplified UI (tabs for Log/History/Analytics)

### For Native (macOS, iOS, Android, etc.)
1. `lib/main.dart` detects native platform
2. Conditionally imports `lib/main_native.dart`
3. Uses **Isar** database (fast local storage)
4. Shows full-featured UI with all capabilities

## Current Feature Status

### ✅ Native Platforms (Fully Functional)
- Complete logging system
- Analytics and charts
- Session tracking
- Template system
- Offline-first with sync

### ⚠️ Web Platform (UI Framework Only)
- Basic UI layout present
- Database initialized (Hive)
- **Not yet connected** - placeholders only
- Awaiting service layer implementation

## Tips

- **For development**: Use hot reload with `r` in the terminal
- **For production builds**: Use `flutter build web` or `flutter build macos`
- **Clean builds**: Run `flutter clean` if you encounter issues
- **See device list**: Run `flutter devices`

## Troubleshooting

### "No devices found"
- For web: Make sure Chrome is installed
- For iOS: Open Xcode and start a simulator
- For Android: Start an emulator from Android Studio

### Compilation errors on web
- These are expected if Isar models are imported
- Make sure `lib/main.dart` conditional imports are working
- Check that you're using `dart.library.js_interop` condition

### Build errors on native
- Run `flutter pub get`
- Run `dart run build_runner build --delete-conflicting-outputs`
- For iOS/macOS: Run `pod install` in the respective directory
