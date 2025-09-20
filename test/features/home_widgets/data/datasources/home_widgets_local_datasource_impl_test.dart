// Tests for HomeWidgetsLocalDataSourceImpl
// Tests SharedPreferences-based storage for widget configurations

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ash_trail/features/home_widgets/data/datasources/home_widgets_local_datasource_impl.dart';
import 'package:ash_trail/features/home_widgets/data/models/widget_data_model.dart';

void main() {
  group('HomeWidgetsLocalDataSourceImpl', () {
    late HomeWidgetsLocalDataSourceImpl dataSource;
    late SharedPreferences prefs;

    setUp(() async {
      // Initialize SharedPreferences with in-memory implementation
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = HomeWidgetsLocalDataSourceImpl(prefs);
    });

    group('getAllWidgets', () {
      const accountId = 'test_account';

      test('should return empty list when no widgets stored', () async {
        final result = await dataSource.getAllWidgets(accountId);
        expect(result, isEmpty);
      });

      test('should return widgets when data exists', () async {
        final testWidget = WidgetDataModel(
          id: 'widget1',
          accountId: accountId,
          size: 'small',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        // Store widget first
        await dataSource.storeWidget(testWidget);

        final result = await dataSource.getAllWidgets(accountId);
        expect(result, hasLength(1));
        expect(result[0].id, equals('widget1'));
        expect(result[0].accountId, equals(accountId));
      });

      test('should handle invalid JSON gracefully', () async {
        // Store invalid JSON
        await prefs.setString('home_widgets_data_$accountId', 'invalid_json');

        final result = await dataSource.getAllWidgets(accountId);
        expect(result, isEmpty);
      });
    });

    group('getWidget', () {
      const accountId = 'test_account';
      const widgetId = 'test_widget';

      test('should return null when widget not found', () async {
        final result = await dataSource.getWidget(widgetId);
        expect(result, isNull);
      });

      test('should return widget when found', () async {
        final testWidget = WidgetDataModel(
          id: widgetId,
          accountId: accountId,
          size: 'medium',
          tapAction: 'quickRecord',
          todayHitCount: 10,
          currentStreak: 5,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        await dataSource.storeWidget(testWidget);

        final result = await dataSource.getWidget(widgetId);
        expect(result, isNotNull);
        expect(result!.id, equals(widgetId));
      });
    });

    group('storeWidget', () {
      test('should store single widget successfully', () async {
        final testWidget = WidgetDataModel(
          id: 'widget1',
          accountId: 'account1',
          size: 'small',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        await dataSource.storeWidget(testWidget);

        final result = await dataSource.getWidget('widget1');
        expect(result, isNotNull);
        expect(result!.id, equals('widget1'));
      });

      test('should update existing widget', () async {
        final originalWidget = WidgetDataModel(
          id: 'widget1',
          accountId: 'account1',
          size: 'small',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        final updatedWidget = originalWidget.copyWith(
          todayHitCount: 10,
          currentStreak: 7,
        );

        await dataSource.storeWidget(originalWidget);
        await dataSource.updateWidget(updatedWidget);

        final result = await dataSource.getWidget('widget1');
        expect(result!.todayHitCount, equals(10));
        expect(result.currentStreak, equals(7));
      });
    });

    group('storeWidgets', () {
      test('should store multiple widgets successfully', () async {
        final widget1 = WidgetDataModel(
          id: 'widget1',
          accountId: 'account1',
          size: 'small',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        final widget2 = WidgetDataModel(
          id: 'widget2',
          accountId: 'account1',
          size: 'medium',
          tapAction: 'quickRecord',
          todayHitCount: 8,
          currentStreak: 4,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        await dataSource.storeWidget(widget1);
        await dataSource.storeWidget(widget2);

        final result = await dataSource.getAllWidgets('account1');
        expect(result, hasLength(2));
        expect(result.map((w) => w.id), containsAll(['widget1', 'widget2']));
      });
    });

    group('updateWidget', () {
      test('should update existing widget', () async {
        final originalWidget = WidgetDataModel(
          id: 'widget1',
          accountId: 'account1',
          size: 'small',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        final updatedWidget = originalWidget.copyWith(todayHitCount: 15);

        await dataSource.storeWidget(originalWidget);
        await dataSource.updateWidget(updatedWidget);

        final result = await dataSource.getWidget('widget1');
        expect(result!.todayHitCount, equals(15));
      });
    });

    group('deleteWidget', () {
      test('should delete widget successfully', () async {
        final testWidget = WidgetDataModel(
          id: 'widget1',
          accountId: 'account1',
          size: 'small',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        await dataSource.storeWidget(testWidget);
        expect(await dataSource.getWidget('widget1'), isNotNull);

        await dataSource.deleteWidget('widget1');
        expect(await dataSource.getWidget('widget1'), isNull);
      });

      test('should handle deleting non-existent widget', () async {
        // Should not throw an error
        await dataSource.deleteWidget('non_existent_widget');
      });
    });

    group('sync timestamp management', () {
      test('should get and set last sync timestamp', () async {
        const accountId = 'test_account';
        final testTime = DateTime(2023, 1, 1);

        await dataSource.setLastSyncTimestamp(accountId, testTime);
        final result = await dataSource.getLastSyncTimestamp(accountId);

        expect(result, equals(testTime));
      });

      test('should return null for no sync timestamp', () async {
        final result = await dataSource.getLastSyncTimestamp('unknown_account');
        expect(result, isNull);
      });
    });

    group('clear operations', () {
      test('should clear all widgets for account', () async {
        final testWidget = WidgetDataModel(
          id: 'widget1',
          accountId: 'account1',
          size: 'small',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        );

        await dataSource.storeWidget(testWidget);
        expect(await dataSource.getAllWidgets('account1'), hasLength(1));

        await dataSource.clearWidgets('account1');
        expect(await dataSource.getAllWidgets('account1'), isEmpty);
      });
    });
  });
}
