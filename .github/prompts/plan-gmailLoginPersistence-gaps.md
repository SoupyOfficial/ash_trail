# Implementation Gaps: Gmail Login Persistence Plan

This document identifies every concrete gap an AI agent developer would need to fill to fully implement the plan in `plan-gmailLoginPersistence.prompt.md`.

---

## Step 1: Firebase Auth Pre-Check in `ensureGmailLoggedIn()`

**Plan says:** Add a `FirebaseAuth.instance.currentUser` check at the top of `ensureGmailLoggedIn()`, verify token via `getIdToken()`, short-circuit if email matches.

### Gaps

1. **Email matching logic is underspecified.** The function accepts `selectAccountEmail` as an optional param (defaults to `null`, not `testEmail4`). The plan says "if email matches `selectAccountEmail` (or default `testEmail4`)" but the current code does not import `config.dart` into `gmail_login_flow.dart` — there's no reference to `testEmail4`. The agent needs to decide:
   - Should `gmail_login_flow.dart` import `config.dart` for the default email?
   - Or should the pre-check simply verify `currentUser != null` regardless of email, and let the email match be a caller responsibility?
   - **Recommendation:** Check `currentUser != null` first. If `selectAccountEmail` is provided, also verify `currentUser.email == selectAccountEmail`. If no `selectAccountEmail`, accept any authenticated user. This matches the existing behavior where `selectAccountEmail` is only used to guide the native picker.

2. **`getIdToken()` can throw on network failure.** The plan says "verify token is valid via `getIdToken()`" but doesn't specify error handling. If the simulator is offline or the token refresh fails, should we:
   - Fall through to UI-based detection (recommended — the app may still work with a cached token)?
   - Throw an error?
   - **The agent must wrap `getIdToken()` in a try-catch** and fall through to UI detection on failure.

3. **Hive active account sync.** `FirebaseAuth.instance.currentUser` being non-null does NOT guarantee the Hive `activeAccount` is set. After a hot-restart, Firebase Auth state is restored from Keychain, but the app's `main()` re-initializes Hive from disk. The pre-check should also verify `AccountService().getActiveAccount()` is non-null and matches, or the app will land on Home but with no active account in the provider layer. The plan doesn't address this edge case.

4. **Where exactly to insert the pre-check.** The plan says "at the top of `ensureGmailLoggedIn()`" — this means BEFORE `gmailLaunchAndDetect($)`. But `gmailLaunchAndDetect()` calls `app.launch()` which calls `app.main()`, which initializes Firebase. If we check `FirebaseAuth.instance.currentUser` before `app.launch()`, Firebase won't be initialized yet. **The agent must insert the check AFTER `gmailLaunchAndDetect()` returns but BEFORE the `switch(screen)` block,** or restructure to check Firebase state early in the switch's `home` case.

---

## Step 2: Firebase Auth Programmatic Fallback (`auth_bypass.dart`)

**Plan says:** Create `integration_test/helpers/auth_bypass.dart` that accepts a Firebase custom token via `--dart-define=FIREBASE_TEST_TOKEN=...` and calls `signInWithCustomToken()`.

### Gaps

1. **Token generation is not addressed.** The plan says "use Firebase Admin SDK to generate custom tokens" but doesn't specify:
   - **Which language/runtime** for the token generation script (Node.js? Python? The project already has a `parse_xcresult.py` and the Cloud Function is apparently in JS/TS).
   - **Where the script lives** (e.g., `scripts/generate_test_token.js`? A CI pipeline step?).
   - **Which Firebase service account key** to use (you need a JSON key file for `firebase-admin`).
   - **Where the service account key is stored** (env var? Secrets manager? Local file?).

2. **The project already has `TokenService` and a Cloud Function (`generate_refresh_token`).** The agent should decide: should `auth_bypass.dart` reuse the existing `TokenService.generateCustomToken(uid)` endpoint (which accepts a UID and returns a custom token), or create a separate offline mechanism? 
   - **Important finding:** The existing Cloud Function at `https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token` accepts a `uid` parameter and returns a custom token. This means the test can generate tokens by calling this endpoint directly — **no Firebase Admin SDK setup is needed locally.** The agent should call this endpoint with the test account UID to get a custom token. But this requires knowing the Firebase UID for `ashtraildev3@gmail.com` and `soupsterx@live.com` ahead of time.
   - **The UIDs are not in the plan or config.** The agent needs to either hardcode them, look them up from Firebase Console, or discover them dynamically.

