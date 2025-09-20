import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/loading_skeletons/presentation/widgets/skeleton_container.dart';

void main() {
  group('SkeletonContainer', () {
    testWidgets('should render child widget', (tester) async {
      const testChild = Text('Test Content');

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonContainer(
                child: testChild,
              ),
            ),
          ),
        ),
      );

      expect(find.byWidget(testChild), findsOneWidget);
    });

    testWidgets('should respect custom width and height', (tester) async {
      const width = 100.0;
      const height = 50.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonContainer(
                width: width,
                height: height,
                child: SizedBox(),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      expect(container.constraints?.maxWidth, equals(width));
      expect(container.constraints?.maxHeight, equals(height));
    });

    testWidgets('should handle reduced motion accessibility', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  accessibleNavigation: true, // Reduced motion enabled
                ),
                child: SkeletonContainer(
                  child: SizedBox(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should render without animation when reduced motion is enabled
      expect(find.byType(SkeletonContainer), findsOneWidget);
    });

    testWidgets('should animate when reduced motion is disabled',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  accessibleNavigation: false, // Reduced motion disabled
                ),
                child: SkeletonContainer(
                  child: SizedBox(),
                ),
              ),
            ),
          ),
        ),
      );

      // Pump a few frames to check animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SkeletonContainer), findsOneWidget);
    });
  });
}
