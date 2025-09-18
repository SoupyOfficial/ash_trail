// Use case for retrieving indexed spotlight items.

import 'package:fpdart/fpdart.dart';
import '../entities/spotlight_item_entity.dart';
import '../repositories/spotlight_indexing_repository.dart';
import '../../../../core/failures/app_failure.dart';

class GetIndexedItemsUseCase {
  const GetIndexedItemsUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  /// Get all indexed spotlight items.
  Future<Either<AppFailure, List<SpotlightItemEntity>>> call() async {
    return _repository.getAllIndexedItems();
  }
}

class GetIndexedItemsByTypeUseCase {
  const GetIndexedItemsByTypeUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  /// Get indexed spotlight items by type.
  Future<Either<AppFailure, List<SpotlightItemEntity>>> call(
      SpotlightItemType type) async {
    return _repository.getIndexedItemsByType(type);
  }
}
