import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/home_widget_config.dart';
import 'package:ash_trail/widgets/home_widgets/widget_catalog.dart';

void main() {
  group('HomeWidgetConfig', () {
    test('creates with required parameters', () {
      const config = HomeWidgetConfig(
        id: 'test-id',
        type: HomeWidgetType.timeSinceLastHit,
        order: 0,
      );

      expect(config.id, 'test-id');
      expect(config.type, HomeWidgetType.timeSinceLastHit);
      expect(config.order, 0);
      expect(config.isVisible, isTrue); // default
      expect(config.settings, isNull);
    });

    test('creates with all parameters', () {
      const config = HomeWidgetConfig(
        id: 'test-id',
        type: HomeWidgetType.quickLog,
        order: 5,
        isVisible: false,
        settings: {'key': 'value'},
      );

      expect(config.isVisible, isFalse);
      expect(config.settings, {'key': 'value'});
    });

    test('factory create generates unique ID', () {
      final config1 = HomeWidgetConfig.create(
        type: HomeWidgetType.timeSinceLastHit,
        order: 0,
      );
      final config2 = HomeWidgetConfig.create(
        type: HomeWidgetType.timeSinceLastHit,
        order: 1,
      );

      expect(config1.id, isNotEmpty);
      expect(config2.id, isNotEmpty);
      expect(config1.id, isNot(config2.id));
    });

    test('factory create accepts settings', () {
      final config = HomeWidgetConfig.create(
        type: HomeWidgetType.recentEntries,
        order: 0,
        settings: {'count': 5},
      );

      expect(config.settings, {'count': 5});
    });

    group('getSetting', () {
      test('returns value when present and correct type', () {
        const config = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.recentEntries,
          order: 0,
          settings: {'count': 5, 'name': 'test'},
        );

        expect(config.getSetting<int>('count'), 5);
        expect(config.getSetting<String>('name'), 'test');
      });

      test('returns null for missing key', () {
        const config = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.recentEntries,
          order: 0,
          settings: {'count': 5},
        );

        expect(config.getSetting<int>('missing'), isNull);
      });

      test('returns null for wrong type', () {
        const config = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.recentEntries,
          order: 0,
          settings: {'count': 'not-an-int'},
        );

        expect(config.getSetting<int>('count'), isNull);
      });

      test('returns null when settings is null', () {
        const config = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
        );

        expect(config.getSetting<int>('count'), isNull);
      });
    });

    group('copyWith', () {
      test('copies with new id', () {
        const original = HomeWidgetConfig(
          id: 'original-id',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
        );
        final copy = original.copyWith(id: 'new-id');
        expect(copy.id, 'new-id');
        expect(copy.type, original.type);
      });

      test('copies with new type', () {
        const original = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
        );
        final copy = original.copyWith(type: HomeWidgetType.quickLog);
        expect(copy.type, HomeWidgetType.quickLog);
      });

      test('copies with new visibility', () {
        const original = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
          isVisible: true,
        );
        final copy = original.copyWith(isVisible: false);
        expect(copy.isVisible, isFalse);
      });

      test('copies with new order', () {
        const original = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
        );
        final copy = original.copyWith(order: 5);
        expect(copy.order, 5);
      });

      test('copies with new settings', () {
        const original = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.recentEntries,
          order: 0,
          settings: {'old': 'value'},
        );
        final copy = original.copyWith(settings: {'new': 'setting'});
        expect(copy.settings, {'new': 'setting'});
      });
    });

    group('JSON serialization', () {
      test('toJson includes all fields', () {
        const config = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.timeSinceLastHit,
          order: 2,
          isVisible: false,
          settings: {'key': 'value'},
        );

        final json = config.toJson();
        expect(json['id'], 'test-id');
        expect(json['type'], 'timeSinceLastHit');
        expect(json['order'], 2);
        expect(json['isVisible'], false);
        expect(json['settings'], {'key': 'value'});
      });

      test('toJson excludes null settings', () {
        const config = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
        );

        final json = config.toJson();
        expect(json.containsKey('settings'), isFalse);
      });

      test('fromJson parses all fields', () {
        final json = {
          'id': 'test-id',
          'type': 'quickLog',
          'order': 3,
          'isVisible': false,
          'settings': {'count': 5},
        };

        final config = HomeWidgetConfig.fromJson(json);
        expect(config.id, 'test-id');
        expect(config.type, HomeWidgetType.quickLog);
        expect(config.order, 3);
        expect(config.isVisible, false);
        expect(config.settings, {'count': 5});
      });

      test('fromJson uses defaults for missing optional fields', () {
        final json = {'id': 'test-id', 'type': 'timeSinceLastHit'};

        final config = HomeWidgetConfig.fromJson(json);
        expect(config.isVisible, isTrue);
        expect(config.order, 0);
        expect(config.settings, isNull);
      });

      test('fromJson uses default type for unknown type', () {
        final json = {'id': 'test-id', 'type': 'unknown_type', 'order': 0};

        final config = HomeWidgetConfig.fromJson(json);
        expect(config.type, HomeWidgetType.timeSinceLastHit);
      });

      test('roundtrip serialization preserves data', () {
        const original = HomeWidgetConfig(
          id: 'test-id',
          type: HomeWidgetType.recentEntries,
          order: 5,
          isVisible: false,
          settings: {'count': 10},
        );

        final json = original.toJson();
        final restored = HomeWidgetConfig.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.order, original.order);
        expect(restored.isVisible, original.isVisible);
        expect(restored.settings, original.settings);
      });
    });

    group('equality', () {
      test('configs with same id are equal', () {
        const config1 = HomeWidgetConfig(
          id: 'same-id',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
        );
        const config2 = HomeWidgetConfig(
          id: 'same-id',
          type: HomeWidgetType.quickLog, // Different type
          order: 5, // Different order
        );

        expect(config1, equals(config2));
      });

      test('configs with different ids are not equal', () {
        const config1 = HomeWidgetConfig(
          id: 'id-1',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
        );
        const config2 = HomeWidgetConfig(
          id: 'id-2',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
        );

        expect(config1, isNot(equals(config2)));
      });

      test('hashCode is based on id', () {
        const config1 = HomeWidgetConfig(
          id: 'same-id',
          type: HomeWidgetType.timeSinceLastHit,
          order: 0,
        );
        const config2 = HomeWidgetConfig(
          id: 'same-id',
          type: HomeWidgetType.quickLog,
          order: 5,
        );

        expect(config1.hashCode, config2.hashCode);
      });
    });
  });

  group('HomeLayoutConfig', () {
    test('creates with widgets list', () {
      final config = HomeLayoutConfig(
        widgets: [
          HomeWidgetConfig.create(
            type: HomeWidgetType.timeSinceLastHit,
            order: 0,
          ),
          HomeWidgetConfig.create(type: HomeWidgetType.quickLog, order: 1),
        ],
      );

      expect(config.widgets.length, 2);
      expect(config.version, 2); // default
    });

    test('defaultConfig creates standard widget set', () {
      final config = HomeLayoutConfig.defaultConfig();
      expect(config.widgets, isNotEmpty);
      expect(config.version, 2);
    });

    group('visibleWidgets', () {
      test('returns only visible widgets sorted by order', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w3',
              type: HomeWidgetType.quickLog,
              order: 2,
            ),
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
            const HomeWidgetConfig(
              id: 'hidden',
              type: HomeWidgetType.recentEntries,
              order: 1,
              isVisible: false,
            ),
            const HomeWidgetConfig(
              id: 'w2',
              type: HomeWidgetType.totalDurationToday,
              order: 1,
            ),
          ],
        );

        final visible = config.visibleWidgets;
        expect(visible.length, 3);
        expect(visible[0].id, 'w1');
        expect(visible[1].id, 'w2');
        expect(visible[2].id, 'w3');
      });

      test('returns empty list when all hidden', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
              isVisible: false,
            ),
          ],
        );

        expect(config.visibleWidgets, isEmpty);
      });
    });

    group('hasWidgetType', () {
      test('returns true when type exists', () {
        final config = HomeLayoutConfig(
          widgets: [
            HomeWidgetConfig.create(
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
          ],
        );

        expect(config.hasWidgetType(HomeWidgetType.timeSinceLastHit), isTrue);
      });

      test('returns false when type does not exist', () {
        final config = HomeLayoutConfig(
          widgets: [
            HomeWidgetConfig.create(
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
          ],
        );

        expect(config.hasWidgetType(HomeWidgetType.quickLog), isFalse);
      });
    });

    group('addWidget', () {
      test('adds widget with next order', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
            const HomeWidgetConfig(
              id: 'w2',
              type: HomeWidgetType.quickLog,
              order: 1,
            ),
          ],
        );

        final updated = config.addWidget(HomeWidgetType.totalDurationToday);
        expect(updated.widgets.length, 3);
        expect(updated.widgets.last.type, HomeWidgetType.totalDurationToday);
        expect(updated.widgets.last.order, 2);
      });

      test('adds widget to empty list with order 0', () {
        const config = HomeLayoutConfig(widgets: []);
        final updated = config.addWidget(HomeWidgetType.timeSinceLastHit);
        expect(updated.widgets.length, 1);
        expect(updated.widgets.first.order, 0);
      });

      test('adds widget with settings', () {
        const config = HomeLayoutConfig(widgets: []);
        final updated = config.addWidget(
          HomeWidgetType.recentEntries,
          settings: {'count': 10},
        );
        expect(updated.widgets.first.settings, {'count': 10});
      });
    });

    group('removeWidget', () {
      test('removes widget by id', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
            const HomeWidgetConfig(
              id: 'w2',
              type: HomeWidgetType.quickLog,
              order: 1,
            ),
          ],
        );

        final updated = config.removeWidget('w1');
        expect(updated.widgets.length, 1);
        expect(updated.widgets.first.id, 'w2');
      });

      test('returns unchanged if id not found', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
          ],
        );

        final updated = config.removeWidget('nonexistent');
        expect(updated.widgets.length, 1);
      });
    });

    group('setWidgetVisibility', () {
      test('hides visible widget', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
              isVisible: true,
            ),
          ],
        );

        final updated = config.setWidgetVisibility('w1', false);
        expect(updated.widgets.first.isVisible, isFalse);
      });

      test('shows hidden widget', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
              isVisible: false,
            ),
          ],
        );

        final updated = config.setWidgetVisibility('w1', true);
        expect(updated.widgets.first.isVisible, isTrue);
      });

      test('does not change other widgets', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
              isVisible: true,
            ),
            const HomeWidgetConfig(
              id: 'w2',
              type: HomeWidgetType.quickLog,
              order: 1,
              isVisible: true,
            ),
          ],
        );

        final updated = config.setWidgetVisibility('w1', false);
        expect(updated.widgets[1].isVisible, isTrue);
      });
    });

    group('reorder', () {
      test('reorders widgets forward', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w0',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.quickLog,
              order: 1,
            ),
            const HomeWidgetConfig(
              id: 'w2',
              type: HomeWidgetType.totalDurationToday,
              order: 2,
            ),
          ],
        );

        // Move w0 to position 2
        final updated = config.reorder(0, 2);
        final visible = updated.visibleWidgets;
        expect(visible[0].id, 'w1');
        expect(visible[1].id, 'w0');
        expect(visible[2].id, 'w2');
      });

      test('reorders widgets backward', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w0',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.quickLog,
              order: 1,
            ),
            const HomeWidgetConfig(
              id: 'w2',
              type: HomeWidgetType.totalDurationToday,
              order: 2,
            ),
          ],
        );

        // Move w2 to position 0
        final updated = config.reorder(2, 0);
        final visible = updated.visibleWidgets;
        expect(visible[0].id, 'w2');
        expect(visible[1].id, 'w0');
        expect(visible[2].id, 'w1');
      });

      test('handles invalid old index', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w0',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
          ],
        );

        final updated = config.reorder(-1, 0);
        expect(updated.widgets.length, config.widgets.length);
      });

      test('handles invalid new index', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w0',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
          ],
        );

        final updated = config.reorder(0, -1);
        expect(updated.widgets.length, config.widgets.length);
      });

      test('preserves hidden widgets after reorder', () {
        final config = HomeLayoutConfig(
          widgets: [
            const HomeWidgetConfig(
              id: 'w0',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
            const HomeWidgetConfig(
              id: 'hidden',
              type: HomeWidgetType.quickLog,
              order: 1,
              isVisible: false,
            ),
            const HomeWidgetConfig(
              id: 'w2',
              type: HomeWidgetType.totalDurationToday,
              order: 2,
            ),
          ],
        );

        final updated = config.reorder(0, 2);
        expect(
          updated.widgets.any((w) => w.id == 'hidden' && !w.isVisible),
          isTrue,
        );
      });
    });

    group('JSON serialization', () {
      test('toJson includes all data', () {
        final config = HomeLayoutConfig(
          version: 2,
          widgets: [
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.timeSinceLastHit,
              order: 0,
            ),
          ],
        );

        final json = config.toJson();
        expect(json['version'], 2);
        expect(json['widgets'], isList);
        expect((json['widgets'] as List).length, 1);
      });

      test('fromJson parses data correctly', () {
        final json = {
          'version': 2,
          'widgets': [
            {'id': 'w1', 'type': 'quickLog', 'order': 0, 'isVisible': true},
          ],
        };

        final config = HomeLayoutConfig.fromJson(json);
        expect(config.version, 2);
        expect(config.widgets.length, 1);
        expect(config.widgets.first.type, HomeWidgetType.quickLog);
      });

      test('fromJson uses defaults for missing fields', () {
        final json = <String, dynamic>{};
        final config = HomeLayoutConfig.fromJson(json);
        expect(config.version, 2);
        expect(config.widgets, isEmpty);
      });

      test('roundtrip preserves data', () {
        final original = HomeLayoutConfig(
          version: 2,
          widgets: [
            const HomeWidgetConfig(
              id: 'w1',
              type: HomeWidgetType.recentEntries,
              order: 5,
              isVisible: false,
              settings: {'count': 10},
            ),
          ],
        );

        final json = original.toJson();
        final restored = HomeLayoutConfig.fromJson(json);

        expect(restored.version, 2);
        expect(restored.widgets.length, original.widgets.length);
        expect(restored.widgets.first.id, original.widgets.first.id);
      });

      test('toJsonString creates valid JSON', () {
        final config = HomeLayoutConfig.defaultConfig();
        final jsonString = config.toJsonString();
        expect(jsonString, isNotEmpty);
        expect(
          () => HomeLayoutConfig.fromJsonString(jsonString),
          returnsNormally,
        );
      });

      test('fromJsonString returns default on invalid JSON', () {
        final config = HomeLayoutConfig.fromJsonString('invalid json');
        expect(config.widgets, isNotEmpty); // Default config
      });

      test('fromJsonString parses valid JSON', () {
        const jsonString = '{"version":2,"widgets":[]}';
        final config = HomeLayoutConfig.fromJsonString(jsonString);
        expect(config.version, 2);
        expect(config.widgets, isEmpty);
      });
    });
  });

  group('WidgetSize.columnSpan', () {
    test('compact spans 1 column regardless of crossAxisCount', () {
      expect(WidgetSize.compact.columnSpan(2), 1);
      expect(WidgetSize.compact.columnSpan(3), 1);
      expect(WidgetSize.compact.columnSpan(4), 1);
    });

    test('standard spans 2 columns', () {
      expect(WidgetSize.standard.columnSpan(2), 2);
      expect(WidgetSize.standard.columnSpan(3), 2);
      expect(WidgetSize.standard.columnSpan(4), 2);
    });

    test('large spans full crossAxisCount', () {
      expect(WidgetSize.large.columnSpan(2), 2);
      expect(WidgetSize.large.columnSpan(3), 3);
      expect(WidgetSize.large.columnSpan(4), 4);
    });
  });

  group('HomeLayoutConfig - v1 to v2 migration', () {
    test('fromJson migrates v1 to v2', () {
      final json = {
        'version': 1,
        'widgets': [
          {'id': 'w1', 'type': 'quickLog', 'order': 0, 'isVisible': true},
        ],
      };

      final config = HomeLayoutConfig.fromJson(json);
      expect(config.version, 2);
      expect(config.widgets.length, 1);
    });

    test('fromJson migrates missing version to v2', () {
      final json = {
        'widgets': [
          {'id': 'w1', 'type': 'timeSinceLastHit', 'order': 0},
        ],
      };

      final config = HomeLayoutConfig.fromJson(json);
      expect(config.version, 2);
    });
  });
}
