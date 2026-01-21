# iOS E2E Testing Implementation

This document describes the E2E (End-to-End) testing implementation for testing the AshTrail app on iOS Simulator, addressing the gap between unit tests and TestFlight deployments.

## Problem Statement

When deploying to TestFlight, issues were being discovered that unit tests weren't catching. This is because:

- Unit tests run in isolation with mocked dependencies
- Widget tests don't test the full app integration
- Real iOS simulator/device behavior differs from test environments

## Solution

Implemented comprehensive E2E testing that runs on iOS Simulator to catch integration issues before TestFlight deployment.

## Test Files

### 1. `integration_test/comprehensive_e2e_test.dart`

**Primary E2E test suite** using standard Flutter integration_test package.

Coverage:

- App startup and basic navigation
- Log record service operations (create, update, delete)
- All event types and unit types
- Mood and physical ratings
- Location data handling
- Reason tracking
- Data queries (by account, date range, event type)
- Statistics calculations
- Data persistence
- Edge cases (empty notes, zero/large durations, special characters)
- Concurrent operations

**To run:**

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/comprehensive_e2e_test.dart \
  -d <simulator_id>
```

### 2. `integration_test/app_e2e_test.dart`

**Patrol-based E2E test suite** for native iOS automation.

Features:

- Native permission handling (location, notifications)
- System dialog interactions
- Full UI navigation testing
- Cross-platform compatibility

**To run (requires Patrol CLI):**

```bash
patrol test --target integration_test/app_e2e_test.dart --device <simulator_id>
```

### 3. Existing Integration Tests

- `logging_flow_test.dart` - Logging workflow tests
- `accounts_screen_test.dart` - Account management tests
- `database_integration_test.dart` - Database operation tests
- `location_collection_test.dart` - Location feature tests
- `legacy_data_integration_test.dart` - Legacy data migration tests

## Running Tests

### Quick Start

```bash
# Run comprehensive E2E tests (recommended)
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
4. Optionally runs Patrol tests
5. Falls back to individual integration tests if needed
6. Uploads test artifacts

Triggers:

- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual dispatch via GitHub UI

## Test Architecture

```text
integration_test/
├── comprehensive_e2e_test.dart    # Main E2E suite (flutter drive)
├── app_e2e_test.dart              # Patrol-based tests
├── logging_flow_test.dart         # Logging workflow
├── accounts_screen_test.dart      # Account management
├── database_integration_test.dart # Database operations
├── location_collection_test.dart  # Location features
└── legacy_data_integration_test.dart

test_driver/
└── integration_test.dart          # Flutter drive entry point

scripts/
└── run_e2e_tests.sh               # Local test runner

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

```yaml
app_name: AshTrail
bundle_id: com.soup.smokeLog
flutter_path: flutter
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
