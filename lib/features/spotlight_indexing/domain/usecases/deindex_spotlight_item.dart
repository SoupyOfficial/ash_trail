// DeindexSpotlightItemUseCase - Remove a single item from spotlight index

import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import '../repositories/spotlight_indexing_repository.dart';

class DeindexSpotlightItemUseCase {
  const DeindexSpotlightItemUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  Future<Either<AppFailure, void>> call(String itemId) async {
    if (itemId.trim().isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Item ID cannot be empty',
        field: 'itemId',
      ));
    }

    return _repository.deindexItem(itemId);
  }
}
