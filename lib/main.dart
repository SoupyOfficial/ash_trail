/// Main entry point - automatically routes to platform-specific implementation
///
/// This file uses conditional imports to load the appropriate implementation:
/// - Web: Uses Hive database and simplified UI
/// - Native (iOS/Android/Desktop): Uses Isar database with full features
///
/// This allows running `flutter run` on any platform without additional flags.

export 'main_native.dart' if (dart.library.js_interop) 'main_web.dart';
