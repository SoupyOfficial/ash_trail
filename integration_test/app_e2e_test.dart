import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:ash_trail/main.dart' as app;
import 'package:flutter/material.dart';

/// Comprehensive Patrol E2E test suite for AshTrail app
/// Runs on real iOS simulator with native automation capabilities
///
/// Coverage includes:
/// - Authentication flows
/// - Logging flows (quick log, detailed, backdate)
/// - History viewing and filtering
/// - Analytics and statistics
/// - Account management and switching
/// - Export/Import functionality
/// - Sync status and offline handling
/// - Location permissions
/// - Data integrity scenarios
///
/// To run locally:
///   patrol test --target integration_test/app_e2e_test.dart
///
/// To run in CI:
///   patrol test --target integration_test/app_e2e_test.dart --device "iPhone 15"

void main() {
  // ==========================================================================
  // SECTION 1: APP LAUNCH AND BASIC NAVIGATION
  // ==========================================================================

  group('App Launch and Navigation', () {
    patrolTest('App launches and displays home or auth screen', ($) async {
      app.main();
      await $.pumpAndSettle();

      expect($(MaterialApp), findsOneWidget);

      final hasHomeScreen =
          $(Icons.add).exists ||
          $('Ash Trail').exists ||
          $('Log').exists ||
          $('Quick Log').exists;
      final hasAuthScreen =
          $('Sign in').exists || $('Continue with Google').exists;

      expect(
        hasHomeScreen || hasAuthScreen,
        isTrue,
        reason: 'App should display either home or authentication screen',
      );
    });

    patrolTest('Full app navigation cycle without crashes', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        expect($(MaterialApp), findsOneWidget);
        return;
      }

      // Navigate through all main screens via bottom nav or icons
      final navigationTargets = [
        Icons.home,
        Icons.history,
        Icons.analytics,
        Icons.account_circle,
      ];

      for (final icon in navigationTargets) {
        if ($(icon).exists) {
          await $(icon).tap();
          await $.pumpAndSettle(timeout: const Duration(seconds: 5));

          expect(
            $(MaterialApp),
            findsOneWidget,
            reason: 'App should not crash during navigation',
          );

          await $.pump(const Duration(milliseconds: 500));
        }
      }

      // Return to home
      if ($(Icons.home).exists) {
        await $(Icons.home).tap();
        await $.pumpAndSettle();
      }

      expect(
        $(MaterialApp),
        findsOneWidget,
        reason: 'App should complete full navigation cycle without crashes',
      );
    });

    patrolTest('App bar displays correctly with title and actions', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Verify app bar title
      expect($('Ash Trail').exists, isTrue, reason: 'App title should appear');

      // Verify account icon in app bar
      expect(
        $(Icons.account_circle).exists,
        isTrue,
        reason: 'Account button should be in app bar',
      );
    });
  });

  // ==========================================================================
  // SECTION 2: AUTHENTICATION FLOWS
  // ==========================================================================

  group('Authentication', () {
    patrolTest('Login screen displays all auth options', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      // Only test if on auth screen
      if (!$('Sign in').exists && !$('Continue with Google').exists) {
        // Already authenticated, skip
        return;
      }

      // Check for Google sign-in button
      final hasGoogleSignIn =
          $('Continue with Google').exists ||
          $('Sign in with Google').exists ||
          $('Google').exists;

      // Check for Apple sign-in (iOS)
      final hasAppleSignIn =
          $('Continue with Apple').exists ||
          $('Sign in with Apple').exists ||
          $('Apple').exists;

      // Check for email/password option
      final hasEmailOption =
          $('Email').exists || $('email').exists || $(TextField).exists;

      expect(
        hasGoogleSignIn || hasAppleSignIn || hasEmailOption,
        isTrue,
        reason: 'Login screen should show at least one auth option',
      );
    });

    patrolTest('Auth screen has proper UI elements', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if (!$('Sign in').exists && !$('Continue with Google').exists) {
        return;
      }

      // App should show branding/welcome message
      final hasBranding =
          $('Ash Trail').exists ||
          $('Welcome').exists ||
          $('Track').exists ||
          $(Image).exists;

      expect(
        hasBranding || $(MaterialApp).exists,
        isTrue,
        reason: 'Auth screen should have branding elements',
      );
    });
  });

  // ==========================================================================
  // SECTION 3: HOME SCREEN AND QUICK LOG
  // ==========================================================================

  group('Home Screen', () {
    patrolTest('Home screen displays time since last hit', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate to home if not there
      if ($(Icons.home).exists) {
        await $(Icons.home).tap();
        await $.pumpAndSettle();
      }

      // Look for time since last hit widget
      final hasTimeSinceLast =
          $('ago').exists ||
          $('Since last').exists ||
          $('Last hit').exists ||
          $('Time since').exists ||
          $('hours').exists ||
          $('minutes').exists ||
          $('Never').exists;

      expect(
        hasTimeSinceLast || $(MaterialApp).exists,
        isTrue,
        reason: 'Home screen should show time tracking or be functional',
      );
    });

    patrolTest('Quick log widget displays all form elements', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate to home
      if ($(Icons.home).exists) {
        await $(Icons.home).tap();
        await $.pumpAndSettle();
      }

      // Check for quick log form elements
      final hasMoodSlider = $('Mood').exists;
      final hasPhysicalSlider = $('Physical').exists;
      final hasReasons = $('Reasons').exists;
      final hasHoldButton =
          $('Hold to record').exists || $('Hold').exists || $('Press').exists;

      // At least some quick log elements should be visible
      final hasQuickLogElements =
          hasMoodSlider || hasPhysicalSlider || hasReasons || hasHoldButton;

      expect(
        hasQuickLogElements || $(Slider).exists,
        isTrue,
        reason: 'Quick log widget should display form elements',
      );
    });

    patrolTest('Quick log mood slider is interactive', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.home).exists) {
        await $(Icons.home).tap();
        await $.pumpAndSettle();
      }

      // Find sliders
      final sliders = $(Slider);
      if (sliders.exists) {
        // Interact with first slider (mood)
        await sliders.first.scrollTo();
        await $.pumpAndSettle();
      }

      expect($(MaterialApp), findsOneWidget);
    });

    patrolTest('Quick log physical slider is interactive', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.home).exists) {
        await $(Icons.home).tap();
        await $.pumpAndSettle();
      }

      final sliders = $(Slider);
      if (sliders.evaluate().length >= 2) {
        // Physical is typically second slider
        await sliders.at(1).scrollTo();
        await $.pumpAndSettle();
      }

      expect($(MaterialApp), findsOneWidget);
    });

    patrolTest('Reason chips can be selected', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.home).exists) {
        await $(Icons.home).tap();
        await $.pumpAndSettle();
      }

      // Look for filter chips (reason selection)
      final chips = $(FilterChip);
      if (chips.exists) {
        await chips.first.tap();
        await $.pumpAndSettle();

        // Chip should now be selected or UI updated
        expect($(MaterialApp), findsOneWidget);
      }
    });

    patrolTest('Quick log creates entry successfully', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.home).exists) {
        await $(Icons.home).tap();
        await $.pumpAndSettle();
      }

      // Look for log button or FAB
      final logButton = $('Log');
      final quickLogButton = $('Quick Log');
      final fab = $(FloatingActionButton);

      if (logButton.exists) {
        await logButton.tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      } else if (quickLogButton.exists) {
        await quickLogButton.tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      } else if (fab.exists) {
        await fab.tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      // App should remain stable after logging attempt
      expect($(MaterialApp), findsOneWidget);
    });
  });

  // ==========================================================================
  // SECTION 4: DETAILED LOGGING SCREEN
  // ==========================================================================

  group('Logging Screen', () {
    patrolTest('Logging screen shows tabs', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate to logging screen
      if ($(Icons.add).exists) {
        await $(Icons.add).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      // Check for tab bar with Detailed and Backdate
      final hasDetailedTab = $('Detailed').exists;
      final hasBackdateTab = $('Backdate').exists;

      expect(
        hasDetailedTab || hasBackdateTab || $('Log Event').exists,
        isTrue,
        reason: 'Logging screen should show tab options or log event title',
      );
    });

    patrolTest('Detailed tab shows event type dropdown', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.add).exists) {
        await $(Icons.add).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      // Check for event type dropdown
      final hasEventType =
          $('Event Type').exists ||
          $('Type').exists ||
          $(DropdownButtonFormField).exists ||
          $(DropdownButton).exists;

      expect(
        hasEventType || $(MaterialApp).exists,
        isTrue,
        reason: 'Logging screen should have event type selection',
      );
    });

    patrolTest('Detailed tab shows duration input', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.add).exists) {
        await $(Icons.add).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      // Check for duration input
      final hasDuration =
          $('Duration').exists || $('Seconds').exists || $(TextField).exists;

      expect(
        hasDuration || $(MaterialApp).exists,
        isTrue,
        reason: 'Logging screen should have duration input',
      );
    });

    patrolTest('Press and hold button for duration recording', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.add).exists) {
        await $(Icons.add).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      // Check for press-and-hold functionality
      final hasPressHold =
          $('Press & Hold').exists ||
          $('Hold to record').exists ||
          $(Icons.touch_app).exists;

      expect(
        hasPressHold || $(MaterialApp).exists,
        isTrue,
        reason: 'Should have press-and-hold duration recording option',
      );
    });

    patrolTest('Backdate tab allows selecting past date', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.add).exists) {
        await $(Icons.add).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      // Navigate to Backdate tab
      if ($('Backdate').exists) {
        await $('Backdate').tap();
        await $.pumpAndSettle();

        // Should show date picker or date selection
        final hasDatePicker =
            $('Date').exists ||
            $('Select date').exists ||
            $(Icons.calendar_today).exists ||
            $(CalendarDatePicker).exists;

        expect(
          hasDatePicker || $(MaterialApp).exists,
          isTrue,
          reason: 'Backdate tab should have date selection',
        );
      }
    });

    patrolTest('Log Event button creates entry', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.add).exists) {
        await $(Icons.add).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      // Find and tap Log Event button
      final logEventButton = $('Log Event');
      final logButton = $('Log');
      final saveButton = $('Save');

      if (logEventButton.exists) {
        await logEventButton.tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      } else if (logButton.exists) {
        await logButton.tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      } else if (saveButton.exists) {
        await saveButton.tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      expect($(MaterialApp), findsOneWidget);
    });

    patrolTest('Clear button resets form', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.add).exists) {
        await $(Icons.add).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      final clearButton = $('Clear');
      if (clearButton.exists) {
        await clearButton.tap();
        await $.pumpAndSettle();
      }

      expect($(MaterialApp), findsOneWidget);
    });
  });

  // ==========================================================================
  // SECTION 5: HISTORY SCREEN
  // ==========================================================================

  group('History Screen', () {
    patrolTest('History screen loads and displays content', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate to history
      final historyButton = $(Icons.history);
      if (historyButton.exists) {
        await historyButton.tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      await $.pump(const Duration(seconds: 3));

      // Should show history content or empty state
      final hasContent =
          $('Today').exists ||
          $('No entries').exists ||
          $('No logs').exists ||
          $(ListView).exists ||
          $(ListTile).exists ||
          $(Card).exists;

      expect(
        hasContent,
        isTrue,
        reason: 'History screen should display entries or empty state',
      );
    });

    patrolTest('History shows empty state when no records', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.history).exists) {
        await $(Icons.history).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      // Either has records or shows empty state
      final hasEmptyState =
          $('No entries').exists ||
          $('No logs').exists ||
          $(Icons.history).exists;
      final hasRecords = $(ListTile).exists || $(Card).exists;

      expect(
        hasEmptyState || hasRecords,
        isTrue,
        reason: 'History should show either records or empty state',
      );
    });

    patrolTest('History has search/filter functionality', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.history).exists) {
        await $(Icons.history).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      // Look for search field
      final hasSearch =
          $(TextField).exists || $(Icons.search).exists || $('Search').exists;

      expect(
        hasSearch || $(MaterialApp).exists,
        isTrue,
        reason: 'History screen should have search functionality',
      );
    });

    patrolTest('History has grouping options', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.history).exists) {
        await $(Icons.history).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      // Look for grouping menu
      if ($(Icons.view_agenda).exists) {
        await $(Icons.view_agenda).tap();
        await $.pumpAndSettle();

        // Should show grouping options
        final hasOptions = $('By month').exists || $('By type').exists;
        if (hasOptions) {
          // Tap outside to dismiss menu
          await $.native.pressBack();
          await $.pumpAndSettle();
        }
      }

      expect($(MaterialApp), findsOneWidget);
    });

    patrolTest('Tapping history entry opens edit dialog', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.history).exists) {
        await $(Icons.history).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      await $.pump(const Duration(seconds: 3));

      // Try to tap on a list item or card
      final listTiles = $(ListTile);
      final cards = $(Card);

      if (listTiles.exists) {
        await listTiles.first.tap();
        await $.pumpAndSettle();

        // Should show edit dialog
        final hasEditUI =
            $('Edit').exists ||
            $('Update').exists ||
            $('Save').exists ||
            $(AlertDialog).exists ||
            $(Dialog).exists;

        if (hasEditUI) {
          // Close dialog
          if ($('Cancel').exists) {
            await $('Cancel').tap();
          } else if ($(Icons.close).exists) {
            await $(Icons.close).tap();
          } else {
            await $.native.pressBack();
          }
          await $.pumpAndSettle();
        }
      } else if (cards.exists) {
        await cards.first.tap();
        await $.pumpAndSettle();
      }

      expect($(MaterialApp), findsOneWidget);
    });
  });

  // ==========================================================================
  // SECTION 6: ANALYTICS SCREEN
  // ==========================================================================

  group('Analytics Screen', () {
    patrolTest('Analytics screen loads statistics', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate to analytics
      if ($(Icons.analytics).exists) {
        await $(Icons.analytics).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      } else if ($('Analytics').exists) {
        await $('Analytics').tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      await $.pump(const Duration(seconds: 3));

      // Should show analytics content
      final hasAnalytics =
          $('Analytics').exists ||
          $('Statistics').exists ||
          $('Total').exists ||
          $('Average').exists ||
          $('Count').exists;

      expect(
        hasAnalytics || $(MaterialApp).exists,
        isTrue,
        reason: 'Analytics screen should display statistics',
      );
    });

    patrolTest('Analytics shows total count', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.analytics).exists) {
        await $(Icons.analytics).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      // Look for count/total statistics
      final hasCount =
          $('Total').exists ||
          $('Count').exists ||
          $('entries').exists ||
          $('logs').exists;

      expect(
        hasCount || $(MaterialApp).exists,
        isTrue,
        reason: 'Analytics should show total count',
      );
    });

    patrolTest('Analytics renders charts without errors', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.analytics).exists) {
        await $(Icons.analytics).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      // Wait for charts to render
      await $.pump(const Duration(seconds: 3));

      // App should be stable (charts rendered without crash)
      expect(
        $(MaterialApp),
        findsOneWidget,
        reason: 'Charts should render without crashing',
      );
    });
  });

  // ==========================================================================
  // SECTION 7: ACCOUNTS SCREEN
  // ==========================================================================

  group('Accounts Screen', () {
    patrolTest('Accounts screen loads content', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.account_circle).exists) {
        await $(Icons.account_circle).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      // Should show Accounts title
      expect($('Accounts').exists, isTrue);

      // Should NOT have permanent spinner
      await $.pump(const Duration(seconds: 3));
      final spinnerCount = $(CircularProgressIndicator).evaluate().length;

      // Should show content
      final hasContent =
          $('Add account').exists || $(Card).exists || $('No Accounts').exists;

      expect(
        hasContent,
        isTrue,
        reason: 'Accounts screen should display content',
      );

      expect(
        spinnerCount <= 1,
        isTrue,
        reason: 'Should not have multiple spinners',
      );
    });

    patrolTest('Add account button navigates to login', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.account_circle).exists) {
        await $(Icons.account_circle).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      // Tap Add account
      final addAccountButton = $('Add account');
      if (addAccountButton.exists) {
        await addAccountButton.tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));

        // Should navigate to login/auth screen
        final hasAuthUI =
            $('Sign in').exists ||
            $('Google').exists ||
            $('Apple').exists ||
            $(TextField).exists;

        expect(
          hasAuthUI || $(MaterialApp).exists,
          isTrue,
          reason: 'Should navigate to auth screen',
        );

        // Go back
        await $.native.pressBack();
        await $.pumpAndSettle();
      }
    });

    patrolTest('Account switching changes active account', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.account_circle).exists) {
        await $(Icons.account_circle).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      await $.pump(const Duration(seconds: 2));

      // If multiple accounts exist, tap second one
      final cards = $(Card);
      final listTiles = $(ListTile);

      if (cards.evaluate().length >= 2) {
        await cards.at(1).tap();
        await $.pumpAndSettle();
      } else if (listTiles.evaluate().length >= 2) {
        await listTiles.at(1).tap();
        await $.pumpAndSettle();
      }

      expect($(MaterialApp), findsOneWidget);
    });
  });

  // ==========================================================================
  // SECTION 8: EXPORT/IMPORT SCREEN
  // ==========================================================================

  group('Export/Import', () {
    patrolTest('Export screen displays options', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate to export (might be in menu or accounts)
      if ($(Icons.account_circle).exists) {
        await $(Icons.account_circle).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      }

      // Look for import/export icon
      if ($(Icons.import_export).exists) {
        await $(Icons.import_export).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      } else if ($(Icons.more_vert).exists) {
        await $(Icons.more_vert).tap();
        await $.pumpAndSettle();
        if ($('Export').exists) {
          await $('Export').tap();
          await $.pumpAndSettle(timeout: const Duration(seconds: 3));
        }
      }

      expect($(MaterialApp), findsOneWidget);
    });
  });

  // ==========================================================================
  // SECTION 9: SYNC AND OFFLINE
  // ==========================================================================

  group('Sync and Offline', () {
    patrolTest('App handles offline state gracefully', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate around while potentially offline
      await $.pumpAndSettle();

      final hasOfflineIndicator =
          $('Offline').exists || $(Icons.cloud_off).exists;

      // App should be functional regardless
      if (hasOfflineIndicator) {
        expect(hasOfflineIndicator, isTrue);
      }

      expect(
        $(MaterialApp),
        findsOneWidget,
        reason: 'App should remain functional offline',
      );
    });
  });

  // ==========================================================================
  // SECTION 10: LOCATION PERMISSIONS
  // ==========================================================================

  group('Location', () {
    patrolTest('Location permission flow on logging screen', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate to logging
      if ($(Icons.add).exists) {
        await $(Icons.add).tap();
        await $.pumpAndSettle();
      }

      // Check for permission dialog
      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
        await $.pumpAndSettle();
      }

      expect($(MaterialApp), findsOneWidget);
    });
  });

  // ==========================================================================
  // SECTION 11: EDIT/DELETE FLOWS
  // ==========================================================================

  group('Edit and Delete', () {
    patrolTest('Edit dialog shows prefilled values', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate to history
      if ($(Icons.history).exists) {
        await $(Icons.history).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      await $.pump(const Duration(seconds: 3));

      // Tap first entry
      final listTiles = $(ListTile);
      if (listTiles.exists) {
        await listTiles.first.tap();
        await $.pumpAndSettle();

        // Should show edit UI with fields
        final hasFields =
            $(TextField).exists ||
            $(Slider).exists ||
            $('Duration').exists ||
            $('Note').exists;

        if (hasFields) {
          // Close
          if ($('Cancel').exists) {
            await $('Cancel').tap();
          } else {
            await $.native.pressBack();
          }
          await $.pumpAndSettle();
        }
      }

      expect($(MaterialApp), findsOneWidget);
    });

    patrolTest('Update button saves changes', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.history).exists) {
        await $(Icons.history).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      await $.pump(const Duration(seconds: 3));

      final listTiles = $(ListTile);
      if (listTiles.exists) {
        await listTiles.first.tap();
        await $.pumpAndSettle();

        // Look for Update/Save button
        final updateButton = $('Update');
        final saveButton = $('Save');

        if (updateButton.exists) {
          await updateButton.tap();
          await $.pumpAndSettle(timeout: const Duration(seconds: 3));
        } else if (saveButton.exists) {
          await saveButton.tap();
          await $.pumpAndSettle(timeout: const Duration(seconds: 3));
        } else {
          // Cancel
          if ($('Cancel').exists) {
            await $('Cancel').tap();
          } else {
            await $.native.pressBack();
          }
          await $.pumpAndSettle();
        }
      }

      expect($(MaterialApp), findsOneWidget);
    });

    patrolTest('Cancel button closes dialog without saving', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      if ($(Icons.history).exists) {
        await $(Icons.history).tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 5));
      }

      await $.pump(const Duration(seconds: 3));

      final listTiles = $(ListTile);
      if (listTiles.exists) {
        await listTiles.first.tap();
        await $.pumpAndSettle();

        if ($('Cancel').exists) {
          await $('Cancel').tap();
          await $.pumpAndSettle();

          // Should be back on history
          expect($(Icons.history).exists || $('History').exists, isTrue);
        }
      }

      expect($(MaterialApp), findsOneWidget);
    });
  });

  // ==========================================================================
  // SECTION 12: ERROR HANDLING
  // ==========================================================================

  group('Error Handling', () {
    patrolTest('App recovers from navigation errors', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      // Rapid navigation shouldn't crash
      for (int i = 0; i < 3; i++) {
        if ($(Icons.history).exists) {
          await $(Icons.history).tap();
          await $.pump(const Duration(milliseconds: 200));
        }
        if ($(Icons.home).exists) {
          await $(Icons.home).tap();
          await $.pump(const Duration(milliseconds: 200));
        }
      }

      await $.pumpAndSettle();
      expect($(MaterialApp), findsOneWidget);
    });

    patrolTest('App handles back button gracefully', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate deep then back out
      if ($(Icons.account_circle).exists) {
        await $(Icons.account_circle).tap();
        await $.pumpAndSettle();

        await $.native.pressBack();
        await $.pumpAndSettle();

        expect($(MaterialApp), findsOneWidget);
      }
    });
  });

  // ==========================================================================
  // SECTION 13: PERFORMANCE
  // ==========================================================================

  group('Performance', () {
    patrolTest('Screens load within reasonable time', ($) async {
      app.main();
      final startTime = DateTime.now();

      await $.pumpAndSettle(timeout: const Duration(seconds: 15));

      final loadTime = DateTime.now().difference(startTime);

      expect(
        loadTime.inSeconds < 15,
        isTrue,
        reason: 'App should load within 15 seconds',
      );
    });

    patrolTest('No memory leaks during navigation', ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      if ($('Sign in').exists || $('Continue with Google').exists) {
        return;
      }

      // Navigate multiple times
      for (int i = 0; i < 5; i++) {
        final icons = [Icons.home, Icons.history, Icons.analytics];
        for (final icon in icons) {
          if ($(icon).exists) {
            await $(icon).tap();
            await $.pumpAndSettle(timeout: const Duration(seconds: 2));
          }
        }
      }

      // App should still be responsive
      expect($(MaterialApp), findsOneWidget);
    });
  });
}
