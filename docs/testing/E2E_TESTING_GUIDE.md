# iOS E2E Testing Implementation

This document describes the E2E (End-to-End) testing implementation for testing the AshTrail app on iOS Simulator, addressing the gap between unit tests and TestFlight deployments.

## Problem Statement

When deploying to TestFlight, issues were being discovered that unit tests weren't catching. This is because:

- Unit tests run in isolation with mocked dependencies
- Widget tests don't test the full app integration
- Real iOS simulator/device behavior differs from test environments

## Solution

Implemented comprehensive E2E testing that runs on iOS Simulator to catch integration issues before TestFlight deployment.

## Patrol-first E2E (recommended)

**Patrol** is the primary E2E runner for the AshTrail app on the iOS Simulator. It provides native automation (permission dialogs, system UI), stable finders, and runs the full app.

### Running Patrol locally

**Use an iOS simulator.** Patrol on physical iOS devices requires release mode. If you have both a physical device and a simulator connected, pass `--device` with a **simulator** name or UUID so Patrol uses the simulator. The recommended way is to use the run script, which selects a simulator automatically:

```bash
./scripts/run_e2e_tests.sh
```

### Auth State Persistence (Gmail Tests)

Gmail multi-account tests (`gmail_multi_account_test.dart`) use Google Sign-In via `ASWebAuthenticationSession`, which **cannot be automated** by any testing framework. The solution is a **seed-once** approach:

1. **First run:** Complete Google Sign-In manually once per simulator (~15 seconds per account)
2. **All subsequent runs:** Fully automatic — Firebase Auth token persists in iOS Keychain

**Key rules:**
- **Never use `--full-isolation`** for Gmail tests — it uninstalls the app and wipes the Keychain, destroying auth state
- **Never run `xcrun simctl erase`** on a seeded simulator
- Default Patrol mode preserves all platform state (Keychain, Hive, Safari cookies) across hot-restarts

**For CI:** Use `--dart-define=FIREBASE_TEST_TOKEN=<token>` to bypass OAuth entirely via `signInWithCustomToken()`. See [Gmail Login Test Guide](../deployment/GMAIL_LOGIN_TEST_GUIDE.md) for token generation.

**Preflight check:** Run `./scripts/preflight_gmail_check.sh` before Gmail tests to verify simulator readiness.

**Seed the simulator:** Run `./scripts/seed_gmail_simulator.sh` for a guided first-time seeding process.

**Build and run time:** The first run (or after a clean) can take **about 5–10 minutes** to build the app and start the simulator; the full test suite adds more time. For quicker feedback, run only smoke tests: `./scripts/run_e2e_tests.sh --tags smoke` or pass `--device "iPhone 16 Pro Max"` (or your simulator name) when calling `patrol` directly.

**Manual Patrol commands (use a simulator device):**

```bash
# Install Patrol CLI (once)
dart pub global activate patrol_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
# If using a custom pub cache: export PATH="$PATH:/Volumes/Jacob-SSD/BuildCache/pub-cache/bin"

# Run main Patrol suite (must specify simulator if a physical device is connected)
patrol test --target integration_test/app_e2e_test.dart --device "iPhone 15"

# Or use device UUID from xcrun simctl list devices available
patrol test --target integration_test/app_e2e_test.dart --device <simulator_uuid>

# Run accounts Patrol tests
patrol test --target integration_test/accounts_screen_test.dart --device "iPhone 15"

# Run only smoke-tagged tests (faster)
patrol test --target integration_test/app_e2e_test.dart --tags smoke --device "iPhone 15"
```

### Adding new Patrol tests

1. In `integration_test/`, use `patrolTest('description', ($) async { ... })` and the `$` finder (e.g. `$(Key('nav_home')).tap()`, `$('Sign in').exists`).
2. Prefer **Keys** or **semantics** over raw text so tests survive copy changes. See [Test ID conventions](PATROL_TEST_IDS.md) for the list of Keys and semantics used in the app.
3. For native dialogs (permissions, system UI), use `$.native` (e.g. `$.native.grantPermissionWhenInUse()`, `$.native.pressBack()`).
4. Use `await $.pumpAndSettle(timeout: ...)` after navigation or async actions.

### Test ID conventions

Stable selectors for Patrol are documented in **[docs/testing/PATROL_TEST_IDS.md](PATROL_TEST_IDS.md)**. It lists all Keys (e.g. `nav_home`, `app_bar_account`, `quick_log_mood_slider`) and semantics (e.g. "Accounts", "Hold to record duration") so tests can target elements by Key or semantics instead of fragile text.

### Tags (filter tests)

Tests are tagged so you can run a subset locally or in CI:

| Tag | Use |
|-----|-----|
| `smoke` | Critical path (launch, nav, quick log) |
| `auth` | Login/sign-in and account navigation |
| `accounts` | Accounts screen |
| `logging` | Logging flows |
| `native` / `permissions` | Native dialogs (e.g. location permission) |

