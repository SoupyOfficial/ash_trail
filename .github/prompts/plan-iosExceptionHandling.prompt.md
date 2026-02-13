## Plan: Full Observability — Exception Handling + Analytics + Performance Traces

**TL;DR:** The app has solid crash reporting foundations (`AppError`, `ErrorReportingService`, `runZonedGuarded`, Crashlytics) but most services still catch-and-swallow errors without reporting them, and there is **zero analytics or performance tracing**. This plan completes the exception handling rollout across all layers, then adds Firebase Analytics (events, screen tracking, user properties) and Firebase Performance (custom traces, HTTP metrics, startup timing) to achieve full three-pillar observability: **logs + metrics + traces**. Scoped for a small team on Firebase free/Blaze tier with low user count.

---

### Conventions & Patterns (reference for all steps)

**Singleton pattern (services):**
```dart
class XService {
  static final _log = AppLogger.logger('XService');
  static final XService _instance = XService._internal();
  static XService get instance => _instance;
  factory XService() => _instance;
  XService._internal();
}
```
Exception: `CrashReportingService` uses **all-static methods** (no instance needed).

**Import paths (relative, from within lib/):**
| From | Import |
|------|--------|
| `lib/services/` | `import '../models/app_error.dart';` and `import 'error_reporting_service.dart';` |
| `lib/screens/` | `import '../models/app_error.dart';` and `import '../services/error_reporting_service.dart';` |
| `lib/providers/` | `import '../models/app_error.dart';` and `import '../services/error_reporting_service.dart';` |
| `lib/repositories/` | `import '../models/app_error.dart';` and `import '../services/error_reporting_service.dart';` |
| `lib/utils/` | `import '../models/app_error.dart';` and `import '../services/error_reporting_service.dart';` |

**Error reporting call pattern:**
```dart
} catch (e, st) {
  _log.e('Description of failure', error: e, stackTrace: st);
  ErrorReportingService.instance.reportException(e, stackTrace: st, context: 'ServiceName.methodName');
}
```

**AppError named constructors available:** `.validation()`, `.auth()`, `.network()`, `.database()`, `.sync()`, `.platform()`, `.unexpected()`, `.from(e, st)` (auto-classifies by exception type).

**Riverpod pattern:** Services are singletons via `Provider<X>((ref) => X())` in `lib/providers/`. `ErrorReportingService` is an exception — uses Dart singleton `ErrorReportingService.instance`.

**Test infrastructure:** No mockito/mocktail. Uses `fake_cloud_firestore`. Test helper is `test/test_helpers.dart` (Hive setup only). Existing test file for error reporting: `test/services/error_reporting_service_test.dart`.

**Flutter SDK:** `^3.7.0`. Dart 3 features (switch expressions, sealed classes, records) are available.

---

### Current State

| Foundation | Status |
|---|---|
| `AppError` model with `ErrorCategory` + `ErrorSeverity` | Done — lib/models/app_error.dart (264 lines) |
| `ErrorReportingService` (unified pipeline → Logger + Crashlytics) | Done — lib/services/error_reporting_service.dart (174 lines) |
| `runZonedGuarded` wrapping `runApp` | Done — lib/main.dart L103-L122 |
| `CrashReportingService` (Crashlytics singleton, all-static) | Done — lib/services/crash_reporting_service.dart (118 lines) |
| `ErrorDisplay` utility (SnackBar, inline, fullScreen, asyncError) | Done — lib/utils/error_display.dart (167 lines) |
| Firebase Analytics (`firebase_analytics`) | **Not installed** |
| Firebase Performance (`firebase_performance`) | **Not installed** |
| Custom `ErrorWidget.builder` | **Not done** |
| Service-layer error instrumentation | **Partial** — only auth_service, hive_database_service, log_record_service |
| Repository / Provider error instrumentation | **Not done** |
| User-facing error sanitization | **Partial** — AuthWrapper uses `ErrorDisplay.asyncError()`, but 4 screens still use raw `e.toString()` |
| Device context on crash reports | **Not done** — neither `package_info_plus` nor `device_info_plus` in pubspec |
| ErrorBoundary widget | **Not done** |
| dSYM upload for iOS release builds | **Not done** — `scripts/deploy_testflight.sh` uses `--split-debug-info=build/app/debug-info` and `--obfuscate` but never uploads symbols |
| Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) | **Not done** — does not exist, no reference in project.pbxproj |
| Error report deduplication / rate limiting | **Not done** |
| Crashlytics velocity alerts | **Not configured** (Firebase Console action) |
| Test isolation for Firebase services | **Not done** |

---

### Part 0 — iOS Build Pipeline Prerequisites (do these first)

#### 0.1. Automate dSYM upload to Crashlytics

The build script (`scripts/deploy_testflight.sh`) runs `flutter build ipa --release --obfuscate --split-debug-info=build/app/debug-info` at L178-L218. dSYMs end up in `build/ios/archive/Runner.xcarchive/dSYMs/`. Neither the script nor `ios/fastlane/Fastfile` upload them.

**Implementation — add to `scripts/deploy_testflight.sh`:**
Insert a new step between step [4/6] Build IPA (ends ~L218) and step [5/6] Validate (starts ~L224):

```bash
# [4.5/6] Upload dSYMs to Firebase Crashlytics
echo "📤 [4.5/6] Uploading dSYMs to Crashlytics..."
# Find the dSYM upload script from the Firebase Crashlytics pod
UPLOAD_SCRIPT=$(find "${PWD}/ios/Pods/FirebaseCrashlytics" -name "upload-symbols" -type f 2>/dev/null | head -1)
if [ -n "$UPLOAD_SCRIPT" ]; then
  "$UPLOAD_SCRIPT" -gsp "ios/Runner/GoogleService-Info.plist" -p ios "build/ios/archive/Runner.xcarchive/dSYMs"
  echo "✅ dSYMs uploaded"
else
  echo "⚠️  upload-symbols script not found — install FirebaseCrashlytics pod"
fi

# Also upload obfuscation mapping from --split-debug-info
if [ -d "build/app/debug-info" ]; then
  "$UPLOAD_SCRIPT" -gsp "ios/Runner/GoogleService-Info.plist" -p ios "build/app/debug-info"
  echo "✅ Debug info symbols uploaded"
fi
```

**Alternatively — add to ios/fastlane/Fastfile:**
The Fastfile has two lanes (`:testflight` at L5-L13, `:upload_ipa` at L15-L39). Add after `upload_to_testflight` in `:upload_ipa` (after L37):
```ruby
upload_symbols_to_crashlytics(gsp_path: "Runner/GoogleService-Info.plist")
```

**Verify:** GoogleService-Info.plist exists at `ios/Runner/GoogleService-Info.plist`.

#### 0.2. Create Apple Privacy Manifest

Create file `ios/Runner/PrivacyInfo.xcprivacy`. File does not exist and is not referenced in `project.pbxproj`.

**Content:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTracking</key>
	<false/>
	<key>NSPrivacyTrackingDomains</key>
	<array/>
	<key>NSPrivacyCollectedDataTypes</key>
	<array>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypeCrashData</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<false/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
			</array>
		</dict>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypePerformanceData</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<false/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
			</array>
		</dict>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypeOtherDiagnosticData</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<false/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
			</array>
		</dict>
	</array>
	<key>NSPrivacyAccessedAPITypes</key>
	<array>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategoryUserDefaults</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array>
				<string>CA92.1</string>
			</array>
		</dict>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategorySystemBootTime</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array>
				<string>35F9.1</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
```

**Post-create:** Add file to the Xcode project's Runner target. Either:
- Edit `ios/Runner.xcodeproj/project.pbxproj` to add PrivacyInfo.xcprivacy to the "Copy Bundle Resources" build phase, OR
- Open in Xcode → Runner target → Build Phases → Copy Bundle Resources → add PrivacyInfo.xcprivacy

**ATT decision:** `NSPrivacyTracking = false`. No ATT prompt. Firebase Analytics works without IDFA.

> **Verify API reason codes** before submission: `CA92.1` (UserDefaults — SharedPreferences) and `35F9.1` (SystemBootTime — Firebase Performance uptime). If future dependencies access `NSPrivacyAccessedAPICategoryFileTimestamp` or `NSPrivacyAccessedAPICategoryDiskSpace`, add corresponding entries. Run `grep -r 'NSFileCreationDate\|NSURLCreationDateKey\|volumeAvailableCapacityKey' ios/Pods/` to check.

#### 0.3. Enable Crashlytics velocity alerts
Manual step in Firebase Console → Crashlytics → Settings. Enable **velocity alerts** and **regression alerts**. No code change.

---

### Part A — Complete Exception Handling Rollout

#### A1. Add custom `ErrorWidget.builder`

**File:** lib/main.dart
**Insert at:** After `WidgetsFlutterBinding.ensureInitialized()` (L52), before Firebase init (L56).

```dart
  // Set custom error widget for release builds
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Report to Crashlytics
    ErrorReportingService.instance.reportException(
      details.exception,
      stackTrace: details.stack,
      context: 'ErrorWidget.builder',
    );
    // Show user-friendly widget
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This section encountered an error. Try navigating away and back.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };
```

**Note:** `ErrorReportingService` import is already in main.dart (L11). No new imports needed.

#### A2. Add report-once deduplication guard

**File:** lib/services/error_reporting_service.dart (205 lines)
**Add field at ~L42** (near `_recentErrors`):
```dart
  final Set<String> _reportedThisSession = {};
