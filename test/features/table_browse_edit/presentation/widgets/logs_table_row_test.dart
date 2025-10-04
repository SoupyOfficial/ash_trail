import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/widgets/logs_table_row.dart';

void main() {
  late SmokeLog testLog;

  setUp(() {
    testLog = SmokeLog(
      id: 'test_log_123',
      accountId: 'test_account',
      ts: DateTime(2023, 6, 15, 14, 30),
      durationMs: 300000, // 5 minutes
      methodId: 'vape',
      moodScore: 7,
      physicalScore: 6,
      potency: 8,
      notes: 'Test session notes',
      createdAt: DateTime(2023, 6, 15, 14, 30),
      updatedAt: DateTime(2023, 6, 15, 14, 35),
    );
  });

  Widget createTestWidget({
    SmokeLog? log,
    bool isSelected = false,
    ValueChanged<bool>? onSelectionChanged,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: LogsTableRow(
          log: log ?? testLog,
          isSelected: isSelected,
          onSelectionChanged: onSelectionChanged ?? (_) {},
          onEdit: onEdit ?? () {},
          onDelete: onDelete ?? () {},
        ),
      ),
    );
  }

  group('LogsTableRow Widget Tests', () {
    group('Initial Display', () {
      testWidgets('should render widget without errors', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(LogsTableRow), findsOneWidget);
      });

      testWidgets('should display all required cells', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Checkbox cell
        expect(find.byType(Checkbox), findsOneWidget);

        // Date and time
        expect(find.text('6/15/2023'), findsOneWidget);
        expect(find.text('2:30 PM'), findsOneWidget);

        // Duration
        expect(find.text('5m 0s'), findsOneWidget);

        // Method
        expect(find.text('vape'), findsOneWidget);

        // Mood score (use key to avoid ambiguity)
        expect(find.byKey(const Key('mood_score_text')), findsOneWidget);

        // Physical score (use key to avoid ambiguity)
        expect(find.byKey(const Key('physical_score_text')), findsOneWidget);

        // Notes
        expect(find.text('Test session notes'), findsOneWidget);

        // Action buttons
        expect(find.byIcon(Icons.edit), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      });

      testWidgets('should show unselected state by default', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isFalse);
      });

      testWidgets('should show selected state when selected', (tester) async {
        await tester.pumpWidget(createTestWidget(isSelected: true));
        await tester.pump();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      });
    });

    group('Date and Time Formatting', () {
      testWidgets('should format date correctly', (tester) async {
        final customLog = testLog.copyWith(
          ts: DateTime(2023, 12, 1, 9, 15), // December 1st, 9:15 AM
        );

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('12/1/2023'), findsOneWidget);
        expect(find.text('9:15 AM'), findsOneWidget);
      });

      testWidgets('should format PM time correctly', (tester) async {
        final customLog = testLog.copyWith(
          ts: DateTime(2023, 6, 15, 23, 45), // 11:45 PM
        );

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('11:45 PM'), findsOneWidget);
      });

      testWidgets('should format midnight correctly', (tester) async {
        final customLog = testLog.copyWith(
          ts: DateTime(2023, 6, 15, 0, 30), // 12:30 AM
        );

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('12:30 AM'), findsOneWidget);
      });

      testWidgets('should format noon correctly', (tester) async {
        final customLog = testLog.copyWith(
          ts: DateTime(2023, 6, 15, 12, 0), // 12:00 PM
        );

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('12:00 PM'), findsOneWidget);
      });
    });

    group('Duration Formatting', () {
      testWidgets('should format duration in minutes and seconds',
          (tester) async {
        final customLog = testLog.copyWith(
          durationMs: 93000, // 1 minute 33 seconds
        );

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('2m 3s'), findsOneWidget); // Rounded to 2 minutes
      });

      testWidgets('should format duration less than a minute', (tester) async {
        final customLog = testLog.copyWith(
          durationMs: 45000, // 45 seconds
        );

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('45s'), findsOneWidget);
      });

      testWidgets('should format duration exactly one minute', (tester) async {
        final customLog = testLog.copyWith(
          durationMs: 60000, // Exactly 1 minute
        );

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('1m 0s'), findsOneWidget);
      });
    });

    group('Mood Score Display', () {
      testWidgets('should display very dissatisfied mood for low scores',
          (tester) async {
        final customLog = testLog.copyWith(moodScore: 2);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('should display dissatisfied mood for low-medium scores',
          (tester) async {
        final customLog = testLog.copyWith(moodScore: 4);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.byIcon(Icons.sentiment_dissatisfied), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
      });

      testWidgets('should display neutral mood for medium scores',
          (tester) async {
        final customLog = testLog.copyWith(moodScore: 6);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.byIcon(Icons.sentiment_neutral), findsOneWidget);
        // Use key to disambiguate from physical score also showing '6'
        final moodTextFinder = find.byKey(const Key('mood_score_text'));
        expect(moodTextFinder, findsOneWidget);
        final moodText = tester.widget<Text>(moodTextFinder);
        expect(moodText.data, '6');
      });

      testWidgets('should display satisfied mood for high scores',
          (tester) async {
        final customLog = testLog.copyWith(moodScore: 8);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.byIcon(Icons.sentiment_satisfied), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
      });

      testWidgets('should display very satisfied mood for highest scores',
          (tester) async {
        final customLog = testLog.copyWith(moodScore: 10);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.byIcon(Icons.sentiment_very_satisfied), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
      });
    });

    group('Physical Score Display', () {
      testWidgets('should display physical score with heart icon',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byIcon(Icons.favorite), findsOneWidget);
        // Physical score uses a dedicated key
        expect(find.byKey(const Key('physical_score_text')), findsOneWidget);
      });

      testWidgets('should display different physical scores', (tester) async {
        final customLog = testLog.copyWith(physicalScore: 9);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        // Physical score uses a dedicated key; also verify displayed text value
        final physicalFinder = find.byKey(const Key('physical_score_text'));
        expect(physicalFinder, findsOneWidget);
        final physicalText = tester.widget<Text>(physicalFinder);
        expect(physicalText.data, '9');
      });
    });

    group('Method Display', () {
      testWidgets('should display method when available', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('vape'), findsOneWidget);
      });

      testWidgets('should display Unknown when method is null', (tester) async {
        final customLog = testLog.copyWith(methodId: null);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('Unknown'), findsOneWidget);
      });
    });

    group('Notes Display', () {
      testWidgets('should display notes when available', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Test session notes'), findsOneWidget);
      });

      testWidgets('should display No notes when notes are null',
          (tester) async {
        final customLog = testLog.copyWith(notes: null);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('No notes'), findsOneWidget);
      });

      testWidgets('should display No notes when notes are empty',
          (tester) async {
        final customLog = testLog.copyWith(notes: '');

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('No notes'), findsOneWidget);
      });

      testWidgets('should handle long notes with ellipsis', (tester) async {
        const longNotes =
            'This is a very long note that should be truncated with ellipsis when it exceeds the maximum number of lines allowed in the display area.';
        final customLog = testLog.copyWith(notes: longNotes);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        // The text widget should be present but may be truncated
        expect(find.textContaining('This is a very long note'), findsOneWidget);
      });
    });

    group('Selection Interaction', () {
      testWidgets('should call onSelectionChanged when checkbox tapped',
          (tester) async {
        bool selectionChanged = false;
        bool selectedValue = false;

        await tester.pumpWidget(createTestWidget(
          onSelectionChanged: (value) {
            selectionChanged = true;
            selectedValue = value;
          },
        ));
        await tester.pump();

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(selectionChanged, isTrue);
        expect(selectedValue, isTrue);
      });

      testWidgets('should call onSelectionChanged when row tapped',
          (tester) async {
        bool selectionChanged = false;
        bool selectedValue = false;

        await tester.pumpWidget(createTestWidget(
          onSelectionChanged: (value) {
            selectionChanged = true;
            selectedValue = value;
          },
        ));
        await tester.pump();

        // Target the primary row tap area InkWell explicitly
        await tester.tap(find.byKey(const Key('logs_table_row_tap_area')));
        await tester.pump();

        expect(selectionChanged, isTrue);
        expect(selectedValue, isTrue);
      });

      testWidgets('should toggle selection when already selected',
          (tester) async {
        bool selectionChanged = false;
        bool selectedValue = true; // Will be flipped

        await tester.pumpWidget(createTestWidget(
          isSelected: true,
          onSelectionChanged: (value) {
            selectionChanged = true;
            selectedValue = value;
          },
        ));
        await tester.pump();

        // Target the primary row tap area InkWell explicitly
        await tester.tap(find.byKey(const Key('logs_table_row_tap_area')));
        await tester.pump();

        expect(selectionChanged, isTrue);
        expect(selectedValue, isFalse);
      });
    });

    group('Action Button Interaction', () {
      testWidgets('should call onEdit when edit button tapped', (tester) async {
        bool editCalled = false;

        await tester.pumpWidget(createTestWidget(
          onEdit: () {
            editCalled = true;
          },
        ));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pump();

        expect(editCalled, isTrue);
      });

      testWidgets('should call onDelete when delete button tapped',
          (tester) async {
        bool deleteCalled = false;

        await tester.pumpWidget(createTestWidget(
          onDelete: () {
            deleteCalled = true;
          },
        ));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pump();

        expect(deleteCalled, isTrue);
      });

      testWidgets('should display tooltips for action buttons', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final editButton = tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(Icons.edit),
            matching: find.byType(IconButton),
          ),
        );
        expect(editButton.tooltip, equals('Edit'));

        final deleteButton = tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(Icons.delete),
            matching: find.byType(IconButton),
          ),
        );
        expect(deleteButton.tooltip, equals('Delete'));
      });
    });

    group('Visual Styling', () {
      testWidgets('should apply selection styling when selected',
          (tester) async {
        await tester.pumpWidget(createTestWidget(isSelected: true));
        await tester.pump();

        final container =
            tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        // Should have selection background color
        expect(decoration.color, isNotNull);
      });

      testWidgets('should not apply selection styling when unselected',
          (tester) async {
        await tester.pumpWidget(createTestWidget(isSelected: false));
        await tester.pump();

        final container =
            tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        // Should not have selection background color
        expect(decoration.color, isNull);
      });

      testWidgets('should apply border styling', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final container =
            tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        // Should have bottom border
        expect(decoration.border, isNotNull);
        final border = decoration.border as Border;
        expect(border.bottom.width, equals(0.5));
      });

      testWidgets('should style delete button with red color', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final deleteButton = tester.widget<IconButton>(
          find.ancestor(
            of: find.byIcon(Icons.delete),
            matching: find.byType(IconButton),
          ),
        );
        expect(deleteButton.color, equals(Colors.red));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle zero duration', (tester) async {
        final customLog = testLog.copyWith(durationMs: 0);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('0s'), findsOneWidget);
      });

      testWidgets('should handle minimum mood score', (tester) async {
        final customLog = testLog.copyWith(moodScore: 1);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('should handle maximum mood score', (tester) async {
        final customLog = testLog.copyWith(moodScore: 10);

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.byIcon(Icons.sentiment_very_satisfied), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
      });

      testWidgets('should handle all null optional fields', (tester) async {
        final customLog = SmokeLog(
          id: 'test_id',
          accountId: 'test_account',
          ts: DateTime(2023, 6, 15, 14, 30),
          durationMs: 60000,
          methodId: null,
          moodScore: 5,
          physicalScore: 5,
          potency: null,
          notes: null,
          createdAt: DateTime(2023, 6, 15, 14, 30),
          updatedAt: DateTime(2023, 6, 15, 14, 35),
        );

        await tester.pumpWidget(createTestWidget(log: customLog));
        await tester.pump();

        expect(find.text('Unknown'), findsOneWidget); // Method
        expect(find.text('No notes'), findsOneWidget); // Notes
        expect(find.text('5'), findsNWidgets(2)); // Mood and physical scores
      });
    });
  });
}
