import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_edit_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SmokeLog sampleLog() => SmokeLog(
        id: 'log1',
        accountId: 'acct',
        ts: DateTime.parse('2024-01-01T10:00:00Z'),
        durationMs: 10 * 60000,
        methodId: 'method1',
        potency: 5,
        moodScore: 7,
        physicalScore: 6,
        notes: 'hello',
        deviceLocalId: 'dev-1',
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T10:00:00Z'),
      );

  Future<void> pumpModal(WidgetTester tester,
      {required SmokeLog log,
      required Future<void> Function(SmokeLog) onSave}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => LogsTableEditModal(log: log, onSave: onSave),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows existing values and validates duration > 0',
      (tester) async {
    SmokeLog? savedLog;
    await pumpModal(tester,
        log: sampleLog(), onSave: (s) async => savedLog = s);

    // Scroll content to ensure form fields are built/visible
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('logs_edit_duration')), findsOneWidget);

    // Enter invalid 0 minutes
    await tester.enterText(find.byKey(const Key('logs_edit_duration')), '0');
    await tester.tap(find.byKey(const Key('logs_edit_save_top')));
    await tester.pump();

    // Expect validation error text
    expect(find.text('Duration must be greater than 0'), findsOneWidget);
    expect(savedLog, isNull);
  });

  testWidgets('saves with trimmed notes and converts minutes to ms',
      (tester) async {
    SmokeLog? saved;
    await pumpModal(tester,
        log: sampleLog().copyWith(notes: null), onSave: (s) async => saved = s);

    // Ensure fields are visible
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    // Set duration to 12 minutes
    await tester.enterText(find.byKey(const Key('logs_edit_duration')), '12');
    // Notes: enter spaces to trigger null
    await tester.enterText(find.byKey(const Key('logs_edit_notes')), '   ');
    await tester.tap(find.byKey(const Key('logs_edit_save_top')));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.durationMs, 12 * 60000);
    expect(saved!.notes, isNull);
  });

  testWidgets('cancel closes without calling onSave', (tester) async {
    var called = false;
    await pumpModal(tester,
        log: sampleLog(), onSave: (s) async => called = true);
    await tester.tap(find.byKey(const Key('logs_edit_cancel_top')));
    await tester.pumpAndSettle();
    expect(called, isFalse);
  });
}