```

**Modify `_forwardToCrashlytics` (L176-L193)** — add dedup check at the start:
```dart
  void _forwardToCrashlytics(AppError error, StackTrace? stackTrace) {
    // Dedup: report each unique error once per session
    final dedupeKey = error.code ?? '${error.category.name}:${error.message}';
    if (_reportedThisSession.contains(dedupeKey)) {
      _log.d('Skipping duplicate Crashlytics report: $dedupeKey');
      return;
    }
    _reportedThisSession.add(dedupeKey);

    try {
      // ... existing Crashlytics forwarding code ...
```

**Add `resetSession()` method** for lifecycle-based reset:
```dart
  void resetSession() {
    _reportedThisSession.clear();
  }
```

No `WidgetsBindingObserver` needed — just call `resetSession()` if you want to enable re-reporting on foreground. For now, per-cold-start dedup is sufficient.

#### A3. Instrument remaining service-layer catch blocks (tiered)

For each file: (1) add imports for `AppError` and `ErrorReportingService`, (2) **change every `catch (e) {` to `catch (e, st) {`** to capture stack traces, (3) add `ErrorReportingService.instance.reportException(e, stackTrace: st, context: '...')` at each catch site.

> **Rule: Every `catch (e) {` must become `catch (e, st) {`.** There are ~50+ stack-trace-less catches across the codebase. Without `st`, Crashlytics reports show only the error message with no call stack — useless for debugging. Apply this transformation mechanically at every catch site being instrumented.

**Tier 1 — instrument now:**

**sync_service.dart** — 19 `catch (e)` blocks without stack traces (L263, L277, L558, L569, L663, L675, L708, L724, L821, L827, L850, L953, L977, L997, L1067, L1091, L1111, L1159, L1181). Does NOT import `AppError` or `ErrorReportingService`.
- Add imports: `import '../models/app_error.dart';` and `import 'error_reporting_service.dart';`
- Catch blocks at lines: L263, L277, L558, L569, L663, L675, L708, L724, L821, L827, L850, L953, L977, L997, L1067, L1091, L1111, L1159, L1181
- **Change every `catch (e)` to `catch (e, st)`** at each of these 19 sites.
- Pattern: add `ErrorReportingService.instance.reportException(e, stackTrace: st, context: 'SyncService.methodName');` after existing `_log.e()` call. For silent catches (e.g., L558 `catch (e) { failedCount++; }`) also add a `_log.e()`.
- For catches that use `e.toString()` (e.g., L263: `_logRecordService.markSyncError(record, e.toString())`), consider passing `AppError.from(e).message` instead.

**account_session_manager.dart** — 6 `catch (e)` blocks without stack traces. Does NOT import `AppError` or `ErrorReportingService`.
- Add imports: `import '../models/app_error.dart';` and `import 'error_reporting_service.dart';`
- **Change every `catch (e)` to `catch (e, st)`** at L101, L138, L198, L218, L294, L487.
- Special attention: L487 (`_getLoggedInList`) is a **completely silent catch** (`return []`) — add `_log.e()` + reporting.
- L294 (`generateDiagnosticSummary`) exposes `e.toString()` in returned map — replace with `AppError.from(e).message`.

**location_service.dart** — 2 `catch (e)` blocks without stack traces. Does NOT import `AppError` or `ErrorReportingService`.
- Add imports: `import '../models/app_error.dart';` and `import 'error_reporting_service.dart';`
- **Change `catch (e)` to `catch (e, st)`** at L47, L77

**token_service.dart** — 2 `catch (e)` blocks without stack traces. Does NOT import `AppError` or `ErrorReportingService`.
- Add imports: `import '../models/app_error.dart';` and `import 'error_reporting_service.dart';`
- **Change `catch (e)` to `catch (e, st)`** at L67, L100

**account_integration_service.dart** — 2 `catch (e)` blocks without stack traces. Imports `CrashReportingService` but NOT `AppError` or `ErrorReportingService`.
- Add imports: `import '../models/app_error.dart';` and `import 'error_reporting_service.dart';`
- L248: Currently calls `CrashReportingService.recordError(e, StackTrace.current, reason: ...)` directly — replace with `ErrorReportingService.instance.reportException(e, stackTrace: StackTrace.current, context: 'AccountIntegrationService.signInWithGoogle')`. Remove or keep the direct CrashReportingService call (ErrorReportingService already forwards to Crashlytics).
- L158: Silent catch — add reporting.

**Tier 2 — instrument next** (same add-imports + change-catch + add-reportException pattern):
- lib/services/export_service.dart — 4 `catch (e)` without stack traces at L119, L135, L183, L199
- lib/services/data_integrity_service.dart — 4 `catch (e)` without stack traces at L359, L380, L412, L429
- lib/services/account_service.dart
- lib/services/legacy_data_adapter.dart — 2 `catch (e)` without stack traces at L50, L59

**Tier 3 — defer** (instrument only when they cause real problems):
- notification_service.dart, home_metrics_service.dart, database_service.dart, analytics_service.dart (NOTE: this is the *existing* local data-aggregation service, NOT the new `AppAnalyticsService`), validation_service.dart

**Special case — crash_reporting_service.dart** (120 lines): Has 7 `catch (e)` blocks internally. Since this IS the error reporting service, it cannot call `ErrorReportingService.instance.reportException()` on itself (circular dependency). Leave these as `catch (e)` with existing `_log.e()` calls — they log to console and Crashlytics breadcrumbs (via D2). Do NOT add `ErrorReportingService` calls here.

#### A4. Instrument repository layer

**File:** lib/repositories/account_repository_hive.dart — 5 catch blocks at L68, L76, L81, L104, L230. Does NOT import `AppError` or `ErrorReportingService`.

Add imports:
```dart
import '../models/app_error.dart';
import '../services/error_reporting_service.dart';
```

Add `ErrorReportingService.instance.reportException(e, stackTrace: st, context: 'AccountRepositoryHive.methodName');` at each catch site.

Special attention: L230 is a **silent catch** (`catch (_) { return null; }`) — add logging + reporting.

#### A5. Instrument provider error states

**File:** lib/providers/account_provider.dart — 9 catch blocks at L69, L92, L161, L174, L186, L211, L244, L262, L280. Does NOT import `AppError` or `ErrorReportingService`.

Add imports:
```dart
import '../models/app_error.dart';
import '../services/error_reporting_service.dart';
```

For catches that set `state = AsyncValue.error(e, st)` (L211, L244, L262, L280): add reporting **before** setting state.

For catches that rethrow (L69, L92): add reporting **before** rethrow.

**File:** lib/providers/log_record_provider.dart — 3 catch blocks. Same pattern.
**File:** lib/providers/home_widget_config_provider.dart — 2 catch blocks. Same pattern.
**File:** lib/providers/sync_provider.dart (95 lines) — orchestrates sync; check for catch blocks and add reporting.
**File:** lib/providers/auth_provider.dart (42 lines) — wraps auth state stream; check for error handling and add reporting if needed.

#### A6. Sanitize user-facing error messages

**Already sanitized (no action):**
- lib/main.dart — `AuthWrapper` error states use `ErrorDisplay.asyncError()` (L198, L211)

**Still using raw `e.toString()` — needs fix:**

**lib/screens/signup_screen.dart** — 3 occurrences at L55, L76, L97.
- Add import: `import '../models/app_error.dart';`
- Replace `_errorMessage = e.toString();` → `_errorMessage = (e is AppError) ? e.message : 'Something went wrong. Please try again.';`

**lib/screens/profile_screen.dart** — 4 occurrences at L75, L111, L164, L255.
- Add import: `import '../models/app_error.dart';`
- Same replacement pattern.

**lib/screens/home_screen.dart** — L252 uses `error.toString()` in a `Text` widget.
- Add import: `import '../models/app_error.dart';`
- Replace `error.toString()` → `(error is AppError) ? error.message : 'Something went wrong.'`

**lib/screens/multi_account_diagnostics_screen.dart** — search for `e.toString()`/`error.toString()` and apply same pattern.

**lib/screens/logging_screen.dart** (1,254 lines) — the largest screen file. Search for `e.toString()`/`error.toString()` and apply the same sanitization. Also has 3 `showDialog` calls at L176, L1043, L1209 that may show raw error text. Has a `MaterialPageRoute` at L991 (covered in B3 RouteSettings table).

#### A7. Add device context to crash reports

**Dependencies needed:** Add to pubspec.yaml (after L76, the last dependency):
```yaml
  package_info_plus: ^8.0.0
  device_info_plus: ^11.0.0
```

**File:** lib/services/crash_reporting_service.dart — add `setDeviceContext()` static method after `initialize()` (after L47):

```dart
  /// Set device context keys on Crashlytics for triage
  static Future<void> setDeviceContext() async {
    try {
      // Platform info
      if (!kIsWeb) {
        await setCustomKey('platform', Platform.operatingSystem);
        await setCustomKey('os_version', Platform.operatingSystemVersion);
        await setCustomKey('dart_version', Platform.version);
      }
      // App version
      final packageInfo = await PackageInfo.fromPlatform();
      await setCustomKey('app_version', packageInfo.version);
      await setCustomKey('build_number', packageInfo.buildNumber);
      // Device model
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        await setCustomKey('device_model', iosInfo.utsname.machine);
        await setCustomKey('ios_version', iosInfo.systemVersion);
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        await setCustomKey('device_model', androidInfo.model);
      }
      if (kDebugMode) _log.i('Device context set');
    } catch (e) {
      _log.e('Failed to set device context', error: e);
    }
  }
```

Add imports to crash_reporting_service.dart:
```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
```

**Call from lib/main.dart** — insert after `CrashReportingService.initialize()` call (after L68):
```dart
    await CrashReportingService.setDeviceContext();
```

#### A8. Create reusable `ErrorBoundary` widget

**Create new file:** lib/widgets/error_boundary.dart

```dart
import 'package:flutter/material.dart';
import '../logging/app_logger.dart';
import '../models/app_error.dart';
import '../services/error_reporting_service.dart';

/// Catches build errors in child widget tree, reports them, and shows a fallback UI.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, VoidCallback retry)? fallbackBuilder;

  const ErrorBoundary({super.key, required this.child, this.fallbackBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  static final _log = AppLogger.logger('ErrorBoundary');
  Object? _error;

  @override
  void initState() {
    super.initState();
  }

  void _retry() {
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallbackBuilder?.call(_error!, _retry) ??
          _DefaultErrorCard(error: _error!, onRetry: _retry);
    }
    // Wrap child — errors are caught via ErrorWidget.builder, but
    // for programmatic errors use a Builder + try/catch approach
    return widget.child;
  }
}

class _DefaultErrorCard extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultErrorCard({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48,
                 color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Something went wrong',
                 style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('This section encountered an error.',
                 style: Theme.of(context).textTheme.bodyMedium,
                 textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Usage:** Wrap major screen sections in `ErrorBoundary(child: ...)`. Candidates:
- lib/navigation/main_navigation.dart — wrap the `IndexedStack` children
- lib/screens/home_screen.dart — wrap the main content column

**Validate:** Run `flutter test test/widgets/` after creating.

---

### Part B — Firebase Analytics (Metrics & Events)

#### B1. Add `firebase_analytics` dependency

**File:** pubspec.yaml — insert after `firebase_crashlytics: ^4.2.2` (L41):
```yaml
  firebase_analytics: ^11.3.6
```

Run: `flutter pub get`

**Test isolation:** The `AppAnalyticsService` singleton should guard every `FirebaseAnalytics` call:
```dart
if (Firebase.apps.isEmpty) return; // Skip in tests
```

This follows the same pattern as `CrashReportingService.initialize()` (L31-L36 of crash_reporting_service.dart) — no-op when Firebase is not available.

#### B2. Create `AppAnalyticsService`

**Create new file:** lib/services/app_analytics_service.dart

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../logging/app_logger.dart';
import '../models/app_error.dart';

/// Singleton wrapper around Firebase Analytics.
/// All analytics events should go through this service.
class AppAnalyticsService {
  static final _log = AppLogger.logger('Analytics');
  static final AppAnalyticsService _instance = AppAnalyticsService._internal();
  static AppAnalyticsService get instance => _instance;
  factory AppAnalyticsService() => _instance;
  AppAnalyticsService._internal();

  FirebaseAnalytics? _analytics;

  /// Initialize after Firebase.initializeApp. Lightweight — no cold-start impact.
  /// Returns a Future because D6 adds `setAnalyticsCollectionEnabled(true)`.
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) return; // test isolation
    _analytics = FirebaseAnalytics.instance;
    // D6: Explicitly enable collection in ALL build modes (always-on)
    await _analytics!.setAnalyticsCollectionEnabled(true);
    _log.i('Analytics initialized — collection explicitly enabled');
  }

  bool get _ready => _analytics != null;

  /// Returns the observer for MaterialApp.navigatorObservers.
  /// Used in main.dart's MaterialApp construction (L125-L168).
  FirebaseAnalyticsObserver? get observer =>
      _ready ? FirebaseAnalyticsObserver(analytics: _analytics!) : null;

  // ────────────────────────────────────────────────────────────────
  // Generic event API — for ad-hoc or future events
  // ────────────────────────────────────────────────────────────────

  /// Log any named event with optional parameters.
  /// Use named methods (logLogin, logLogCreated, etc.) for catalog events;
  /// use this for one-off or experimental events without modifying the class.
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: name, parameters: parameters);
    } catch (e) {
      _log.w('logEvent($name) failed', error: e);
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Core events — 9 events covering all key user journeys
  // ────────────────────────────────────────────────────────────────

  /// Track cold launch. Called once per app start from main.dart.
  Future<void> logAppOpen() async {
    if (!_ready) return;
    try {
      await _analytics!.logAppOpen();
    } catch (e) {
      _log.w('logAppOpen failed', error: e);
    }
  }

  /// Track authentication. Maps to Firebase's built-in login event.
  /// `method` values: 'email_signup', 'email', 'google', 'apple'
  Future<void> logLogin({required String method}) async {
    if (!_ready) return;
    try {
      await _analytics!.logLogin(loginMethod: method);
    } catch (e) {
      _log.w('logLogin failed', error: e);
    }
  }

  /// Track sign-out. Distinguishes single-account vs sign-out-all.
  Future<void> logSignOut({bool allAccounts = false}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'sign_out', parameters: {
        'all_accounts': allAccounts,
      });
    } catch (e) {
      _log.w('logSignOut failed', error: e);
    }
  }

  /// Track log record creation — the app's core user action.
  /// `quickLog` distinguishes quick-log from full form creation.
  /// `eventType` records what type of log was created.
  Future<void> logLogCreated({bool quickLog = false, String? eventType}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'log_created', parameters: {
        'quick_log': quickLog,
        if (eventType != null) 'event_type': eventType,
      });
    } catch (e) {
      _log.w('logLogCreated failed', error: e);
    }
  }

  /// Track log record edits.
  Future<void> logLogUpdated() async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'log_updated');
    } catch (e) {
      _log.w('logLogUpdated failed', error: e);
    }
  }

  /// Track log record deletions.
  Future<void> logLogDeleted({bool restored = false}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'log_deleted', parameters: {
        'restored': restored,
      });
    } catch (e) {
      _log.w('logLogDeleted failed', error: e);
    }
  }

  /// Track sync completion with outcome metrics.
  Future<void> logSyncCompleted({
    int pushed = 0,
    int pulled = 0,
    int failed = 0,
    int durationMs = 0,
  }) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'sync_completed', parameters: {
        'records_pushed': pushed,
        'records_pulled': pulled,
        'records_failed': failed,
        'duration_ms': durationMs,
      });
    } catch (e) {
      _log.w('logSyncCompleted failed', error: e);
    }
  }

  /// Track data export events.
  /// `format` values: 'csv', 'json'
  Future<void> logExport({required String format, int recordCount = 0}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'data_exported', parameters: {
        'format': format,
        'record_count': recordCount,
      });
    } catch (e) {
      _log.w('logExport failed', error: e);
    }
  }

  /// Track error occurrences as analytics events (separate from Crashlytics).
  /// Enables error-rate dashboards without touching crash reports.
  Future<void> logError(ErrorCategory category, ErrorSeverity severity) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'app_error', parameters: {
        'category': category.name,
        'severity': severity.name,
      });
    } catch (e) {
      // Silent — don't log errors about logging errors
    }
  }

  /// Track bottom navigation tab switches.
  /// `tabName` values: 'home', 'analytics', 'history'
  Future<void> logTabSwitch({required String tabName}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'tab_switch', parameters: {
        'tab_name': tabName,
      });
    } catch (e) {
      _log.w('logTabSwitch failed', error: e);
    }
  }

  /// Track account switch events (multi-account feature).
  Future<void> logAccountSwitch() async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'account_switch');
    } catch (e) {
      _log.w('logAccountSwitch failed', error: e);
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Screen tracking — manual logScreenView for non-route screens
  // ────────────────────────────────────────────────────────────────

  /// Log a screen view. Use for IndexedStack tabs (Home, Analytics, History)
  /// which are NOT tracked by FirebaseAnalyticsObserver (no route push).
  Future<void> logScreenView({required String screenName}) async {
    if (!_ready) return;
    try {
      await _analytics!.logScreenView(screenName: screenName);
    } catch (e) {
      _log.w('logScreenView failed', error: e);
    }
  }

  // ────────────────────────────────────────────────────────────────
  // User properties — segmentation dimensions
  // ────────────────────────────────────────────────────────────────

  /// Set the number of logged-in accounts (multi-account feature).
  Future<void> setAccountCount(int count) async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'account_count', value: '$count');
    } catch (_) {}
  }

  /// Set a bucketed total log count for user segmentation.
  /// Buckets: '0', '1-10', '11-50', '51-200', '200+'
  Future<void> setLogCountBucket(int count) async {
    if (!_ready) return;
    final bucket = switch (count) {
      0 => '0',
      <= 10 => '1-10',
      <= 50 => '11-50',
      <= 200 => '51-200',
      _ => '200+',
    };
    try {
      await _analytics!.setUserProperty(name: 'total_log_count', value: bucket);
    } catch (_) {}
  }

  /// Set the app version as a user property for version-based filtering.
  Future<void> setAppVersion(String version) async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'app_version', value: version);
    } catch (_) {}
  }

  /// Set the authentication method used (for segmentation by auth provider).
  Future<void> setAuthMethod(String method) async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'auth_method', value: method);
    } catch (_) {}
  }

  /// Set the sync status as a user property.
  /// Values: 'enabled', 'disabled', 'error'
  Future<void> setSyncStatus(String status) async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'sync_status', value: status);
    } catch (_) {}
  }

  /// Reset user properties on sign-out.
  Future<void> clearUserProperties() async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'account_count', value: null);
      await _analytics!.setUserProperty(name: 'total_log_count', value: null);
      await _analytics!.setUserProperty(name: 'auth_method', value: null);
      await _analytics!.setUserProperty(name: 'sync_status', value: null);
    } catch (_) {}
  }
}
```

**Event catalog summary (9 events + 5 user properties):**

| Event | Parameters | Wired From |
|---|---|---|
| `app_open` | (built-in) | main.dart init |
| `login` | `method` | auth_service.dart |
| `sign_out` | `all_accounts` | auth_service.dart, accounts_screen.dart |

> **Re-auth vs. fresh login:** Currently, re-sign-in flows (e.g., accounts_screen.dart L220 re-auth) trigger the same `login` event as fresh logins. If distinguishing these matters for analytics, add a `is_reauth: true` parameter to `logLogin()`. Defer for now — the screen-level RouteSettings already differentiates the navigation origin.
| `log_created` | `quick_log`, `event_type` | log_record_service.dart |
| `log_updated` | — | log_record_service.dart |
| `log_deleted` | `restored` | log_record_service.dart |
| `sync_completed` | `records_pushed/pulled/failed`, `duration_ms` | sync_service.dart |
| `data_exported` | `format`, `record_count` | export_service.dart |
| `app_error` | `category`, `severity` | error_reporting_service.dart (D1) |
| `tab_switch` | `tab_name` | main_navigation.dart |
| `account_switch` | — | account_provider.dart |

| User Property | Values | Set From |
|---|---|---|
| `account_count` | `'1'`–`'N'` | account_provider.dart |
| `total_log_count` | `'0'`, `'1-10'`, `'11-50'`, `'51-200'`, `'200+'` | log_record_service.dart |
| `app_version` | semver string | main.dart init |
| `auth_method` | `'email'`, `'google'`, `'apple'` | auth_service.dart |
| `sync_status` | `'enabled'`, `'disabled'`, `'error'` | sync_service.dart |

#### B3. Integrate screen tracking (two mechanisms)

The app has **two navigation patterns** that require different tracking approaches:

**Pattern 1: IndexedStack tabs (Home / Analytics / History).**
`main_navigation.dart` uses `IndexedStack` at L29 with `NavigationBar` at L30. Tab switches at L32-L35 call `setState(() { _currentIndex = index; })`. These are NOT route pushes — `FirebaseAnalyticsObserver` will NOT see them. Must use **manual `logScreenView()`**.

**Pattern 2: Pushed routes (Login, Signup, Profile, Export, Diagnostics, LocationMapPicker).**
All are `MaterialPageRoute(builder: ...)` pushes. `FirebaseAnalyticsObserver` CAN track these — but only if `RouteSettings(name:)` is provided.

**Implementation — Pattern 1 (tab tracking):**

**File:** lib/navigation/main_navigation.dart — Modify `onDestinationSelected` at L32-L35.

Add import: `import '../services/app_analytics_service.dart';`

```dart
  // Current (L32-L35):
  onDestinationSelected: (index) {
    setState(() { _currentIndex = index; });
  }

  // After:
  onDestinationSelected: (index) {
    setState(() { _currentIndex = index; });
    const tabNames = ['home', 'analytics', 'history'];
    AppAnalyticsService.instance.logTabSwitch(tabName: tabNames[index]);
    AppAnalyticsService.instance.logScreenView(screenName: tabNames[index]);
  }
