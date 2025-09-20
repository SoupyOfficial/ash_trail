// Use case for syncing spotlight index with current app data.
// This is the main operation that keeps spotlight search up-to-date.

import 'package:fpdart/fpdart.dart';
import '../repositories/spotlight_indexing_repository.dart';
import '../../../../core/failures/app_failure.dart';

class SyncSpotlightIndexUseCase {
  const SyncSpotlightIndexUseCase(this._repository);

  final SpotlightIndexingRepository _repository;

  /// Sync the spotlight index with current app data.
  Future<Either<AppFailure, void>> call() async {
    return _repository.syncIndex();
  }
}
