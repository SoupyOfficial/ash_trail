// Comprehensive widget tests for logs table filter bar
// Tests filter display, user interactions, and basic functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_filter_bar.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_filter.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_state_provider.dart';

void main() {
  const testAccountId = 'test_account_123';

  Widget createTestWidget({LogsTableState? initialState}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: LogsTableFilterBar(accountId: testAccountId),
        ),
      ),
    );
  }

  group('LogsTableFilterBar Widget Tests', () {
    group('Basic Display', () {
      testWidgets('should display filters label', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Filters'), findsOneWidget);
      });

      testWidgets('should display filter options button', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
        expect(find.byTooltip('Filter Options'), findsOneWidget);
      });

      testWidgets('should not show clear filters button when no filters',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.text('Clear'), findsNothing);
      });
    });

    group('Filter Modal', () {
      testWidgets('should show filter modal when filter button tapped',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byIcon(Icons.filter_alt_outlined));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Filter Logs'), findsOneWidget);
        expect(find.text('Clear All'), findsOneWidget);
      });

      testWidgets('should show date range section in modal', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byIcon(Icons.filter_alt_outlined));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Date Range'), findsOneWidget);
        expect(find.text('Start Date'), findsOneWidget);
        expect(find.text('End Date'), findsOneWidget);
      });
    });

    group('Styling and Layout', () {
      testWidgets('should apply correct container styling', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find
              .ancestor(
                of: find.text('Filters'),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(
            container.padding,
            equals(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ));
        expect(container.decoration, isA<BoxDecoration>());
      });

      testWidgets('should have proper row layout for filter header',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Row), findsOneWidget);
        expect(find.byType(Spacer), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper tooltip for filter button',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byTooltip('Filter Options'), findsOneWidget);
      });

      testWidgets('should have proper semantic structure', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(IconButton), findsOneWidget);
        expect(find.text('Filters'), findsOneWidget);
      });
    });

    group('Widget Structure', () {
      testWidgets('should have Column as main layout', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        expect(find.byType(Column), findsOneWidget);
      });

      testWidgets('should have Container with proper decoration',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final containers = find.byType(Container);
        expect(containers, findsAtLeastNWidgets(1));

        final mainContainer = tester.widget<Container>(containers.first);
        expect(mainContainer.decoration, isA<BoxDecoration>());
      });

      testWidgets('should display IconButton for filter options',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert
        final iconButton = find.byType(IconButton);
        expect(iconButton, findsOneWidget);

        final iconButtonWidget = tester.widget<IconButton>(iconButton);
        expect(iconButtonWidget.onPressed, isNotNull);
        expect(iconButtonWidget.tooltip, equals('Filter Options'));
      });
    });

    group('Modal Content', () {
      testWidgets('should show draggable scrollable sheet in modal',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byIcon(Icons.filter_alt_outlined));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });

      testWidgets('should show proper modal header with close functionality',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byIcon(Icons.filter_alt_outlined));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Filter Logs'), findsOneWidget);
        expect(find.text('Clear All'), findsOneWidget);
      });

      testWidgets('should show filter sections in modal', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byIcon(Icons.filter_alt_outlined));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Start Date'), findsOneWidget);
        expect(find.text('End Date'), findsOneWidget);
        expect(find.text('Not set'), findsAtLeastNWidgets(2));
      });

      testWidgets('should show calendar icons for date selection',
          (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.tap(find.byIcon(Icons.filter_alt_outlined));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.calendar_today), findsNWidgets(2));
      });
    });

    group('Theme Integration', () {
      testWidgets('should use theme colors properly', (tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Scaffold(
                body: LogsTableFilterBar(accountId: testAccountId),
              ),
            ),
          ),
        );

        // Assert - widget builds successfully with theme
        expect(find.byType(LogsTableFilterBar), findsOneWidget);
      });

      testWidgets('should work with dark theme', (tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: Scaffold(
                body: LogsTableFilterBar(accountId: testAccountId),
              ),
            ),
          ),
        );

        // Assert - widget builds successfully with dark theme
        expect(find.byType(LogsTableFilterBar), findsOneWidget);
      });
    });

    group('Widget Rendering', () {
      testWidgets('should render without errors', (tester) async {
        // Act & Assert - should not throw
        await tester.pumpWidget(createTestWidget());
        expect(find.byType(LogsTableFilterBar), findsOneWidget);
      });

      testWidgets('should handle empty state correctly', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Assert - should show basic structure
        expect(find.text('Filters'), findsOneWidget);
        expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
      });

      testWidgets('shows active filter chips and clears them', (tester) async {
        // Arrange: provide a notifier with active filters
        final notifier = LogsTableStateNotifier(accountId: testAccountId);
        notifier.updateFilter(LogFilter(
          startDate: DateTime(2024, 10, 1),
          endDate: DateTime(2024, 10, 31),
          methodIds: ['m1'],
          includeTagIds: ['t1', 't2'],
          minDurationMs: 60000, // 1min
          maxDurationMs: 180000, // 3min
          minMoodScore: 3,
          maxMoodScore: 7,
        ));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              logsTableStateProvider(testAccountId)
                  .overrideWith((ref) => notifier),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: LogsTableFilterBar(accountId: testAccountId),
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert: chips for date range, method, tags, duration, mood are visible
        expect(find.byType(Chip), findsAtLeastNWidgets(5));
        expect(find.textContaining('Mood:'), findsOneWidget);
        expect(find.textContaining('min'), findsWidgets); // duration label
        expect(find.textContaining('Method:'), findsOneWidget);
        expect(find.text('#t1'), findsOneWidget);
        expect(find.text('#t2'), findsOneWidget);

        // Clear all via header Clear button
        expect(find.text('Clear'), findsOneWidget);
        await tester.tap(find.text('Clear'));
        await tester.pump();

        // Chips should disappear
        expect(find.byType(Chip), findsNothing);
      });
    });
  });
}
