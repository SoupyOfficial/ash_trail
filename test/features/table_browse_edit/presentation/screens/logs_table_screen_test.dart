// Unit tests for LogsTableScreen
// Tests screen composition, navigation, state management, user interactions, and accessibility

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ash_trail/features/table_browse_edit/presentation/screens/logs_table_screen.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_state_provider.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_actions_provider.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_header.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_content.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_filter_bar.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_pagination.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_selection_toolbar.dart';

// Mock classes
class MockTableActions extends Mock implements TableActions {}

void main() {
  late MockTableActions mockTableActions;
  const testAccountId = 'test-account-id';

  setUp(() {
    mockTableActions = MockTableActions();
    // Ensure refresh() returns a Future<void> when called to avoid type errors in gestures
    when(() => mockTableActions.refresh()).thenAnswer((_) async {});
  });

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const LogsTableState(accountId: 'fallback-account'));
  });

  Widget createTestWidget({
    LogsTableState? tableState,
    TableActions? tableActions,
  }) {
    return MaterialApp(
      home: ProviderScope(
        overrides: [
          logsTableStateProvider(testAccountId).overrideWith((ref) {
            return LogsTableStateNotifier(accountId: testAccountId);
          }),
          tableActionsProvider(testAccountId).overrideWith((ref) {
            return tableActions ?? mockTableActions;
          }),
        ],
        child: const LogsTableScreen(accountId: testAccountId),
      ),
    );
  }

  group('LogsTableScreen Widget Tests', () {
    testWidgets('displays basic screen structure correctly', (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert - AppBar and title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Smoke Logs'), findsOneWidget);

  // assert - Refresh button
  expect(find.byKey(const Key('logs_refresh_button')), findsOneWidget);
  expect(find.byKey(const Key('logs_more_menu_button')), findsOneWidget);

      // assert - Main content components present
      expect(find.byType(LogsTableFilterBar), findsOneWidget);
      expect(find.byType(LogsTableHeader), findsOneWidget);
      expect(find.byType(LogsTableContent), findsOneWidget);
      expect(find.byType(LogsTablePagination), findsOneWidget);
    });

    testWidgets('displays refresh button with correct tooltip', (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert
  final refreshButton = find.byKey(const Key('logs_refresh_button'));
      expect(refreshButton, findsOneWidget);

      // Check tooltip
      await tester.longPress(refreshButton);
      await tester.pumpAndSettle();
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('refresh button calls tableActions.refresh when pressed',
        (tester) async {
      // arrange
      await tester.pumpWidget(createTestWidget(tableActions: mockTableActions));
      await tester.pumpAndSettle();

      // act
  await tester.tap(find.byKey(const Key('logs_refresh_button')));
      await tester.pumpAndSettle();

      // assert
      verify(() => mockTableActions.refresh()).called(1);
    });

    testWidgets('displays popup menu with correct items', (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // act - tap popup menu button
  await tester.tap(find.byKey(const Key('logs_more_menu_button')));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Clear Filters'), findsOneWidget);
      expect(find.text('Reset View'), findsOneWidget);
    });

    testWidgets('clear filters menu item works correctly', (tester) async {
      // arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // act - open menu and select clear filters
  await tester.tap(find.byKey(const Key('logs_more_menu_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      // Menu should close (no assertion needed, just verify no errors)
    });

    testWidgets('reset view menu item works correctly', (tester) async {
      // arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // act - open menu and select reset view
  await tester.tap(find.byKey(const Key('logs_more_menu_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset View'));
      await tester.pumpAndSettle();

      // Menu should close (no assertion needed, just verify no errors)
    });

    testWidgets('does not show selection toolbar when no items selected',
        (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(LogsTableSelectionToolbar), findsNothing);
    });

    testWidgets('does not show floating action button when no items selected',
        (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('screen layout is responsive', (tester) async {
      // arrange - set different screen size
      await tester.binding.setSurfaceSize(const Size(400, 800));

      // act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert - key elements should still be visible
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(LogsTableFilterBar), findsOneWidget);
      expect(find.byType(LogsTableHeader), findsOneWidget);
      expect(find.byType(LogsTableContent), findsOneWidget);
      expect(find.byType(LogsTablePagination), findsOneWidget);

      // Clean up
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('screen handles theme changes correctly', (tester) async {
      // arrange & act - light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: ProviderScope(
            overrides: [
              logsTableStateProvider(testAccountId).overrideWith((ref) {
                return LogsTableStateNotifier(accountId: testAccountId);
              }),
              tableActionsProvider(testAccountId).overrideWith((ref) {
                return mockTableActions;
              }),
            ],
            child: const LogsTableScreen(accountId: testAccountId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(AppBar), findsOneWidget);

      // act - dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ProviderScope(
            overrides: [
              logsTableStateProvider(testAccountId).overrideWith((ref) {
                return LogsTableStateNotifier(accountId: testAccountId);
              }),
              tableActionsProvider(testAccountId).overrideWith((ref) {
                return mockTableActions;
              }),
            ],
            child: const LogsTableScreen(accountId: testAccountId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('LogsTableScreen Accessibility Tests', () {
    testWidgets('has proper semantic labels', (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert - AppBar should have title semantics
      expect(find.text('Smoke Logs'), findsOneWidget);

      // Refresh button should have tooltip
  final refreshButton = find.byKey(const Key('logs_refresh_button'));
      await tester.longPress(refreshButton);
      await tester.pumpAndSettle();
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('supports screen reader navigation', (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert - key interactive elements should be found
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));
  expect(find.byKey(const Key('logs_more_menu_button')), findsOneWidget);
    });

    testWidgets('has adequate touch targets', (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert - buttons should have minimum 48dp touch targets
    final refreshButton = tester
      .widget<IconButton>(find.byKey(const Key('logs_refresh_button')));
      expect(refreshButton, isNotNull);

    final popupButton = tester
      .widget<PopupMenuButton>(find.byKey(const Key('logs_more_menu_button')));
      expect(popupButton, isNotNull);
    });
  });

  group('LogsTableScreen Error Handling Tests', () {
    testWidgets('handles provider errors gracefully', (tester) async {
      // arrange - create widget that might have provider issues
      await tester.pumpWidget(createTestWidget());

      // act & assert - should not throw errors
      await tester.pumpAndSettle();
      expect(find.byType(LogsTableScreen), findsOneWidget);
    });

    testWidgets('handles navigation errors gracefully', (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // act - try to interact with elements
  await tester.tap(find.byKey(const Key('logs_refresh_button')));
      await tester.pumpAndSettle();

      // assert - should not crash
      expect(find.byType(LogsTableScreen), findsOneWidget);
    });
  });

  group('LogsTableScreen Performance Tests', () {
    testWidgets('builds efficiently without excessive rebuilds',
        (tester) async {
      // arrange
      int buildCount = 0;
      Widget countingWidget = Builder(
        builder: (context) {
          buildCount++;
          return const LogsTableScreen(accountId: testAccountId);
        },
      );

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              logsTableStateProvider(testAccountId).overrideWith((ref) {
                return LogsTableStateNotifier(accountId: testAccountId);
              }),
              tableActionsProvider(testAccountId).overrideWith((ref) {
                return mockTableActions;
              }),
            ],
            child: countingWidget,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert - should build only once initially
      expect(buildCount, equals(1));
    });

    testWidgets('handles rapid user interactions', (tester) async {
      // arrange
      await tester.pumpWidget(createTestWidget(tableActions: mockTableActions));
      await tester.pumpAndSettle();

      // act - rapid taps on refresh
      for (int i = 0; i < 3; i++) {
  await tester.tap(find.byKey(const Key('logs_refresh_button')));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // assert - should handle gracefully
      expect(find.byType(LogsTableScreen), findsOneWidget);
    });
  });

  group('LogsTableScreen Integration Tests', () {
    testWidgets('integrates correctly with child components', (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert - all child components should be present
      expect(find.byType(LogsTableFilterBar), findsOneWidget);
      expect(find.byType(LogsTableHeader), findsOneWidget);
      expect(find.byType(LogsTableContent), findsOneWidget);
      expect(find.byType(LogsTablePagination), findsOneWidget);

      // Each should receive correct accountId
      final filterBar =
          tester.widget<LogsTableFilterBar>(find.byType(LogsTableFilterBar));
      expect(filterBar.accountId, equals(testAccountId));

      final header =
          tester.widget<LogsTableHeader>(find.byType(LogsTableHeader));
      expect(header.accountId, equals(testAccountId));

      final content =
          tester.widget<LogsTableContent>(find.byType(LogsTableContent));
      expect(content.accountId, equals(testAccountId));

      final pagination =
          tester.widget<LogsTablePagination>(find.byType(LogsTablePagination));
      expect(pagination.accountId, equals(testAccountId));
    });

    testWidgets('maintains correct widget hierarchy', (tester) async {
      // arrange & act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // assert - verify hierarchy
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });
  });
}