**Run by tag:**

```bash
patrol test --target integration_test/app_e2e_test.dart --tags smoke --device "iPhone 15"
patrol test --target integration_test/app_e2e_test.dart --tags='smoke||auth' --device "iPhone 15"
patrol test --exclude-tags native --device "iPhone 15"
```

When adding new `patrolTest`s, add `tags: ['smoke']` (or `auth`, `logging`, etc.) where appropriate.

### Additional Patrol configuration

- **pubspec.yaml:** A `patrol` section is defined with `app_name`, `test_directory: integration_test`, and iOS/Android `bundle_id` / `package_name`. The Patrol CLI reads this for test discovery and app identity.
- **patrol.yaml:** Optional root file used by scripts/docs; same values as pubspec for consistency.
- **Full isolation (iOS):** See [Full isolation and resetting app state](#full-isolation-and-resetting-app-state) below.
- **Coverage:** `patrol test --coverage` writes an LCOV report to `coverage/patrol_lcov.info`. Use `--coverage-ignore="**/*.g.dart"` to exclude generated files.
- **Build versioning:** `patrol test --build-name=1.2.3 --build-number=123` overrides version for the test build (e.g. for CI build numbers).
- **Android (future):** For test isolation on Android, set `clearPackageData: "true"` in `android/app/build.gradle` under `testInstrumentationRunnerArguments` with Patrol’s test runner.
- **More semantics:** Add `Semantics(label: '...')` or use `SemanticIconButton` / `SemanticLabelBuilder` from `lib/utils/a11y_utils.dart` on primary actions so Patrol (and screen readers) can find them by label. See [PATROL_TEST_IDS.md](PATROL_TEST_IDS.md) for existing labels.

### Full isolation and resetting app state

**`--full-isolation`** makes Patrol uninstall the app from the simulator before the test run, then reinstall it. That clears app data (Hive, SharedPreferences, Firebase local state, etc.) and guarantees a fresh launch (e.g. auth/welcome screen or clean account list).

**When to use:**

- **CI:** The Patrol E2E job in [.github/workflows/e2e-ios.yml](../../.github/workflows/e2e-ios.yml) runs with `--full-isolation` so every run starts from a clean simulator state.
- **Local:** Optional for full parity with CI. Recommended when running the **quick-log** or **multi-profile** story groups so History counts and "first account / second account" are predictable.

**How to run with full isolation:**

```bash
# Direct Patrol
patrol test --target integration_test/app_e2e_test.dart --device "iPhone 15" --full-isolation

# Via run script (same as --full-isolation)
./scripts/run_e2e_tests.sh --full-isolation
./scripts/run_e2e_tests.sh --clean
./scripts/run_e2e_tests.sh --full-isolation app_e2e_test.dart
```

Without full isolation, tests may see leftover accounts or logs from a previous run; precondition checks (e.g. "if on auth screen, skip") and per-story setup in the test file handle that.

**Run duration:** Allow **15+ minutes** for a full Patrol run (build ~5–10 min plus test execution). Use `--tags smoke` for a shorter run after the first build.

**iOS build output:** The first time (or after a clean), `xcodebuild` will compile the app and all CocoaPods/plugins. You will see **many compiler/linker warnings** from dependencies (e.g. `sign_in_with_apple`, `objective_c`, `permission_handler_apple`, `geolocator_apple`, linker “search path not found”). These are **warnings, not errors**—they come from third‑party packages and do not stop the build. Ignore them unless the run ends with an actual **error** or **Build failed**. Real failures will show `error:` or a non‑zero exit.

---

## Test Files

### 1. `integration_test/app_e2e_test.dart` (Patrol – primary UI E2E)

**Patrol-based E2E test suite** for native iOS automation. This is the main UI E2E suite.

Features:

- Native permission handling (location, notifications)
- System dialog interactions
- Full UI navigation testing
- App launch, auth, home, quick log, logging, history, analytics, accounts, export, edit/delete flows

**To run:**

```bash
patrol test --target integration_test/app_e2e_test.dart --device "iPhone 15"
```

### 2. `integration_test/accounts_screen_test.dart` (Patrol)

**Patrol-based** account screen tests (load accounts, navigate to login via Add account).

```bash
patrol test --target integration_test/accounts_screen_test.dart --device "iPhone 15"
```

### 3. `integration_test/comprehensive_e2e_test.dart` (flutter drive)

E2E suite using standard Flutter integration_test + flutter drive (no Patrol). Covers service-level and data operations.

**To run:**

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/comprehensive_e2e_test.dart \
  -d <simulator_id>
```

### 4. Other integration tests (flutter test / flutter drive)

- `logging_flow_test.dart` – Log record service tests (create, update, delete, queries, stats)
- `location_collection_test.dart` – Location permission and capture flows
- `database_integration_test.dart` – Database operations
- `legacy_data_integration_test.dart` – Legacy data migration

Run with `flutter test integration_test/<file>.dart --device-id=<id>` or via the CI workflow.

## Testing defaults: iOS

E2E and integration test runs **default to iOS**. The recommended runner `./scripts/run_e2e_tests.sh` automatically selects an iOS simulator (iPhone 15 preferred, then any iPhone). CI uses the same default (see `.github/workflows/e2e-ios.yml`). To run on Android or web, pass the appropriate device or use `patrol test --device <id>` with a non‑iOS device.

## Running Tests

### Quick Start

```bash
# Run E2E tests on iOS (default)
./scripts/run_e2e_tests.sh

# Run specific test file
./scripts/run_e2e_tests.sh logging_flow_test.dart

# List available simulators
./scripts/run_e2e_tests.sh --list-devices
```

### Manual Commands

```bash
# List simulators
xcrun simctl list devices available | grep iPhone

# Boot a simulator
xcrun simctl boot "iPhone 15 Pro"

# Run with flutter drive
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/comprehensive_e2e_test.dart \
  -d <simulator_id>
```

## CI/CD Integration

### GitHub Actions Workflow

File: `.github/workflows/e2e-ios.yml`

The workflow:

1. Boots an iOS simulator on macOS runner
2. Installs dependencies and CocoaPods
3. Runs comprehensive E2E tests with flutter drive
4. Runs Patrol E2E tests (app_e2e_test.dart); failures fail the job
5. Falls back to individual integration tests if needed
6. Uploads test artifacts

Triggers:

- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual dispatch via GitHub UI

## Test Architecture

```text
integration_test/
├── app_e2e_test.dart              # Patrol – main UI E2E (primary)
├── accounts_screen_test.dart      # Patrol – account screen E2E
├── comprehensive_e2e_test.dart    # Flutter drive – service/data E2E
├── logging_flow_test.dart         # Log record service tests
├── database_integration_test.dart # Database operations
├── location_collection_test.dart  # Location features
└── legacy_data_integration_test.dart

test_driver/
└── integration_test.dart          # Flutter drive entry point

scripts/
└── run_e2e_tests.sh               # Local runner (default: Patrol app_e2e_test)

docs/testing/
├── E2E_TESTING_GUIDE.md           # This file
└── PATROL_TEST_IDS.md             # Test Keys and semantics for Patrol

.github/workflows/
└── e2e-ios.yml                    # CI workflow
```

## Dependencies

Added to `pubspec.yaml`:

```yaml
dev_dependencies:
  patrol: ^3.13.0
  patrol_finders: ^2.5.0
  integration_test:
    sdk: flutter
```

## Configuration

### patrol.yaml

Default platform is iOS. Root `patrol.yaml` (and optional `pubspec.yaml` patrol section) configures test directory and iOS/Android app ids.

```yaml
# Default platform: iOS
patrol:
  test_dir: integration_test
  default_platform: ios
  ios:
    flavor: Runner
    bundle_id: com.soup.smokeLog
  android:
    app_id: com.soup.smokeLog
```

## Test Coverage Comparison

| Feature | Unit Tests | Widget Tests | E2E Tests |
| --- | --- | --- | --- |
| Log creation | ✅ | ✅ | ✅ |
| Log editing | ✅ | ✅ | ✅ |
| Log deletion | ✅ | ✅ | ✅ |
| Data persistence | ❌ | ❌ | ✅ |
| iOS-specific behavior | ❌ | ❌ | ✅ |
| Full navigation | ❌ | Partial | ✅ |
| Native permissions | ❌ | ❌ | ✅ (Patrol) |
| System dialogs | ❌ | ❌ | ✅ (Patrol) |
| Cross-service integration | ❌ | ❌ | ✅ |

## Troubleshooting

### Tests timeout during build

iOS builds take 10-15 minutes on first run. Subsequent runs are faster due to caching.

### Simulator not found

```bash
# List available simulators
xcrun simctl list devices available | grep iPhone

# Create a new simulator if needed
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" "iOS17.2"
```

### CocoaPods issues

```bash
cd ios
pod deintegrate
pod install --repo-update
```

### Patrol CLI not found

```bash
dart pub global activate patrol_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### Debugging Patrol tests

Use **Patrol DevTools** (browser extension or IDE) to inspect the running app and discover semantics/Keys on the device. Run tests in verbose mode: `patrol test ... --verbose`.

## Best Practices

1. **Run E2E tests before TestFlight** - Add to your release checklist
2. **Keep tests focused** - Each test should verify one specific behavior
3. **Use service layer tests** - More reliable than UI tests for data operations
4. **Test edge cases** - Empty values, max values, special characters
5. **Clean up test data** - Use setUp/tearDown to isolate tests

## Future Improvements

- [ ] Add visual regression testing with screenshots
- [ ] Implement performance benchmarks
- [ ] Add network condition simulation
- [ ] Create test data factories
- [ ] Add accessibility testing