```

**Add initial screen view in `initState`** — the `onDestinationSelected` callback only fires on tab changes, NOT on first render. The initial Home tab must be tracked explicitly:

```dart
  @override
  void initState() {
    super.initState();
    // Track the initial screen view (Home tab, index 0)
    AppAnalyticsService.instance.logScreenView(screenName: 'home');
  }
```

**Implementation — Pattern 2 (route tracking):**

**File:** lib/main.dart — Add `navigatorObservers` to `MaterialApp` at L125-L168.

Add import: `import 'services/app_analytics_service.dart';`

Insert before `home:` at L168:
```dart
      navigatorObservers: [
        if (AppAnalyticsService.instance.observer != null)
          AppAnalyticsService.instance.observer!,
      ],
```

**Add `RouteSettings` to ALL `MaterialPageRoute` calls (14 total):**

| File | Line | Target | `RouteSettings` to add |
|---|---|---|---|
| lib/main.dart | L278 | `LoginScreen` | `settings: const RouteSettings(name: 'LoginScreen')` |
| lib/screens/accounts_screen.dart | L40 | `ExportScreen` | `settings: const RouteSettings(name: 'ExportScreen')` |
| lib/screens/accounts_screen.dart | L49 | `ProfileScreen` | `settings: const RouteSettings(name: 'ProfileScreen')` |
| lib/screens/accounts_screen.dart | L95 | `MultiAccountDiagnosticsScreen` | `settings: const RouteSettings(name: 'DiagnosticsScreen')` |
| lib/screens/accounts_screen.dart | L220 | `LoginScreen` (re-sign-in) | `settings: const RouteSettings(name: 'LoginScreen')` |
| lib/screens/accounts_screen.dart | L285 | `LoginScreen` (add account) | `settings: const RouteSettings(name: 'LoginScreen')` |
| lib/screens/accounts_screen.dart | L618 | `LoginScreen` (empty state) | `settings: const RouteSettings(name: 'LoginScreen')` |
| lib/screens/home_screen.dart | L115 | `AccountsScreen` | `settings: const RouteSettings(name: 'AccountsScreen')` |
| lib/screens/home_screen.dart | L188 | `AccountsScreen` | `settings: const RouteSettings(name: 'AccountsScreen')` |
| lib/screens/logging_screen.dart | L991 | `LocationMapPicker` (map) | `settings: const RouteSettings(name: 'LocationMapPicker')` |
| lib/screens/login_screen.dart | L131 | `SignupScreen` | `settings: const RouteSettings(name: 'SignupScreen')` |
| lib/widgets/edit_log_record_dialog.dart | L653 | `LocationMapPicker` | `settings: const RouteSettings(name: 'LocationMapPicker')` |

**Note on dialog routes:** The app uses `showDialog()` in several screens (e.g., logging_screen.dart L176, L1043, L1209; accounts_screen.dart confirmation dialogs). These accept a `routeSettings:` parameter that `FirebaseAnalyticsObserver` can track. For MVP, skip dialog-level tracking — the screen views are sufficient. If funnel analysis later needs dialog engagement data, add `routeSettings: RouteSettings(name: 'DeleteConfirmDialog')` etc.

**Initialize analytics in `main()`** — insert after `Firebase.initializeApp` (L52-L57):
```dart
    await AppAnalyticsService.instance.initialize();
