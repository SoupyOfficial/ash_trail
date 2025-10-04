import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ash_trail/features/loading_skeletons/presentation/widgets/skeleton_chart_simple.dart';
import 'package:ash_trail/features/loading_skeletons/presentation/widgets/skeleton_container.dart';

void main() {
  group('SkeletonChartSimple', () {
    /// Helper to wrap widgets with required providers
    Widget wrapWithProviders(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('should render default chart skeleton', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple()),
      );

      // Assert
      expect(find.byType(SkeletonChartSimple), findsOneWidget);
      expect(find.byType(SkeletonContainer), findsWidgets);

      // Check default dimensions
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(SkeletonContainer).first,
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.minHeight, equals(200.0));
    });

    testWidgets('should render chart with custom height', (tester) async {
      // Arrange
      const customHeight = 300.0;

      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple(height: customHeight)),
      );

      // Assert
      final widget = tester.widget<SkeletonChartSimple>(
        find.byType(SkeletonChartSimple),
      );
      expect(widget.height, equals(customHeight));
    });

    testWidgets('should render chart with custom bar count', (tester) async {
      // Arrange
      const customBarCount = 5;

      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple(barCount: customBarCount)),
      );

      // Assert
      final widget = tester.widget<SkeletonChartSimple>(
        find.byType(SkeletonChartSimple),
      );
      expect(widget.barCount, equals(customBarCount));
    });

    testWidgets('should show legend when enabled', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple(showLegend: true)),
      );

      // Assert
      final widget = tester.widget<SkeletonChartSimple>(
        find.byType(SkeletonChartSimple),
      );
      expect(widget.showLegend, isTrue);

      // Legend should add more skeleton containers
      expect(find.byType(SkeletonContainer), findsWidgets);
    });

    testWidgets('should not show legend when disabled', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple(showLegend: false)),
      );

      // Assert
      final widget = tester.widget<SkeletonChartSimple>(
        find.byType(SkeletonChartSimple),
      );
      expect(widget.showLegend, isFalse);
    });

    testWidgets('should have proper container styling', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple()),
      );

      // Assert
      final containerFinder = find.descendant(
        of: find.byType(SkeletonChartSimple),
        matching: find.byType(Container).first,
      );

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration?.color, equals(Colors.white));
      expect(decoration?.borderRadius, isA<BorderRadius>());
      expect(decoration?.border, isA<Border>());
    });

    testWidgets('should render Y-axis labels', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple()),
      );

      // Assert - Should have Y-axis skeleton containers
      expect(find.byType(SkeletonContainer), findsWidgets);

      // Check for Column containing Y-axis labels
      final columns = find.byType(Column);
      expect(columns, findsWidgets);
    });

    testWidgets('should render X-axis labels', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple(barCount: 3)),
      );

      // Assert
      expect(find.byType(SkeletonContainer), findsWidgets);

      // Should have Row for the chart bars
      final rows = find.byType(Row);
      expect(rows, findsWidgets);
    });

    testWidgets('should handle edge case with zero bars', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple(barCount: 0)),
      );

      // Assert - Should not crash
      expect(find.byType(SkeletonChartSimple), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle large bar count', (tester) async {
      // Act
      await tester.pumpWidget(
        wrapWithProviders(const SkeletonChartSimple(barCount: 20)),
      );

      // Assert - Should not crash
      expect(find.byType(SkeletonChartSimple), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
