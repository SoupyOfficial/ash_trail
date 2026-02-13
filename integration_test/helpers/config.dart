import 'package:patrol/patrol.dart';

// ─── Test credentials ────────────────────────────────────────────────────────
const testEmail = 'test1@ashtrail.dev';
const testPassword = 'TestPass123!';

const testEmail2 = 'test2@ashtrail.dev';
const testPassword2 = 'TestPass456!';

// Account 4 (Gmail — Google Sign-In)
const testEmail4 = 'ashtraildev3@gmail.com';
const testPassword4 = 'AshTestPass123!';

// Account 5 (Gmail — Google Sign-In)
// const testEmail5 = 'ashtraildev4@gmail.com';
// const testPassword5 = 'AshTestPass456!';
// Account 5 (Gmail — Google Sign-In)
const testEmail5 = 'soupsterx@live.com';
const testPassword5 = 'Achieve23!';

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
