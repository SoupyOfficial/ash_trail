// Use case for retrieving all widget configurations for an account.
// Encapsulates business logic for fetching widget data.

import 'package:fpdart/fpdart.dart';
import '../entities/widget_data.dart';
import '../repositories/home_widgets_repository.dart';
import 'base_usecase.dart';
import '../../../../core/failures/app_failure.dart';

class GetAllWidgetsUseCase implements UseCase<List<WidgetData>, AccountParams> {
  const GetAllWidgetsUseCase(this._repository);

  final HomeWidgetsRepository _repository;

  @override
  Future<Either<AppFailure, List<WidgetData>>> call(
      AccountParams params) async {
    return await _repository.getAllWidgets(params.accountId);
  }
}