```

**Note:** `initialize()` is `Future<void>` (not synchronous) because D6 adds `setAnalyticsCollectionEnabled(true)` inside it. The `await` is required.

**Log initial app open** — insert after all init steps, before `runZonedGuarded` (before L96):
```dart
    AppAnalyticsService.instance.logAppOpen();
```

**Optional — lifecycle analytics:** Consider adding `WidgetsBindingObserver` to `MainNavigation` to track `didChangeAppLifecycleState` → `AppLifecycleState.resumed` events as `app_foreground`. This enables session-depth analysis (how often users background/foreground). Defer to post-MVP — `app_open` covers cold-start frequency.

**Debug verification setup:** Add `-FIRDebugEnabled` to Xcode scheme:
- Open `ios/Runner.xcodeproj` → Runner scheme → Run → Arguments → add `-FIRDebugEnabled`
- Opens Firebase Analytics DebugView for real-time event validation

#### B4. Wire analytics into service layer (tiered)

For each file: (1) add import `import 'app_analytics_service.dart';`, (2) add analytics call at the appropriate site.

**Tier 1 — instrument now (core user journeys):**

**auth_service.dart** — 5 instrumentation points. Add import: `import 'app_analytics_service.dart';`

| Line | Method | Insert Before | Analytics Call |
|---|---|---|---|
| L67 | `signUpWithEmail` | `return userCredential` | `AppAnalyticsService.instance.logLogin(method: 'email_signup');` |
| L67 | `signUpWithEmail` | `return userCredential` | `AppAnalyticsService.instance.setAuthMethod('email');` |
| L84 | `signInWithEmail` | `return userCredential` | `AppAnalyticsService.instance.logLogin(method: 'email');` |
| L181 | `signInWithGoogle` | `return userCredential` | `AppAnalyticsService.instance.logLogin(method: 'google');` |
| L181 | `signInWithGoogle` | `return userCredential` | `AppAnalyticsService.instance.setAuthMethod('google');` |
| L237 | `signInWithApple` | `return userCredential` | `AppAnalyticsService.instance.logLogin(method: 'apple');` |
| L237 | `signInWithApple` | `return userCredential` | `AppAnalyticsService.instance.setAuthMethod('apple');` |
| L314 | `signOut` | after existing body | `AppAnalyticsService.instance.logSignOut();` |
| L314 | `signOut` | after existing body | `AppAnalyticsService.instance.clearUserProperties();` |

**Also wire `CrashReportingService.setUserId()` on sign-in** — so Crashlytics reports can be filtered by user:

| Line | Method | Insert After `logLogin` | Call |
|---|---|---|---|
| L67 | `signUpWithEmail` | after `logLogin` | `CrashReportingService.setUserId(userCredential.user?.uid ?? '');` |
| L84 | `signInWithEmail` | after `logLogin` | `CrashReportingService.setUserId(userCredential.user?.uid ?? '');` |
| L181 | `signInWithGoogle` | after `logLogin` | `CrashReportingService.setUserId(userCredential.user?.uid ?? '');` |
| L237 | `signInWithApple` | after `logLogin` | `CrashReportingService.setUserId(userCredential.user?.uid ?? '');` |
| L314 | `signOut` | after `clearUserProperties` | `CrashReportingService.setUserId('');` |

**log_record_service.dart** — 5 instrumentation points. Add import: `import 'app_analytics_service.dart';`

| Method (Line) | Insert | Analytics Call |
|---|---|---|
| `createLogRecord` (L65-L121) | before final return | `AppAnalyticsService.instance.logLogCreated(eventType: eventType);` |
| `quickLog` (L407-L444) | before final return | `AppAnalyticsService.instance.logLogCreated(quickLog: true, eventType: eventType);` |
| `updateLogRecord` (L173-L213) | before final return | `AppAnalyticsService.instance.logLogUpdated();` |
| `deleteLogRecord` (L216-L219) | before soft-delete | `AppAnalyticsService.instance.logLogDeleted();` |
| `restoreDeleted` (L546-L551) | after restore | `AppAnalyticsService.instance.logLogDeleted(restored: true);` |

Additionally, update `setLogCountBucket` user property after record creation/deletion:
```dart
    // After successful create/delete in log_record_service.dart:
    final count = await countLogRecords(accountId: accountId);
    AppAnalyticsService.instance.setLogCountBucket(count);
```

**sync_service.dart** — 2 instrumentation points. Add import: `import 'app_analytics_service.dart';`

| Method (Line) | Insert Before | Analytics Call |
|---|---|---|
| `syncAllLoggedInAccounts` (L536-L541) | `return SyncResult(...)` | `AppAnalyticsService.instance.logSyncCompleted(pushed: totalSuccess, failed: totalFailed, durationMs: stopwatch.elapsedMilliseconds);` |
| `pullAllLoggedInAccounts` (L611-L616) | `return SyncResult(...)` | `AppAnalyticsService.instance.logSyncCompleted(pulled: totalSuccess, failed: totalFailed, durationMs: stopwatch.elapsedMilliseconds);` |

**Tier 2 — instrument next:**

**export_service.dart** — 2 instrumentation points. Add import: `import 'app_analytics_service.dart';`

| Method (Line) | Insert | Analytics Call |
|---|---|---|
| `exportToCsv` (L9-L37) | after file generation | `AppAnalyticsService.instance.logExport(format: 'csv', recordCount: records.length);` |
| `exportToJson` (L41-L51) | after file generation | `AppAnalyticsService.instance.logExport(format: 'json', recordCount: records.length);` |

**account_provider.dart** — 2 instrumentation points. Add import: `import '../services/app_analytics_service.dart';`

| Location (Line) | Insert | Analytics Call |
|---|---|---|
| `AccountSwitcher.switchAccount` (L130) | after successful switch | `AppAnalyticsService.instance.logAccountSwitch();` |
| `allAccountsProvider` (L68) | after loading count | `AppAnalyticsService.instance.setAccountCount(accounts.length);` |

**accounts_screen.dart** — 2 instrumentation points. Add import: `import '../services/app_analytics_service.dart';`

| Location (Line) | Insert | Analytics Call |
|---|---|---|
| Sign-out-all popup (L84) | before `signOut` | `AppAnalyticsService.instance.logSignOut(allAccounts: true);` |
| `_signOutSingleAccount` (L522) | before sign-out call | `AppAnalyticsService.instance.logSignOut();` |

**Tier 3 — defer (instrument only when needed):**
- `data_integrity_service.dart` — log integrity check events
- `account_session_manager.dart` — log token refresh events
- `notification_service.dart` — log notification opt-in/out

#### B5. Set user properties at key lifecycle points

User properties are set at these moments:

**On app launch (main.dart, after init):**
```dart
    // After Firebase + Analytics init:
    final packageInfo = await PackageInfo.fromPlatform();
    AppAnalyticsService.instance.setAppVersion(packageInfo.version);
