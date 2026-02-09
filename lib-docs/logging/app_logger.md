# app_logger

> **Source:** `lib/logging/app_logger.dart`

## Purpose

Centralized logging utility for Ash Trail using the `logger` package. Provides named logger instances with consistent formatting, build-mode awareness, and a verbose-logging toggle for TestFlight/QA diagnostics. In debug/profile mode all logs >= debug are shown; in release only warning+ unless verbose mode is enabled.

## Dependencies

- `package:flutter/foundation.dart` — `kDebugMode` constant for build-mode detection
- `package:logger/logger.dart` — Logger, LogFilter, PrettyPrinter, PrefixPrinter

## Pseudo-Code

### Class: AppLogger (static utility, private constructor)

```
CLASS AppLogger

  PRIVATE STATIC _loggers: Map<String, Logger> = {}
  PRIVATE STATIC _initialized: bool = false
  PRIVATE STATIC _verboseLogging: bool = false

  // ── Verbose Logging Toggle ──

  STATIC FUNCTION setVerboseLogging(enabled: bool) -> void
    SET _verboseLogging = enabled

    IF enabled THEN
      SET Logger.level = Level.debug       // show everything
    ELSE
      IF kDebugMode THEN
        SET Logger.level = Level.debug
      ELSE
        SET Logger.level = Level.warning   // release default
      END IF
    END IF

    // Force re-creation of all loggers with new filter
    CLEAR _loggers map
    SET _initialized = false
    CALL _ensureInitialized()
  END FUNCTION

  STATIC GETTER isVerboseLogging -> bool
    RETURN _verboseLogging
  END GETTER

  // ── Logger Factory ──

  STATIC FUNCTION logger(name: String) -> Logger
    CALL _ensureInitialized()

    RETURN _loggers.putIfAbsent(name, () =>
      CREATE Logger(
        filter: _AppLogFilter(),
        printer: PrefixPrinter(
          PrettyPrinter(
            methodCount: 0,              // no method stack in normal logs
            errorMethodCount: 8,         // 8 frames for errors
            lineLength: 120,
            colors: true,
            printEmojis: false,
            dateTimeFormat: time + since start
          ),
          prefix all levels with "[{name}]"
        )
      )
    )
  END FUNCTION

  // ── Initialization ──

  PRIVATE STATIC FUNCTION _ensureInitialized() -> void
    IF _initialized THEN RETURN

    SET _initialized = true
    IF kDebugMode OR _verboseLogging THEN
      SET Logger.level = Level.debug
    ELSE
      SET Logger.level = Level.warning
    END IF
  END FUNCTION

  // ── Diagnostics ──

  STATIC GETTER diagnostics -> Map<String, dynamic>
    RETURN {
      "verboseLogging": _verboseLogging,
      "kDebugMode": kDebugMode,
      "loggerLevel": Logger.level.name,
      "activeLoggers": list of _loggers keys
    }
  END GETTER

END CLASS
```

### Class: _AppLogFilter (private, extends LogFilter)

```
CLASS _AppLogFilter EXTENDS LogFilter

  FUNCTION shouldLog(event: LogEvent) -> bool
    CALL AppLogger._ensureInitialized()

    // Verbose mode: pass anything at or above global level
    IF AppLogger._verboseLogging THEN
      RETURN event.level.index >= Logger.level.index
    END IF

    // Release mode: suppress below warning
    IF NOT kDebugMode AND event.level < Level.warning THEN
      RETURN false
    END IF

    // Default: respect global level
    RETURN event.level.index >= Logger.level.index
  END FUNCTION

END CLASS
```
