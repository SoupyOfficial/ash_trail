import 'package:ash_trail/core/feature_flags/feature_flags.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_actions_provider.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_providers.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_state_provider.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_selection_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake notifier for add-tags batch
class _FakeTableActions extends TableActions {
  _FakeTableActions(Ref ref, this.accountId) : super(ref, accountId);

  final String accountId;
  String? lastAccountId;
  List<String>? lastSmokeLogIds;
  List<String>? lastTagIds;

  @override
  Future<int> addTagsToLogs({
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    lastAccountId = accountId;
    lastSmokeLogIds = List<String>.from(smokeLogIds);
    lastTagIds = List<String>.from(tagIds);
    return smokeLogIds.length;
  }

  @override
  Future<int> removeTagsFromLogs({
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    lastAccountId = accountId;
    lastSmokeLogIds = List<String>.from(smokeLogIds);
    lastTagIds = List<String>.from(tagIds);
    return smokeLogIds.length;
  }
}

// Test helper: StateNotifier with preselected IDs
class _TestLogsTableStateNotifier extends LogsTableStateNotifier {
  _TestLogsTableStateNotifier(
      {required super.accountId, required Set<String> selected}) {
    state = state.copyWith(selectedLogIds: selected);
  }
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  const accountId = 'acct1';

  group('LogsTableSelectionToolbar – feature gating', () {
    testWidgets('hides Tags menu when logging.batch_edit_delete is disabled',
        (tester) async {
      // No feature flag override: default provider map returns false
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Provide an initial selection so the toolbar shows selection count
            logsTableStateProvider(accountId).overrideWith(
              (ref) => _TestLogsTableStateNotifier(
                accountId: accountId,
                selected: {'a', 'b'},
              ),
            ),
          ],
          child: _wrapWithApp(LogsTableSelectionToolbar(accountId: accountId)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('selected'), findsOneWidget);
      expect(find.text('Tags'), findsNothing);
    });
  });

  group('LogsTableSelectionToolbar – tag actions', () {
    testWidgets('shows Tags and applies Add tags flow when feature enabled',
        (tester) async {
      late _FakeTableActions fakeActions;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Enable the feature flag
            featureFlagsProvider.overrideWithValue(const {
              'logging.batch_edit_delete': true,
            }),
            // Provide some available tags
            usedTagIdsProvider(accountId)
                .overrideWith((ref) async => ['tagA', 'tagB', 'tagC']),
            // Preselect two logs
            logsTableStateProvider(accountId).overrideWith(
              (ref) => _TestLogsTableStateNotifier(
                accountId: accountId,
                selected: {'log1', 'log2'},
              ),
            ),
            // Intercept TableActions to capture calls
            tableActionsProvider(accountId).overrideWith((ref) {
              fakeActions = _FakeTableActions(ref, accountId);
              return fakeActions;
            }),
          ],
          child: _wrapWithApp(LogsTableSelectionToolbar(accountId: accountId)),
        ),
      );

      await tester.pumpAndSettle();

      // Tags button visible
      expect(find.text('Tags'), findsOneWidget);

      // Open the menu
      await tester.tap(find.text('Tags'));
      await tester.pumpAndSettle();

      // Choose Add tags
      await tester.tap(find.text('Add tags'));
      await tester.pumpAndSettle();

      // Select two tags
      await tester.tap(find.text('tagA'));
      await tester.pump();
      await tester.tap(find.text('tagB'));
      await tester.pump();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify call captured by fake
      expect(fakeActions.lastAccountId, accountId);
      expect(fakeActions.lastSmokeLogIds, ['log1', 'log2']);
      expect(fakeActions.lastTagIds, ['tagA', 'tagB']);

      // SnackBar feedback
      expect(find.text('Added tags to 2 logs'), findsOneWidget);
    });

    testWidgets('applies Remove tags flow with confirmation', (tester) async {
      late _FakeTableActions fakeActions;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            featureFlagsProvider.overrideWithValue(const {
              'logging.batch_edit_delete': true,
            }),
            usedTagIdsProvider(accountId)
                .overrideWith((ref) async => ['x', 'y']),
            logsTableStateProvider(accountId).overrideWith(
              (ref) => _TestLogsTableStateNotifier(
                accountId: accountId,
                selected: {'l1', 'l2'},
              ),
            ),
            tableActionsProvider(accountId).overrideWith((ref) {
              fakeActions = _FakeTableActions(ref, accountId);
              return fakeActions;
            }),
          ],
          child: _wrapWithApp(LogsTableSelectionToolbar(accountId: accountId)),
        ),
      );

      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.text('Tags'));
      await tester.pumpAndSettle();

      // Choose Remove tags
      await tester.tap(find.text('Remove tags'));
      await tester.pumpAndSettle();

      // Select one tag
      await tester.tap(find.text('x'));
      await tester.pump();

      // Apply selection -> opens confirmation dialog
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Confirm removal
      await tester.tap(find.widgetWithText(TextButton, 'Remove'));
      await tester.pumpAndSettle();

      // Verify call captured by fake
      expect(fakeActions.lastAccountId, accountId);
      expect(fakeActions.lastSmokeLogIds, ['l1', 'l2']);
      expect(fakeActions.lastTagIds, ['x']);

      // SnackBar feedback
      expect(find.text('Removed tags from 2 logs'), findsOneWidget);
    });
  });
}
