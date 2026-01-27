# Integration Tests - Comprehensive Guide

> **Last Updated**: January 26, 2026  
> **Test Status**: ✅ **722 unit tests passing**, 6 integration tests skipped  
> **Related Documentation**: [E2E_TESTING_GUIDE.md](./E2E_TESTING_GUIDE.md), [TESTING_STRATEGY.md](../TESTING_STRATEGY.md)

## Table of Contents

- [Overview](#overview)
- [Why Some Tests Are Skipped](#why-some-tests-are-skipped)
- [Skipped Tests](#skipped-tests)
- [Running Integration Tests](#running-integration-tests)
- [Recommended Approach](#recommended-approach)
- [Best Practices](#best-practices)
- [Future Work](#future-work)

## Overview

This document provides a comprehensive guide to integration testing in the Ash Trail project. The project currently has **6 integration tests** that are intentionally skipped during regular unit test runs. These tests require platform-specific plugins (like Hive database with `path_provider`) and/or Firebase initialization.

**Current Test Status:**
- ✅ **722 unit tests passing**
- ⏭️ **6 integration tests skipped** (require platform plugins)

## Why Some Tests Are Skipped

These tests interact with **real implementations** rather than mocks:
- `DatabaseService.instance` uses `Hive.initFlutter()` which requires `path_provider` plugin
- `path_provider` needs platform channel implementations not available in pure unit tests
- These are true **integration tests** that verify end-to-end functionality with real database

**Note:** We've successfully enabled error-handling tests that don't need real databases - they just verify that proper exceptions are thrown when services are created without initialization!

## Skipped Tests

### 1. LogRecordService - Database Initialization (2 tests)
**File:** `test/services/log_record_service_test.dart`

- ~~`should throw error when created without database initialization` (line 142)~~ ✅ **ENABLED** - Tests error handling, no DB needed
- `should initialize with database service` (line 162)  
- ~~`should require database context when no repository provided` (line 449)~~ ✅ **ENABLED** - Tests error handling, no DB needed
- `should accept valid database context` (line 463)

**Why Skipped:** These remaining 2 tests actually initialize and use the real Hive database, which requires `path_provider` platform plugin.

### 2. Account Data Isolation (1 test)
**File:** `test/services/account_data_isolation_test.dart`

- `real database maintains account isolation` (line 688)

**Why Skipped:** This is a full integration test that verifies account isolation works correctly with the real Hive database, not mocks.

### 3. Home Quick Log Widget (1 test)
**File:** `test/widgets/home_quick_log_widget_test.dart`

- `should cancel recording when finger moves away` (line 265)

**Why Skipped:** The long press gesture in this test triggers actual database access through providers that aren't easily mocked in the widget test environment.

### 4. App Initialization (2 tests)
**File:** `test/widget_test.dart`

- `App initializes and shows home screen` (line 21)
- `App has proper Material 3 theming` (line 35)

**Why Skipped:** These tests require full Firebase initialization and all platform plugins to be available, as they test the complete app startup.

## Running Integration Tests

### Current Limitations

These tests cannot run as-is because:
1. `DatabaseService.instance` is a singleton that calls `Hive.initFlutter()`
2. `Hive.initFlutter()` requires `path_provider` plugin
3. `path_provider` needs platform channels not available in `flutter test`

### Solution 1: Integration Test Directory (Recommended)

Move these tests to `integration_test/` and run them on actual devices/emulators:

```bash
# Run on connected device
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d chrome
flutter test integration_test/ -d macos
```

Integration tests run with full platform support and can access all plugins.

### Solution 2: Refactor for Dependency Injection

Instead of using `DatabaseService.instance` singleton, inject the database service:

```dart
class LogRecordService {
  final LogRecordRepository _repository;
  
  LogRecordService({
    LogRecordRepository? repository,
    DatabaseService? databaseService,  // Add this
  }) {
    if (repository != null) {
      _repository = repository;
    } else {
      // Use injected service or fallback to instance
      final dbService = databaseService ?? DatabaseService.instance;
      _repository = createLogRecordRepository(dbService.boxes);
    }
  }
}
```

Then in tests, inject a `TestDatabaseService` that doesn't use `initFlutter()`.

### Solution 3: Use `integration_test` Package with TestWidgetsFlutterBinding

For widget tests that need database access:

```dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('test with database', (tester) async {
    // Now has access to platform plugins
  });
}
```

### Solution 4: Mock Platform Channels

For unit tests, mock the platform channels:

```dart
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(
  MethodChannel('plugins.flutter.io/path_provider'),
  (MethodCall methodCall) async {
    if (methodCall.method == 'getApplicationDocumentsDirectory') {
      return '/tmp/test';
    }
    return null;
  },
);
```

However, this requires mocking many platform channels and defeats the purpose of integration testing.

## Recommended Approach

**For this project, we recommend:**

1. **Keep unit tests pure** - Use mocks, no platform dependencies (current state ✅)
2. **Create integration_test/ directory** - Move real database tests there
3. **Run integration tests separately** - On actual devices when needed

### Creating Integration Test Suite

```bash
# Create directory
mkdir -p integration_test

# Move integration tests
mv test/services/database_integration_test.dart integration_test/

# Run them
flutter test integration_test/
```

### Benefits of This Approach

- ✅ Unit tests stay fast (<30 seconds for 720+ tests)
- ✅ Integration tests verify real behavior
- ✅ Clear separation of concerns
- ✅ Both test types can run in CI/CD
- ✅ No complex mocking or workarounds needed

## Alternative: Enable Some Tests Now

The **first test** in each group (`should throw error when created without database initialization`) can actually run because it just verifies that creating the service without init throws an error. To enable it:

```dart
test('should throw error when created without database initialization', () {
  expect(() => LogRecordService(), throwsA(isA<Exception>()));
});  // Remove skip parameter
```

This doesn't need a real database - it just checks error handling!

## Test Results

**Current Status:** ✅ **722 unit tests passing**, 6 integration tests properly skipped

**Improvements Made:**
- Enabled 2 error-handling tests that don't need real database
- These tests verify proper exceptions are thrown when services are misused
- Reduced skipped tests from 8 → 6

The skipped tests are marked with clear messages indicating they are integration tests that require platform plugins for real database operations.

## Best Practices

1. **Unit tests** should use mocks and not require platform plugins
2. **Integration tests** should test real implementations and be in `integration_test/`
3. **Widget tests** should mock providers and services to avoid platform dependencies

## Future Work

### Planned Improvements

1. **Move Integration Tests to Proper Directory**
   - Consider moving these integration tests to the `integration_test/` directory where they belong
   - This will allow them to run in a proper integration test environment with all necessary plugins initialized

2. **CI/CD Integration**
   - Set up automated integration test runs in CI/CD pipeline
   - Configure device/emulator provisioning for integration tests

3. **Test Coverage Expansion**
   - Add more integration tests for critical user flows
   - Implement end-to-end tests for authentication flows
   - Add integration tests for sync functionality

4. **Test Infrastructure**
   - Create test fixtures and helpers for integration tests
   - Set up test data management for integration tests
   - Implement test isolation and cleanup strategies

## Additional Resources

- [Flutter Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)
- [Flutter Testing Best Practices](https://docs.flutter.dev/testing/best-practices)
- [Dart Testing Documentation](https://dart.dev/guides/testing)

---

**Documentation Version**: 1.0  
**Maintained By**: Ash Trail Development Team
