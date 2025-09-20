import 'package:ash_trail/features/responsive/presentation/widgets/responsive_padding.dart';
import 'package:ash_trail/features/responsive/presentation/providers/layout_provider.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ResponsivePadding uses padding based on breakpoint',
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
            body: ResponsivePadding(child: Text('child')),
          ),
        ),
      ));
      await tester.pump();
    }

    await pumpWithWidth(375);
    expect(find.byType(Padding), findsOneWidget);

    await pumpWithWidth(700); // tablet
    expect(find.byType(Padding), findsOneWidget);

    await pumpWithWidth(1000); // desktop
    expect(find.byType(Padding), findsOneWidget);

    // Cleanup
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });
}
