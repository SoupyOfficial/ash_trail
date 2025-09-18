// BatchIndexSpotlightItemsUseCase - Index multiple items efficiently

import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import '../entities/spotlight_item_entity.dart';
import '../repositories/spotlight_indexing_repository.dart';

class BatchIndexSpotlightItemsUseCase {
  const BatchIndexSpotlightItemsUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  Future<Either<AppFailure, void>> call(List<SpotlightItemEntity> items) async {
    if (items.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Items list cannot be empty',
        field: 'items',
      ));
    }

    // Filter out invalid items
    final validItems = items.where((item) => item.isValidForIndexing).toList();

    if (validItems.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'No valid items found for indexing',
        field: 'items',
      ));
    }

    return _repository.indexItems(validItems);
  }
}
