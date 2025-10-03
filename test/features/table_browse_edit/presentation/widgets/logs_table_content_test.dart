import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_filter.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_actions_provider.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_providers.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_state_provider.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_content.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _accountId = 'acct-test';

SmokeLog _buildLog({required String id, String? notes}) {
  final now = DateTime(2024, 7, 10, 15, 24);
  return SmokeLog(
    id: id,
    accountId: _accountId,
    ts: now,
    durationMs: 90 * 1000,
    methodId: 'method-$id',
    potency: 5,
    moodScore: 7,
    physicalScore: 6,
    notes: notes,
    deviceLocalId: 'device-$id',
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now,
  );
}

class _TestLogsTableStateNotifier extends LogsTableStateNotifier {
  _TestLogsTableStateNotifier({required LogsTableState initialState})
      : super(accountId: initialState.accountId) {
    state = initialState;
  }
}

class _StubTableActions implements TableActions {
  _StubTableActions({this.shouldThrowOnDelete = false});

  final bool shouldThrowOnDelete;
  bool refreshCalled = false;
  SmokeLog? lastUpdatedLog;
  final List<String> deleteLogCalls = <String>[];

  @override
  Future<SmokeLog> updateLog(SmokeLog smokeLog) async {
    lastUpdatedLog = smokeLog;
    return smokeLog;
  }

  @override
  Future<void> deleteLog(String smokeLogId) async {
    deleteLogCalls.add(smokeLogId);
    if (shouldThrowOnDelete) {
      throw Exception('delete-failure');
    }
  }

  @override
  Future<int> deleteLogs(List<String> smokeLogIds) {
    throw UnsupportedError('deleteLogs not used in tests');
  }

  @override
  Future<int> deleteSelectedLogs() {
    throw UnsupportedError('deleteSelectedLogs not used in tests');
  }

  @override
  Future<void> refresh() async {
    refreshCalled = true;
  }

  @override
  Future<int> addTagsToLogs({
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) {
    throw UnsupportedError('addTagsToLogs not used in tests');
  }

  @override
  Future<int> removeTagsFromLogs({
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) {
    throw UnsupportedError('removeTagsFromLogs not used in tests');
  }
}

Override _overrideState(LogsTableState initialState) {
  return logsTableStateProvider(_accountId).overrideWith(
    (ref) => _TestLogsTableStateNotifier(initialState: initialState),
  );
}

Future<void> _pumpLogsTable(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: Scaffold(
          body: LogsTableContent(accountId: _accountId),
        ),
      ),
    ),
  );
}

