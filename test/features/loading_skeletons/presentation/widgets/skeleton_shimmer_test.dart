import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ash_trail/features/loading_skeletons/presentation/widgets/skeleton_shimmer.dart';

void main() {
  group('SkeletonShimmer', () {
    testWidgets('should render child widget when enabled is false',
        (tester) async {
      // Arrange
      const testChild = Text('Test Content');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonShimmer(
                enabled: false,
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Content'), findsOneWidget);
      // When disabled, our specific shimmer ShaderMask should not be created
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('should render child widget when reduce motion is enabled',
        (tester) async {
      // Arrange
      const testChild = Text('Test Content');

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(accessibleNavigation: true),
              child: Scaffold(
                body: SkeletonShimmer(
                  enabled: true,
                  child: testChild,
                ),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Content'), findsOneWidget);
      // When reduce motion is enabled, shimmer should not be shown
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('should render shimmer animation when enabled', (tester) async {
      // Arrange
      final testChild = Container(
        width: 100,
        height: 20,
        color: Colors.grey,
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonShimmer(
                enabled: true,
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Assert
      // When enabled and reduce motion is off, shimmer should be shown
      expect(find.byType(ShaderMask), findsOneWidget);

      // Advance animation to verify it's running
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('should handle animation controller properly', (tester) async {
      // Arrange
      const testChild = Text('Test');

      // Act - Create widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonShimmer(
                enabled: true,
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Assert - Widget is created successfully
      expect(find.byType(SkeletonShimmer), findsOneWidget);

      // Act - Dispose widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Container(),
            ),
          ),
        ),
      );

      // Assert - No errors during disposal
      expect(tester.takeException(), isNull);
    });

    testWidgets('should use theme colors for shimmer gradient', (tester) async {
      // Arrange
      final testChild = SizedBox(width: 100, height: 20);
      final customTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: customTheme,
            home: Scaffold(
              body: SkeletonShimmer(
                enabled: true,
                child: testChild,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ShaderMask), findsOneWidget);
      final shaderMask = tester.widget<ShaderMask>(find.byType(ShaderMask));
      expect(shaderMask.blendMode, equals(BlendMode.srcATop));
    });
  });
}
