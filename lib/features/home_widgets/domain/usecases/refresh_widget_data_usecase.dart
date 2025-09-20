// Use case for refreshing widget data from remote sources.
// Handles synchronization logic and ensures data consistency.

import 'package:fpdart/fpdart.dart';
import '../entities/widget_data.dart';
import '../repositories/home_widgets_repository.dart';
import 'base_usecase.dart';
import '../../../../core/failures/app_failure.dart';

class RefreshWidgetDataUseCase
    implements UseCase<List<WidgetData>, AccountParams> {
  const RefreshWidgetDataUseCase(this._repository);

  final HomeWidgetsRepository _repository;

  @override
  Future<Either<AppFailure, List<WidgetData>>> call(
      AccountParams params) async {
    // Validate account ID
    if (params.accountId.isEmpty) {
      return left(const AppFailure.validation(
        message: 'Account ID cannot be empty',
        field: 'accountId',
      ));
    }

    return await _repository.refreshWidgetData(params.accountId);
  }
}
