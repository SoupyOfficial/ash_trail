// SyncSpotlightIndexUseCase - Main synchronization operation

import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import '../repositories/spotlight_indexing_repository.dart';

class SyncSpotlightIndexUseCase {
  const SyncSpotlightIndexUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  Future<Either<AppFailure, void>> call() async {
    return _repository.syncIndex();
  }
}
