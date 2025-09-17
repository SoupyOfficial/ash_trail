// Repository implementation for home screen widget data management.
// Implements clean architecture repository pattern with offline-first approach.

import 'package:fpdart/fpdart.dart';
import '../../domain/entities/widget_data.dart';
import '../../domain/entities/widget_size.dart';
import '../../domain/entities/widget_tap_action.dart';
import '../../domain/repositories/home_widgets_repository.dart';
import '../datasources/home_widgets_local_datasource.dart';
import '../datasources/home_widgets_remote_datasource.dart';
import '../models/widget_data_model.dart';
import '../../../../core/failures/app_failure.dart';

class HomeWidgetsRepositoryImpl implements HomeWidgetsRepository {
  const HomeWidgetsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final HomeWidgetsLocalDataSource localDataSource;
  final HomeWidgetsRemoteDataSource remoteDataSource;

  @override
  Future<Either<AppFailure, List<WidgetData>>> getAllWidgets(
      String accountId) async {
    try {
      // Try local first (offline-first approach)
      final localWidgets = await localDataSource.getAllWidgets(accountId);
      if (localWidgets.isNotEmpty) {
        return right(localWidgets.map((model) => model.toEntity()).toList());
      }

      // Fallback to remote if local is empty
      final remoteWidgets = await remoteDataSource.getAllWidgets(accountId);

      // Cache remote data locally
      for (final widget in remoteWidgets) {
        await localDataSource.storeWidget(widget);
      }

      return right(remoteWidgets.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return left(AppFailure.unexpected(
          message: 'Failed to get widgets: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, WidgetData>> getWidget(String widgetId) async {
    try {
      // Try local first
      final localWidget = await localDataSource.getWidget(widgetId);
      if (localWidget != null) {
        return right(localWidget.toEntity());
      }

      // Fallback to remote
      final remoteWidget = await remoteDataSource.getWidget(widgetId);

      // Cache locally
      await localDataSource.storeWidget(remoteWidget);

      return right(remoteWidget.toEntity());
    } on Exception catch (e) {
      return left(
          AppFailure.notFound(message: 'Widget not found: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, WidgetData>> createWidget({
    required String accountId,
    required WidgetSize size,
    required WidgetTapAction tapAction,
    bool? showStreak,
    bool? showLastSync,
  }) async {
    try {
      final now = DateTime.now();
      final widgetId = '${accountId}_${now.millisecondsSinceEpoch}';

      // Get initial stats
      final hitCountResult = await getTodayHitCount(accountId);
      final streakResult = await getCurrentStreak(accountId);

      final hitCount = hitCountResult.fold((l) => 0, (r) => r);
      final streak = streakResult.fold((l) => 0, (r) => r);

      final widgetModel = WidgetDataModel(
        id: widgetId,
        accountId: accountId,
        size: size.name,
        tapAction: tapAction.name,
        todayHitCount: hitCount,
        currentStreak: streak,
        lastSyncAt: now,
        createdAt: now,
        showStreak: showStreak,
        showLastSync: showLastSync,
      );

      // Create remotely first
      final remoteWidget = await remoteDataSource.createWidget(widgetModel);

      // Cache locally
      await localDataSource.storeWidget(remoteWidget);

      return right(remoteWidget.toEntity());
    } on Exception catch (e) {
      return left(AppFailure.unexpected(
          message: 'Failed to create widget: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, WidgetData>> updateWidget(WidgetData widget) async {
    try {
      final widgetModel = WidgetDataModel.fromEntity(widget);

      // Update remotely first
      final updatedRemoteWidget =
          await remoteDataSource.updateWidget(widgetModel);

      // Update locally
      await localDataSource.updateWidget(updatedRemoteWidget);

      return right(updatedRemoteWidget.toEntity());
    } on Exception catch (e) {
      return left(AppFailure.unexpected(
          message: 'Failed to update widget: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> deleteWidget(String widgetId) async {
    try {
      // Delete remotely first
      await remoteDataSource.deleteWidget(widgetId);

      // Delete locally
      await localDataSource.deleteWidget(widgetId);

      return right(unit);
    } on Exception catch (e) {
      return left(AppFailure.unexpected(
          message: 'Failed to delete widget: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, WidgetData>> updateWidgetStats({
    required String widgetId,
    required int todayHitCount,
    required int currentStreak,
  }) async {
    try {
      final widgetResult = await getWidget(widgetId);
      return widgetResult.fold(
        (failure) => left(failure),
        (widget) async {
          final updatedWidget = widget.copyWith(
            todayHitCount: todayHitCount,
            currentStreak: currentStreak,
            lastSyncAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          return await updateWidget(updatedWidget);
        },
      );
    } on Exception catch (e) {
      return left(AppFailure.unexpected(
          message: 'Failed to update widget stats: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, List<WidgetData>>> refreshWidgetData(
      String accountId) async {
    try {
      // Get fresh stats from remote
      final stats = await remoteDataSource.getWidgetStats(accountId);
      final hitCount = stats['todayHitCount'] as int? ?? 0;
      final streak = stats['currentStreak'] as int? ?? 0;

      // Get all widgets for this account
      final widgets = await localDataSource.getAllWidgets(accountId);
      final updatedWidgets = <WidgetDataModel>[];

      // Update each widget with fresh stats
      for (final widget in widgets) {
        final updatedWidget = widget.copyWith(
          todayHitCount: hitCount,
          currentStreak: streak,
          lastSyncAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await localDataSource.updateWidget(updatedWidget);
        updatedWidgets.add(updatedWidget);
      }

      await localDataSource.setLastSyncTimestamp(accountId, DateTime.now());

      return right(updatedWidgets.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return left(AppFailure.network(
          message: 'Failed to refresh widget data: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, int>> getTodayHitCount(String accountId) async {
    try {
      final count = await remoteDataSource.getTodayHitCount(accountId);
      return right(count);
    } on Exception catch (e) {
      return left(AppFailure.network(
          message: 'Failed to get hit count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, int>> getCurrentStreak(String accountId) async {
    try {
      final streak = await remoteDataSource.getCurrentStreak(accountId);
      return right(streak);
    } on Exception catch (e) {
      return left(
          AppFailure.network(message: 'Failed to get streak: ${e.toString()}'));
    }
  }
}
