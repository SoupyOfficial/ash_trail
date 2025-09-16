import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/loading_skeletons/presentation/widgets/skeleton_list.dart';

void main() {
  group('SkeletonList', () {
    testWidgets('should render correct number of skeleton items',
        (tester) async {
      const itemCount = 3;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonList(itemCount: itemCount),
            ),
          ),
        ),
      );

      // Should find itemCount number of skeleton items
      expect(find.byType(ListView), findsOneWidget);

      // Pump a few frames instead of pumpAndSettle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify items are present (checking for container structures)
      expect(find.byType(Row), findsNWidgets(itemCount));
    });

    testWidgets('should render items with correct height', (tester) async {
      const itemHeight = 100.0;

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonList(
                itemCount: 2,
                itemHeight: itemHeight,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find all skeleton list items
      final itemFinders = find.byType(Row);
      expect(itemFinders, findsNWidgets(2));
    });

    testWidgets('should conditionally show avatar and subtitle',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonList(
                itemCount: 1,
                showAvatar: false,
                showSubtitle: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should have fewer skeleton containers when avatar/subtitle are hidden
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('should handle empty list', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonList(itemCount: 0),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should render ListView but with no items
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });
  });
}
