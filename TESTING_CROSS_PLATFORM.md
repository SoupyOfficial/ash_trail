# Cross-Platform Testing Guide

## Overview
All tests in this project use **Hive** database, which works on **ALL platforms**:
- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ iOS
- ✅ Android  
- ✅ macOS
- ✅ Linux
- ✅ Windows

## Running Tests

### Run all tests (works on all platforms)
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/services/log_record_service_test.dart
```

### Run tests in Chrome (web platform)
```bash
flutter test --platform chrome
```

### Run widget tests
```bash
flutter test test/widgets/
```

### Run with coverage
```bash
flutter test --coverage
```

## Test Structure

### Unit Tests (Platform-Independent)
- `test/models/` - Model serialization and business logic
- `test/services/` - Service layer with Hive database

### Widget Tests (Platform-Independent)
- `test/widgets/` - Widget rendering and interactions
- `test/screens/` - Screen-level integration

### Integration Tests (Platform-Specific)
- `integration_test/` - Full app flows (run on specific device/browser)

## Writing Cross-Platform Tests

### Use Test Helpers
```dart
import '../test_helpers.dart';

setUp(() async {
  await initializeHiveForTest();
  final box = await createTestBox('my_test_box');
  // ... setup
});

tearDown() async {
  await cleanupTestBox(box);
});
```

### ✅ Do This (Cross-Platform)
```dart
// Use Hive - works everywhere
import 'package:hive/hive.dart';
import 'package:ash_trail/repositories/log_record_repository_hive.dart';

final box = await Hive.openBox('test_box');
final repository = LogRecordRepositoryHive({'logRecords': box});
```

### ❌ Don't Do This (Platform-Specific)
```dart
// DON'T use dart:io Platform - doesn't work on web
import 'dart:io';
if (Platform.isAndroid) { ... }

// DON'T use Isar - doesn't work on web
import 'package:isar/isar.dart';
```

## Current Test Coverage

### ✅ Fully Cross-Platform (Web + Mobile)
- `test/services/log_record_service_test.dart` (38 tests)
- `test/widgets/quick_log_widget_test.dart`
- `test/models/*_test.dart`
- `test/widget_test.dart`

### ⚠️ Deprecated (Old Isar-based)
- `*.dart.old` files - kept for reference only

## Platform-Specific Testing

### Web Browser Testing
```bash
# Test in Chrome
flutter test --platform chrome

# Test with hot reload
flutter run -d chrome
```

### Mobile Device Testing  
```bash
# iOS Simulator
flutter test
flutter run -d ios

# Android Emulator
flutter test
flutter run -d android
```

### Integration Tests
```bash
# Web
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart -d chrome

# Mobile
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart -d <device-id>
```

## Continuous Integration

All tests run automatically on:
- Every commit (web + mobile platforms)
- Pull requests
- Pre-deployment checks

## Best Practices

1. **Always use Hive** - It's cross-platform and consistent
2. **Avoid platform checks** - Write tests that work everywhere
3. **Use test_helpers.dart** - Standardized test setup
4. **Test in browser** - Run `flutter test --platform chrome` regularly
5. **Mock external dependencies** - Keep tests fast and reliable
6. **Clean up resources** - Always dispose repositories and close boxes

## Troubleshooting

### Tests fail on web but pass on mobile
- Check for `dart:io` imports (not available on web)
- Verify no native-only plugins are used
- Ensure Hive boxes are properly initialized

### Database errors in tests
- Make sure each test uses unique box names
- Always clean up boxes in tearDown
- Use `test_helpers.dart` functions for consistency

### Widget tests timing out
- Use `await tester.pumpAndSettle()`
- Check for infinite animations
- Verify async operations complete

## Migration Notes

The project migrated from Isar (native-only) to Hive (cross-platform) to support web deployment. All new tests should use Hive. Old Isar-based tests are marked with `.old` extension and kept for reference only.