void main() {
  group('LogsTableContent', () {
    testWidgets('renders loading indicator while fetching logs',
        (tester) async {
      final overrides = <Override>[
        _overrideState(const LogsTableState(accountId: _accountId)),
        filteredSortedLogsProvider.overrideWith((ref, params) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return <SmokeLog>[];
        }),
      ];

      await _pumpLogsTable(tester, overrides: overrides);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading logs...'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
    });

    testWidgets('shows error state and retries when prompted', (tester) async {
      var fetchCount = 0;
      final overrides = <Override>[
        _overrideState(const LogsTableState(accountId: _accountId)),
        filteredSortedLogsProvider.overrideWith((ref, params) async {
          fetchCount++;
          throw Exception('network down');
        }),
      ];

      await _pumpLogsTable(tester, overrides: overrides);
      await tester.pump();

      expect(find.text('Failed to load logs'), findsOneWidget);
      expect(fetchCount, equals(1));

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(fetchCount, equals(2));
    });

    testWidgets('shows empty state message when no logs exist', (tester) async {
      final overrides = <Override>[
        _overrideState(const LogsTableState(accountId: _accountId)),
        filteredSortedLogsProvider.overrideWith(
          (ref, params) async => <SmokeLog>[],
        ),
      ];

      await _pumpLogsTable(tester, overrides: overrides);
      await tester.pump();

      expect(find.text('No logs yet'), findsOneWidget);
      expect(
        find.text('Your smoke logs will appear here once you start tracking'),
        findsOneWidget,
      );
    });

    testWidgets('shows filter messaging and clears filters on request',
        (tester) async {
      const initialState = LogsTableState(
        accountId: _accountId,
        filter: LogFilter(searchText: 'calm'),
      );

      final overrides = <Override>[
        _overrideState(initialState),
        filteredSortedLogsProvider.overrideWith(
          (ref, params) async => <SmokeLog>[],
        ),
      ];

      await _pumpLogsTable(tester, overrides: overrides);
      await tester.pump();

      expect(find.text('No logs match your filters'), findsOneWidget);
      expect(find.text('Clear Filters'), findsOneWidget);

      await tester.tap(find.text('Clear Filters'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('No logs yet'), findsOneWidget);
    });

    testWidgets('renders logs and toggles selection from row interaction',
        (tester) async {
      final logs = [_buildLog(id: 'log-1'), _buildLog(id: 'log-2')];
      const initialState = LogsTableState(
        accountId: _accountId,
        selectedLogIds: {'log-2'},
      );

      late _StubTableActions stub;
      final overrides = <Override>[
        _overrideState(initialState),
        filteredSortedLogsProvider.overrideWith(
          (ref, params) async => logs,
        ),
        tableActionsProvider(_accountId).overrideWith((ref) {
          stub = _StubTableActions();
          return stub;
        }),
      ];

      await _pumpLogsTable(tester, overrides: overrides);
      await tester.pump();

      expect(find.byType(LogsTableRow), findsNWidgets(2));

      // First row should start unchecked, second checked
      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      expect(checkboxes.elementAt(0).value, isFalse);
      expect(checkboxes.elementAt(1).value, isTrue);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      final updatedCheckboxes =
          tester.widgetList<Checkbox>(find.byType(Checkbox));
      expect(updatedCheckboxes.elementAt(0).value, isTrue);
      expect(stub.deleteLogCalls, isEmpty);
    });

    testWidgets('confirms deletion and shows success feedback', (tester) async {
      final log = _buildLog(id: 'log-3');
      late _StubTableActions stub;

      final overrides = <Override>[
        _overrideState(const LogsTableState(accountId: _accountId)),
        filteredSortedLogsProvider.overrideWith(
          (ref, params) async => <SmokeLog>[log],
        ),
        tableActionsProvider(_accountId).overrideWith((ref) {
          stub = _StubTableActions();
          return stub;
        }),
      ];

      await _pumpLogsTable(tester, overrides: overrides);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Delete Log'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(stub.deleteLogCalls, ['log-3']);
      expect(find.text('Log deleted'), findsOneWidget);
    });

    testWidgets('shows failure feedback when deletion throws', (tester) async {
      final log = _buildLog(id: 'log-4');
      late _StubTableActions stub;

      final overrides = <Override>[
        _overrideState(const LogsTableState(accountId: _accountId)),
        filteredSortedLogsProvider.overrideWith(
          (ref, params) async => <SmokeLog>[log],
        ),
        tableActionsProvider(_accountId).overrideWith((ref) {
          stub = _StubTableActions(shouldThrowOnDelete: true);
          return stub;
        }),
      ];

      await _pumpLogsTable(tester, overrides: overrides);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(stub.deleteLogCalls, ['log-4']);
      expect(
        find.textContaining('Failed to delete log:'),
        findsOneWidget,
      );
    });

    testWidgets('pull-to-refresh triggers table actions refresh',
        (tester) async {
      final log = _buildLog(id: 'log-5');
      late _StubTableActions stub;

      final overrides = <Override>[
        _overrideState(const LogsTableState(accountId: _accountId)),
        filteredSortedLogsProvider.overrideWith(
          (ref, params) async => <SmokeLog>[log],
        ),
        tableActionsProvider(_accountId).overrideWith((ref) {
          stub = _StubTableActions();
          return stub;
        }),
      ];

      await _pumpLogsTable(tester, overrides: overrides);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(stub.refreshCalled, isTrue);
    });

    testWidgets('tapping edit opens modal sheet', (tester) async {
      final log = _buildLog(id: 'log-6');
      late _StubTableActions stub;

      final overrides = <Override>[
        _overrideState(const LogsTableState(accountId: _accountId)),
        filteredSortedLogsProvider.overrideWith(
          (ref, params) async => <SmokeLog>[log],
        ),
        tableActionsProvider(_accountId).overrideWith((ref) {
          stub = _StubTableActions();
          return stub;
        }),
      ];

      await _pumpLogsTable(tester, overrides: overrides);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Edit Log'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Log'), findsNothing);
      expect(stub.lastUpdatedLog, isNull);
    });
  });
}
