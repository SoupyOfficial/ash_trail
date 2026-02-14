import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/models/home_widget_config.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/providers/home_widget_config_provider.dart';

void main() {
  group('HomeLayoutConfigNotifier', () {
    late ProviderContainer container;

    Future<ProviderContainer> createContainer() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          activeAccountProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );

      // Force notifier creation and let async _loadConfig settle
      c.read(homeLayoutConfigProvider);
      await Future<void>.delayed(Duration.zero);

      return c;
    }

    setUp(() async {
      container = await createContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with default config', () {
      final config = container.read(homeLayoutConfigProvider);
      expect(config.widgets, isNotEmpty);
      expect(config.version, 2);
    });

    test('reorder changes widget order', () async {
      final notifier = container.read(homeLayoutConfigProvider.notifier);

      final initialVisible =
          container.read(homeLayoutConfigProvider).visibleWidgets;
      expect(initialVisible.length, greaterThanOrEqualTo(3));

      final firstId = initialVisible[0].id;
      final thirdId = initialVisible[2].id;

      // Move first widget to position 2 (reorder adjusts newIndex if > old)
      // reorder(0, 2): newIndex becomes 1 after adjustment
      //   → removes index 0, inserts at 1 → [w1, w0, w2, ...]
      await notifier.reorder(0, 2);
      await Future<void>.delayed(Duration.zero);

      final afterReorder =
          container.read(homeLayoutConfigProvider).visibleWidgets;
      // w0 moved from position 0 to position 1
      expect(afterReorder[1].id, firstId);
      // w2 stays at position 2
      expect(afterReorder[2].id, thirdId);
    });

    test('undoReorder restores previous state', () async {
      final notifier = container.read(homeLayoutConfigProvider.notifier);

      final initialVisible =
          container.read(homeLayoutConfigProvider).visibleWidgets;
      final originalOrder = initialVisible.map((w) => w.id).toList();

      // Reorder
      await notifier.reorder(0, 3);
      await Future<void>.delayed(Duration.zero);

      final afterReorder =
          container.read(homeLayoutConfigProvider).visibleWidgets;
      final reorderedOrder = afterReorder.map((w) => w.id).toList();
      expect(reorderedOrder, isNot(equals(originalOrder)));

      // Undo
      final didUndo = await notifier.undoReorder();
      await Future<void>.delayed(Duration.zero);
      expect(didUndo, isTrue);

      final afterUndo = container.read(homeLayoutConfigProvider).visibleWidgets;
      final undoneOrder = afterUndo.map((w) => w.id).toList();
      expect(undoneOrder, equals(originalOrder));
    });

    test('undoReorder returns false when nothing to undo', () async {
      final notifier = container.read(homeLayoutConfigProvider.notifier);
      final didUndo = await notifier.undoReorder();
      expect(didUndo, isFalse);
    });

    test('undoReorder only undoes the last reorder', () async {
      final notifier = container.read(homeLayoutConfigProvider.notifier);

      final initialVisible =
          container.read(homeLayoutConfigProvider).visibleWidgets;
      final originalOrder = initialVisible.map((w) => w.id).toList();

      // First reorder: move 0 → 3
      await notifier.reorder(0, 3);
      await Future<void>.delayed(Duration.zero);

      final afterFirst =
          container.read(homeLayoutConfigProvider).visibleWidgets;
      final firstReorderOrder = afterFirst.map((w) => w.id).toList();

      // Second reorder: move 0 → 2
      await notifier.reorder(0, 2);
      await Future<void>.delayed(Duration.zero);

      // Undo should restore to after-first-reorder, not original
      await notifier.undoReorder();
      await Future<void>.delayed(Duration.zero);

      final afterUndo = container.read(homeLayoutConfigProvider).visibleWidgets;
      final undoneOrder = afterUndo.map((w) => w.id).toList();
      expect(undoneOrder, equals(firstReorderOrder));
      expect(undoneOrder, isNot(equals(originalOrder)));
    });

    test('undoReorder clears previous state after undo', () async {
      final notifier = container.read(homeLayoutConfigProvider.notifier);

      await notifier.reorder(0, 3);
      await Future<void>.delayed(Duration.zero);

      final didFirst = await notifier.undoReorder();
      await Future<void>.delayed(Duration.zero);
      expect(didFirst, isTrue);

      // Second undo should fail — no previous state
      final didSecond = await notifier.undoReorder();
      expect(didSecond, isFalse);
    });

    test('addWidget adds to the layout', () async {
      final notifier = container.read(homeLayoutConfigProvider.notifier);

      final config = container.read(homeLayoutConfigProvider);
      final existingWidget = config.widgets.first;

      await notifier.removeWidget(existingWidget.id);
      await Future<void>.delayed(Duration.zero);

      final afterRemove = container.read(homeLayoutConfigProvider);
      expect(afterRemove.widgets.length, config.widgets.length - 1);

      await notifier.addWidget(existingWidget.type);
      await Future<void>.delayed(Duration.zero);

      final afterAdd = container.read(homeLayoutConfigProvider);
      expect(afterAdd.widgets.length, config.widgets.length);
    });

    test('removeWidget removes from the layout', () async {
      final notifier = container.read(homeLayoutConfigProvider.notifier);
      final config = container.read(homeLayoutConfigProvider);
      final widgetId = config.widgets.first.id;

      await notifier.removeWidget(widgetId);
      await Future<void>.delayed(Duration.zero);

      final after = container.read(homeLayoutConfigProvider);
      expect(after.widgets.any((w) => w.id == widgetId), isFalse);
    });

    test('updateWidgetSettings merges settings', () async {
      final notifier = container.read(homeLayoutConfigProvider.notifier);

      final config = container.read(homeLayoutConfigProvider);
      final widgetId = config.widgets.first.id;

      await notifier.updateWidgetSettings(widgetId, {'count': 10});
      await Future<void>.delayed(Duration.zero);

      final after = container.read(homeLayoutConfigProvider);
      final updated = after.widgets.firstWhere((w) => w.id == widgetId);
      expect(updated.settings?['count'], 10);
    });

    test('persists config to SharedPreferences', () async {
      final notifier = container.read(homeLayoutConfigProvider.notifier);
      final config = container.read(homeLayoutConfigProvider);
      final widgetId = config.widgets.first.id;

      await notifier.removeWidget(widgetId);
      await Future<void>.delayed(Duration.zero);

      final prefs = container.read(sharedPreferencesProvider);
      final stored = prefs.getString('home_layout_default');
      expect(stored, isNotNull);

      final restored = HomeLayoutConfig.fromJsonString(stored!);
      expect(restored.widgets.any((w) => w.id == widgetId), isFalse);
    });
  });
}
