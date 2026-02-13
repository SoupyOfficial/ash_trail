## Plan: Keep Gmail Logged In on iOS Simulator

---

### Problem Statement

Google Sign-In on iOS uses `ASWebAuthenticationSession`, a system-level Safari view controller that **no testing framework can automate** (see [Framework Comparison](#framework-comparison-for-ios-simulator-testing) below). The current `_handleGoogleAccountPicker()` in `integration_test/flows/gmail_login_flow.dart` waits 60 seconds for manual interaction every time. The goal is to keep Google Sign-In state intact across repeated Patrol runs in the same iOS simulator session so that the manual step is performed **once** and all subsequent test runs short-circuit past it.

### Scope and Constraints

| Constraint | Value |
|---|---|
| Platform | iOS simulator only (Android out of scope) |
| Patrol mode | Default (no `--full-isolation`, which uninstalls the app and wipes Keychain) |
| Persistence target | Across repeated `patrol test` runs in the same simulator session |
| Test accounts | `ashtraildev3@gmail.com` (account 4), `soupsterx@live.com` (account 5) -- defined in `integration_test/helpers/config.dart` |
| Simulators | iPhone 13 Pro (`84A035C2`), iPhone 16 Pro Max (`0A875592`) |
| Bundle ID | `com.soup.smokeLog` |
| Patrol version | `^3.13.0` (pubspec.yaml) -- latest stable is 4.1.1 |
| Flutter SDK | `^3.7.0` |
| Auth packages | `firebase_auth: ^5.3.4`, `google_sign_in: ^6.2.2` |

---

### Framework Comparison for iOS Simulator Testing

The core blocker is `ASWebAuthenticationSession` -- a system-presented Safari view controller used by `google_sign_in` on iOS. It runs in a **separate process** from the app, shares Safari's cookie jar, and provides no DOM access to the host app.

#### Why ASWebAuthenticationSession Cannot Be Automated

`ASWebAuthenticationSession` (introduced iOS 12, replacing `SFAuthenticationSession`) is Apple's recommended OAuth flow for native apps. It is **not a WKWebView** -- it is a system browser sheet managed by `AuthenticationServices.framework`. Key limitations:

- Runs in a separate process (`com.apple.AuthenticationServicesAgent`)
- Content is rendered by Safari, not the host app
- XCUITest can see alert-level UI elements but **cannot reliably type into web form fields** inside the session
- `accessibilityIdentifier` / `accessibilityLabel` are set by the web page (Google's HTML), not the native app, making them unpredictable across Google UI versions
- Google's sign-in page uses reCAPTCHA, dynamic JS, and anti-bot detection that interfere with automated input
- Apple explicitly designed this as a security boundary -- no app process can read or write into the session

#### Framework Comparison Table

| Framework | Type | Flutter Support | Native View Automation | Can Automate ASWebAuthenticationSession? | Notes |
|---|---|---|---|---|---|
| **Patrol (current)** | Flutter + XCUITest | First-class (Dart) | Yes (via `NativeAutomator` -> XCUITest) | **No** -- can see elements but cannot reliably interact with Safari-process web fields | Best Flutter-native option. XCUITest under the hood. Hot-restart preserves platform state. Already integrated in this project. |
| **Maestro** | YAML-driven, accessibility-tree | First-class (since Flutter 3.19, via `Semantics` widget) | Yes (via accessibility tree + WebView support) | **No** -- claims WebView support but ASWebAuthenticationSession is not a WebView; it is a system browser sheet | Simpler YAML syntax, no Dart compilation needed. No physical iOS device support. Cannot run Dart code for setup/teardown. Would require rewriting all tests from Dart to YAML. |
| **Appium + XCUITest driver** | WebDriver protocol | Via `appium-flutter-driver` (limited, community-maintained) | Yes (XCUITest under the hood) | **No** -- same XCUITest limitation applies | Most flexible cross-platform, but Flutter integration is second-class. Complex setup (Node.js + Java server + driver management). Good for mixed native/web apps, overkill for pure Flutter. |
| **Detox** | Gray-box (React Native) | **None** | React Native only | N/A | Not applicable -- React Native only framework. Cannot test Flutter apps. |
| **flutter_test + integration_test (no Patrol)** | Flutter framework testing | Built-in | **No** -- cannot interact with native UI at all | **No** -- zero native UI access | Fastest for widget/logic tests but useless for native auth flows, permission dialogs, or anything outside the Flutter rendering layer. |
| **XCUITest (raw)** | Apple native UI testing | None (treats Flutter as opaque `FlutterView`) | Full native access | **Partially** -- can tap buttons in the sheet but cannot reliably fill Google's dynamic web forms due to reCAPTCHA and anti-bot measures | Would require maintaining a separate Xcode test target. No Flutter widget inspection. Could supplement Patrol for specific native-only scenarios. |

#### Verdict

**No framework can reliably automate Google's OAuth flow via ASWebAuthenticationSession.** This is an Apple + Google limitation, not a framework limitation. The correct approach is:

1. **Keep Patrol** -- it remains the best framework for Flutter + native iOS testing, and is already deeply integrated
2. **Seed the simulator once** with manual Google Sign-In, then rely on state persistence across Patrol runs
3. **Use programmatic Firebase Auth** as a fallback for CI/headless environments (sign in with custom tokens, bypassing the native OAuth flow entirely)

Switching frameworks would add significant integration complexity without solving the core problem.

---

### Background Research

#### State Persistence Model in Default Patrol Mode

| Store | Survives Hot-Restart? | Survives App Reinstall? | Survives `--full-isolation`? | Survives Simulator Reboot? | Survives Simulator Erase? |
|---|---|---|---|---|---|
| iOS Keychain (Firebase Auth refresh token) | Yes | Yes | **No** (uninstalls app) | Yes | **No** |
| Hive local DB (`~/Library/.../Documents/`) | Yes | **No** | **No** | Yes | **No** |
| SharedPreferences (`NSUserDefaults`) | Yes | **No** | **No** | Yes | **No** |
| ASWebAuthenticationSession cookies (Safari) | Yes | Yes (Safari process) | Yes (Safari process) | Yes | **No** |
| Dart static variables | **No** (reset on hot-restart) | **No** | **No** | **No** | **No** |

Key insight: In **default mode**, Patrol hot-restarts the app between `patrolTest` blocks (documented in `login_flow.dart` line 60). This resets Dart statics but preserves **all platform state** including Keychain, Hive DBs, SharedPreferences, and Safari cookies. Google Sign-In state survives because:

1. Firebase Auth persists its refresh token to the iOS Keychain
2. `ASWebAuthenticationSession` shares cookies with Safari, stored at the OS level
3. Default Patrol mode does **not** uninstall the app
4. `ensureGmailLoggedIn()` already detects `GmailAppScreen.home` and short-circuits (no login needed)

#### Current Gmail Flow Architecture

The existing `gmail_login_flow.dart` already has good state detection:

- `detectGmailScreen()` probes for `nav_home` (home), `Welcome to Ash Trail` (welcome), `email-input` (login), or `CircularProgressIndicator` (loading)
- `ensureGmailLoggedIn()` switches on the detected screen and only triggers the native Google Sign-In flow when on Welcome or Login screens
- `_handleGoogleAccountPicker()` logs the manual interaction requirement and waits 60 seconds
- `ensureGmailLoggedOut()` programmatically signs out via `FirebaseAuth.instance.signOut()` + `AccountService().deactivateAllAccounts()`

The gap: there is no **Firebase Auth pre-check** before hitting the UI. If `FirebaseAuth.instance.currentUser` is non-null, we can skip UI detection entirely.

#### Patrol 3.x vs 4.x Differences

| Feature | Patrol 3.x (`^3.13.0`, current) | Patrol 4.x (latest: 4.1.1) |
|---|---|---|
| Native API | `NativeAutomator` via `$.native` | `PlatformAutomator` via `$.native2` |
| Selector API | `NativeAutomatorConfig` | `PlatformSelector` with builder pattern |
| ASWebAuthenticationSession | Cannot automate | Cannot automate (same limitation) |
| Hot-restart behavior | Resets Dart, keeps platform state | Same |
| Breaking changes | N/A | API surface renamed; migration guide available |

Upgrading would not solve the ASWebAuthenticationSession problem but is recommended for long-term maintenance. Not in scope for this plan.

---

### Common Flutter + Patrol Testing Issues and Solutions

These are issues frequently encountered in the Flutter/Patrol ecosystem, documented with solutions specific to this project's architecture.

#### Issue 1: `pumpAndSettle` Hangs Indefinitely

**Symptoms:** Test freezes and never completes. The test runner appears stuck with no error output.

**Root Causes:**
- Perpetual animations (`AnimatedBuilder`, `AnimationController` in repeat mode)
- Active `Timer.periodic` instances (e.g., polling, countdown timers)
- Open `StreamSubscription` that keeps emitting
- `CircularProgressIndicator` or shimmer loading widgets that never resolve
- Riverpod `StreamProvider` or `FutureProvider` that stays in loading state

**Solutions (project-specific):**
- Replace `pumpAndSettle()` with `pump(Duration(seconds: 1))` or bounded loops (already the pattern in this codebase)
- Use `pumpUntilFound()` / `pumpUntilGone()` helpers from `integration_test/helpers/pump.dart` -- these use manual pumping and avoid the settle trap
- Use `settle($, frames: 20)` for post-navigation settling -- pumps a fixed number of frames
- Set explicit settle timeout: `await $.pumpAndSettle(timeout: Duration(seconds: 10))`
- Identify the offending widget with `debugDumpApp()` -- look for `_ticker` or `Timer` in the output
- The `HomeQuickLogWidget` hold-to-record animation is a known offender -- always use `pumpUntilFound` after navigating to Home

**Industry Best Practice:** Avoid `pumpAndSettle` entirely in integration tests. Use explicit waits for specific widgets instead. The Flutter team recommends `pump` + finder checks over `pumpAndSettle` for apps with animations.

#### Issue 2: Native Permission Dialogs Block Tests

**Symptoms:** Tests hang when iOS shows location, notification, camera, or tracking permission dialogs. The Flutter widget tree is obscured by the native overlay.

**Root Causes:**
- `Geolocator.requestPermission()` called on first launch triggers iOS location dialog
- Push notification permission requested on startup
- Camera/microphone permission for media features
- iOS App Tracking Transparency dialog

**Solutions (project-specific):**
- Use `handleNativePermissionDialogs($)` from `pump.dart` -- already checks `$.native.isPermissionDialogVisible()` and calls `$.native.grantPermissionWhenInUse()`
- Use `handlePermissionDialogs($)` which handles both the app's Flutter location dialog AND the native iOS dialog in sequence
- The app shows a custom Flutter `AlertDialog` for Location Access before triggering the native one -- `handleLocationDialog($)` taps "Not Now" to dismiss it
- In CI, pre-configure simulator privacy settings: `xcrun simctl privacy <uuid> grant location-always com.soup.smokeLog`
- Call `handlePermissionDialogs($)` after every navigation that might trigger permissions (login, home screen entry)

**Industry Best Practice:** Always handle permissions proactively at the start of each test, not reactively. Pre-grant permissions in CI via `simctl privacy` to avoid flakiness.

#### Issue 3: Test Order Dependencies / Shared State Leaks

**Symptoms:** Tests pass individually but fail when run together. One test's side effects corrupt another test's expected state. Account switching tests are particularly susceptible.

**Root Causes:**
- Firebase Auth state persists across hot-restarts (by design)
- Hive boxes retain data across hot-restarts
- Riverpod providers maintain stale references after auth state changes
- Snackbar queue from a previous test blocking UI interaction in the next test

**Solutions (project-specific):**
- Use `ensureLoggedOut($)` or `ensureGmailLoggedOut($)` in `setUp`/`tearDown` to reset auth state when needed
- Use `clearSnackbars($)` from `pump.dart` before tests that check snackbar content
- Each `patrolTest` gets a fresh Dart state (hot-restart), but platform state persists -- design tests accordingly
- Use `debugDumpAccountState($, 'label')` to trace exactly which account is active at each step
- The `waitForProviderPropagation($, expectedEmail)` helper polls until Riverpod reflects the expected account
- For Gmail multi-account tests, explicitly verify the active account email matches expectations at each step using `debugLogActiveUser('step')`

**Industry Best Practice:** Each test should be able to run independently. Use explicit setup/teardown rather than relying on test execution order. The `ensureGmailLoggedIn`/`ensureGmailLoggedOut` pattern is correct.

#### Issue 4: Provider State Lag After Authentication

**Symptoms:** After login or account switch, the home screen does not reflect the new auth state immediately. Tests fail because widgets show stale data or the old account's logs.

**Root Causes:**
- Firebase Auth state change propagates asynchronously through `authStateChanges()` stream
- Riverpod `StreamProvider` for `activeAccountProvider` needs time to process the new value
- Hive write is synchronous but the Riverpod invalidation is async
- UI rebuild happens on the next frame after provider notification

**Solutions (project-specific):**
- Use `waitForProviderPropagation($, expectedEmail)` -- polls `activeAccountProvider` until it matches
- Add `await settle($, frames: 20)` after auth state changes (pumps 20 frames with 250ms gaps = 5 seconds)
- Verify with `debugLogActiveUser('after-login')` that Firebase uid, Hive userId, and Provider uid all match
- Use `debugDumpLogCreationPipeline($, 'label')` for comprehensive state chain verification
- The cross-check in `debugDumpLogCreationPipeline` (section [4]) detects Firebase/Hive/Provider mismatches

**Industry Best Practice:** Never assume auth state is immediately available after `signIn()` returns. Always wait for the provider/state management layer to propagate. Use explicit polling with timeout rather than fixed delays.

#### Issue 5: Simulator Reset/Erase Wipes All State

**Symptoms:** After "Erase All Content and Settings" or `xcrun simctl erase`, all auth state is gone and manual Gmail login is required again.

**Root Causes:**
- `xcrun simctl erase` deletes the entire simulator data partition including Keychain, app data, Safari cookies
- Xcode version upgrades can reset simulators silently
- Accidentally running with `--full-isolation` uninstalls and reinstalls the app, wiping Keychain entries

**Solutions:**
- **Never erase** the simulator during a testing session -- document this clearly for all team members
- Use `xcrun simctl shutdown` + `xcrun simctl boot` for soft resets (preserves all data)
- After an erase, follow the seeding procedure: install app, run once, manually complete Google Sign-In
- Mark seeded simulators with a naming convention (e.g., rename via Xcode to include "Seeded")
- Add a preflight script that checks if auth state exists before running the suite (Step 3)

**Industry Best Practice:** Treat the seeded simulator as a persistent test fixture. Document exactly which simulators are seeded and maintain a runbook for re-seeding.

#### Issue 6: Firebase Auth Token Expiration

**Symptoms:** Tests fail with auth errors after the simulator has been idle for >1 hour. Firebase ID tokens expire after 60 minutes.

**Root Causes:**
- Firebase ID tokens have a 1-hour TTL
- The refresh token (stored in Keychain) is long-lived but requires a network call to exchange for a new ID token
- If the app hasn't been launched in a while, `currentUser` may be non-null but the token is expired
- Offline simulators cannot refresh tokens

**Solutions (project-specific):**
- Firebase SDK automatically refreshes tokens using the Keychain-stored refresh token on app startup
- `ensureGmailLoggedIn()` already handles this: if the app lands on Home, the token was refreshed successfully
- If refresh fails (network issue), the app will redirect to Welcome/Login screen, and `ensureGmailLoggedIn()` will detect that
- For CI, use Firebase Admin SDK to generate custom tokens with configurable TTL
- Add a preflight check: `FirebaseAuth.instance.currentUser?.getIdToken()` -- if this throws, re-seed is needed

**Industry Best Practice:** Always verify token validity at the start of a test session, not just check `currentUser != null`. Call `getIdToken()` to force a refresh attempt.

#### Issue 7: Patrol Cannot Tap Inside OAuth WebView

**Symptoms:** `$.native.tap()` on Google Sign-In form elements fails, taps the wrong location, or does nothing. The native automator can see the ASWebAuthenticationSession sheet but cannot interact with its web content.

**Root Causes:**
- `ASWebAuthenticationSession` runs in a separate process (`com.apple.AuthenticationServicesAgent`)
- XCUITest can query the accessibility tree of the sheet but web form fields have unreliable accessibility identifiers
- Google's sign-in page dynamically generates UI elements and uses anti-bot measures (reCAPTCHA)
- Coordinate-based tapping fails because Google's UI layout varies by account state

**Solutions:**
- **Do not attempt to automate ASWebAuthenticationSession** -- this is the core finding from the framework comparison
- Seed the account manually once and rely on state persistence
- For CI, use programmatic Firebase Auth with custom tokens: `FirebaseAuth.instance.signInWithCustomToken(token)` -- bypasses OAuth entirely
- The existing `_handleGoogleAccountPicker()` correctly logs "MANUAL INTERACTION REQUIRED" and waits 60 seconds
- On subsequent runs, `ensureGmailLoggedIn()` detects `GmailAppScreen.home` and skips the native flow entirely

**Industry Best Practice:** For OAuth flows that involve third-party web UI (Google, Apple, Facebook), always use token-based test authentication in CI and reserve manual OAuth for initial device seeding only.

#### Issue 8: Screenshot Capture Fails in Patrol iOS Tests

**Symptoms:** `takeScreenshot()` returns null or produces blank images. Debug logs show "Could not find RepaintBoundary."

**Root Causes:**
- Patrol wraps the app differently than `integration_test` -- the `RepaintBoundary` may not be at the expected location
- `toImage()` can fail if the render tree hasn't completed layout (e.g., during transitions)
- iOS simulator GPU rendering differences from physical devices

**Solutions (project-specific):**
- The `takeScreenshot()` in `pump.dart` already handles this with a fallback chain: tries `MaterialApp` -> `WidgetsApp` -> any `RepaintBoundary`
- Always call `await $.pump(Duration(milliseconds: 100))` before screenshot to ensure layout is complete
- For native screenshots (e.g., during ASWebAuthenticationSession), use `xcrun simctl io <uuid> screenshot` from the host
- Screenshots are saved to `/tmp/ash_trail_screenshots/` with auto-incrementing numeric prefixes

#### Issue 9: `print()` Output Not Visible in Patrol iOS Tests

**Symptoms:** `print()` and `debugPrint()` statements in test code produce no output in the terminal when running Patrol on iOS.

**Root Causes:**
- Patrol iOS tests compile to a native XCUITest runner -- Dart's `print()` goes to the app process stdout, which is separate from the host terminal
- `developer.log()` also may not reach the host terminal

**Solutions (project-specific):**
- All diagnostic output is written to file via `testLog()` in `pump.dart` -- writes to `/tmp/ash_trail_test_diagnostics.log` (or project `logs/` directory)
- The `_flowLog()` functions in `gmail_login_flow.dart` and `login_flow.dart` similarly write to `/tmp/ash_trail_test_diagnostics.log`
- After a test run, inspect the log file: `cat /tmp/ash_trail_test_diagnostics.log`
- `testLog()` also attempts `print()` and `developer.log()` as a best-effort fallback

**Industry Best Practice:** Always use file-based logging for Patrol iOS tests. Never rely solely on console output.

#### Issue 10: Riverpod Container Not Found in Widget Tree

**Symptoms:** `debugDumpAccountState()` or `waitForProviderPropagation()` logs "Could not find ProviderContainer in widget tree."

**Root Causes:**
- `_findProviderContainer($)` walks the widget tree looking for `UncontrolledProviderScope`
- If the app hasn't fully launched or is in a transition state, the scope may not be mounted yet
- Hot-restart can temporarily leave the tree in a partial state

**Solutions (project-specific):**
- Ensure `await app.launch()` has completed and a known screen is visible before calling diagnostic helpers
- Add `await settle($, frames: 10)` before calling `debugDumpAccountState()`
- The helper returns `null` gracefully -- callers should check for null and log appropriately
- In most cases, the container is available after `pumpUntilFound(find.byKey(Key('nav_home')))` succeeds

---

### Implementation Steps

#### Step 1: Add Firebase Auth Pre-Check to `ensureGmailLoggedIn()`

**File:** `integration_test/flows/gmail_login_flow.dart`

Before hitting the UI detection path, check `FirebaseAuth.instance.currentUser` directly. This is the fastest short-circuit -- if the user is already authenticated with the expected email, skip all UI interaction.

Changes:
- At the top of `ensureGmailLoggedIn()`, check `FirebaseAuth.instance.currentUser`
- If `currentUser` is non-null and email matches `selectAccountEmail` (or default `testEmail4`), verify token is valid via `getIdToken()`, log the short-circuit, and return
- If email does not match, fall through to existing UI-based detection
- Add clear diagnostic logging at each decision point

#### Step 2: Add Firebase Auth Programmatic Fallback (CI Only)

**File:** New `integration_test/helpers/auth_bypass.dart`

For CI environments where no human is present to manually sign in:
- Accept a Firebase custom token via `--dart-define=FIREBASE_TEST_TOKEN=...`
- Call `FirebaseAuth.instance.signInWithCustomToken(token)` to bypass OAuth entirely
- This is the **industry-standard approach** for CI testing with Firebase Auth (recommended by Firebase docs)
- Guard with `const String.fromEnvironment('FIREBASE_TEST_TOKEN')` -- empty string means manual mode

Server-side: use Firebase Admin SDK (`firebase-admin` npm package or Python SDK) to generate custom tokens for the test accounts. Tokens can be generated in CI pipeline and passed as build args.

#### Step 3: Create Preflight Validation Script

**File:** `scripts/preflight_gmail_check.sh`

A script to run before `patrol test` that validates the simulator is ready:
- Verify target simulator is booted (`xcrun simctl list devices | grep Booted`)
- Verify app is installed (`xcrun simctl listapps <uuid> | grep com.soup.smokeLog`)
- Remind user about manual seeding if this is a fresh simulator
- Exit with clear pass/fail status and actionable instructions

#### Step 4: Document Persistence Rules in Testing Guides

**Files:** `docs/testing/E2E_TESTING_GUIDE.md`, `docs/deployment/GMAIL_LOGIN_TEST_GUIDE.md`

Add a dedicated "Gmail Auth Persistence" section covering:
- Why default Patrol mode is required (no `--full-isolation`)
- The state persistence table (what survives hot-restart, reinstall, erase)
- The one-time manual seeding procedure
- When re-seeding is required (after simulator erase, after `--full-isolation`, after Xcode version upgrade)
- Why no framework can automate `ASWebAuthenticationSession` (link to this plan)
- Clear warnings about destructive actions

#### Step 5: Add Auth Persistence Smoke Test

**File:** `integration_test/gmail_multi_account_test.dart`

Add a lightweight first test that verifies auth state exists before running the full suite:
- Check `FirebaseAuth.instance.currentUser` -- if non-null, log success and continue
- If null, log a clear message: "No cached auth -- manual seeding required on first run"
- Don't fail -- just log. The first actual login test will handle the manual flow via `ensureGmailLoggedIn()`

#### Step 6: Add Patrol Caveats to Login Flow Documentation

**File:** `integration_test/flows/login_flow.dart`

Expand the existing doc comment on `launchAndDetect()` (line 60) to include:
- Explicit list of what resets (Dart statics) and what persists (Keychain, Hive, SharedPrefs, Safari cookies)
- Warning: `--full-isolation` destroys all persisted state
- Warning: `xcrun simctl erase` destroys all persisted state
- Reference to the Gmail Login Test Guide for re-seeding after state loss

#### Step 7: Create Simulator Session Seeding Script

**File:** `scripts/seed_gmail_simulator.sh`

A convenience script for one-time simulator seeding:
- Boot the target simulator (default: iPhone 16 Pro Max `0A875592`)
- Build and install the app (`flutter build ios --simulator` + `xcrun simctl install`)
- Launch the app (`xcrun simctl launch`)
- Print instructions for manual Gmail sign-in
- Wait for user confirmation (press Enter to continue)
- Optionally run the smoke test to verify auth state was persisted
- Print summary of seeded state

---

### Verification Criteria

| Test | Expected Result |
|---|---|
| Run Gmail multi-account suite, then run it again immediately | Second run skips manual Google Sign-In entirely (auth persisted in Keychain). `_flowLog` shows "Already on Home" or Firebase pre-check short-circuit. |
| Run with `--full-isolation` flag | Auth state is destroyed; manual re-seeding required. `ensureGmailLoggedIn()` detects Welcome/Login screen. |
| Reboot simulator (`xcrun simctl shutdown` + `boot`) | Auth state persists (Keychain survives reboot). Second run skips manual sign-in. |
| Erase simulator (`xcrun simctl erase`) | Auth state destroyed; manual re-seeding required. |
| Run `ensureGmailLoggedIn()` on fresh simulator | Detects missing auth, triggers 60s manual wait with clear log instructions. |
| Run with `FIREBASE_TEST_TOKEN` dart-define (CI) | Signs in programmatically, no manual interaction needed. |
| Firebase token expired (idle >1hr) | Firebase SDK auto-refreshes on app launch; `ensureGmailLoggedIn()` detects Home screen as normal. |

---

### Decisions

| Decision | Rationale |
|---|---|
| **Stay with Patrol** | Best Flutter-native framework. No alternative solves the ASWebAuthenticationSession problem (see framework comparison). Already deeply integrated with 15+ test files, custom helpers, and CI scripts. |
| **Default Patrol mode only** | `--full-isolation` uninstalls the app and wipes Keychain, destroying auth state. The default mode preserves all platform state across hot-restarts, which is exactly what we need. |
| **iOS simulator only** | Android out of scope for this plan. Android uses a different Google Sign-In flow (Google Play Services intent) which has its own automation challenges. |
| **One-time manual seeding is acceptable** | Industry standard for OAuth testing. Even Google's own testing documentation recommends pre-seeded auth for OAuth flows. Firebase custom tokens provide a fully automated CI alternative. |
| **Firebase custom tokens for CI** | The industry-standard approach for CI testing with Firebase Auth. Avoids the need for any native OAuth automation. Tokens are generated server-side and passed via `--dart-define`. |
| **No custom OAuth mock server** | Firebase custom tokens (Step 2) are sufficient for CI. A full mock OAuth server is over-engineering for current needs and would require modifying production auth code. |
| **Patrol version stays at `^3.13.0`** | Plan works with both 3.x and 4.x. Upgrading is recommended for long-term maintenance but is out of scope for this feature and does not solve the ASWebAuthenticationSession limitation. |
| **No framework switch** | Maestro, Appium, Detox, and raw XCUITest were evaluated. None can automate ASWebAuthenticationSession. Patrol provides the best Flutter integration + native access combination. The migration cost would be significant with no benefit for this specific problem. |
