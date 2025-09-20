import 'package:ash_trail/features/haptics_baseline/presentation/providers/haptics_providers.dart';
import 'package:ash_trail/features/logging/presentation/logs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoopHapticNotifier extends HapticTriggerNotifier {
  @override
  Future<bool> tap() async => true;
  @override
  Future<bool> success() async => true;
  @override
  Future<bool> impactLight() async => true;
}

void main() {
  Future<void> pump(WidgetTester tester, Widget child, {Size? size}) async {
    // Set viewport size BEFORE pumping so BreakpointBuilder computes correctly
    if (size != null) {
      tester.binding.window.physicalSizeTestValue =
          Size(size.width * 2, size.height * 2);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
    }
    await tester.pumpWidget(ProviderScope(
      overrides: [
        hapticTriggerProvider.overrideWith(() => _NoopHapticNotifier()),
      ],
      child: MaterialApp(home: child),
    ));
    // Initial pump
    await tester.pump();
  }

  tearDown(() {
    // Reset window after each test
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  testWidgets('Mobile: shows loading then content', (tester) async {
    await pump(tester, const LogsScreen(), size: const Size(375, 812));

    // Initially loading skeleton
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Mobile Logs View'), findsNothing);

    // LoadingStateHandler uses SkeletonList; wait for 600ms delay
    await tester.pump(const Duration(milliseconds: 650));

    expect(find.text('Mobile Logs View'), findsOneWidget);
    expect(find.text('Add Log'), findsOneWidget);

    // Press Add Log (should show snackbar, and haptics overridden)
    await tester.tap(find.text('Add Log'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  }, skip: true);

  testWidgets('Tablet: shows filter button after loading', (tester) async {
    // Width in tablet range (>=600 && <840): use 700 width to avoid desktop
    await pump(tester, const LogsScreen(), size: const Size(700, 800));

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Filter'), findsOneWidget);
    await tester.tap(find.text('Filter'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  }, skip: true);

  testWidgets('Desktop: shows export button after loading', (tester) async {
    await pump(tester, const LogsScreen(), size: const Size(1440, 900));

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Export'), findsOneWidget);
    await tester.tap(find.text('Export'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  }, skip: true);
}
