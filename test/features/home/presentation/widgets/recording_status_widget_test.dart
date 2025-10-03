import 'package:ash_trail/features/capture_hit/presentation/providers/record_button_state_provider.dart'
    as record;
import 'package:ash_trail/features/home/presentation/widgets/recording_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecordingStatusWidget', () {
    testWidgets('shows idle instructions when state is idle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecordingStatusWidget(
                recordState: record.RecordButtonState.idle(),
                onUndoPressed: _noop,
                onErrorRetry: _noop,
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Tap for quick log • Hold for timed recording'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('renders recording state with formatted duration',
        (WidgetTester tester) async {
      final record.RecordButtonRecordingState recordingState =
          record.RecordButtonRecordingState(
        startTime: DateTime(2024, 1, 1, 12, 0),
        currentDurationMs: 2500,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecordingStatusWidget(
                recordState: recordingState,
                onUndoPressed: _noop,
                onErrorRetry: _noop,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Recording: 2.5s'), findsOneWidget);
      expect(
        find.text('Release the button to save your session'),
        findsOneWidget,
      );
    });

    testWidgets('renders completed state and triggers undo callback',
        (WidgetTester tester) async {
      bool undoTapped = false;
      const record.RecordButtonCompletedState completedState =
          record.RecordButtonCompletedState(
        durationMs: 2000,
        smokeLogId: 'log-1',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecordingStatusWidget(
                recordState: completedState,
                onUndoPressed: () => undoTapped = true,
                onErrorRetry: _noop,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Session saved (2.0s)'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(undoTapped, isTrue);
    });

    testWidgets('renders error state and triggers retry',
        (WidgetTester tester) async {
      bool retried = false;
      const record.RecordButtonErrorState errorState =
          record.RecordButtonErrorState(message: 'Network offline');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RecordingStatusWidget(
                recordState: errorState,
                onUndoPressed: _noop,
                onErrorRetry: () => retried = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Recording failed'), findsOneWidget);
      expect(find.text('Network offline'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retried, isTrue);
    });
  });
}

void _noop() {}
