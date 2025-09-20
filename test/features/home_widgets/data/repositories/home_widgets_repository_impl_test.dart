// Simplified unit tests for HomeWidgetsRepositoryImpl
// Tests basic repository functionality with offline-first patterns

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ash_trail/features/home_widgets/data/repositories/home_widgets_repository_impl.dart';
import 'package:ash_trail/features/home_widgets/data/datasources/home_widgets_local_datasource.dart';
import 'package:ash_trail/features/home_widgets/data/datasources/home_widgets_remote_datasource.dart';
import 'package:ash_trail/features/home_widgets/data/models/widget_data_model.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_data.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_size.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';

class MockHomeWidgetsLocalDataSource extends Mock
    implements HomeWidgetsLocalDataSource {}

class MockHomeWidgetsRemoteDataSource extends Mock
    implements HomeWidgetsRemoteDataSource {}

// Fake implementations for test stubs
class FakeWidgetDataModel extends Fake implements WidgetDataModel {}

class FakeWidgetData extends Fake implements WidgetData {}

void main() {
  group('HomeWidgetsRepositoryImpl Basic Tests', () {
    late MockHomeWidgetsLocalDataSource mockLocalDataSource;
    late MockHomeWidgetsRemoteDataSource mockRemoteDataSource;
    late HomeWidgetsRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(FakeWidgetDataModel());
      registerFallbackValue(FakeWidgetData());
    });

    setUp(() {
      mockLocalDataSource = MockHomeWidgetsLocalDataSource();
      mockRemoteDataSource = MockHomeWidgetsRemoteDataSource();
      repository = HomeWidgetsRepositoryImpl(
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource,
      );
    });

    group('getAllWidgets', () {
      const accountId = 'test_account';
      final testModels = [
        WidgetDataModel(
          id: 'widget1',
          accountId: accountId,
          size: 'small',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: DateTime(2023, 1, 1),
          createdAt: DateTime(2023, 1, 1),
        ),
      ];

      test('should return widgets from local cache when available', () async {
        // arrange
        when(() => mockLocalDataSource.getAllWidgets(accountId))
            .thenAnswer((_) async => testModels);

        // act
        final result = await repository.getAllWidgets(accountId);

        // assert
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (widgets) {
            expect(widgets, hasLength(1));
            expect(widgets[0].id, equals('widget1'));
          },
        );

        verify(() => mockLocalDataSource.getAllWidgets(accountId));
        verifyNever(() => mockRemoteDataSource.getAllWidgets(accountId));
      });

      test('should return failure when exception occurs', () async {
        // arrange
        when(() => mockLocalDataSource.getAllWidgets(accountId))
            .thenThrow(Exception('Database error'));

        // act
        final result = await repository.getAllWidgets(accountId);

        // assert
        result.fold(
          (failure) {
            expect(failure.toString(), contains('Failed to get widgets'));
          },
          (widgets) => fail('Expected failure, got success: $widgets'),
        );
      });
    });

    group('getWidget', () {
      const widgetId = 'test_widget';
      final testModel = WidgetDataModel(
        id: widgetId,
        accountId: 'account1',
        size: 'small',
        tapAction: 'openApp',
        todayHitCount: 5,
        currentStreak: 3,
        lastSyncAt: DateTime(2023, 1, 1),
        createdAt: DateTime(2023, 1, 1),
      );

      test('should return widget from local cache when available', () async {
        // arrange
        when(() => mockLocalDataSource.getWidget(widgetId))
            .thenAnswer((_) async => testModel);

        // act
        final result = await repository.getWidget(widgetId);

        // assert
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (widget) {
            expect(widget.id, equals(widgetId));
          },
        );

        verify(() => mockLocalDataSource.getWidget(widgetId));
        verifyNever(() => mockRemoteDataSource.getWidget(widgetId));
      });

      test('should return failure when widget not found', () async {
        // arrange
        when(() => mockLocalDataSource.getWidget(widgetId))
            .thenAnswer((_) async => null);
        when(() => mockRemoteDataSource.getWidget(widgetId))
            .thenThrow(Exception('Widget not found'));

        // act
        final result = await repository.getWidget(widgetId);

        // assert
        result.fold(
          (failure) {
            expect(failure.toString(), contains('Widget not found'));
          },
          (widget) => fail('Expected failure, got success: $widget'),
        );
      });
    });

    group('updateWidget', () {
      final testWidget = WidgetData(
        id: 'widget1',
        accountId: 'account1',
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.quickRecord,
        todayHitCount: 10,
        currentStreak: 5,
        lastSyncAt: DateTime(2023, 1, 1),
        createdAt: DateTime(2023, 1, 1),
      );

      final updatedModel = WidgetDataModel.fromEntity(testWidget);

      test('should update widget remotely and locally', () async {
        // arrange
        when(() => mockRemoteDataSource.updateWidget(any()))
            .thenAnswer((_) async => updatedModel);
        when(() => mockLocalDataSource.updateWidget(any()))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.updateWidget(testWidget);

        // assert
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (widget) {
            expect(widget.id, equals('widget1'));
            expect(widget.todayHitCount, equals(10));
          },
        );

        verify(() => mockRemoteDataSource.updateWidget(any()));
        verify(() => mockLocalDataSource.updateWidget(any()));
      });

      test('should return failure when update fails', () async {
        // arrange
        when(() => mockRemoteDataSource.updateWidget(any()))
            .thenThrow(Exception('Network error'));

        // act
        final result = await repository.updateWidget(testWidget);

        // assert
        result.fold(
          (failure) {
            expect(failure.toString(), contains('Failed to update widget'));
          },
          (widget) => fail('Expected failure, got success: $widget'),
        );
      });
    });

    group('deleteWidget', () {
      const widgetId = 'test_widget';

      test('should delete widget remotely and locally', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteWidget(widgetId))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.deleteWidget(widgetId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.deleteWidget(widgetId);

        // assert
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (unit) => expect(unit, equals(unit)),
        );

        verify(() => mockRemoteDataSource.deleteWidget(widgetId));
        verify(() => mockLocalDataSource.deleteWidget(widgetId));
      });

      test('should return failure when delete fails', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteWidget(widgetId))
            .thenThrow(Exception('Network error'));

        // act
        final result = await repository.deleteWidget(widgetId);

        // assert
        result.fold(
          (failure) {
            expect(failure.toString(), contains('Failed to delete widget'));
          },
          (unit) => fail('Expected failure, got success: $unit'),
        );
      });
    });

    group('getTodayHitCount', () {
      const accountId = 'test_account';

      test('should return hit count from remote', () async {
        // arrange
        when(() => mockRemoteDataSource.getTodayHitCount(accountId))
            .thenAnswer((_) async => 15);

        // act
        final result = await repository.getTodayHitCount(accountId);

        // assert
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (count) {
            expect(count, equals(15));
          },
        );

        verify(() => mockRemoteDataSource.getTodayHitCount(accountId));
      });

      test('should return failure when remote call fails', () async {
        // arrange
        when(() => mockRemoteDataSource.getTodayHitCount(accountId))
            .thenThrow(Exception('Network error'));

        // act
        final result = await repository.getTodayHitCount(accountId);

        // assert
        result.fold(
          (failure) {
            expect(failure.toString(), contains('Failed to get hit count'));
          },
          (count) => fail('Expected failure, got success: $count'),
        );
      });
    });

    group('getCurrentStreak', () {
      const accountId = 'test_account';

      test('should return streak from remote', () async {
        // arrange
        when(() => mockRemoteDataSource.getCurrentStreak(accountId))
            .thenAnswer((_) async => 7);

        // act
        final result = await repository.getCurrentStreak(accountId);

        // assert
        result.fold(
          (failure) => fail('Expected success, got failure: $failure'),
          (streak) {
            expect(streak, equals(7));
          },
        );

        verify(() => mockRemoteDataSource.getCurrentStreak(accountId));
      });

      test('should return failure when remote call fails', () async {
        // arrange
        when(() => mockRemoteDataSource.getCurrentStreak(accountId))
            .thenThrow(Exception('Network error'));

        // act
        final result = await repository.getCurrentStreak(accountId);

        // assert
        result.fold(
          (failure) {
            expect(failure.toString(), contains('Failed to get streak'));
          },
          (streak) => fail('Expected failure, got success: $streak'),
        );
      });
    });
  });
}