```
(Requires `package_info_plus` from A7.)

**On auth state change (auth_service.dart):**
- Set `auth_method` after each successful sign-in (covered in B4)
- Clear all user properties on sign-out (covered in B4)

**On account data load (account_provider.dart):**
- Set `account_count` when `allAccountsProvider` resolves (covered in B4)

**On log record changes (log_record_service.dart):**
- Update `total_log_count` bucket after create/delete (covered in B4)

**On sync configuration (sync_service.dart):**
- Set `sync_status` when auto-sync is started/stopped:
  - `startAutoSync` (L71-L86): `AppAnalyticsService.instance.setSyncStatus('enabled');`
  - `stopAutoSync` (L88-L96): `AppAnalyticsService.instance.setSyncStatus('disabled');`
  - On persistent sync failure in catch: `AppAnalyticsService.instance.setSyncStatus('error');`

#### B6. Create analytics test file

**Create new file:** test/services/app_analytics_service_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/app_analytics_service.dart';
import 'package:ash_trail/models/app_error.dart';

void main() {
  group('AppAnalyticsService', () {
    test('singleton returns same instance', () {
      final a = AppAnalyticsService.instance;
      final b = AppAnalyticsService();
      expect(identical(a, b), true);
    });

    test('initialize is no-op when Firebase not initialized', () {
      // Firebase.apps.isEmpty == true in test environment
      AppAnalyticsService.instance.initialize();
      expect(AppAnalyticsService.instance.observer, isNull);
    });

    test('all log methods are no-op when not initialized', () async {
      // Should not throw even when _analytics is null
      await AppAnalyticsService.instance.logAppOpen();
      await AppAnalyticsService.instance.logLogin(method: 'email');
      await AppAnalyticsService.instance.logSignOut();
      await AppAnalyticsService.instance.logLogCreated();
      await AppAnalyticsService.instance.logLogUpdated();
      await AppAnalyticsService.instance.logLogDeleted();
      await AppAnalyticsService.instance.logSyncCompleted();
      await AppAnalyticsService.instance.logExport(format: 'csv');
      await AppAnalyticsService.instance.logError(
        ErrorCategory.network, ErrorSeverity.warning,
      );
      await AppAnalyticsService.instance.logTabSwitch(tabName: 'home');
      await AppAnalyticsService.instance.logAccountSwitch();
      await AppAnalyticsService.instance.logScreenView(screenName: 'test');
    });

    test('user property setters are no-op when not initialized', () async {
      await AppAnalyticsService.instance.setAccountCount(3);
      await AppAnalyticsService.instance.setLogCountBucket(42);
      await AppAnalyticsService.instance.setAppVersion('1.0.3');
      await AppAnalyticsService.instance.setAuthMethod('google');
      await AppAnalyticsService.instance.setSyncStatus('enabled');
      await AppAnalyticsService.instance.clearUserProperties();
    });

    test('logCountBucket returns correct buckets', () {
      // Verify bucket logic independently (extract for testability)
      String bucket(int count) => switch (count) {
        0 => '0',
        <= 10 => '1-10',
        <= 50 => '11-50',
        <= 200 => '51-200',
        _ => '200+',
      };
      expect(bucket(0), '0');
      expect(bucket(1), '1-10');
      expect(bucket(10), '1-10');
      expect(bucket(11), '11-50');
      expect(bucket(50), '11-50');
      expect(bucket(51), '51-200');
      expect(bucket(200), '51-200');
      expect(bucket(201), '200+');
    });
  });
}
```

#### B7. Wire `AppAnalyticsService` provider for Riverpod

**File:** lib/providers/ — create analytics provider or use direct singleton access.

Decision: follow existing pattern — `ErrorReportingService` uses `ErrorReportingService.instance` directly, NOT a Riverpod provider. `AppAnalyticsService` should be the same: `AppAnalyticsService.instance` everywhere. No Riverpod provider needed.

This keeps analytics calls zero-dependency and works in services that don't have Riverpod access.

#### B8. Add `.when()` error callback improvements for analytics

Several `.when()` error callbacks in screens discard the stack trace and show raw errors. While these are primarily Part A (error sanitization), they also represent missed analytics opportunities.

**Screens with `.when()` error callbacks that discard stack traces:**

| File | Line | Current | Add |
|---|---|---|---|
| lib/screens/analytics_screen.dart | L51 | `error: (error, _)` | Log error via `ErrorReportingService.instance.reportException(error, context: 'logRecordStatsProvider')` |
| lib/screens/analytics_screen.dart | L55 | `error: (error, _)` | Same pattern |
| lib/screens/analytics_screen.dart | L122 | `error: (e, _)` | Same pattern |
| lib/screens/history_screen.dart | L122 | `error: (error, _)` | Same pattern |
| lib/screens/home_screen.dart | L132 | `error: (error, _)` | `.when(` error callback — report via `ErrorReportingService` |
| lib/screens/home_screen.dart | L206 | `error: (error, _)` | `.when(` error callback — report via `ErrorReportingService` |
| lib/screens/profile_screen.dart | L284 | `error: (error, _)` | `.when(` error callback — report via `ErrorReportingService` |
| lib/screens/accounts_screen.dart | L233 | `error: (error, stackTrace)` | Already logs via `_log.e(...)` but add `ErrorReportingService` call |

These feed into the `app_error` analytics event via the D1 bridge (ErrorReportingService → Analytics).

---

### Part C — Firebase Performance (Traces & HTTP Metrics)

#### C1. Add `firebase_performance` dependency

**File:** pubspec.yaml — insert after the `firebase_analytics` line added in B1:
```yaml
  firebase_performance: ^0.10.0+12
```

Run: `flutter pub get`

**Auto-captured with zero code (always-on in all build modes):**
- HTTP request/response traces for all `http` package calls
- Slow/frozen frame rendering traces per screen
- Native `_app_start` trace (cold start to first frame)

**Test isolation:** Same `Firebase.apps.isEmpty` guard pattern — `_ready` returns `false` in unit tests.

**Always-on guarantee:** Firebase Performance collects automatically in all build modes (debug, profile, release). No `kDebugMode` gates. The `_ready` guard checks only for Firebase initialization, not build mode.

#### C2. Create `AppPerformanceService`

**Create new file:** lib/services/app_performance_service.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import '../logging/app_logger.dart';

/// Singleton wrapper around Firebase Performance for custom traces.
///
/// Active in ALL build modes (debug, profile, release/TestFlight).
/// The only guard is Firebase initialization — in unit tests where
/// Firebase.apps.isEmpty, all trace methods execute the operation
/// without wrapping it in a trace (zero-overhead fallback).
class AppPerformanceService {
  static final _log = AppLogger.logger('Performance');
  static final AppPerformanceService _instance = AppPerformanceService._internal();
  static AppPerformanceService get instance => _instance;
  factory AppPerformanceService() => _instance;
  AppPerformanceService._internal();

  /// Returns true when Firebase is available.
  /// No kDebugMode check — traces run in ALL build modes including TestFlight.
  bool get _ready => Firebase.apps.isNotEmpty;

