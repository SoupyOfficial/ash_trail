// Use case for deindexing spotlight items.

import 'package:fpdart/fpdart.dart';
import '../repositories/spotlight_indexing_repository.dart';
import '../../../../core/failures/app_failure.dart';

class DeindexSpotlightItemUseCase {
  const DeindexSpotlightItemUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  /// Deindex a single spotlight item.
  Future<Either<AppFailure, void>> call(String itemId) async {
    if (itemId.isEmpty) {
      return left(const AppFailure.validation(
        message: 'Item ID cannot be empty',
        field: 'itemId',
      ));
    }

    return _repository.deindexItem(itemId);
  }
}

class DeindexSpotlightItemsUseCase {
  const DeindexSpotlightItemsUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  /// Deindex multiple spotlight items.
  Future<Either<AppFailure, void>> call(List<String> itemIds) async {
    if (itemIds.isEmpty) {
      return left(const AppFailure.validation(
        message: 'Item IDs list cannot be empty',
        field: 'itemIds',
      ));
    }

    return _repository.deindexItems(itemIds);
  }
}
