// Widget tests for WidgetPreview component.
// Tests UI rendering, theming, and display logic for different widget sizes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_size.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';
import 'package:ash_trail/features/home_widgets/presentation/widgets/widget_preview.dart';

void main() {
  group('WidgetPreview', () {
    late DateTime testDateTime;

    setUp(() {
      testDateTime = DateTime(2023, 12, 1, 14, 30);
    });

    Widget createTestWidget(WidgetPreview widget) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: widget),
        ),
      );
    }

    testWidgets('displays small widget content correctly', (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.small,
        tapAction: WidgetTapAction.openApp,
        showStreak: false,
        showLastSync: false,
        todayHitCount: 7,
        currentStreak: 3,
        lastSyncAt: testDateTime,
      );

      // Act
      await tester.pumpWidget(createTestWidget(widget));

      // Assert
      expect(find.text('7'), findsOneWidget);
      expect(find.text('today'), findsOneWidget);

      // Small widget should not show streak info
      expect(find.textContaining('streak'), findsNothing);
      expect(find.textContaining('ago'), findsNothing);
    });

    testWidgets('displays medium widget content with hit count and streak',
        (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.recordOverlay,
        showStreak: true,
        showLastSync: false,
        todayHitCount: 5,
        currentStreak: 2,
        lastSyncAt: testDateTime,
      );

      // Act
      await tester.pumpWidget(createTestWidget(widget));

      // Assert
      expect(find.text('AshTrail'), findsOneWidget);
      expect(find.text('5 hits'), findsOneWidget);
      expect(find.text('today'), findsOneWidget);
      expect(find.text('2 days'), findsOneWidget);
      expect(find.text('streak'), findsOneWidget);

      // Should show fire department icon
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets(
        'displays medium widget without streak when showStreak is false',
        (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.viewLogs,
        showStreak: false,
        showLastSync: false,
        todayHitCount: 3,
        currentStreak: 5,
        lastSyncAt: testDateTime,
      );

      // Act
      await tester.pumpWidget(createTestWidget(widget));

      // Assert
      expect(find.text('3 hits'), findsOneWidget);
      expect(find.textContaining('5'),
          findsNothing); // Streak count should not show
      expect(find.textContaining('days'), findsNothing);
    });

    testWidgets('displays large widget with all information when enabled',
        (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.large,
        tapAction: WidgetTapAction.quickRecord,
        showStreak: true,
        showLastSync: true,
        todayHitCount: 8,
        currentStreak: 4,
        lastSyncAt: testDateTime,
      );

      // Act
      await tester.pumpWidget(createTestWidget(widget));

      // Assert
      expect(find.text('AshTrail'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('hits today'), findsOneWidget);
      expect(find.text('4 day streak'), findsOneWidget);
      expect(find.textContaining('ago'), findsOneWidget); // Last sync
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('displays extra large widget with detailed layout',
        (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.extraLarge,
        tapAction: WidgetTapAction.recordOverlay,
        showStreak: true,
        showLastSync: true,
        todayHitCount: 12,
        currentStreak: 7,
        lastSyncAt: testDateTime,
      );

      // Act
      await tester.pumpWidget(createTestWidget(widget));

      // Assert
      expect(find.text('AshTrail'), findsOneWidget);
      expect(find.text('Record Overlay'), findsOneWidget); // Tap action display
      expect(find.text('12'), findsOneWidget);
      expect(find.text('hits today'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('day streak'), findsOneWidget);
      expect(find.textContaining('Last sync:'), findsOneWidget);
    });

    testWidgets('handles zero values correctly', (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.openApp,
        showStreak: true,
        showLastSync: false,
        todayHitCount: 0,
        currentStreak: 0,
        lastSyncAt: testDateTime,
      );

      // Act
      await tester.pumpWidget(createTestWidget(widget));

      // Assert
      expect(find.text('0 hits'), findsOneWidget);
      // Should not show streak when it's 0
      expect(find.textContaining('0 day'), findsNothing);
    });

    testWidgets('handles single count values correctly', (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.large,
        tapAction: WidgetTapAction.openApp,
        showStreak: true,
        showLastSync: false,
        todayHitCount: 1,
        currentStreak: 1,
        lastSyncAt: testDateTime,
      );

      // Act
      await tester.pumpWidget(createTestWidget(widget));

      // Assert
      expect(find.text('1'), findsWidgets);
      expect(find.text('hits today'), findsOneWidget);
      expect(find.text('1 day streak'), findsOneWidget); // Singular form
    });

    testWidgets('respects theme colors', (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.openApp,
        showStreak: false,
        showLastSync: false,
        todayHitCount: 3,
        currentStreak: 2,
        lastSyncAt: testDateTime,
      );

      final app = MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: Scaffold(
          body: Center(child: widget),
        ),
      );

      // Act
      await tester.pumpWidget(app);

      // Assert - Widget should render without throwing
      expect(find.byType(WidgetPreview), findsOneWidget);
      expect(find.text('3 hits'), findsOneWidget);
    });

    testWidgets('handles dark theme correctly', (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.small,
        tapAction: WidgetTapAction.openApp,
        showStreak: false,
        showLastSync: false,
        todayHitCount: 5,
        currentStreak: 1,
        lastSyncAt: testDateTime,
      );

      final app = MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(child: widget),
        ),
      );

      // Act
      await tester.pumpWidget(app);

      // Assert
      expect(find.byType(WidgetPreview), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    group('time formatting', () {
      testWidgets('displays "Just now" for recent sync', (tester) async {
        // Arrange
        final recentTime = DateTime.now().subtract(const Duration(seconds: 30));
        final widget = WidgetPreview(
          size: WidgetSize.large,
          tapAction: WidgetTapAction.openApp,
          showStreak: false,
          showLastSync: true,
          todayHitCount: 1,
          currentStreak: 0,
          lastSyncAt: recentTime,
        );

        // Act
        await tester.pumpWidget(createTestWidget(widget));

        // Assert
        expect(find.textContaining('Just now'), findsOneWidget);
      });

      testWidgets('displays minutes for recent sync', (tester) async {
        // Arrange
        final minutesAgo = DateTime.now().subtract(const Duration(minutes: 15));
        final widget = WidgetPreview(
          size: WidgetSize.large,
          tapAction: WidgetTapAction.openApp,
          showStreak: false,
          showLastSync: true,
          todayHitCount: 1,
          currentStreak: 0,
          lastSyncAt: minutesAgo,
        );

        // Act
        await tester.pumpWidget(createTestWidget(widget));

        // Assert
        expect(find.textContaining('15m ago'), findsOneWidget);
      });
    });

    testWidgets('has correct semantics for accessibility', (tester) async {
      // Arrange
      final widget = WidgetPreview(
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.openApp,
        showStreak: true,
        showLastSync: false,
        todayHitCount: 4,
        currentStreak: 2,
        lastSyncAt: testDateTime,
      );

      // Act
      await tester.pumpWidget(createTestWidget(widget));

      // Assert - Should render without accessibility errors
      expect(find.byType(WidgetPreview), findsOneWidget);

      // Verify key text is readable by screen readers
      expect(find.text('4 hits'), findsOneWidget);
      expect(find.text('2 days'), findsOneWidget);
    });
  });
}
