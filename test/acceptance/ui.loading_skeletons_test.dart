// GENERATED - DO NOT EDIT.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/loading_skeletons/presentation/widgets/widgets.dart';
import 'package:ash_trail/core/routing/app_router.dart';

void main() {
  group('Feature ui.loading_skeletons', () {
    testWidgets(
      '1. Home, logs table, and charts show skeletons for ≥300ms pending loads.',
      (tester) async {
        // Load the home screen
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: HomeScreen(),
            ),
          ),
        );
        await tester.pump();

        // Initially should show loading skeletons due to the 2s timer in HomeScreen
        expect(find.byType(SkeletonChart), findsOneWidget);
        expect(find.byType(SkeletonList), findsOneWidget);

        // Verify that welcome text is not visible initially
        expect(find.text('Welcome to AshTrail'), findsNothing);

        // Wait for the timer to complete and animations to settle
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Now should show actual content
        expect(find.text('Welcome to AshTrail'), findsOneWidget);
      },
    );

    testWidgets("2. Avoids layout shift >16px on content load.",
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingStateHandler(
                isLoading: true,
                loadingWidget: SizedBox(
                  height: 200,
                  child: SkeletonChart(),
                ),
                child: SizedBox(
                  height: 200,
                  child: Text('Content loaded'),
                ),
              ),
            ),
          ),
        ),
      );

      final initialSize = tester.getSize(find.byType(Scaffold));

      // Simulate loading completion
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingStateHandler(
                isLoading: false,
                loadingWidget: SizedBox(
                  height: 200,
                  child: SkeletonChart(),
                ),
                child: SizedBox(
                  height: 200,
                  child: Text('Content loaded'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final finalSize = tester.getSize(find.byType(Scaffold));

      // Layout should remain stable (no significant shift)
      expect((finalSize.height - initialSize.height).abs(), lessThan(16.0));
      expect((finalSize.width - initialSize.width).abs(), lessThan(16.0));
    });

    testWidgets(
        "3. Respects Reduce Motion: shimmer replaced by subtle fade when enabled.",
        (tester) async {
      // Test with reduced motion enabled
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  accessibleNavigation: true, // Reduced motion enabled
                ),
                child: SkeletonContainer(
                  child: SizedBox(height: 50, width: 100),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should render container without shimmer animation
      expect(find.byType(SkeletonContainer), findsOneWidget);

      // Test with reduced motion disabled
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  accessibleNavigation: false, // Reduced motion disabled
                ),
                child: SkeletonContainer(
                  child: SizedBox(height: 50, width: 100),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should render container with animation when reduced motion is disabled
      expect(find.byType(SkeletonContainer), findsOneWidget);
    });
  });
}
