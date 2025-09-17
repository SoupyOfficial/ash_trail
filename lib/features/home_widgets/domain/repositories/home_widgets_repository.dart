// Repository interface for home screen widget data management.
// Defines contract for widget data persistence and retrieval.

import 'package:fpdart/fpdart.dart';
import '../entities/widget_data.dart';
import '../entities/widget_size.dart';
import '../entities/widget_tap_action.dart';
import '../../../../core/failures/app_failure.dart';

abstract class HomeWidgetsRepository {
  /// Retrieves all widget configurations for the given account
  Future<Either<AppFailure, List<WidgetData>>> getAllWidgets(String accountId);

  /// Retrieves a specific widget by ID
  Future<Either<AppFailure, WidgetData>> getWidget(String widgetId);

  /// Creates a new widget configuration
  Future<Either<AppFailure, WidgetData>> createWidget({
    required String accountId,
    required WidgetSize size,
    required WidgetTapAction tapAction,
    bool? showStreak,
    bool? showLastSync,
  });

  /// Updates an existing widget configuration
  Future<Either<AppFailure, WidgetData>> updateWidget(WidgetData widget);

  /// Deletes a widget configuration
  Future<Either<AppFailure, Unit>> deleteWidget(String widgetId);

  /// Updates widget data with current hit count and streak
  Future<Either<AppFailure, WidgetData>> updateWidgetStats({
    required String widgetId,
    required int todayHitCount,
    required int currentStreak,
  });

  /// Refreshes all widget data from remote sources
  Future<Either<AppFailure, List<WidgetData>>> refreshWidgetData(
      String accountId);

  /// Gets today's hit count for the account
  Future<Either<AppFailure, int>> getTodayHitCount(String accountId);

  /// Gets current streak for the account
  Future<Either<AppFailure, int>> getCurrentStreak(String accountId);
}
