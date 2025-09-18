// ClearSpotlightIndexUseCase - Clear all indexed items

import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import '../repositories/spotlight_indexing_repository.dart';

class ClearSpotlightIndexUseCase {
  const ClearSpotlightIndexUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  Future<Either<AppFailure, void>> call({String? accountId}) async {
    if (accountId != null && accountId.trim().isNotEmpty) {
      return _repository.deindexAccountItems(accountId);
    } else {
      return _repository.clearAllItems();
    }
  }
}
