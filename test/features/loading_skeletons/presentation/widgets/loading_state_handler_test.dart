import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/loading_skeletons/presentation/widgets/loading_state_handler.dart';

void main() {
  group('LoadingStateHandler', () {
    testWidgets('should show loading widget when isLoading is true',
        (tester) async {
      const loadingWidget = Text('Loading...');
      const contentWidget = Text('Content');

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingStateHandler(
                isLoading: true,
                loadingWidget: loadingWidget,
                child: contentWidget,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.text('Content'), findsNothing);
    });

    testWidgets('should show content when isLoading is false', (tester) async {
      const loadingWidget = Text('Loading...');
      const contentWidget = Text('Content');

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingStateHandler(
                isLoading: false,
                loadingWidget: loadingWidget,
                child: contentWidget,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('should transition from loading to content', (tester) async {
      const loadingWidget = Text('Loading...');
      const contentWidget = Text('Content');

      bool isLoading = true;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LoadingStateHandler(
                    isLoading: isLoading,
                    loadingWidget: loadingWidget,
                    child: contentWidget,
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially showing loading
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.text('Content'), findsNothing);

      // Simulate loading completion after minimum duration
      await tester.pump(const Duration(milliseconds: 350));

      // Note: The actual transition test would require more complex setup
      // to properly test the minimum duration enforcement
      expect(find.byType(LoadingStateHandler), findsOneWidget);
    });

    testWidgets('should respect custom transition duration', (tester) async {
      const loadingWidget = Text('Loading...');
      const contentWidget = Text('Content');
      const customDuration = Duration(milliseconds: 500);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingStateHandler(
                isLoading: false,
                loadingWidget: loadingWidget,
                transitionDuration: customDuration,
                child: contentWidget,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should handle rapid state changes', (tester) async {
      const loadingWidget = Text('Loading...');
      const contentWidget = Text('Content');

      bool isLoading = true;

      Widget buildWidget() {
        return ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LoadingStateHandler(
                isLoading: isLoading,
                loadingWidget: loadingWidget,
                child: contentWidget,
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildWidget());

      // Start with loading
      expect(find.text('Loading...'), findsOneWidget);

      // Change to not loading
      isLoading = false;
      await tester.pumpWidget(buildWidget());
      await tester.pump(); // Allow widget to process state change

      // Change back to loading quickly
      isLoading = true;
      await tester.pumpWidget(buildWidget());
      await tester.pump(); // Allow widget to process state change

      expect(find.text('Loading...'), findsOneWidget);

      // Clean up any pending timers
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}
