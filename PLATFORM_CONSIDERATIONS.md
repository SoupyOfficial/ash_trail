# Platform Considerations for AshTrail

## Database Platform Support

### Isar Database Limitations

AshTrail uses **Isar** as its local NoSQL database. Isar provides excellent performance on native platforms but has important limitations:

#### ✅ Supported Platforms
- iOS
- Android
- macOS
- Linux
- Windows

#### ❌ NOT Supported
- **Web** (Chrome, Safari, Firefox, Edge, etc.)
- Dart VM standalone (non-Flutter contexts)

### Why This Matters

The choice of Isar means the app cannot run on web browsers. If web support is required in the future, you would need to:

1. **Option A:** Add conditional compilation to use a different database for web
   - Use IndexedDB or Hive for web
   - Create an abstraction layer for database operations
   
2. **Option B:** Switch to a cross-platform database
   - Consider Hive (supports web but less performant)
   - Consider cloud-only storage (Firebase/Firestore)

## Impact on Testing

### Test Compatibility Matrix

| Test Category | Platforms | Status | Notes |
|--------------|-----------|--------|-------|
| **Model Tests** | All | ✅ Works | No database required |
| **Service Tests** | Native only | ⚠️ Limited | Requires Isar |
| **Integration Tests** | Native only | ⚠️ Limited | Requires Isar |
| **E2E Tests (Playwright)** | Web + Native | ✅ Works | Browser-based |

### Running Tests by Platform

```bash
# ✅ Works on ALL platforms (including Web)
flutter test test/models/

# ⚠️ Only works on native platforms (will FAIL on Web)
flutter test test/services/
flutter test integration_test/

# ✅ E2E tests work on Web
cd e2e
npx playwright test
```

### Test Results (macOS)

All model tests passing:
```
✅ log_record_test.dart      - 11 tests passing
✅ daily_rollup_test.dart    - 4 tests passing  
✅ range_query_spec_test.dart - 14 tests passing
---
Total: 29 tests passing
```

Service tests require native platform setup (Isar native library).

## Development Recommendations

### For Current Setup (Native Only)

Continue using Isar for best performance on mobile and desktop platforms.

### If Web Support Needed

1. **Create database abstraction layer:**
   ```dart
   abstract class DatabaseService {
     Future<void> init();
     Future<T> save<T>(T object);
     Future<T?> get<T>(String id);
     // ...
   }
   
   class IsarDatabaseService implements DatabaseService { /* Native */ }
   class HiveDatabaseService implements DatabaseService { /* Web */ }
   ```

2. **Use conditional imports:**
   ```dart
   import 'database_service_stub.dart'
       if (dart.library.io) 'database_service_isar.dart'
       if (dart.library.html) 'database_service_hive.dart';
   ```

3. **Update tests to use abstraction:**
   - Mock database service in tests
   - Platform-specific test suites

## Migration Path (If Needed)

If you decide to add web support later:

1. **Phase 1:** Create abstraction layer
2. **Phase 2:** Implement web-compatible database (Hive/IndexedDB)
3. **Phase 3:** Update tests to use mocked database
4. **Phase 4:** Add web-specific E2E tests

## Current Status

✅ **Native platforms fully supported** with high-performance Isar database
⚠️ **Web platform not supported** - by design choice
📝 **Tests adapted** to skip service tests on unsupported platforms
🎯 **E2E tests ready** for cross-platform validation

## References

- [Isar Documentation](https://isar.dev)
- [Isar Platform Support](https://isar.dev/tutorials/quickstart.html#platform-support)
- [Flutter Platform-Specific Code](https://docs.flutter.dev/development/platform-integration/platform-channels)
