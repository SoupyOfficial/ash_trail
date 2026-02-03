# Logging Conventions

Ash Trail uses the `logger` package with a centralized `AppLogger` wrapper for all application logging. This document defines the conventions and patterns to follow.

## Getting a Logger

Use `AppLogger.logger()` to obtain a named logger:

```dart
// For classes, use the class or component name
final _log = AppLogger.logger('SyncService');

// Or with runtime type
final _log = AppLogger.logger(runtimeType.toString());
```

The logger name appears as a `[ComponentName]` prefix in log output for easy grep/filter.

## Log Levels

| Level | When to Use | Example |
|-------|-------------|---------|
| **trace** | Very verbose: stream events, microtask timing, box watch | `_log.t('Controller hasListener? $_hasListener');` |
| **debug** | Provider creation, method entry, intermediate state | `_log.d('Creating TokenService instance');` |
| **info** | App lifecycle, sync progress, success confirmations | `_log.i('Firebase initialized');` |
| **warning** | Skipped operations, recoverable issues | `_log.w('No authenticated user, skipping sync');` |
| **error** | Catch blocks, failures | `_log.e('Sync failed', error: e, stackTrace: st);` |
| **fatal** | Unrecoverable errors (rare) | `_log.f('Database corrupted', error: e, stackTrace: st);` |

### Decision Tree

1. **Is it an error or exception?** → `error` (or `fatal` if unrecoverable)
2. **Is something skipped or degraded but recoverable?** → `warning`
3. **Is it normal operation progress or success?** → `info`
4. **Is it provider/service creation or method flow?** → `debug`
5. **Is it very verbose (streams, timing, box changes)?** → `trace`

## API Usage

```dart
// Info
_log.i('Message');
_log.i('Syncing ${records.length} records');

// Warning
_log.w('Skipped: $reason');

// Error with exception
_log.e('Operation failed', error: e, stackTrace: st);

// Debug
_log.d('Stream event: $userId');
```

## Build Mode Behavior

- **Debug/Profile**: All logs at level `debug` and above are shown.
- **Release**: Only `warning` and above are shown. Use `Logger.level = Level.warning` (default for release).

## Rules

1. **Do not use `print()` or `debugPrint()`** in new code. Use `AppLogger.logger(name)` instead.
2. Prefer named loggers over a global logger so logs can be filtered by component.
3. For errors, always pass `error` and `stackTrace` when available: `_log.e('msg', error: e, stackTrace: st)`.
4. Keep messages concise but actionable. Avoid logging sensitive data (tokens, passwords, PII).

## Migration from debugPrint

When migrating existing `debugPrint` calls:
- Success/init messages → `info`
- Warnings (⚠️) → `warning`
- Errors (❌) → `error`
- Provider/stream lifecycle → `debug` or `trace`
- Verbose box/controller state → `trace`
