import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/widgets/backdate_dialog.dart';
import 'package:ash_trail/widgets/log_entry_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return ProviderScope(child: MaterialApp(home: Scaffold(body: child)));
}

void main() {
  group('CreateLogEntryDialog defaults', () {
    testWidgets('defaults to vape + seconds', (tester) async {
      await tester.pumpWidget(_wrap(const CreateLogEntryDialog()));

      final eventState = tester.state<FormFieldState<EventType>>(
        find.byType(DropdownButtonFormField<EventType>),
      );
      final unitState = tester.state<FormFieldState<Unit>>(
        find.byType(DropdownButtonFormField<Unit>),
      );

      expect(eventState.value, EventType.vape);
      expect(unitState.value, Unit.seconds);
    });

    testWidgets('switching back to vape sets unit to seconds', (tester) async {
      await tester.pumpWidget(_wrap(const CreateLogEntryDialog()));

      final eventFinder = find.byType(DropdownButtonFormField<EventType>);
      final unitFinder = find.byType(DropdownButtonFormField<Unit>);

      // Change to Inhale first to ensure unit changes
      await tester.tap(eventFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inhale').last);
      await tester.pumpAndSettle();

      var unitState = tester.state<FormFieldState<Unit>>(unitFinder);
      expect(unitState.value, Unit.hits);

      // Change back to Vape and expect seconds
      await tester.tap(eventFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vape').last);
      await tester.pumpAndSettle();

      unitState = tester.state<FormFieldState<Unit>>(unitFinder);
      expect(unitState.value, Unit.seconds);
    });
  });

  group('BackdateDialog defaults', () {
    testWidgets('defaults to vape + seconds', (tester) async {
      await tester.pumpWidget(_wrap(const BackdateDialog()));

      final eventState = tester.state<FormFieldState<EventType>>(
        find.byType(DropdownButtonFormField<EventType>),
      );
      final unitState = tester.state<FormFieldState<Unit>>(
        find.byType(DropdownButtonFormField<Unit>),
      );

      expect(eventState.value, EventType.vape);
      expect(unitState.value, Unit.seconds);
    });
  });
}
