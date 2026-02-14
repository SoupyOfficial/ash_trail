# error_boundary

> **Source:** `lib/widgets/error_boundary.dart`

## Purpose

Catches build errors in a child widget tree, reports them via `ErrorReportingService`, and shows a fallback UI. Wrap major screen sections in `ErrorBoundary(child: ...)` to prevent a single widget error from taking down the entire screen.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `../logging/app_logger.dart` — Structured logging
- `../services/error_reporting_service.dart` — `ErrorReportingService`

## Pseudo-Code

### Class: ErrorBoundary (StatefulWidget)

#### Constructor Parameters

```
  child: Widget                                           — the widget tree to protect
  fallbackBuilder: (Object error, VoidCallback retry)?    — optional custom fallback UI
```

### Class: _ErrorBoundaryState

```
FIELDS:
  _error: Object?      — captured error, null when healthy

FUNCTION initState()
  _error = null

FUNCTION _retry()
  SET _error = null (triggers rebuild, re-attempts child)

FUNCTION build(context) → Widget
  IF _error != null:
    IF fallbackBuilder provided → RETURN fallbackBuilder(_error, _retry)
    ELSE → RETURN _DefaultErrorCard(error: _error, onRetry: _retry)

  TRY:
    RETURN widget.child
  CATCH (e, st):
    LOG 'ErrorBoundary caught build error'
    REPORT to ErrorReportingService
    SCHEDULE post-frame callback: setState(_error = e)
    RETURN SizedBox.shrink()    // placeholder during current frame
```

### Class: _DefaultErrorCard (StatelessWidget, private)

```
FIELDS:
  error: Object
  onRetry: VoidCallback

FUNCTION build(context) → Widget
  RETURN Card(margin: 16) → Padding(16) → Column:
    Icon(warning_amber_rounded, size: 36, orange)
    Text('This section encountered an error', bold)
    Text('The rest of the app should work normally.', grey)
    OutlinedButton.icon(onRetry, icon: refresh, label: 'Retry')
```

## Notes

- The error is caught in a try/catch around `widget.child` in the build method.
- State update is deferred to a post-frame callback to avoid setState during build.
- The retry button clears `_error`, causing a rebuild that re-attempts the child widget.
- Custom fallback UI can be provided via `fallbackBuilder` for context-specific error displays.