3. **When to call the bypass.** The plan says the bypass should be controlled by `const String.fromEnvironment('FIREBASE_TEST_TOKEN')`. But what happens after `signInWithCustomToken()`? The agent needs to:
   - Ensure the Hive account is also created/activated (Firebase Auth alone isn't enough — the app requires a Hive `Account` entry with `isActive=true`).
   - Use `AccountIntegrationService` or `AccountService` to persist the account to Hive after Firebase sign-in.
   - The plan doesn't address this Hive setup step.

4. **Integration point.** Where does `auth_bypass.dart` get called?
   - From `ensureGmailLoggedIn()` (before UI detection)?
   - From `AppComponent.launch()` (before `main()`)?  
   - From a new `setUp` block in the test file?
   - **Recommendation:** Call it at the top of `ensureGmailLoggedIn()`, after `app.launch()` but before screen detection. If the token is present, sign in programmatically, wait for the Home screen, and return early.

5. **`signInWithCustomToken()` triggers `AccountIntegrationService` automatically?** When the app's `AuthWrapper` sees a new Firebase user, it may or may not auto-create the Hive account. The agent needs to trace the auth state flow in the production code:
   - `lib/providers/auth_provider.dart` → `authStateChangesProvider` listens to `FirebaseAuth.instance.authStateChanges()`
   - When a new user appears, does the `AuthWrapper` widget call `AccountIntegrationService.handleSignIn()`?
   - **If yes**, the bypass just needs to sign in and wait for the Home screen.
   - **If no**, the bypass must also call `AccountIntegrationService.handleSignIn()` manually.

---

## Step 3: Preflight Validation Script (`scripts/preflight_gmail_check.sh`)

**Plan says:** Create a script to verify simulator state before `patrol test`.

### Gaps

1. **Simulator UUID is hardcoded in the plan** (iPhone 13 Pro `84A035C2`, iPhone 16 Pro Max `0A875592`) but `run_all_e2e.sh` already auto-discovers simulators dynamically. The agent should decide: hardcode UUIDs or auto-discover like the existing scripts?
   - **Recommendation:** Auto-discover, with the hardcoded UUIDs as documentation/comments only.

2. **"Verify app is installed" check.** The plan says use `xcrun simctl listapps`. The actual command is `xcrun simctl listapps <uuid>` which outputs a plist. The agent needs to parse it (e.g., `xcrun simctl listapps <uuid> | grep com.soup.smokeLog`). On some macOS/Xcode versions, `listapps` isn't available — the alternative is `xcrun simctl get_app_container <uuid> com.soup.smokeLog` which returns the container path or errors.

3. **"Remind user about manual seeding" — how?** The plan says "remind user" but doesn't specify the mechanism. A simple `echo` to stdout? Open a dialog? The agent should use `echo` with color-coded output (ANSI codes), matching the style of `run_all_e2e.sh`.

4. **Checking auth state from the host side.** The plan says "exit with clear pass/fail status" — but there's no way to check Firebase Auth state from a shell script without running Dart code. The script can only check if the app is installed, not if the user is logged in. The plan's scope here is limited to "is the simulator booted and is the app installed" — the actual auth check happens at runtime (Step 1/Step 5).

---

## Step 4: Document Persistence Rules

**Plan says:** Update `docs/testing/E2E_TESTING_GUIDE.md` and `docs/deployment/GMAIL_LOGIN_TEST_GUIDE.md`.

### Gaps

1. **Both files already exist with content.** The agent needs to ADD sections, not create new files. The plan doesn't specify where in each file the new sections should be inserted.
   - `E2E_TESTING_GUIDE.md` is focused on Patrol setup and running tests.
   - `GMAIL_LOGIN_TEST_GUIDE.md` is focused on manual Gmail login verification.
   - **Recommendation:** Add a "## Gmail Auth Persistence" section near the top of `GMAIL_LOGIN_TEST_GUIDE.md`, and a "## Auth State Persistence" section to `E2E_TESTING_GUIDE.md` under the "Running Patrol locally" heading.

2. **The state persistence table from the plan should be embedded** in the docs, but the plan uses `--full-isolation` terminology which needs to be mapped to the actual Patrol 3.x flag (`--no-label-isolation` isn't a thing — the relevant flag is just the default vs `--full-isolation` which patrol_cli supports).

---

## Step 5: Auth Persistence Smoke Test

**Plan says:** Add a lightweight first test to `gmail_multi_account_test.dart` that checks `FirebaseAuth.instance.currentUser`.

### Gaps

1. **Firebase isn't initialized until `app.main()` is called.** The check `FirebaseAuth.instance.currentUser` will crash if called before `Firebase.initializeApp()`. The smoke test must call `AppComponent($).launch()` first (which calls `main()`), then check auth state. But launching the app also triggers UI rendering, permission dialogs, etc. The agent needs to use `gmailLaunchAndDetect($)` or replicate that pattern.

2. **Where in the test file to insert it.** The plan says to add it as a first test in `gmail_multi_account_test.dart`, but the file already has 8 `patrolTest` blocks (Tests 1-8). Patrol runs tests in the order they appear. The agent should insert a new `patrolTest` at the very top of `main()`, before Test 1. But note that **Patrol hot-restarts between tests**, so the smoke test's app state won't carry over to Test 1 — its only purpose is logging.

3. **Test naming convention.** The existing tests are numbered G1-G8. The smoke test should be G0 or "Gmail: Auth persistence pre-check" to sort before Test 1.

---

## Step 6: Patrol Caveats in Login Flow Documentation

**Plan says:** Expand the doc comment on `launchAndDetect()` (line 60) in `login_flow.dart`.

### Gaps

1. **Line 60 reference is accurate** — `launchAndDetect()` at line 60 of `login_flow.dart` already has a doc comment about Patrol hot-restart behavior. The agent just needs to expand it.

2. **No code changes needed**, only doc comment expansion. Straightforward.

---

## Step 7: Simulator Seeding Script (`scripts/seed_gmail_simulator.sh`)

**Plan says:** Create a convenience script for one-time simulator seeding.

### Gaps

1. **`flutter build ios --simulator` is not a real command.** The correct command is:
   ```bash
   flutter build ios --debug --simulator
   ```
   Or more commonly, the build happens implicitly via `patrol test` or `flutter run`. For explicit install:
   ```bash
   flutter build ios --debug --simulator
   xcrun simctl install <uuid> build/ios/iphonesimulator/Runner.app
   ```
   The agent needs to use the correct commands.

2. **"Launch the app" step — how?** `xcrun simctl launch <uuid> com.soup.smokeLog` launches the app but doesn't interact with it. The user would need to manually complete Google Sign-In in the simulator. The script should:
   - Open Simulator.app (so the user can see the screen)
   - Launch the app
   - Print instructions
   - Wait for Enter

3. **"Optionally run the smoke test" — which test?** The plan references Step 5's smoke test. The agent should run:
   ```bash
   patrol test --target integration_test/gmail_multi_account_test.dart --device <uuid> --test-names "Gmail: Auth persistence pre-check"
   ```
   But Patrol's `--test-names` flag may not exist in version 3.15.2. The agent needs to verify this or use a different approach (e.g., a separate test file for the smoke test).

4. **Default simulator UUID.** The plan defaults to iPhone 16 Pro Max `0A875592`, but this UUID is machine-specific. The script should auto-discover like `run_all_e2e.sh` does.

---

## Cross-Cutting Gaps

### A. `testEmail5` is `soupsterx@live.com`, not a Gmail address

The plan states test accounts are:
- `ashtraildev3@gmail.com` (account 4)
- `soupsterx@live.com` (account 5)

But `soupsterx@live.com` is a **Microsoft Live account**, not Gmail. The plan title says "Gmail Login Persistence" and discusses **Google Sign-In** exclusively. Can `soupsterx@live.com` be used with Google Sign-In? Only if the user has a Google account linked to that email, or if they sign in with that email through Google's login page (which supports non-Google emails for accounts that have been added to Google). 

**The agent needs to verify:** does the Google Sign-In flow actually work with a `@live.com` email? If the test account is registered as a Google account (e.g., "Sign in with a different email" → `soupsterx@live.com` → password), this works. If not, the second account flow will fail.

### B. Config credentials contain plaintext passwords

`config.dart` stores `testPassword4 = 'AshTestPass123!'` and `testPassword5 = 'Achieve23!'`. These are committed to source control. The plan should address whether these should be moved to `--dart-define` or environment variables, especially for CI. (Low priority — these are test accounts — but a security-conscious agent might flag it.)

### C. `_handleGoogleAccountPicker()` always waits 60 seconds

The current implementation has a hard-coded 60-second `$.pump()` regardless of whether the user completes interaction in 5 seconds. The plan focuses on persistence (avoiding this call entirely on subsequent runs) but doesn't propose improving the first-run experience. **On the first manual seed**, the tester must wait the full 60 seconds even if they complete sign-in in 10 seconds.

**Possible improvement (not in plan):** Replace the single 60s pump with a polling loop that watches for `nav_home` to appear, breaking early when sign-in completes. This would speed up the seeding process. The existing `pumpUntilFound` with 60s timeout would work here. The agent could propose this as a bonus improvement.

### D. Existing `gmail_multi_account_test.dart` Test 1 already has unreliable native automation

In Test 1 (line ~194 of the test file), there's an attempt to automate the Google picker:
```dart
await $.native.tap(
  Selector(textContains: testEmail5),
  appId: 'com.google.chrome',
);
```
This contradicts the plan's core finding that ASWebAuthenticationSession cannot be automated. The same pattern appears in Test 6. These attempts will silently fail (caught by try/catch). The plan should recommend removing or documenting these as best-effort fallbacks. The agent implementing the plan should decide whether to leave them in or clean them up.

### E. Cloud Function security for CI token generation

The existing `generate_refresh_token` Cloud Function accepts a raw `uid` via POST with no authentication. For CI, the plan proposes using `--dart-define=FIREBASE_TEST_TOKEN` but generating that token requires calling the Cloud Function with the test account's UID. This means:
- Either the CI pipeline calls the Cloud Function directly (HTTP POST) — which works but exposes an unauthenticated token generation endpoint
- Or the agent creates a local script that uses Firebase Admin SDK with a service account key

**The existing Cloud Function has no auth guard** — anyone can generate a custom token for any UID. For a test-only project this is acceptable, but the agent should document this security consideration.

### F. `AppComponent.launch()` uses a static bool guard

`AppComponent._launched` is a static bool set to `true` after the first `app.main()` call. Since Patrol hot-restarts between tests (resetting Dart statics), this bool resets to `false` each time, so `main()` is called exactly once per test — which is correct. But if the auth bypass (Step 2) needs to sign in **after** `main()` but **before** the app renders, there's a timing issue. The agent needs to ensure the bypass happens after Firebase initialization but before (or concurrent with) the `AuthWrapper` widget deciding which screen to show.

### G. No `ensureGmailLoggedIn()` for specific account without full flow

The current `ensureGmailLoggedIn()` doesn't support switching to a specific account if already logged in with a *different* account. If `currentUser` is `soupsterx@live.com` but `selectAccountEmail` is `ashtraildev3@gmail.com`, the pre-check (Step 1) would see a non-null user but with the wrong email. The agent needs to handle this case:
- If logged in with wrong email, should it sign out and trigger the full flow?
- Or navigate to Accounts screen and switch?
- Or fall through to UI detection (which will see Home and skip login)?

**Recommendation:** If `selectAccountEmail` is provided and doesn't match `currentUser.email`, skip the pre-check and fall through to UI-based flow. The existing `GmailAppScreen.home` case will execute correctly (staying on Home), and the caller is responsible for switching accounts after if needed.

---

## Summary: Actionable Items for Agent

| # | Gap | Priority | Action Required |
|---|-----|----------|-----------------|
| 1 | Firebase pre-check must come AFTER `app.launch()`, not before | High | Insert check after `gmailLaunchAndDetect()` but before `switch(screen)` |
| 2 | `getIdToken()` error handling needed | High | Wrap in try-catch, fall through on failure |
| 3 | Hive account may not be synced with Firebase after hot-restart | Medium | Also check `AccountService().getActiveAccount()` in pre-check |
| 4 | Token generation script missing (language, location, credentials) | High | Reuse existing Cloud Function endpoint or create `scripts/generate_test_token.sh` that curls the endpoint |
| 5 | Test account Firebase UIDs not documented | High | Look up UIDs in Firebase Console and add to `config.dart` |
| 6 | Hive account creation after `signInWithCustomToken()` not addressed | High | Trace `AuthWrapper` flow or call `AccountIntegrationService.handleSignIn()` |
| 7 | `auth_bypass.dart` integration point unclear | Medium | Call from `ensureGmailLoggedIn()` after `app.launch()` |
| 8 | Preflight script can't verify auth state from shell | Low | Limit scope to simulator + app install checks |
| 9 | `testEmail5` is `@live.com`, not Gmail — verify Google Sign-In works | Medium | Verify in Firebase Console or test manually |
| 10 | Existing native picker automation attempts contradict plan | Low | Clean up or document as best-effort |
| 11 | `_handleGoogleAccountPicker()` wastes 60s even on fast completion | Medium | Replace with polling loop for first-seed improvement |
| 12 | `flutter build ios --simulator` isn't the right command | Low | Use correct build/install commands in seed script |
| 13 | Smoke test needs `app.launch()` before Firebase check | Medium | Use `gmailLaunchAndDetect()` pattern |
| 14 | Email mismatch handling in pre-check | Medium | If `selectAccountEmail` set and != `currentUser.email`, skip pre-check |
| 15 | Cloud Function has no auth guard for token generation | Low | Document security consideration for CI |
| 16 | Both target doc files exist — need section insertion, not creation | Low | Add sections to existing files |

---

## One-Time Manual Seeding Procedure (Seed Once, Run Forever)

This section describes how to manually log in to both test Gmail accounts **once** so that all subsequent `patrol test` runs skip the native Google Sign-In entirely.

### Why This Works

In default Patrol mode (no `--full-isolation`), Patrol hot-restarts the app between `patrolTest` blocks. This resets all Dart statics but preserves **all platform state**:

| Store | Survives Hot-Restart | Survives App Reinstall | Survives Sim Reboot | Survives Sim Erase |
|-------|---------------------|----------------------|--------------------|--------------------|
| iOS Keychain (Firebase refresh token) | Yes | Yes | Yes | **No** |
| Hive local DB (accounts, logs) | Yes | **No** | Yes | **No** |
| Safari cookies (ASWebAuth session) | Yes | Yes | Yes | **No** |

Firebase Auth stores its refresh token in the iOS Keychain. Once Google Sign-In completes, this token is valid indefinitely (it auto-refreshes on app launch). `ensureGmailLoggedIn()` detects the persisted session (app lands on Home) and skips the entire native OAuth flow.

### Prerequisites

- iOS Simulator booted (iPhone 16 Pro Max recommended)
- Network connectivity (Firebase needs to reach Google's OAuth servers)
- Know the test account credentials:
  - **Account 4:** `ashtraildev3@gmail.com` / `AshTestPass123!`
  - **Account 5:** `soupsterx@live.com` / `Achieve23!`

### Step-by-Step Seeding

#### 1. Boot the simulator and run the Gmail test suite

```bash
# From the project root
open -a Simulator

# Run just the first Gmail multi-account test (adds both accounts)
patrol test --target integration_test/gmail_multi_account_test.dart \
  --device "iPhone 16 Pro Max"
```

#### 2. Complete the first manual sign-in (~15 seconds)

When the test starts, `ensureGmailLoggedIn()` will navigate to the Login screen and tap "Continue with Google". The native `ASWebAuthenticationSession` sheet will appear in the simulator.

In the simulator:
1. The Safari-based sign-in sheet appears → tap **Continue**
2. Google's sign-in page loads → enter `ashtraildev3@gmail.com`
3. Enter password `AshTestPass123!` → complete any 2FA if prompted
4. Grant permissions if asked → the sheet dismisses automatically

The test polls every 2 seconds and proceeds **immediately** once sign-in completes (no more 60-second hard wait).

#### 3. Complete the second manual sign-in (for account 5)

Test 1 (`Gmail multi-account: add second account`) will also call `addGmailAccount()` which triggers Google Sign-In again for the second account.

In the simulator:
1. Sheet appears again → tap **Continue**
2. Enter `soupsterx@live.com` (or select it if already offered)
3. Enter password `Achieve23!` → complete sign-in

#### 4. Verify seeding succeeded

After both manual interactions, the test should pass. Check the diagnostics log:

```bash
cat /tmp/ash_trail_test_diagnostics.log | grep -E "Persisted session|Sign-in completed"
```

Expected output on successful seed:
```
GMAIL_SETUP: Sign-in completed after ~12s — session will persist
GMAIL_SETUP: Sign-in completed after ~10s — session will persist
```

#### 5. All subsequent runs are fully automatic

```bash
# Run the full suite again — no manual interaction needed
patrol test --target integration_test/gmail_multi_account_test.dart \
  --device "iPhone 16 Pro Max"
```

Check the log to confirm the persisted session was detected:
```bash
cat /tmp/ash_trail_test_diagnostics.log | grep "Persisted session"
```

Expected:
```
GMAIL_SETUP: Persisted session found: ashtraildev3@gmail.com (uid: abc12345...)
GMAIL_SETUP: Firebase token refresh OK — session valid
```

### When Re-Seeding Is Required

You must repeat the manual seeding procedure after any of these actions:

| Action | Destroys Auth State? | Re-Seed Required? |
|--------|---------------------|-------------------|
| `patrol test` (default mode) | No | No |
| `xcrun simctl shutdown` + `boot` | No | No |
| Xcode restart | No | No |
| Mac reboot | No | No |
| `xcrun simctl erase <uuid>` | **Yes** — wipes entire simulator | **Yes** |
| `patrol test --full-isolation` | **Yes** — uninstalls app, wipes Keychain | **Yes** |
| Xcode version upgrade (sometimes resets simulators) | **Maybe** | Check — run once, if Home appears you're fine |
| Delete simulator in Xcode | **Yes** | **Yes** (on the new simulator) |

### Troubleshooting

**Test lands on Welcome/Login instead of Home on a subsequent run:**
- The session was lost. Check if the simulator was erased or `--full-isolation` was used.
- Re-seed by running the test and completing manual sign-in again.

**"Token refresh failed" in the log but test still passes:**
- The simulator may be offline. Firebase can work with a cached token for a while, but refreshing requires network. Connect to WiFi and the next run will refresh automatically.

**"Hive has no active account" in the log:**
- This can happen on the first run after an app reinstall (Keychain is preserved but Hive data dir is new). The app's `AuthWrapper` will detect the Firebase user and re-create the Hive account automatically.

### Code Changes Made (Implemented)

Two changes to `integration_test/flows/gmail_login_flow.dart` make this workflow possible:

1. **`ensureGmailLoggedIn()` — Enhanced `home` case:** When the app lands on Home (meaning the Firebase session persisted from a prior run), the code now logs the persisted Firebase user, verifies the token can refresh, and checks Hive account sync. This provides clear diagnostic evidence that seeding worked.

2. **`_handleGoogleAccountPicker()` — Polling instead of hard wait:** Replaced the fixed 60-second `$.pump()` with a polling loop that checks for `nav_home` every 2 seconds, breaking immediately when sign-in completes. The maximum wait is extended to 120 seconds (for slow sign-ins) but typical completion is 10-15 seconds. This makes the one-time seeding much faster.
