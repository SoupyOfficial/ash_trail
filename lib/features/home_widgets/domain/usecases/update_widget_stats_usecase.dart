// Use case for updating widget statistics (hit count and streak).
// Handles business logic for refreshing widget data from current app state.

import 'package:fpdart/fpdart.dart';
import '../entities/widget_data.dart';
import '../repositories/home_widgets_repository.dart';
import 'base_usecase.dart';
import '../../../../core/failures/app_failure.dart';

class UpdateWidgetStatsParams {
  const UpdateWidgetStatsParams({
    required this.widgetId,
    required this.todayHitCount,
    required this.currentStreak,
  });

  final String widgetId;
  final int todayHitCount;
  final int currentStreak;
}

class UpdateWidgetStatsUseCase
    implements UseCase<WidgetData, UpdateWidgetStatsParams> {
  const UpdateWidgetStatsUseCase(this._repository);

  final HomeWidgetsRepository _repository;

  @override
  Future<Either<AppFailure, WidgetData>> call(
      UpdateWidgetStatsParams params) async {
    // Validate parameters
    if (params.widgetId.isEmpty) {
      return left(const AppFailure.validation(
        message: 'Widget ID cannot be empty',
        field: 'widgetId',
      ));
    }

    if (params.todayHitCount < 0) {
      return left(const AppFailure.validation(
        message: 'Hit count cannot be negative',
        field: 'todayHitCount',
      ));
    }

    if (params.currentStreak < 0) {
      return left(const AppFailure.validation(
        message: 'Streak cannot be negative',
        field: 'currentStreak',
      ));
    }

    return await _repository.updateWidgetStats(
      widgetId: params.widgetId,
      todayHitCount: params.todayHitCount,
      currentStreak: params.currentStreak,
    );
  }
}
