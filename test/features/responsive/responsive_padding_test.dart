import 'package:ash_trail/features/responsive/presentation/widgets/breakpoint_builder.dart';
import 'package:ash_trail/features/responsive/presentation/widgets/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets(
      'ResponsivePadding renders child when wrapped in BreakpointBuilder',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: BreakpointBuilder(
            builder: (context, breakpoint, _) => const ResponsivePadding(
              child: Text('Hello'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
  });
}