  /// Generic trace wrapper. All other trace methods delegate here.
  ///
  /// When Firebase is not available (unit tests), executes [operation] directly
  /// without any trace overhead.
  ///
  /// Automatically sets:
  /// - `success` attribute ('true'/'false')
  /// - `error_type` attribute on failure
  /// - Any caller-provided [attributes] and [metrics]
  Future<T> trace<T>(
    String name,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
    Map<String, int>? metrics,
  }) async {
    if (!_ready) return operation();

    final trace = FirebasePerformance.instance.newTrace(name);
    attributes?.forEach(trace.putAttribute);
    await trace.start();
    try {
      final result = await operation();
      trace.putAttribute('success', 'true');
      metrics?.forEach(trace.setMetric);
      return result;
    } catch (e) {
      trace.putAttribute('success', 'false');
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Trace with an explicit [Trace] handle for setting metrics mid-operation.
  ///
  /// Returns a started [Trace] that the caller must stop with `trace.stop()`.
  /// Returns `null` when Firebase is unavailable (unit tests).
  ///
  /// Usage:
  /// ```dart
  /// final t = await AppPerformanceService.instance.startTrace('sync_push');
  /// t?.putAttribute('account_count', '3');
  /// // ... do work ...
  /// t?.setMetric('records_synced', 42);
  /// await t?.stop();
  /// ```
  Future<Trace?> startTrace(String name, {Map<String, String>? attributes}) async {
    if (!_ready) return null;
    final t = FirebasePerformance.instance.newTrace(name);
    attributes?.forEach(t.putAttribute);
    await t.start();
    return t;
  }

  /// Trace an app startup phase (Firebase init, Hive init, etc.)
  /// Named `startup_<phase>` in console.
  Future<T> traceStartup<T>(String phase, Future<T> Function() operation) {
    return trace('startup_$phase', operation);
  }

  /// Trace a sync cycle.
  /// Named `sync` in console with `sync_type` attribute.
  Future<T> traceSync<T>(
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) {
    return trace('sync', operation, attributes: attributes);
  }

  /// Trace a token refresh / Cloud Function call.
  /// Named `token_refresh` in console.
  Future<T> traceTokenRefresh<T>(Future<T> Function() operation) {
    return trace('token_refresh', operation);
  }

  /// Trace a data export operation.
  /// Named `data_export` in console.
  Future<T> traceExport<T>(
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) {
    return trace('data_export', operation, attributes: attributes);
  }

  /// Trace a Google Sign-In flow (multi-step: Google → Firebase → token).
  /// Named `google_sign_in` in console.
  Future<T> traceGoogleSignIn<T>(Future<T> Function() operation) {
    return trace('google_sign_in', operation);
  }

  /// Trace account switching (token generation + re-auth).
  /// Named `account_switch` in console.
  Future<T> traceAccountSwitch<T>(Future<T> Function() operation) {
    return trace('account_switch', operation);
  }
}
```

**Custom trace catalog (8 traces):**

| Trace Name | Source | Attributes | Metrics |
|---|---|---|---|
| `startup_firebase` | main.dart | `success` | — |
| `startup_crashlytics` | main.dart | `success` | — |
| `startup_hive` | main.dart | `success` | — |
| `startup_shared_prefs` | main.dart | `success` | — |
| `sync` | sync_service.dart | `sync_type`, `success`, `account_count` | `records_synced`, `records_failed` |
| `token_refresh` | token_service.dart | `success`, `error_type` | — |
| `google_sign_in` | auth_service.dart | `success`, `error_type` | — |
| `account_switch` | account_provider.dart | `success`, `error_type` | — |
| `data_export` | export_service.dart | `format`, `success` | `record_count` |

#### C3. Instrument HTTP calls in token_service.dart

**File:** lib/services/token_service.dart

Two HTTP endpoints hit `https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token`:
- `generateCustomToken(uid)` at L34-L66 — uses `Stopwatch` at L34, logs at L44/L57/L64
- `isEndpointReachable()` at L72-L93 — uses `Stopwatch` at L72, logs at L85/L91

**Firebase Performance auto-traces `http` package calls.** These will appear automatically as network traces in the Performance console. Keep the existing Stopwatch for local log output, but also wrap with the custom trace for richer attributes:

Add import: `import 'app_performance_service.dart';`

**`generateCustomToken`** — wrap the entire method body (L34-L66):
```dart
  Future<String> generateCustomToken(String uid) async {
    return AppPerformanceService.instance.traceTokenRefresh(() async {
      final stopwatch = Stopwatch()..start(); // Keep for log output
      // ... existing body ...
    });
  }
```

**`isEndpointReachable`** — No custom trace needed. The auto-trace captures the HTTP call. Keep existing Stopwatch for local logs.

Add `ErrorReportingService` (from A3, Tier 1) to the catch blocks at L61-L66 and L89-L93 at the same time.

#### C4. Add startup tracing

**File:** lib/main.dart — init steps at L52-L92. Wrap each async init step.

Add import: `import 'services/app_performance_service.dart';`

**Important sequencing note:** The `traceStartup('firebase', ...)` call executes before Firebase is initialized, so `_ready` returns `false` and the operation runs unwrapped. This is correct — the native `_app_start` trace covers overall startup. The three post-Firebase init steps (Crashlytics, Hive, SharedPreferences) will all be properly traced.

**Replace each init block (L59-L92):**

```dart
  // Crash reporting (L59-L63) → wrap:
  try {
    _log.i('Initializing CrashReportingService...');
    await AppPerformanceService.instance.traceStartup('crashlytics', () async {
      await CrashReportingService.initialize();
    });
    _log.i('CrashReportingService initialized');
  } catch (e) {
    _log.e('Crash reporting initialization error', error: e);
  }

  // Hive (L65-L70) → wrap:
  try {
    _log.i('Initializing Hive database...');
    await AppPerformanceService.instance.traceStartup('hive', () async {
      final db = HiveDatabaseService();
      await db.initialize();
    });
    _log.i('Hive database initialized');
  } catch (e) {
    _log.e('Hive database initialization error', error: e);
  }

  // Location (L72-L81) → no trace needed (fast synchronous check)

  // SharedPreferences (L83-L92) → wrap:
  try {
    _log.i('Initializing SharedPreferences...');
    sharedPrefs = await AppPerformanceService.instance.traceStartup('shared_prefs', () async {
      return await SharedPreferences.getInstance();
    });
    _log.i('SharedPreferences initialized');
  } catch (e) {
    _log.e('SharedPreferences initialization error', error: e);
  }
```

#### C5. Instrument sync service with custom traces

**File:** lib/services/sync_service.dart — current Stopwatch at L487 (`syncAllLoggedInAccounts`) and L561 (`pullAllLoggedInAccounts`).

Add import: `import 'app_performance_service.dart';`

**Approach: Use `startTrace()` for metric-setting access.** The `trace()` wrapper doesn't allow setting metrics mid-operation. Use `startTrace()` to get a `Trace` handle:

**`syncAllLoggedInAccounts()` (L477-L548):**

Insert after the Stopwatch start (L487), before the main logic:
```dart
    final perfTrace = await AppPerformanceService.instance.startTrace(
      'sync', attributes: {'sync_type': 'push'},
    );
```

Insert before each `return SyncResult(...)`:
- Success return (L536-L541): add metrics before return:
  ```dart
      perfTrace?.setMetric('records_synced', totalSuccess);
      perfTrace?.setMetric('records_failed', totalFailed);
      perfTrace?.putAttribute('success', 'true');
      perfTrace?.putAttribute('account_count', '${loggedInAccounts.length}');
      await perfTrace?.stop();
  ```
- Error return (L546-L550): add error attributes before return:
  ```dart
      perfTrace?.putAttribute('success', 'false');
      perfTrace?.putAttribute('error_type', e.runtimeType.toString());
      await perfTrace?.stop();
  ```
- Early returns (L488-L509): stop trace before each early return:
  ```dart
      perfTrace?.putAttribute('success', 'true');
      perfTrace?.putAttribute('early_exit', 'already_syncing'); // or 'offline' or 'no_accounts'
      await perfTrace?.stop();
  ```

**`pullAllLoggedInAccounts()` (L551-L624):** Same pattern with `sync_type: 'pull'`.

#### C6. Instrument auth_service.dart sign-in flows

**File:** lib/services/auth_service.dart — `signInWithGoogle()` already has a Stopwatch at L90.

Add import: `import 'app_performance_service.dart';`

**`signInWithGoogle()` (L89-L192):** Wrap the entire method body:
```dart
  Future<UserCredential> signInWithGoogle() async {
    return AppPerformanceService.instance.traceGoogleSignIn(() async {
      final stopwatch = Stopwatch()..start(); // Keep for local logs
      // ... existing body ...
    });
  }
```

This captures the full multi-step flow (GoogleSignIn → Firebase auth → token generation) in a single trace. The Stopwatch remains for local log output — the two serve different purposes (local diagnostics vs. cloud metrics).

**`signInWithApple()` (L195-L244):** Same pattern (no existing Stopwatch, add trace wrapper):
```dart
  Future<UserCredential> signInWithApple() async {
    return AppPerformanceService.instance.trace('apple_sign_in', () async {
      // ... existing body ...
    });
  }
```

`signUpWithEmail` and `signInWithEmail` are simple single-step calls — no custom trace needed. Firebase Auth SDK and network auto-traces cover them.

#### C7. Instrument account switching

**File:** lib/providers/account_provider.dart — `AccountSwitcher.switchAccount` (L130) includes token generation + `signInWithCustomToken` calls with timing-sensitive retry logic at L164-L175.

Add import: `import '../services/app_performance_service.dart';`

Wrap `switchAccount` body:
```dart
  Future<void> switchAccount(String userId) async {
    return AppPerformanceService.instance.traceAccountSwitch(() async {
      // ... existing body ...
    });
  }
```

#### C8. Instrument export operations

**File:** lib/services/export_service.dart — `exportToCsv` (L9-L37) and `exportToJson` (L41-L51).

Add import: `import 'app_performance_service.dart';`

```dart
  Future<String> exportToCsv(List<LogRecord> records) async {
    return AppPerformanceService.instance.traceExport(() async {
      // ... existing body ...
    }, attributes: {'format': 'csv'});
  }

  Future<String> exportToJson(List<LogRecord> records) async {
    return AppPerformanceService.instance.traceExport(() async {
      // ... existing body ...
    }, attributes: {'format': 'json'});
  }
```

#### C9. Create performance test file

**Create new file:** test/services/app_performance_service_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/app_performance_service.dart';

void main() {
  group('AppPerformanceService', () {
    test('singleton returns same instance', () {
      final a = AppPerformanceService.instance;
      final b = AppPerformanceService();
      expect(identical(a, b), true);
    });

    test('trace executes operation when Firebase not initialized', () async {
      // Firebase.apps.isEmpty == true in test environment
      // Should execute the operation directly, no trace wrapper
      final result = await AppPerformanceService.instance.trace(
        'test_trace',
        () async => 42,
      );
      expect(result, 42);
    });

    test('traceStartup executes operation when Firebase not initialized', () async {
      final result = await AppPerformanceService.instance.traceStartup(
        'test_phase',
        () async => 'done',
      );
      expect(result, 'done');
    });

    test('traceSync executes operation when Firebase not initialized', () async {
      final result = await AppPerformanceService.instance.traceSync(
        () async => true,
        attributes: {'sync_type': 'push'},
      );
      expect(result, true);
    });

    test('traceTokenRefresh executes operation when Firebase not initialized', () async {
      final result = await AppPerformanceService.instance.traceTokenRefresh(
        () async => 'token_value',
      );
      expect(result, 'token_value');
    });

    test('trace propagates exceptions when Firebase not initialized', () async {
      expect(
        () => AppPerformanceService.instance.trace(
          'failing_trace',
          () async => throw Exception('test'),
        ),
        throwsException,
      );
    });

    test('startTrace returns null when Firebase not initialized', () async {
      final trace = await AppPerformanceService.instance.startTrace('test');
      expect(trace, isNull);
    });

    test('traceExport executes operation when Firebase not initialized', () async {
      final result = await AppPerformanceService.instance.traceExport(
        () async => 'csv_data',
        attributes: {'format': 'csv'},
      );
      expect(result, 'csv_data');
    });

    test('traceGoogleSignIn executes operation when Firebase not initialized', () async {
      final result = await AppPerformanceService.instance.traceGoogleSignIn(
        () async => 'user_credential',
      );
      expect(result, 'user_credential');
    });

    test('traceAccountSwitch executes operation when Firebase not initialized', () async {
      final result = await AppPerformanceService.instance.traceAccountSwitch(
        () async => 'switched',
      );
      expect(result, 'switched');
    });
  });
}
```

---

### Part D — Unified Observability Wiring

This part connects the three pillars together: errors flow into analytics, logs flow into Crashlytics breadcrumbs, and all three services are initialized in the correct order in main.dart.

#### D1. Bridge `ErrorReportingService` → Analytics

**File:** lib/services/error_reporting_service.dart

Every reported error should also be recorded as an analytics event so error rates appear in the Firebase Analytics dashboard alongside user behavior — correlating "this version has 3× more sync errors" with "users also stopped logging."

Add import at top of file:
```dart
import 'app_analytics_service.dart';
```

Insert at L86 (after the Crashlytics forwarding block at L80-L85, before the closing `}` of `report()`):
```dart
    // Step 5: Forward to Analytics as a counted event
    AppAnalyticsService.instance.logError(error.category, error.severity);
```

This is fire-and-forget — `logError` handles its own `_ready` guard and swallows any internal exceptions. The analytics event goes out independently of the Crashlytics report.

**Cross-reference:** `logError` is defined in B2 (`AppAnalyticsService`) and logs the `error_occurred` event with `error_category` and `error_severity` parameters.

#### D2. Add `_BreadcrumbLogOutput` to `AppLogger`

**File:** lib/logging/app_logger.dart (107 lines)

**Goal:** Every `_log.e(...)` or `_log.wtf(...)` call throughout the app automatically creates a Crashlytics breadcrumb, so when a crash report arrives, the preceding error logs are visible in the "Logs" tab without any per-call-site changes.

**Step 1 — Add static callback field at L28** (after `static bool _verboseLogging = false;`):
```dart
  /// Optional callback invoked on every log at Level.error or higher.
  /// Wired to CrashReportingService.logMessage() in main.dart D4.
  static void Function(String loggerName, String message)? onErrorLog;
```

**Step 2 — Create `_BreadcrumbLogOutput` class** at end of file (after `_AppLogFilter` at L96-L107):
```dart
/// Wraps the default ConsoleOutput and additionally invokes
/// [AppLogger.onErrorLog] for Level.error and above.
///
/// This turns every high-severity log statement into a Crashlytics
/// breadcrumb without the caller needing to call CrashReportingService
/// explicitly.
class _BreadcrumbLogOutput extends LogOutput {
  final String name;
  final LogOutput _delegate;
  _BreadcrumbLogOutput(this.name, this._delegate);

  @override
  void output(OutputEvent event) {
    // Always delegate to console first
    _delegate.output(event);

    // Forward errors+ to Crashlytics breadcrumbs
    if (event.level.index >= Level.error.index && AppLogger.onErrorLog != null) {
      // Join multi-line output (stack traces, pretty-printed objects) into
      // a single breadcrumb string, truncated to 1024 chars (Crashlytics limit).
      final message = event.lines.join('\n');
      final truncated = message.length > 1024 ? message.substring(0, 1024) : message;
      AppLogger.onErrorLog!(name, truncated);
    }
  }
}
```

**Step 3 — Wire into Logger constructor** at L60-L80 (the `logger()` factory method).

Current code creates Logger like this:
```dart
return Logger(
  filter: _AppLogFilter(),
  printer: PrefixPrinter(PrettyPrinter(...), prefix: name),
);
```

Add `output:` parameter:
```dart
return Logger(
  filter: _AppLogFilter(),
  printer: PrefixPrinter(PrettyPrinter(...), prefix: name),
  output: _BreadcrumbLogOutput(name, ConsoleOutput()),
);
```

**Exact change location:** Logger constructor call inside `logger()` at approximately L67-L72.

**How it works at runtime:**
1. Any service calls `_log.e('Sync failed', error: e)`
2. Logger passes through `_AppLogFilter` (allows Level.error in all build modes)
3. `_BreadcrumbLogOutput.output()` fires → prints to console → invokes `onErrorLog`
4. Callback (set in D4) calls `CrashReportingService.logMessage()`
5. Crashlytics stores the breadcrumb — visible in crash report timeline

**In tests:** `onErrorLog` is `null` by default → no Crashlytics calls in test environment.

#### D3. Create Riverpod providers for new services

**File:** lib/providers/ — new file or add to existing provider barrel.

The three new services (`AppAnalyticsService`, `AppPerformanceService`, `ErrorReportingService`) are all singletons accessed via `.instance`. Riverpod providers are not strictly required (unlike `SyncService` which needs `ref` for dependencies), but adding them enables:
- Override in tests via `ProviderScope.overrides`
- Future dependency injection if services need constructor params

**Create file:** lib/providers/observability_providers.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_analytics_service.dart';
import '../services/app_performance_service.dart';
import '../services/error_reporting_service.dart';

/// Exposes observability singletons to the Riverpod graph.
/// Override in tests to inject fakes.
final analyticsServiceProvider = Provider<AppAnalyticsService>(
  (ref) => AppAnalyticsService.instance,
);

final performanceServiceProvider = Provider<AppPerformanceService>(
  (ref) => AppPerformanceService.instance,
);

final errorReportingServiceProvider = Provider<ErrorReportingService>(
  (ref) => ErrorReportingService.instance,
);
```

**Usage in widgets/providers** (optional — direct `.instance` access is also fine):
```dart
final analytics = ref.read(analyticsServiceProvider);
analytics.logEvent('my_event');
```

**Decision:** Direct `.instance` access is used throughout this plan for simplicity. The providers exist for test overriding and future flexibility, not as the primary access pattern.

#### D4. Wire init sequence in main.dart

**File:** lib/main.dart

All three observability services must be initialized in the correct order in `_initializeApp()`. The current init sequence (L49-L107) handles Firebase → Crashlytics → Hive → Location → SharedPreferences → runZonedGuarded.

**Insert after CrashReportingService.initialize() (L59-L63), before Hive init (L65):**

```dart
  // --- Observability init (always-on, all build modes) ---

  // Wire logger breadcrumbs → Crashlytics (D2)
  AppLogger.onErrorLog = (name, message) {
    CrashReportingService.logMessage('[$name] $message');
  };

  // Initialize analytics (B2) — explicitly enable collection
  try {
    await AppAnalyticsService.instance.initialize();
    _log.i('AppAnalyticsService initialized');
  } catch (e) {
    _log.e('Analytics initialization error', error: e);
  }

  // Performance SDK needs no explicit init — auto-starts with Firebase.
  // Custom traces are available immediately via AppPerformanceService.instance.
  _log.i('AppPerformanceService ready (auto-started with Firebase)');
```

**Add imports at top of main.dart:**
```dart
import 'services/app_analytics_service.dart';
import 'services/app_performance_service.dart';
import 'logging/app_logger.dart';
```

**Full init sequence after this change:**
1. `WidgetsFlutterBinding.ensureInitialized()` (L49)
2. `Firebase.initializeApp()` (L52-L57)
3. `CrashReportingService.initialize()` (L59-L63) — **exits kDebugMode guard, see D5**
4. `AppLogger.onErrorLog = ...` (NEW — D4)
5. `AppAnalyticsService.instance.initialize()` (NEW — D4)
6. `HiveDatabaseService().initialize()` (L65-L70)
7. Location permission check (L72-L81)
8. `SharedPreferences.getInstance()` (L83-L92)
9. `runZonedGuarded { runApp(...) }` (L96-L107)

#### D5. Fix Crashlytics `kDebugMode` guard for always-on collection

**File:** lib/services/crash_reporting_service.dart

**Current code at L37-L40:**
```dart
    if (kDebugMode) {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(true);
    }
```

**Problem:** This only explicitly enables collection in debug mode. In release (TestFlight), collection relies on the Firebase default (enabled). This is fragile — if the Firebase default ever changes, or if a `GoogleService-Info.plist` flag overrides it, Crashlytics silently stops collecting.

**Fix:** Enable collection unconditionally, in ALL build modes:
```dart
    // Always-on: explicitly enable in all build modes (debug + release + TestFlight)
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(true);
```

**Also:** Move the `FlutterError.onError` assignment outside any guard:
```dart
    // Capture all Flutter framework errors (widget build, layout, paint)
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

This is already correct in the current code (L42-L43, outside the `if`), but verify it stays outside after removing the `kDebugMode` block.

#### D6. Add explicit always-on collection in `AppAnalyticsService.initialize()`

**File:** lib/services/app_analytics_service.dart (created in B2)

**In the `initialize()` method**, after `_analytics = FirebaseAnalytics.instance;`, add:

```dart
    // Explicitly enable collection in ALL build modes.
    // Firebase Analytics defaults to enabled, but this makes intent explicit
    // and guards against GoogleService-Info.plist overrides or future SDK changes.
    await _analytics!.setAnalyticsCollectionEnabled(true);
```

**Full `initialize()` after this change:**
```dart
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) return; // test isolation
    _analytics = FirebaseAnalytics.instance;
    await _analytics!.setAnalyticsCollectionEnabled(true); // always-on
    _log.i('Analytics initialized — collection explicitly enabled');
  }
```

**Note:** The `_log.i(...)` line will appear in debug logs AND in release when `VERBOSE_LOGGING=true` (the current default). Remove the `if (kDebugMode)` guard that was in the B2 draft — log unconditionally so TestFlight builds confirm initialization via device logs.

#### D7. Add always-on verification to deploy script

**File:** scripts/deploy_testflight.sh

After the `flutter build ipa` line, add a verification step:

```bash
echo "--- Verifying observability configuration ---"

# 1. Verify PrivacyInfo.xcprivacy is in the built IPA
if ! unzip -l build/ios/ipa/*.ipa | grep -q "PrivacyInfo.xcprivacy"; then
  echo "❌ ERROR: PrivacyInfo.xcprivacy not found in IPA bundle"
  exit 1
fi
echo "✅ PrivacyInfo.xcprivacy present in IPA"

# 2. Verify GoogleService-Info.plist has analytics enabled (not disabled)
if grep -q "FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED" ios/Runner/GoogleService-Info.plist; then
  echo "❌ ERROR: Analytics collection is deactivated in GoogleService-Info.plist"
  exit 1
fi
echo "✅ Analytics collection not deactivated in plist"

# 3. Verify dSYMs were generated (required for readable Crashlytics traces)
if [ -z "$(find build/ios/archive -name '*.dSYM' 2>/dev/null)" ]; then
  echo "⚠️  WARNING: No dSYMs found — Crashlytics traces will be unreadable"
fi
echo "✅ dSYM verification complete"

# 4. Verify no kDebugMode guards around collection-enable calls
if grep -rn "kDebugMode.*setAnalyticsCollectionEnabled\|kDebugMode.*setCrashlyticsCollectionEnabled\|kDebugMode.*setPerformanceCollectionEnabled" lib/; then
  echo "❌ ERROR: Found kDebugMode guard around collection-enable call"
  exit 1
fi
echo "✅ No kDebugMode guards on collection-enable calls"

echo "--- Observability verification passed ---"
```

#### D8. Create wiring test file

**Create new file:** test/services/observability_wiring_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/app_analytics_service.dart';
import 'package:ash_trail/services/app_performance_service.dart';
import 'package:ash_trail/logging/app_logger.dart';

/// Tests that verify the observability wiring works correctly
/// without Firebase (all guards return false, operations still execute).
void main() {
  group('Observability Wiring', () {
    group('AppLogger.onErrorLog callback', () {
      test('callback is null by default', () {
        expect(AppLogger.onErrorLog, isNull);
      });

      test('callback can be set and invoked', () {
        String? capturedName;
        String? capturedMessage;

        AppLogger.onErrorLog = (name, message) {
          capturedName = name;
          capturedMessage = message;
        };

        // Simulate what _BreadcrumbLogOutput would do
        AppLogger.onErrorLog!('TestLogger', 'Something went wrong');

        expect(capturedName, 'TestLogger');
        expect(capturedMessage, 'Something went wrong');

        // Clean up
        AppLogger.onErrorLog = null;
      });
    });

    group('Service singletons', () {
      test('AppAnalyticsService is singleton', () {
        expect(
          identical(AppAnalyticsService.instance, AppAnalyticsService()),
          true,
        );
      });

      test('AppPerformanceService is singleton', () {
        expect(
          identical(AppPerformanceService.instance, AppPerformanceService()),
          true,
        );
      });
    });

    group('Guard behavior without Firebase', () {
      test('analytics initialize is no-op without Firebase', () async {
        // Firebase.apps.isEmpty == true in tests → should return immediately
        await AppAnalyticsService.instance.initialize();
        // No exception → success
      });

      test('analytics logEvent is no-op without Firebase', () async {
        await AppAnalyticsService.instance.logEvent('test_event');
        // No exception → success
      });

      test('performance trace executes callback without Firebase', () async {
        final result = await AppPerformanceService.instance.trace(
          'test', () async => 42,
        );
        expect(result, 42);
      });

      test('performance startTrace returns null without Firebase', () async {
        final trace = await AppPerformanceService.instance.startTrace('test');
        expect(trace, isNull);
      });
    });

    group('Error propagation through traces', () {
      test('performance trace rethrows exceptions', () async {
        expect(
          () => AppPerformanceService.instance.trace(
            'failing', () async => throw StateError('boom'),
          ),
          throwsStateError,
        );
      });

      test('analytics does not throw on logEvent failure', () async {
        // With no Firebase, logEvent should be a silent no-op
        await AppAnalyticsService.instance.logEvent(
          'test', parameters: {'key': 'value'},
        );
        // No exception → success
      });
    });
  });
}
```

#### D9. TestFlight analytics debugging checklist

After deploying a TestFlight build, verify all three pillars are reporting:

**Pre-deploy (on development machine):**
1. `grep -rn 'kDebugMode.*Collection' lib/` → must return zero matches
2. `grep -rn 'setAnalyticsCollectionEnabled\|setCrashlyticsCollectionEnabled' lib/` → confirm both are called unconditionally
3. `flutter analyze` → no new warnings
4. `flutter test` → all tests pass

**Post-deploy (on TestFlight device):**
1. **Crashlytics:** Force a crash with `FirebaseCrashlytics.instance.crash()` in a debug build first. Verify it appears in Firebase Console within 5 minutes. Then remove the test crash and deploy release.
2. **Analytics:** Add `-FIRDebugEnabled` launch argument in Xcode scheme → run on device → open Firebase Console > Analytics > DebugView → confirm events appear in real-time. Remove `-FIRDebugEnabled` before TestFlight archive.
3. **Performance:** Open Firebase Console > Performance > check for `_app_start` trace and network traces within 12 hours of first TestFlight launch (Performance data is not real-time).
4. **Breadcrumbs:** Trigger an error condition → check Crashlytics report → verify "Logs" tab shows `[ServiceName] error message` breadcrumbs from `_BreadcrumbLogOutput`.

**TestFlight-specific (post-upload):**
1. Install TestFlight build on physical device
2. Launch app, sign in, create a log, trigger sync
3. Wait 30 minutes (Analytics batches in release mode)
4. Check Firebase Console:
   - Analytics > Events: `app_open`, `login`, `log_created` visible
   - Crashlytics > Issues: any test crashes visible with dSYM-decoded stack traces
   - Performance > Traces: `_app_start` visible

---

### Verification

**After each part, run:**
```bash
flutter analyze   # no new warnings
flutter test      # existing tests pass
```

**Exception handling (Part A):**
- Force a sync failure → confirm it appears in Crashlytics with `error_category: sync` custom key
- Force location permission denial → confirm `error_category: platform`
- Trigger the same error 10 times → verify only 1 Crashlytics report (dedup guard)
- Intentionally break a widget build → confirm custom error card appears (not red screen)
- Verify no raw `e.toString()` in UI: `grep -rn 'e\.toString\|error\.toString' lib/screens/ lib/widgets/`

**Analytics (Part B):**
- Add `-FIRDebugEnabled` to Xcode scheme launch arguments
- Open Firebase Analytics DebugView
- Cold-launch → confirm `app_open` event
- Sign in → confirm `login` event with `method` parameter
- Create a log → confirm `log_created` event
- Trigger sync → confirm `sync_completed` with counts
- Switch accounts → confirm `account_switched` event
- Navigate to Analytics tab → confirm `screen_view` with `analytics` screen name
- Check user properties: `account_count`, `total_log_count`

**Performance (Part C):**
- Open Firebase Performance console
- Cold-launch → confirm `_app_start` trace (auto-captured)
- Confirm per-phase startup traces: `startup_crashlytics`, `startup_hive`, `startup_shared_prefs`
- Trigger sync → confirm `sync` trace with `sync_type`, `success`, `records_synced` attributes/metrics
- Cloud Function call → confirm `token_refresh` custom trace appears
- Sign in with Google → confirm `google_sign_in` trace with timing
- Check automatic HTTP network traces for the Cloud Function URL
- Check automatic screen rendering traces appear

**Wiring (Part D):**
- Trigger a `_log.e(...)` call → confirm breadcrumb appears in Crashlytics report "Logs" tab
- Trigger an error via `ErrorReportingService` → confirm `error_occurred` analytics event fires alongside Crashlytics report
- Verify init sequence: check device logs for ordered init messages
- Run: `grep -rn 'kDebugMode.*CollectionEnabled' lib/` → zero matches

**Always-on validation (cross-cutting):**
- `grep -rn 'kDebugMode.*setAnalyticsCollectionEnabled\|kDebugMode.*setCrashlyticsCollectionEnabled\|kDebugMode.*setPerformanceCollectionEnabled' lib/` → ZERO matches
- Build with `--release` → install on device → confirm events reach Firebase Console
- Check `scripts/deploy_testflight.sh` exits non-zero if any guard check fails
- After TestFlight upload: install on device, use app for 5 minutes, wait 30 minutes, verify all three Firebase Console sections show data

**Privacy / App Store (Part 0):**
- Archive an iOS build → no App Store Connect privacy warnings
- Confirm `PrivacyInfo.xcprivacy` is in the bundle: `unzip -l build/ios/ipa/*.ipa | grep Privacy`
- After TestFlight build: open Crashlytics console → verify stack traces show readable method names (dSYM upload works)

---

### Decisions
- **Firebase-only stack** — Analytics + Performance + Crashlytics. All share the Firebase console, are free-tier compatible, no additional accounts or billing.
- **All-platform, not iOS-specific** — Same code paths for iOS/Android/web/macOS. iOS-specific context via Crashlytics custom keys + dSYM uploads.
- **No ATT prompt** — `NSPrivacyTracking = false`. IDFA attribution has zero value at low user count.
- **Always-on collection, all build modes** — `setAnalyticsCollectionEnabled(true)` and `setCrashlyticsCollectionEnabled(true)` are called unconditionally. NO `kDebugMode` gates around any collection-enable call. The deploy script verifies this invariant before every TestFlight upload. Analytics events fire in debug, profile, AND release. TestFlight builds include the same analytics pipeline as App Store builds.
- **Explicit over implicit** — Even though Firebase defaults to collection-enabled, we call `setAnalyticsCollectionEnabled(true)` and `setCrashlyticsCollectionEnabled(true)` explicitly. This protects against future SDK default changes, `GoogleService-Info.plist` overrides, or accidental configuration drift.
- **Lazy init for Analytics** — init after Firebase Core; lightweight, no cold-start impact. Performance SDK auto-captures `_app_start` natively.
- **Test isolation** — `Firebase.apps.isEmpty` guard in all new services. In unit tests, Firebase is never initialized, so all telemetry methods are silent no-ops. The guard checks Firebase initialization, NOT build mode — this is what makes always-on collection safe (tests are isolated by architecture, not by `kDebugMode`).
- **Report-once deduplication** — `Set<String>` of error codes per cold start. Prevents sync-loop flooding.
- **Tiered instrumentation** — 5 critical services (Tier 1), 4 lower-priority (Tier 2), 5 deferred (Tier 3). Avoid instrumentation debt on dead-code paths.
- **9 analytics events, 8 custom traces** — validate pipeline end-to-end before expanding. Wrapper services make expansion trivial later.
- **Skip in-app diagnostics UI** — Firebase Console is the dashboard at low user count.
- **dSYM upload is step zero** — without it, Crashlytics on iOS release builds produces unreadable traces.
- **Privacy manifest before analytics** — Apple rejects binaries without `PrivacyInfo.xcprivacy`.
- **Crashlytics velocity + regression alerts** — free, Firebase Console, emails on crash spikes.
- **Logger breadcrumbs via LogOutput, not per-call-site** — The `_BreadcrumbLogOutput` class intercepts ALL error-level logs automatically. No existing code needs to add `CrashReportingService.logMessage()` calls — the wiring is transparent.
- **Deploy-time verification** — `deploy_testflight.sh` runs automated checks (`kDebugMode` guards, `PrivacyInfo.xcprivacy`, dSYMs) and fails the build if any observability invariant is violated.

### Cost & Quota Awareness
All three Firebase products have **no usage caps** for this app's data volumes. Budget alerts in Firebase Console should be enabled as a guardrail. Firebase SDKs queue events offline and flush on reconnect — dashboards will show post-reconnect spikes, not real-time issues.

> **Offline behavior:** When the device is offline, Analytics, Crashlytics, and Performance all queue data locally and flush on reconnect. This means: (1) dashboards may show delayed spikes after periods of no connectivity, (2) event timestamps reflect the *time of occurrence*, not upload time, (3) no special offline-suppression code is needed — the SDKs handle this transparently.

**Always-on impact:** Enabling analytics in debug mode means development sessions generate events. This is intentional — it validates the pipeline during development. At current user counts (single developer + TestFlight testers), this adds negligible volume. If needed later, filter by `app_instance_id` or `user_id` dimension in BigQuery exports.

### Execution Order
1. **Part 0** (prerequisites) — dSYM upload, privacy manifest, Crashlytics alerts
2. **Part A** (exception handling) — ErrorWidget.builder, dedup guard, Tier 1 services, repositories, providers, error sanitization, device context, ErrorBoundary
3. **Part B** (analytics) — dependency, AppAnalyticsService, screen tracking, RouteSettings, service instrumentation, test file, NavigatorObserver, Riverpod
4. **Part C** (performance) — dependency, AppPerformanceService, token_service traces, startup tracing, sync tracing, auth tracing, account switching, exports, test file
5. **Part D** (wiring) — ErrorReporting→Analytics bridge, Logger→Crashlytics breadcrumbs, Riverpod providers, init sequence, Crashlytics always-on fix, Analytics always-on, deploy script verification, wiring tests, TestFlight checklist

### File Change Summary

| Action | File | Part |
|--------|------|------|
| Edit | scripts/deploy_testflight.sh | 0.1, D7 |
| Create | ios/Runner/PrivacyInfo.xcprivacy | 0.2 |
| Edit | ios/Runner.xcodeproj/project.pbxproj | 0.2 |
| Edit | lib/main.dart | A1, A7, B3, C4, D4 |
| Edit | lib/services/error_reporting_service.dart | A2, D1 |
| Edit | lib/services/sync_service.dart | A3, B4, C5 |
| Edit | lib/services/account_session_manager.dart | A3 |
| Edit | lib/services/location_service.dart | A3 |
| Edit | lib/services/token_service.dart | A3, C3 |
| Edit | lib/services/account_integration_service.dart | A3 |
| Edit | lib/repositories/account_repository_hive.dart | A4 |
| Edit | lib/providers/account_provider.dart | A5, C7 |
| Edit | lib/providers/log_record_provider.dart | A5 |
| Edit | lib/providers/home_widget_config_provider.dart | A5 |
| Edit | lib/providers/sync_provider.dart | A5 |
| Edit | lib/providers/auth_provider.dart | A5 |
| Edit | lib/screens/signup_screen.dart | A6 |
| Edit | lib/screens/profile_screen.dart | A6 |
| Edit | lib/screens/home_screen.dart | A6 |
| Edit | lib/screens/multi_account_diagnostics_screen.dart | A6 |
| Edit | lib/screens/logging_screen.dart | A6, B3 |
| Edit | lib/screens/accounts_screen.dart | A6, B5 |
| Edit | lib/screens/history_screen.dart | A6 |
| Edit | lib/screens/analytics_screen.dart | A6 |
| Edit | lib/services/crash_reporting_service.dart | A7, D5 |
| Edit | pubspec.yaml | A7, B1, C1 |
| Create | lib/widgets/error_boundary.dart | A8 |
| Create | lib/services/app_analytics_service.dart | B2, D6 |
| Edit | lib/navigation/main_navigation.dart | B3 |
| Edit | lib/screens/login_screen.dart | B5 |
| Edit | lib/widgets/edit_log_record_dialog.dart | B5 |
| Create | test/services/app_analytics_service_test.dart | B6 |
| Edit | lib/services/auth_service.dart | B4, C6 |
| Edit | lib/services/log_record_service.dart | B4 |
| Edit | lib/services/export_service.dart | C8 |
| Create | lib/services/app_performance_service.dart | C2 |
| Create | test/services/app_performance_service_test.dart | C9 |
| Edit | lib/logging/app_logger.dart | D2 |
| Create | lib/providers/observability_providers.dart | D3 |
| Create | test/services/observability_wiring_test.dart | D8 |

**Total:** 7 new files created, ~30 files edited.
