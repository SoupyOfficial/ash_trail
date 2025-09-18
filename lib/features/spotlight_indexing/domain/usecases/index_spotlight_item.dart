// IndexSpotlightItemUseCase - Index a single spotlight item

import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import '../entities/spotlight_item_entity.dart';
import '../repositories/spotlight_indexing_repository.dart';

class IndexSpotlightItemUseCase {
  const IndexSpotlightItemUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  Future<Either<AppFailure, void>> call(SpotlightItemEntity item) async {
    // Validate item before indexing
    if (!item.isValidForIndexing) {
      return const Left(AppFailure.validation(
        message: 'Item is not valid for indexing',
        field: 'spotlightItem',
      ));
    }

    return _repository.indexItem(item);
  }
}
