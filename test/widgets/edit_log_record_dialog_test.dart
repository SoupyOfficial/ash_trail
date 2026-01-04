import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/providers/log_record_provider.dart';
import 'package:ash_trail/widgets/edit_log_record_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestLogRecordNotifier extends LogRecordNotifier {
  _TestLogRecordNotifier(super.ref);

  int updateCallCount = 0;
  Map<String, Object?>? lastPayload;

  @override
  Future<void> updateLogRecord(
    LogRecord record, {
    EventType? eventType,
    DateTime? eventAt,
    double? duration,
    Unit? unit,
    String? note,
    double? moodRating,
    double? physicalRating,
    List<LogReason>? reasons,
    double? latitude,
    double? longitude,
  }) async {
    updateCallCount++;
    lastPayload = {
      'record': record,
      'eventType': eventType,
      'eventAt': eventAt,
      'duration': duration,
      'unit': unit,
      'note': note,
      'moodRating': moodRating,
      'physicalRating': physicalRating,
      'reasons': reasons,
      'latitude': latitude,
      'longitude': longitude,
    };
    state = const AsyncValue.data(null);
  }
}

void main() {
  group('EditLogRecordDialog', () {
    late LogRecord record;
    late _TestLogRecordNotifier notifier;

    setUp(() {
      record = LogRecord.create(
        logId: 'log-1',
        accountId: 'acct',
        eventAt: DateTime(2024, 1, 1, 12),
        eventType: EventType.vape,
        duration: 60,
        unit: Unit.seconds,
        note: 'Initial note',
        moodRating: 5,
        physicalRating: 6,
        reasons: [LogReason.pain],
      );
    });

    Future<void> _openDialog(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            logRecordNotifierProvider.overrideWith((ref) {
              notifier = _TestLogRecordNotifier(ref);
              return notifier;
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => EditLogRecordDialog(record: record),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Force provider instantiation so notifier is available even if validation short-circuits
      final element = tester.element(find.byType(EditLogRecordDialog));
      ProviderScope.containerOf(
        element,
        listen: false,
      ).read(logRecordNotifierProvider);
    }

    testWidgets('shows validation error when only one coordinate is provided', (
      tester,
    ) async {
      await _openDialog(tester);

      await tester.enterText(find.bySemanticsLabel('Latitude'), '10');
      await tester.ensureVisible(find.text('Update'));

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(
        find.text('Location must have both latitude and longitude, or neither'),
        findsOneWidget,
      );
      expect(notifier.updateCallCount, 0);
      expect(find.byType(EditLogRecordDialog), findsOneWidget);
    });

    testWidgets('submits updates through notifier and closes dialog', (
      tester,
    ) async {
      await _openDialog(tester);

      await tester.enterText(find.bySemanticsLabel('Duration'), '5');
      await tester.enterText(find.bySemanticsLabel('Notes'), 'Updated note');
      await tester.enterText(find.bySemanticsLabel('Latitude'), '10');
      await tester.enterText(find.bySemanticsLabel('Longitude'), '20');
      await tester.ensureVisible(find.text('Update'));

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(notifier.updateCallCount, 1);
      expect(notifier.lastPayload?['duration'], 5);
      expect(notifier.lastPayload?['note'], 'Updated note');
      expect(notifier.lastPayload?['latitude'], 10); // parsed double
      expect(notifier.lastPayload?['longitude'], 20);
      expect(find.byType(EditLogRecordDialog), findsNothing);
    });
  });
}
