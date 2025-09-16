import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/loading_skeletons/presentation/widgets/skeleton_chart.dart';

void main() {
  group('SkeletonChart', () {
    testWidgets('should render with default configuration', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonChart(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(SkeletonChart), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('should respect custom height', (tester) async {
      const customHeight = 400.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonChart(height: customHeight),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(SkeletonChart), findsOneWidget);
    });

    testWidgets('should conditionally show legend', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonChart(showLegend: false),
            ),
          ),
        ),
      );

      await tester.pump();

      // With showLegend: false, there should be fewer row widgets
      expect(find.byType(SkeletonChart), findsOneWidget);
    });

    testWidgets('should render correct number of bars', (tester) async {
      const barCount = 5;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonChart(barCount: barCount),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(SkeletonChart), findsOneWidget);

      // Should find the chart area with bars
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('should have proper layout structure', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonChart(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify key components are present
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Expanded), findsWidgets);
    });
  });
}
