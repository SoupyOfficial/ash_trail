# crash_reporting_service

> **Source:** `lib/services/crash_reporting_service.dart`

## Purpose

Singleton wrapper around Firebase Crashlytics. Captures uncaught Flutter framework errors, platform-level fatal errors, and explicit `recordError` calls. Collection is enabled unconditionally in all build modes (debug, profile, release/TestFlight). Provides device context enrichment via `PackageInfo` and `DeviceInfoPlugin`.

## Dependencies

- `dart:io` — `Platform` (iOS vs Android detection)
- `package:firebase_crashlytics/firebase_crashlytics.dart` — `FirebaseCrashlytics`
- `package:flutter/foundation.dart` — `kDebugMode`, `kIsWeb`, `FlutterError`, `PlatformDispatcher`
- `package:package_info_plus/package_info_plus.dart` — `PackageInfo.fromPlatform()`
- `package:device_info_plus/device_info_plus.dart` — `DeviceInfoPlugin`
- `../logging/app_logger.dart` — Structured logging (`AppLogger`)

## Pseudo-Code

### Class: CrashReportingService (Singleton)

```
  _log: AppLogger (tagged 'CrashReportingService')
  _instance: CrashReportingService (static final, lazy)
  factory() -> _instance
```

---

#### `initialize()` -> static Future\<void\>

```
TRY:
  // Wire Flutter framework errors -> Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError

  // Wire uncaught platform errors -> Crashlytics (fatal: true)
  PlatformDispatcher.instance.onError = (error, stack) ->
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true)
    RETURN true

  // Enable collection in ALL build modes (debug, profile, release)
  AWAIT FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true)

  IF kDebugMode -> LOG 'Crash reporting initialized'

CATCH -> LOG error
```

#### `setDeviceContext()` -> static Future\<void\>

```
TRY:
  // App version custom keys
  packageInfo = AWAIT PackageInfo.fromPlatform()
  SET custom key 'app_version' = packageInfo.version
  SET custom key 'build_number' = packageInfo.buildNumber

  // Platform-specific device keys (skip web)
  IF NOT kIsWeb:
    IF Platform.isIOS:
      ios = AWAIT DeviceInfoPlugin().iosInfo
      SET custom key 'device_model' = ios.utsname.machine
      SET custom key 'os_version' = ios.systemVersion
    ELSE IF Platform.isAndroid:
      android = AWAIT DeviceInfoPlugin().androidInfo
      SET custom key 'device_model' = android.model
      SET custom key 'os_version' = 'Android ${android.version.release}'

  LOG 'Device context set on Crashlytics'

CATCH -> LOG error (non-fatal)
```

#### `recordError(error, stackTrace?, {reason?, fatal = false})` -> static Future\<void\>

```
TRY:
  AWAIT FirebaseCrashlytics.instance.recordError(error, stackTrace,
    reason: reason, fatal: fatal)
  IF kDebugMode -> LOG 'Error recorded: $error, Fatal: $fatal'
CATCH -> LOG error
```

#### `setCustomKey(key, value)` -> static Future\<void\>

```
TRY: AWAIT FirebaseCrashlytics.instance.setCustomKey(key, value)
CATCH -> LOG error
```

#### `setUserId(userId)` -> static Future\<void\>

```
TRY: AWAIT FirebaseCrashlytics.instance.setUserIdentifier(userId)
CATCH -> LOG error
```

#### `clearUserId()` -> static Future\<void\>

```
TRY: AWAIT FirebaseCrashlytics.instance.setUserIdentifier('')
CATCH -> LOG error
```

#### `logMessage(message)` -> static void

```
TRY: FirebaseCrashlytics.instance.log(message)
CATCH -> LOG error
```

#### `isCrashlyticsCollectionEnabled()` -> static Future\<bool\>

```
TRY: RETURN FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled
CATCH -> LOG error, RETURN false
```

## Notes

- Collection is always enabled (`setCrashlyticsCollectionEnabled(true)` in all build modes). Previous versions only enabled in non-debug; this was changed to ensure TestFlight crashes are always captured.
- `setDeviceContext()` should be called once after `initialize()` at app startup (see `main.dart`). It sets four custom keys: `app_version`, `build_number`, `device_model`, `os_version`.
- All public methods are `static` — the singleton instance is only used to satisfy the factory constructor pattern. Callers use `CrashReportingService.recordError(...)` etc.
- Every method wraps its body in try/catch to prevent Crashlytics failures from crashing the app.
