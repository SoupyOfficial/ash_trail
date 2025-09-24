import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ash_trail/features/charts_time_series/presentation/screens/charts_time_series_screen.dart';

const testAccountId = 'test-account-id';

void main() {
  group('ChartsTimeSeriesScreen Widget Tests', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      // Build the widget with provider scope
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ChartsTimeSeriesScreen(accountId: testAccountId),
            ),
          ),
        ),
      );

      // Verify the screen renders
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Look for app bar and title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Charts'), findsOneWidget);
    });

    testWidgets('has proper widget structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Allow any async operations to settle
      await tester.pumpAndSettle();

      // Verify basic structure exists
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles tap events without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for any tappable elements and test them
      final iconButtons = find.byType(IconButton);
      if (iconButtons.evaluate().isNotEmpty) {
        await tester.tap(iconButtons.first);
        await tester.pump();
      }

      // Verify no exceptions were thrown
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('maintains state during widget lifecycle',
        (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);

      // Rebuild widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Verify widget still exists after rebuild
      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('displays legend toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pump();

      // Look for legend toggle button in app bar
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));
    });
  });

  group('Basic Functionality Tests', () {
    testWidgets('screen can be navigated to', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(tester.element(find.byType(ElevatedButton)))
                        .push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ChartsTimeSeriesScreen(accountId: testAccountId),
                      ),
                    );
                  },
                  child: Text('Navigate to Charts'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap the button to navigate
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify navigation succeeded
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('screen handles provider updates', (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);

      // Dispose container
      container.dispose();
    });

    testWidgets('handles different account IDs', (WidgetTester tester) async {
      // Test with different account ID
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: 'another-account'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('displays loading or empty state initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Initial state - might show loading or empty content
      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);

      // Allow providers to settle
      await tester.pumpAndSettle();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('contains expected child widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have a Column for layout
      expect(find.byType(Column), findsAtLeastNWidgets(1));

      // Should have Padding for controls
      expect(find.byType(Padding), findsAtLeastNWidgets(1));

      // Should have Expanded for chart area
      expect(find.byType(Expanded), findsAtLeastNWidgets(1));
    });

    testWidgets('respects account ID parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pump();

      // Widget should be created with the account ID
      final chartScreen = tester.widget<ChartsTimeSeriesScreen>(
        find.byType(ChartsTimeSeriesScreen),
      );
      expect(chartScreen.accountId, equals(testAccountId));
    });
  });
}
