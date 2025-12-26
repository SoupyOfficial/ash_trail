# AshTrail Testing Guide

Comprehensive testing documentation for the AshTrail logging system.

## ⚠️ IMPORTANT: Platform Limitations

**Service and integration tests require native platforms** due to Isar database:

- ✅ **Works:** iOS, Android, macOS, Linux, Windows
- ❌ **Fails:** Web browsers (Isar not supported)
- ✅ **Model tests:** Work on ALL platforms
- ✅ **E2E tests:** Work on Web (Playwright)

```bash
# These work everywhere:
flutter test test/models/

# These require native platforms:
flutter test test/services/        # FAILS on Web
flutter test integration_test/     # FAILS on Web
```

## 📋 Table of Contents

- [Overview](#overview)
- [Test Structure](#test-structure)
- [Unit Tests](#unit-tests)
- [Integration Tests](#integration-tests)
- [E2E Tests](#e2e-tests)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [CI/CD Integration](#cicd-integration)

## 🎯 Overview

The AshTrail logging system has comprehensive test coverage across multiple layers:

```
┌─────────────────────────────────────┐
│      E2E Tests (Playwright)         │ ← User workflows
├─────────────────────────────────────┤
│      Integration Tests              │ ← Full app flows
├─────────────────────────────────────┤
│      Widget Tests                   │ ← UI components
├─────────────────────────────────────┤
│      Provider Tests                 │ ← State management
├─────────────────────────────────────┤
│      Service Tests                  │ ← Business logic
├─────────────────────────────────────┤
│      Model Tests                    │ ← Data structures
└─────────────────────────────────────┘
```

## 📁 Test Structure

```
ash_trail/
├── test/                           # Unit and widget tests
│   ├── models/
│   │   ├── log_record_test.dart           # ✅ 50+ tests
│   │   ├── daily_rollup_test.dart         # ✅ 15+ tests
│   │   └── range_query_spec_test.dart     # ✅ 20+ tests
│   │
│   ├── services/
│   │   ├── log_record_service_test.dart   # ✅ 21 tests
│   │   └── analytics_service_test.dart    # ✅ 14 tests
│   │
│   ├── providers/
│   │   ├── log_record_provider_test.dart  # TODO
│   │   ├── sync_provider_test.dart        # TODO
│   │   └── analytics_provider_test.dart   # TODO
│   │
│   └── widgets/
│       ├── log_entry_widgets_test.dart    # TODO
│       ├── log_record_list_test.dart      # TODO
│       └── sync_status_widget_test.dart   # TODO
│
├── integration_test/               # Integration tests
│   └── logging_flow_test.dart              # ✅ Full flow tests
│
└── playwright/                     # E2E tests
    ├── tests/
    │   ├── logging-flow.spec.ts            # ✅ 20+ tests
    │   ├── visual-regression.spec.ts       # ✅ 15+ tests
    │   ├── page-object-tests.spec.ts       # ✅ 10+ tests
    │   └── fixtures.ts                     # Page Object Model
    └── README.md
```

## 🧪 Unit Tests

### Model Tests

#### LogRecord Tests (`test/models/log_record_test.dart`)

**Coverage**: 50+ tests

Tests cover:
- ✅ Creating log records with all fields
- ✅ Tag handling (list ↔ string conversion)
- ✅ Empty tag handling
- ✅ `markDirty()` - revision tracking, dirty fields
- ✅ `markSynced()` - clearing sync state
- ✅ `markSyncError()` - error state management
- ✅ `softDelete()` - soft deletion logic
- ✅ `copyWith()` - immutable updates
- ✅ `toFirestore()` - serialization
- ✅ `fromFirestore()` - deserialization
- ✅ Round-trip serialization

**Run:**
```bash
flutter test test/models/log_record_test.dart
```

#### DailyRollup Tests (`test/models/daily_rollup_test.dart`)

**Coverage**: 15+ tests

Tests cover:
- ✅ Creating rollups with all fields
- ✅ `isStale()` - cache invalidation logic
- ✅ Null hash handling
- ✅ Optional field handling
- ✅ Date comparisons

**Run:**
```bash
flutter test test/models/daily_rollup_test.dart
```

#### RangeQuerySpec Tests (`test/models/range_query_spec_test.dart`)

**Coverage**: 20+ tests

Tests cover:
- ✅ Factory methods: `today()`, `week()`, `month()`, `year()`, `ytd()`, `custom()`
- ✅ `containsDate()` - date range checking
- ✅ `durationInDays` - duration calculation
- ✅ `copyWith()` - immutable updates
- ✅ Optional filters (profiles, event types, tags)
- ✅ Edge cases: same start/end, leap years, time components

**Run:**
```bash
flutter test test/models/range_query_spec_test.dart
```

### Service Tests

#### LogRecordService Tests (`test/services/log_record_service_test.dart`)

**Coverage**: 21 tests across 14 groups

Tests cover:
- ✅ **Create Operations** (4 tests)
  - Basic creation
  - UUID generation
  - Timestamp setting
  - Pending sync state
  
- ✅ **Read Operations** (6 tests)
  - Get by ID
  - Get by account
  - Get by profile
  - Event type filtering
  - Date range filtering
  - Tag filtering
  
- ✅ **Update Operations** (3 tests)
  - Basic update
  - Dirty field tracking
  - Revision increment
  
- ✅ **Delete Operations** (3 tests)
  - Soft delete
  - Hard delete
  - Deletion flags
  
- ✅ **Sync Operations** (3 tests)
  - Get pending records
  - Mark as synced
  - Mark sync errors
  
- ✅ **Batch Operations** (1 test)
  - Bulk creation
  
- ✅ **Statistics** (1 test)
  - Count, sum, avg, min, max

**Run:**
```bash
flutter test test/services/log_record_service_test.dart
```

#### AnalyticsService Tests (`test/services/analytics_service_test.dart`)

**Coverage**: 14 tests across 6 groups

Tests cover:
- ✅ **Time Series** (2 tests)
  - Hourly grouping
  - Daily grouping
  
- ✅ **Aggregations** (2 tests)
  - Count aggregation
  - Sum aggregation
  
- ✅ **Event Type Breakdown** (1 test)
  - Event distribution
  
- ✅ **Period Summary** (2 tests)
  - Total values
  - Averages
  
- ✅ **Daily Rollup** (3 tests)
  - Rollup creation
  - Cache invalidation
  - Rollup reuse
  
- ✅ **RangeQuerySpec** (4 tests)
  - Filter application
  - Date range filtering
  - Event type filtering
  - Combined filters

**Run:**
```bash
flutter test test/services/analytics_service_test.dart
```

### Running All Unit Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific directory
flutter test test/models/
flutter test test/services/
```

## 🔗 Integration Tests

### Logging Flow Tests (`integration_test/logging_flow_test.dart`)

**Coverage**: Full end-to-end flows

Tests cover:
- ✅ **Complete Logging Flow**
  - Create log entry via UI
  - View in list
  - View details
  - Edit entry
  - Delete entry
  - Quick log button
  - Filter by event type
  - Analytics display
  
- ✅ **Offline Scenarios**
  - Create entries offline
  - Edit offline entries
  - Pending sync indicators
  
- ✅ **Data Persistence**
  - Data survives app restart

**Run:**
```bash
# Run integration tests
flutter test integration_test/logging_flow_test.dart

# Run on device
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/logging_flow_test.dart
```

## 🌐 E2E Tests (Playwright)

### Comprehensive Browser Testing

**Location**: `playwright/tests/`

**Coverage**: 45+ tests across multiple suites

#### 1. Logging Flow Tests (`logging-flow.spec.ts`)

- ✅ Create log entries
- ✅ View entry details
- ✅ Edit entries
- ✅ Delete entries
- ✅ Quick log buttons
- ✅ Filter by event type
- ✅ Search by note
- ✅ Date range filtering
- ✅ Sync status monitoring
- ✅ Manual sync trigger
- ✅ Offline support
- ✅ Performance benchmarks

#### 2. Visual Regression Tests (`visual-regression.spec.ts`)

- ✅ Home screen screenshots
- ✅ Create dialog screenshots
- ✅ Analytics screen screenshots
- ✅ Mobile viewport
- ✅ Tablet viewport
- ✅ Dark mode
- ✅ Component states (empty, loading, error)
- ✅ Interaction states (hover, focus, disabled)

#### 3. Page Object Tests (`page-object-tests.spec.ts`)

- ✅ Create multiple entries efficiently
- ✅ Search and filter workflows
- ✅ Edit and delete workflows
- ✅ Sync monitoring
- ✅ Analytics interactions
- ✅ Complete user journeys
- ✅ Offline to online workflows

**Run:**
```bash
cd playwright

# Install dependencies
npm install
npx playwright install

# Run all tests
npm test

# Run with UI
npm run test:ui

# Run in headed mode
npm run test:headed

# Debug tests
npm run test:debug

# View report
npm run report
```

**Browsers Tested:**
- ✅ Chromium (Desktop)
- ✅ Firefox (Desktop)
- ✅ WebKit/Safari (Desktop)
- ✅ Mobile Chrome (Pixel 5)
- ✅ Mobile Safari (iPhone 12)

## 📊 Test Coverage

### Current Coverage

```
Models:           ████████████████████ 100% (3/3 files)
Services:         ████████████         60%  (2/3 files)
Providers:        ░░░░░░░░░░░░░░░░░░░░  0%  (0/3 files)
Widgets:          ░░░░░░░░░░░░░░░░░░░░  0%  (0/3 files)
Integration:      ████████████████████ 100% (1/1 file)
E2E:              ████████████████████ 100% (3/3 files)

Overall:          ████████████░░░░░░░░ 65%
```

### Coverage Goals

- ✅ Models: 100% coverage
- ✅ Core Services: 100% coverage (LogRecord, Analytics)
- 🎯 Sync Service: Target 90%+
- 🎯 Providers: Target 80%+
- 🎯 Widgets: Target 75%+
- ✅ Integration: Critical paths covered
- ✅ E2E: User workflows covered

### Generating Coverage Reports

```bash
# Generate coverage
flutter test --coverage

# Convert to HTML (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

## 🚀 Running All Tests

### Quick Test Suite

```bash
# Unit tests only (fast)
flutter test

# Integration tests (medium)
flutter test integration_test/

# E2E tests (slow)
cd playwright && npm test
```

### Complete Test Suite

```bash
#!/bin/bash

echo "Running unit tests..."
flutter test --coverage

echo "Running integration tests..."
flutter test integration_test/

echo "Running E2E tests..."
cd playwright
npm test
cd ..

echo "All tests complete!"
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Run integration tests
        run: flutter test integration_test/

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      
      - name: Install dependencies
        run: |
          flutter pub get
          cd playwright && npm install
      
      - name: Install Playwright
        run: cd playwright && npx playwright install --with-deps
      
      - name: Run E2E tests
        run: cd playwright && npm test
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright/playwright-report/
```

## 🐛 Debugging Tests

### Unit Test Debugging

```bash
# Run specific test
flutter test test/services/log_record_service_test.dart

# Run with verbose output
flutter test --verbose

# Debug in IDE
# VS Code: Set breakpoint and press F5
# Android Studio: Right-click test → Debug
```

### Integration Test Debugging

```bash
# Run with verbose logging
flutter test integration_test/ --verbose

# Run on physical device
flutter drive --target=integration_test/logging_flow_test.dart
```

### E2E Test Debugging

```bash
cd playwright

# Run in UI mode (best for debugging)
npm run test:ui

# Run in headed mode
npm run test:headed

# Step through with inspector
npm run test:debug

# Add pause in test
await page.pause();
```

## 📝 Writing New Tests

### Model Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/your_model.dart';

void main() {
  group('YourModel', () {
    test('creates with default values', () {
      final model = YourModel();
      expect(model.field, expectedValue);
    });

    test('serializes to/from JSON', () {
      final model = YourModel(field: 'value');
      final json = model.toJson();
      final restored = YourModel.fromJson(json);
      expect(restored.field, model.field);
    });
  });
}
```

### Service Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/your_service.dart';
import 'package:ash_trail/services/isar_service.dart';

void main() {
  late IsarService isarService;
  late YourService service;

  setUp(() async {
    isarService = IsarService();
    await isarService.init(inMemory: true);
    service = YourService(isarService);
  });

  tearDown(() async {
    await isarService.close();
  });

  group('YourService', () {
    test('performs operation', () async {
      final result = await service.doSomething();
      expect(result, expectedValue);
    });
  });
}
```

### E2E Test Template

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  test('should do something', async ({ page }) => {
    await page.goto('/');
    await page.click('[data-testid="button"]');
    await expect(page.locator('text=Result')).toBeVisible();
  });
});
```

## 📚 Best Practices

### Unit Tests
- ✅ Use in-memory database for isolation
- ✅ Test one thing per test
- ✅ Use descriptive test names
- ✅ Clean up resources in tearDown
- ✅ Mock external dependencies

### Integration Tests
- ✅ Test critical user paths
- ✅ Keep tests independent
- ✅ Use realistic data
- ✅ Verify UI state changes

### E2E Tests
- ✅ Use data-testid attributes
- ✅ Implement Page Object Model
- ✅ Handle async operations properly
- ✅ Take screenshots on failure
- ✅ Test across browsers

## 🎯 Next Steps

### High Priority
1. ⏳ Add SyncService unit tests
2. ⏳ Add Provider tests
3. ⏳ Add Widget tests

### Medium Priority
4. ⏳ Increase integration test coverage
5. ⏳ Add accessibility tests
6. ⏳ Add performance tests

### Low Priority
7. ⏳ Add load testing
8. ⏳ Add security tests
9. ⏳ Add compatibility tests

## 📞 Support

For testing questions:
- Review existing tests for examples
- Check [Flutter testing docs](https://docs.flutter.dev/testing)
- Check [Playwright docs](https://playwright.dev/)
- Open an issue for clarification

## 📄 License

Same as project license.
