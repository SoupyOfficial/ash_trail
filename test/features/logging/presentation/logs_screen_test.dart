import 'package:ash_trail/features/haptics_baseline/presentation/providers/haptics_providers.dart';
import 'package:ash_trail/features/loading_skeletons/presentation/widgets/skeleton_list.dart';
import 'package:ash_trail/features/logging/presentation/logs_screen.dart';
import 'package:ash_trail/features/responsive/presentation/widgets/min_tap_target.dart';
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
  Future<void> pumpLogsScreen(
    WidgetTester tester, {
    required Size size,
  }) async {
    final view = tester.view;
    view.devicePixelRatio = 1.0;
    view.physicalSize = Size(size.width, size.height);

    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hapticTriggerProvider.overrideWith(() => _NoopHapticNotifier()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LogsScreen(),
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('Mobile: shows loading then content', (tester) async {
    await pumpLogsScreen(
      tester,
      size: const Size(375, 812),
    );

    expect(find.byType(SkeletonList), findsAtLeastNWidgets(1));
    expect(find.text('Mobile Logs View'), findsNothing);

    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    final addLogButton = find.widgetWithText(ResponsiveButton, 'Add Log');
    expect(addLogButton, findsOneWidget);
    expect(find.text('Mobile Logs View'), findsOneWidget);

    await tester.tap(addLogButton);
    await tester.pumpAndSettle();
    expect(find.text('Add new log'), findsOneWidget);
  });

  testWidgets('Tablet: shows filter button after loading', (tester) async {
    await pumpLogsScreen(
      tester,
      size: const Size(720, 1024),
    );

    expect(find.byType(SkeletonList), findsAtLeastNWidgets(1));

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    final filterButton = find.widgetWithText(ResponsiveButton, 'Filter');
    expect(filterButton, findsOneWidget);
    expect(find.text('Tablet log table will appear here'), findsOneWidget);

    await tester.tap(filterButton);
    await tester.pumpAndSettle();
    expect(find.text('Filter logs'), findsOneWidget);
  });

  testWidgets('Desktop: shows export button after loading', (tester) async {
    await pumpLogsScreen(
      tester,
      size: const Size(1440, 900),
    );

    expect(find.byType(SkeletonList), findsAtLeastNWidgets(1));

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    final exportButton = find.widgetWithText(ResponsiveButton, 'Export');
    expect(exportButton, findsOneWidget);
    expect(find.text('Log Details'), findsOneWidget);

    await tester.tap(exportButton);
    await tester.pumpAndSettle();
    expect(find.text('Export logs'), findsOneWidget);
  });
}
