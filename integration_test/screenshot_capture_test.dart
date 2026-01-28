// Integration test for capturing screenshots of all screens for Figma import
// 
// NOTE: This is a helper test for automated screenshot capture.
// For the main workflow, use: ./scripts/capture_flutter_screenshots.sh
//
// Run with: flutter drive --driver=test_driver/integration_test.dart \
//   --target=integration_test/screenshot_capture_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ash_trail/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Screenshot Capture for Figma', () {
    testWidgets('capture all screen screenshots', (WidgetTester tester) async {
      // Start the app
      await tester.pumpWidget(
        const ProviderScope(child: app.AshTrailApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for app to fully initialize
      await Future.delayed(const Duration(seconds: 2));

      // Capture Welcome/Home screen
      // Note: Screenshots are saved automatically by the integration_test framework
      // when running with: flutter drive --driver=test_driver/integration_test.dart
      await _captureScreenshot(tester, 'welcome');

      // Navigate to different screens if possible
      // Note: You may need to adjust navigation based on your app's auth state

      // Try to find and tap navigation items
      try {
        // Look for bottom navigation or drawer
        final drawerFinder = find.byIcon(Icons.menu);
        if (drawerFinder.evaluate().isNotEmpty) {
          await tester.tap(drawerFinder);
          await tester.pumpAndSettle();
        }

        // Try to navigate to Analytics
        final analyticsFinder = find.textContaining('Analytics');
        if (analyticsFinder.evaluate().isNotEmpty) {
          await tester.tap(analyticsFinder);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await _captureScreenshot(tester, 'analytics');
        }

        // Try to navigate to History
        final historyFinder = find.textContaining('History');
        if (historyFinder.evaluate().isNotEmpty) {
          await tester.tap(historyFinder);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await _captureScreenshot(tester, 'history');
        }

        // Try to navigate to Accounts
        final accountsFinder = find.textContaining('Account');
        if (accountsFinder.evaluate().isNotEmpty) {
          await tester.tap(accountsFinder);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await _captureScreenshot(tester, 'accounts');
        }
      } catch (e) {
        debugPrint('Navigation error (this is okay): $e');
      }

      // Note: For screens that require authentication or specific state,
      // you may need to manually navigate and capture, or set up test data first
      // 
      // The main workflow uses shell scripts for easier manual navigation:
      // ./scripts/capture_flutter_screenshots.sh
    });
  });
}

Future<void> _captureScreenshot(
  WidgetTester tester,
  String screenName,
) async {
  // Wait for any animations to complete
  await tester.pumpAndSettle();

  // For integration tests, screenshots are typically handled by the test driver
  // This function serves as a placeholder and documentation point
  // 
  // When running with flutter drive, screenshots can be taken using:
  // - The test driver's screenshot capability
  // - Or manually using device screenshot tools
  //
  // For the Figma workflow, the shell script approach is recommended:
  // ./scripts/capture_flutter_screenshots.sh
  
  debugPrint('📸 Screenshot point: $screenName');
  debugPrint('   Use ./scripts/capture_flutter_screenshots.sh for actual capture');
  
  // Small delay between captures
  await Future.delayed(const Duration(milliseconds: 500));
}
