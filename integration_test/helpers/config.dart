import 'package:patrol/patrol.dart';

// ─── Test credentials ────────────────────────────────────────────────────────
const testEmail = 'test1@ashtrail.dev';
const testPassword = 'TestPass123!';

const testEmail2 = 'test2@ashtrail.dev';
const testPassword2 = 'TestPass456!';

// ─── Patrol configuration ────────────────────────────────────────────────────

/// Default PatrolTesterConfig shared across all E2E tests.
const defaultPatrolConfig = PatrolTesterConfig(
  settleTimeout: Duration(seconds: 15),
  existsTimeout: Duration(seconds: 15),
  printLogs: true,
);

/// Default NativeAutomatorConfig for iOS/Android native interactions.
const defaultNativeConfig = NativeAutomatorConfig(
  packageName: 'com.soup.smokeLog',
  bundleId: 'com.soup.smokeLog',
);
