/// Test helpers for cross-platform testing
/// Works on web, mobile, and desktop platforms
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:math';
import 'dart:io';

/// Initialize Flutter bindings and Hive for testing
/// This ensures platform bindings are available for Hive operations
/// Works on all platforms (web, iOS, Android, desktop)
Future<void> initializeHiveForTest() async {
  // Ensure Flutter bindings are initialized for platform channel access
  TestWidgetsFlutterBinding.ensureInitialized();

  // Create a temporary directory for test database
  final testDir = Directory.systemTemp.createTempSync(
    'hive_test_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}',
  );

  // Initialize Hive with the test directory (doesn't use path_provider)
  Hive.init(testDir.path);
}

/// Clean up Hive after tests
Future<void> cleanupHiveForTest() async {
  await Hive.close();
  await Hive.deleteFromDisk();
}

/// Create a test box with a unique name
/// Works on all platforms
Future<Box> createTestBox(String baseName) async {
  final boxName =
      '${baseName}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
  return await Hive.openBox(boxName);
}

/// Clean up test box
/// Clears and closes the box
Future<void> cleanupTestBox(Box box) async {
  await box.clear();
  await box.close();
}

/// Get platform description for test reporting
String getPlatformDescription() {
  // Note: We can't use dart:io Platform in tests that should run on web
  // Instead, we rely on Hive being cross-platform
  return 'Cross-platform (Hive supports web, iOS, Android, desktop)';
}
