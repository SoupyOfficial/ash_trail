// Use case for indexing a single spotlight item.

import 'package:fpdart/fpdart.dart';
import '../entities/spotlight_item_entity.dart';
import '../repositories/spotlight_indexing_repository.dart';
import '../../../../core/failures/app_failure.dart';

class IndexSpotlightItemUseCase {
  const IndexSpotlightItemUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  /// Index a single spotlight item with validation.
  Future<Either<AppFailure, void>> call(SpotlightItemEntity item) async {
    // Validate the item before indexing
    if (!item.isValidForIndexing) {
      return left(const AppFailure.validation(
        message: 'Invalid spotlight item: missing required fields',
        field: 'item',
      ));
    }

    return _repository.indexItem(item);
  }
}
