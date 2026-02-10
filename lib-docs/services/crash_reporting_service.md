# crash_reporting_service

> **Source:** `lib/services/crash_reporting_service.dart`

## Purpose

Wraps Firebase Crashlytics for crash and error reporting. Captures Flutter framework errors, platform-level errors, custom errors, user identifiers, and breadcrumb log messages. Initializes Crashlytics collection at app startup and provides static methods for recording errors and setting context throughout the app lifecycle.

## Dependencies

- `package:firebase_crashlytics/firebase_crashlytics.dart` — Crashlytics SDK
- `package:flutter/foundation.dart` — `FlutterError`, `PlatformDispatcher`, `kDebugMode`
- `../logging/app_logger.dart` — Structured logging via `AppLogger`

## Pseudo-Code

### Class: CrashReportingService

#### Fields
- `_log` — static logger tagged `'CrashReportingService'`
- `_instance` — static singleton instance (factory constructor)

#### Constructor (Singleton)

```
CrashReportingService._internal()   // private

factory CrashReportingService() → _instance
```

---

#### `initialize() → Future<void>` (static)

```
TRY:
  // Hook Flutter framework errors → Crashlytics
  FlutterError.onError = (errorDetails) →
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails)

  // Hook platform-level uncaught errors → Crashlytics (fatal)
  PlatformDispatcher.instance.onError = (error, stack) →
    FirebaseCrashlytics.instance.recordError(error, stack, fatal=true)
    RETURN true

  IF kDebugMode:
    AWAIT FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true)
    LOG 'Crash reporting initialized'

CATCH e:
  LOG ERROR 'Error initializing crash reporting'
```

---

#### `recordError(error, stackTrace?, {reason?, fatal=false}) → Future<void>` (static)

```
TRY:
  AWAIT FirebaseCrashlytics.instance.recordError(error, stackTrace, reason, fatal)
  IF kDebugMode → LOG 'Error recorded: error, Fatal: fatal'
CATCH e:
  LOG ERROR 'Failed to record error'
```

---

#### `setCustomKey(String key, dynamic value) → Future<void>` (static)

```
TRY: AWAIT FirebaseCrashlytics.instance.setCustomKey(key, value)
CATCH: LOG ERROR 'Failed to set custom key'
```

---

#### `setUserId(String userId) → Future<void>` (static)

```
TRY: AWAIT FirebaseCrashlytics.instance.setUserIdentifier(userId)
CATCH: LOG ERROR 'Failed to set user ID'
```

---

#### `clearUserId() → Future<void>` (static)

```
TRY: AWAIT FirebaseCrashlytics.instance.setUserIdentifier('')
CATCH: LOG ERROR 'Failed to clear user ID'
```

---

#### `logMessage(String message) → void` (static)

```
TRY: FirebaseCrashlytics.instance.log(message)
CATCH: LOG ERROR 'Failed to log message'
```

---

#### `isCrashlyticsCollectionEnabled() → Future<bool>` (static)

```
TRY: RETURN FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled
CATCH: LOG ERROR, RETURN false
```
