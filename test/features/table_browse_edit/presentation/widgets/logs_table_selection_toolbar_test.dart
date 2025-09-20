import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_selection_toolbar.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_state_provider.dart';

void main() {
  const accountId = 'test_account_toolbar';

  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('renders with selection count and actions', (tester) async {
    // Arrange: start with a controlled notifier via overrides
    final notifier = LogsTableStateNotifier(accountId: accountId);

    await tester.pumpWidget(wrap(
      LogsTableSelectionToolbar(accountId: accountId),
      overrides: [
        logsTableStateProvider(accountId).overrideWith((ref) => notifier),
      ],
    ));
    await tester.pump();

    // Initially zero selected
    expect(find.text('0 selected'), findsOneWidget);

    // Act: update selection through notifier (no rebuild of ProviderScope)
    notifier.toggleLogSelection('a');
    notifier.toggleLogSelection('b');
    await tester.pump();

    // Assert
    expect(find.text('2 selected'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget); // Clear
    expect(find.byIcon(Icons.delete), findsOneWidget); // Delete
  });
}
