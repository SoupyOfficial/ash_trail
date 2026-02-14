# error_display

> **Source:** `lib/utils/error_display.dart`

## Purpose

Standardized UI utilities for displaying errors consistently, per design doc §11.3. User errors surface as snackbars or inline text, system errors show generic messages, and fatal errors trigger a full-screen fallback. All display methods automatically report through `ErrorReportingService`.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `../models/app_error.dart` — `AppError`, `ErrorSeverity`
- `../services/error_reporting_service.dart` — `ErrorReportingService`

## Pseudo-Code

### Class: ErrorDisplay (static utility, private constructor)

#### `showSnackBar(context, AppError, {reportContext?, duration?, action?})` (static)

```
REPORT error through ErrorReportingService.instance
GET ScaffoldMessenger from context (return if null)
HIDE current snackbar
SHOW SnackBar:
  content: Row [ Icon(_iconFor(severity)), SizedBox(12), Expanded(Text(message)) ]
  backgroundColor: _colorFor(severity)
  behavior: floating
  duration: _durationFor(severity) or provided duration
  action: provided action
```

#### `showException(context, exception, {stackTrace?, reportContext?})` (static)

```
CONVERT exception → AppError via AppError.from(exception, stackTrace)
CALL showSnackBar(context, appError, reportContext)
```

#### `inline(AppError error)` → Widget (static)

```
RETURN Container with colored border + background (10% opacity):
  Row [ Icon(severity), SizedBox(8), Expanded(Text(message)) ]
```

#### `fullScreen({required AppError, onRetry?})` → Widget (static)

```
RETURN Center → Padding(32) → Column:
  Icon(severity, size: 48)
  Text(message, centered)
  IF onRetry → FilledButton.icon('Retry')
```

#### `asyncError(error, stackTrace, {onRetry?, reportContext?})` → Widget (static)

```
CONVERT error → AppError via AppError.from
REPORT through ErrorReportingService
RETURN fullScreen(appError, onRetry)
```

_For use in Riverpod `AsyncValue.when(error: ...)`._

#### Private Helpers

```
_iconFor(severity) →
  info: info_outline | warning: warning_amber_rounded
  error: error_outline | fatal: dangerous

_colorFor(severity) →
  info: blue (#2196F3) | warning: orange (#F57C00)
  error: red (#D32F2F)  | fatal: dark red (#B71C1C)

_durationFor(severity) →
  info: 2s | warning: 3s | error: 4s | fatal: 6s
```

## Notes

- `showSnackBar` auto-reports through the error pipeline before displaying.
- `asyncError` is designed for direct use in Riverpod `AsyncValue.when(error:)` handlers.
- Color/icon/duration are derived from severity, ensuring visual consistency across the app.
