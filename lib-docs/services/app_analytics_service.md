# app_analytics_service

> **Source:** `lib/services/app_analytics_service.dart`

## Purpose

Singleton wrapper around Firebase Analytics. All analytics events flow through this service. Active in ALL build modes (debug, profile, release/TestFlight). When Firebase is not initialized (e.g. unit tests), all methods are silent no-ops.

## Dependencies

- `package:firebase_analytics/firebase_analytics.dart` — `FirebaseAnalytics`, `FirebaseAnalyticsObserver`
- `package:firebase_core/firebase_core.dart` — `Firebase.apps`
- `../logging/app_logger.dart` — Structured logging
- `../models/app_error.dart` — `ErrorCategory`, `ErrorSeverity`
- `otel_service.dart` — `OTelService` for dual-write metrics

## Pseudo-Code

### Class: AppAnalyticsService (Singleton)

```
CLASS AppAnalyticsService

  FIELDS:
    _analytics: FirebaseAnalytics?

  SINGLETON via factory constructor + static _instance

  // ── Initialization ──

  ASYNC FUNCTION initialize() → void
    IF Firebase.apps.isEmpty → RETURN   // test isolation
    _analytics = FirebaseAnalytics.instance
    AWAIT _analytics.setAnalyticsCollectionEnabled(true)
    LOG 'Analytics initialized — collection explicitly enabled'

  GETTER _ready → bool
    RETURN _analytics != null

  GETTER observer → FirebaseAnalyticsObserver?
    IF _ready → RETURN FirebaseAnalyticsObserver(analytics: _analytics)
    ELSE → RETURN null

  // ── Generic Event API ──

  ASYNC logEvent(name, {parameters?})
    IF NOT _ready → RETURN
    TRY: _analytics.logEvent(name, parameters)
    CATCH: LOG warning

  // ── Core Events ──

  ASYNC logAppOpen()           — track cold launch
  ASYNC logLogin({method})     — 'email_signup', 'email', 'google', 'apple'
  ASYNC logSignOut({allAccounts})
  ASYNC logLogCreated({quickLog, eventType})   — also fires OTel metric
  ASYNC logLogUpdated()
  ASYNC logLogDeleted({restored})
  ASYNC logSyncCompleted({pushed, pulled, failed, durationMs})
                               — also fires OTel push/pull/duration metrics
  ASYNC logExport({format, recordCount})
  ASYNC logError(ErrorCategory, ErrorSeverity)
  ASYNC logTabSwitch({tabName})
  ASYNC logAccountSwitch()

  // ── Screen Tracking ──

  ASYNC logScreenView({screenName})
    // For IndexedStack tabs not tracked by FirebaseAnalyticsObserver

  // ── User Properties (segmentation) ──

  ASYNC setAccountCount(count)     — int
  ASYNC setLogCountBucket(count)   — bucketed: '0','1-10','11-50','51-200','200+'
  ASYNC setAppVersion(version)
  ASYNC setAuthMethod(method)
  ASYNC setSyncStatus(status)
  ASYNC clearUserProperties()      — reset all on sign-out

END CLASS
```

## Notes

- Every public method guards on `_ready` and silently returns when Firebase is unavailable.
- `logLogCreated` and `logSyncCompleted` dual-write to both Firebase Analytics and `OTelService` counters.
- `observer` can be passed to `MaterialApp.navigatorObservers` for automatic screen tracking of pushed routes.
