// Use case for creating a new widget configuration.
// Handles business logic for widget creation including validation.

import 'package:fpdart/fpdart.dart';
import '../entities/widget_data.dart';
import '../entities/widget_size.dart';
import '../entities/widget_tap_action.dart';
import '../repositories/home_widgets_repository.dart';
import 'base_usecase.dart';
import '../../../../core/failures/app_failure.dart';

class CreateWidgetParams {
  const CreateWidgetParams({
    required this.accountId,
    required this.size,
    required this.tapAction,
    this.showStreak,
    this.showLastSync,
  });

  final String accountId;
  final WidgetSize size;
  final WidgetTapAction tapAction;
  final bool? showStreak;
  final bool? showLastSync;
}

class CreateWidgetUseCase implements UseCase<WidgetData, CreateWidgetParams> {
  const CreateWidgetUseCase(this._repository);

  final HomeWidgetsRepository _repository;

  @override
  Future<Either<AppFailure, WidgetData>> call(CreateWidgetParams params) async {
    // Validate account ID
    if (params.accountId.isEmpty) {
      return left(const AppFailure.validation(
        message: 'Account ID cannot be empty',
        field: 'accountId',
      ));
    }

    return await _repository.createWidget(
      accountId: params.accountId,
      size: params.size,
      tapAction: params.tapAction,
      showStreak: params.showStreak,
      showLastSync: params.showLastSync,
    );
  }
}
