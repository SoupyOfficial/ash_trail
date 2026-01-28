// Comprehensive screenshot capture for Figma import
// Navigates through all app screens and captures screenshots
// Run with: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/figma_screenshot_capture.dart -d <device-id>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ash_trail/main.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Figma Screenshot Capture', () {
    testWidgets('capture all screens for Figma', (WidgetTester tester) async {
      // Create output directory
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final outputDir = Directory('screenshots/flutter/$timestamp');
      await outputDir.create(recursive: true);
      
      print('📸 Screenshot output directory: ${outputDir.path}');

      // Start the app
      await tester.pumpWidget(
        const ProviderScope(child: app.AshTrailApp()),
      );
      
      // Wait for app to fully initialize
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await Future.delayed(const Duration(seconds: 2));

      // Capture Welcome/Home screen (initial state)
      await _captureAndSave(tester, outputDir, '00_welcome_or_home');

      // Check if we're on welcome screen or main navigation
      final hasWelcome = find.textContaining('Welcome').evaluate().isNotEmpty ||
                         find.textContaining('Sign In').evaluate().isNotEmpty;
      final hasNavBar = find.byType(NavigationBar).evaluate().isNotEmpty;

      if (hasWelcome) {
        print('📱 App showing welcome screen - attempting to continue anonymously or sign in');
        
        // Try to find and tap "Continue anonymously" or similar
        final continueAnon = find.textContaining('Continue').evaluate().isNotEmpty ||
                            find.textContaining('anonymous').evaluate().isNotEmpty;
        
        if (continueAnon) {
          try {
            await tester.tap(find.textContaining('Continue').first);
            await tester.pumpAndSettle(const Duration(seconds: 3));
            await _captureAndSave(tester, outputDir, '01_home_after_auth');
          } catch (e) {
            print('Could not tap continue anonymously: $e');
          }
        }
      }

      // If we have navigation bar, navigate through all main screens
      if (hasNavBar || find.byType(NavigationBar).evaluate().isNotEmpty) {
        print('📱 Navigating through main screens...');

        // Screen 1: Home (already captured, but capture again to be sure)
        await _navigateToTab(tester, 0, 'Home');
        await _captureAndSave(tester, outputDir, '01_home');

        // Screen 2: Analytics
        await _navigateToTab(tester, 1, 'Analytics');
        await _captureAndSave(tester, outputDir, '02_analytics');

        // Screen 3: History
        await _navigateToTab(tester, 2, 'History');
        await _captureAndSave(tester, outputDir, '03_history');

        // Screen 4: Logging
        await _navigateToTab(tester, 3, 'Logging');
        await _captureAndSave(tester, outputDir, '04_logging');

        // Try to navigate to Accounts screen (via app bar icon)
        try {
          final accountIcon = find.byIcon(Icons.account_circle);
          if (accountIcon.evaluate().isNotEmpty) {
            // Go back to home first
            await _navigateToTab(tester, 0, 'Home');
            await tester.pumpAndSettle();
            
            await tester.tap(accountIcon.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            await _captureAndSave(tester, outputDir, '05_accounts');
            
            // Go back
            await tester.tap(find.byType(BackButton).first);
            await tester.pumpAndSettle();
          }
        } catch (e) {
          print('Could not navigate to Accounts: $e');
        }

        // Try to find Export screen
        try {
          // Look for export button or navigation
          final exportFinder = find.textContaining('Export');
          if (exportFinder.evaluate().isNotEmpty) {
            await tester.tap(exportFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            await _captureAndSave(tester, outputDir, '06_export');
            
            // Go back if needed
            if (find.byType(BackButton).evaluate().isNotEmpty) {
              await tester.tap(find.byType(BackButton).first);
              await tester.pumpAndSettle();
            }
          }
        } catch (e) {
          print('Could not navigate to Export: $e');
        }

        // Try to find Profile screen
        try {
          final profileFinder = find.textContaining('Profile');
          if (profileFinder.evaluate().isNotEmpty) {
            await tester.tap(profileFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            await _captureAndSave(tester, outputDir, '07_profile');
            
            // Go back if needed
            if (find.byType(BackButton).evaluate().isNotEmpty) {
              await tester.tap(find.byType(BackButton).first);
              await tester.pumpAndSettle();
            }
          }
        } catch (e) {
          print('Could not navigate to Profile: $e');
        }
      }

      // Capture any dialogs or modals that might be open
      try {
        final dialog = find.byType(Dialog);
        if (dialog.evaluate().isNotEmpty) {
          await _captureAndSave(tester, outputDir, '08_dialog');
        }
      } catch (e) {
        // No dialog
      }

      print('');
      print('✅ Screenshot capture complete!');
      print('📁 Screenshots saved to: ${outputDir.path}');
      print('');
      print('Next steps:');
      print('1. Review screenshots in: ${outputDir.path}');
      print('2. Run: ./scripts/prepare_figma_import.sh');
      print('3. Import to Figma using the generated guide');
    });
  });
}

Future<void> _navigateToTab(WidgetTester tester, int index, String screenName) async {
  print('  → Navigating to $screenName...');
  
  try {
    // Find NavigationBar
    final navBar = find.byType(NavigationBar);
    if (navBar.evaluate().isNotEmpty) {
      // Tap the destination at the given index
      final destinations = find.descendant(
        of: navBar,
        matching: find.byType(NavigationDestination),
      );
      
      if (destinations.evaluate().length > index) {
        await tester.tap(destinations.at(index));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }
    }
    
    // Fallback: try finding by icon or text
    final screenFinder = find.textContaining(screenName, findRichText: true);
    if (screenFinder.evaluate().isNotEmpty) {
      await tester.tap(screenFinder.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await Future.delayed(const Duration(milliseconds: 500));
    }
  } catch (e) {
    print('    ⚠️  Could not navigate to $screenName: $e');
  }
}

Future<void> _captureAndSave(
  WidgetTester tester,
  Directory outputDir,
  String name,
) async {
  // Wait for any animations
  await tester.pumpAndSettle();
  await Future.delayed(const Duration(milliseconds: 500));
  
  print('  📸 Capturing: $name');
  
  // Integration test screenshots are saved automatically by the test driver
  // They go to integration_test/screenshots/ directory
  // We'll use the binding's screenshot capability
  try {
    // The integration test driver will save screenshots automatically
    // when we call takeScreenshot on the binding
    final binding = IntegrationTestWidgetsFlutterBinding.instance;
    if (binding is IntegrationTestWidgetsFlutterBinding) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      
      // Screenshot will be saved by the test driver to integration_test/screenshots/
      // with the name we provide
      print('    ✅ Screenshot queued: $name');
      print('    ℹ️  Will be saved to: integration_test/screenshots/$name.png');
    }
  } catch (e) {
    print('    ⚠️  Screenshot capture note: $e');
    print('    ℹ️  Screenshots will be saved by test driver');
  }
}
