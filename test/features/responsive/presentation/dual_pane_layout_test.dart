import 'package:ash_trail/features/responsive/presentation/widgets/adaptive_layout.dart';
import 'package:ash_trail/features/responsive/presentation/providers/layout_provider.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DualPaneLayout shows single pane on non-wide, two panes on wide',
      (tester) async {
    Future<void> pumpWithWidth(double width) async {
      tester.binding.window.physicalSizeTestValue = Size(width * 2, 800 * 2);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      await tester.pumpWidget(ProviderScope(
        overrides: [
          breakpointProvider.overrideWithValue(Breakpoint.fromWidth(width)),
          screenSizeProvider.overrideWithValue(Size(width, 800)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: DualPaneLayout(
              primary: Text('primary'),
              secondary: Text('secondary'),
            ),
          ),
        ),
      ));
      await tester.pump();
    }

    await pumpWithWidth(700); // tablet -> not wide, should only show primary
    expect(find.text('primary'), findsOneWidget);
    expect(find.text('secondary'), findsNothing);

    await pumpWithWidth(1000); // desktop -> dual pane
    expect(find.text('primary'), findsOneWidget);
    expect(find.text('secondary'), findsOneWidget);

    // Cleanup
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });
}
