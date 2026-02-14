# app_error

> **Source:** `lib/models/app_error.dart`

## Purpose

Standardized error types per design doc §11 (Error Handling). All errors are classified by `ErrorCategory` and `ErrorSeverity` for consistent logging, crash reporting, and user-facing display. Provides named constructors for common error patterns and an auto-classifying `AppError.from()` factory.

## Dependencies

_(none — pure Dart)_

## Pseudo-Code

### Enum: ErrorCategory

```
VALUES:
  validation   — invalid user input / action (recoverable)
  auth         — authentication / authorization failures
  network      — connectivity issues
  database     — local database read/write failures
  sync         — cloud sync failures (Firestore, etc.)
  platform     — platform service errors (location, notifications)
  unexpected   — programmer / unknown errors
```

### Enum: ErrorSeverity

```
VALUES:
  info     — informational only, no user action needed
  warning  — degraded but app continues
  error    — operation failed, user should be notified
  fatal    — unrecoverable, app may need restart
```

### Class: AppError (implements Exception)

#### Fields

```
  message: String               — human-readable, safe to show to user
  technicalDetail: String?      — for logging only, never shown to user
  category: ErrorCategory       — broad classification (default: unexpected)
  severity: ErrorSeverity       — severity level (default: error)
  originalError: Object?        — the wrapped exception, if any
  stackTrace: StackTrace?       — original stack trace, if any
  code: String?                 — machine-readable code, e.g. 'AUTH_TOKEN_EXPIRED'
```

#### Default Constructor

```
CONSTRUCTOR AppError({required message, technicalDetail?, category?, severity?, originalError?, stackTrace?, code?})
```

#### Named Constructors

```
CONST CONSTRUCTOR AppError.validation({required message, code?, technicalDetail?})
  category = validation, severity = warning, code = code ?? 'VALIDATION_ERROR'

FACTORY AppError.auth({required message, originalError?, stackTrace?, code?})
  category = auth, severity = error, code = code ?? 'AUTH_ERROR'

FACTORY AppError.network({message = default, originalError?, stackTrace?, code?})
  category = network, severity = warning, code = code ?? 'NETWORK_ERROR'

FACTORY AppError.database({required message, originalError?, stackTrace?, code?})
  category = database, severity = error, code = code ?? 'DATABASE_ERROR'

FACTORY AppError.sync({required message, originalError?, stackTrace?, code?})
  category = sync, severity = warning, code = code ?? 'SYNC_ERROR'

FACTORY AppError.platform({required message, originalError?, stackTrace?, code?})
  category = platform, severity = warning, code = code ?? 'PLATFORM_ERROR'

FACTORY AppError.unexpected({message = default, required originalError, stackTrace?, code?})
  category = unexpected, severity = error, code = code ?? 'UNEXPECTED_ERROR'
  technicalDetail = originalError.toString()
```

#### Factory: `AppError.from(Object error, [StackTrace?])` → AppError

```
IF error IS AppError → RETURN error (passthrough)

errorString = error.toString().toLowerCase()

IF error IS ArgumentError       → RETURN AppError.validation(...)
IF contains 'socket|connection|timeout|network' → RETURN AppError.network(...)
IF contains 'hive|box|database' → RETURN AppError.database(...)
IF contains 'permission|denied' → RETURN AppError.platform(..., code: 'PLATFORM_PERMISSION_DENIED')

ELSE → RETURN AppError.unexpected(...)
```

#### Methods

```
toString() → message                   // user-facing display
toLogString() → '[CATEGORY][SEVERITY][code] message | detail | cause'  // diagnostic
```
