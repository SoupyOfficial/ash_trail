import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/widgets/reason_chips_grid.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('ReasonChipsGrid', () {
    testWidgets('displays all LogReason values', (tester) async {
      final selected = <LogReason>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: selected,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      // All LogReason values should have their display name shown
      for (final reason in LogReason.values) {
        expect(find.text(reason.displayName), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('shows selected state for selected reasons', (tester) async {
      final selected = {LogReason.medical, LogReason.stress};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: selected,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      // Widget should build successfully with selected items
      expect(find.text(LogReason.medical.displayName), findsOneWidget);
      expect(find.text(LogReason.stress.displayName), findsOneWidget);
    });

    testWidgets('calls onToggle when chip is tapped', (tester) async {
      LogReason? toggledReason;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: <LogReason>{},
              onToggle: (reason) => toggledReason = reason,
            ),
          ),
        ),
      );

      // Find and tap the first reason chip
      final firstReason = LogReason.values.first;
      await tester.tap(find.text(firstReason.displayName));
      await tester.pumpAndSettle();

      expect(toggledReason, equals(firstReason));
    });

    testWidgets('uses default 2 columns', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: <LogReason>{},
              onToggle: (_) {},
            ),
          ),
        ),
      );

      // Find Row widgets - should be one row for each pair of reasons
      final expectedRows = (LogReason.values.length / 2).ceil();
      expect(find.byType(Row), findsAtLeastNWidgets(expectedRows));
    });

    testWidgets('respects custom columnsPerRow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: <LogReason>{},
              onToggle: (_) {},
              columnsPerRow: 3,
            ),
          ),
        ),
      );

      // Widget should build successfully with 3 columns
      expect(find.byType(ReasonChipsGrid), findsOneWidget);
    });

    testWidgets('shows icons when showIcons is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: <LogReason>{},
              onToggle: (_) {},
              showIcons: true,
            ),
          ),
        ),
      );

      // Find Icon widgets - should be one for each reason
      expect(find.byType(Icon), findsNWidgets(LogReason.values.length));
    });

    testWidgets('does not show icons when showIcons is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: <LogReason>{},
              onToggle: (_) {},
              showIcons: false,
            ),
          ),
        ),
      );

      // No Icon widgets should be present
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('uses custom spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: <LogReason>{},
              onToggle: (_) {},
              spacing: 16.0,
            ),
          ),
        ),
      );

      // Widget should build successfully with custom spacing
      expect(find.byType(ReasonChipsGrid), findsOneWidget);
    });

    testWidgets('wraps chips in Column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: <LogReason>{},
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('toggles selection when tapped', (tester) async {
      final selected = <LogReason>{};
      LogReason? lastToggled;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ReasonChipsGrid(
                  selected: selected,
                  onToggle: (reason) {
                    setState(() {
                      lastToggled = reason;
                      if (selected.contains(reason)) {
                        selected.remove(reason);
                      } else {
                        selected.add(reason);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap a reason to select it
      await tester.tap(find.text(LogReason.recreational.displayName));
      await tester.pumpAndSettle();

      expect(lastToggled, equals(LogReason.recreational));
      expect(selected.contains(LogReason.recreational), isTrue);

      // Tap again to deselect
      await tester.tap(find.text(LogReason.recreational.displayName));
      await tester.pumpAndSettle();

      expect(selected.contains(LogReason.recreational), isFalse);
    });

    testWidgets('handles empty selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: const <LogReason>{},
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ReasonChipsGrid), findsOneWidget);
    });

    testWidgets('handles all selected', (tester) async {
      final allSelected = Set<LogReason>.from(LogReason.values);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: allSelected,
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ReasonChipsGrid), findsOneWidget);
    });

    testWidgets('each chip is tappable via InkWell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: <LogReason>{},
              onToggle: (_) {},
            ),
          ),
        ),
      );

      // Each reason chip should have an InkWell
      expect(find.byType(InkWell), findsNWidgets(LogReason.values.length));
    });

    testWidgets('chips have Material ancestor for ripple effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReasonChipsGrid(
              selected: <LogReason>{},
              onToggle: (_) {},
            ),
          ),
        ),
      );

      // Each chip should be wrapped in Material for visual effects
      expect(find.byType(Material), findsAtLeastNWidgets(LogReason.values.length));
    });
  });
}
