// Use case: fetch suggested tags for quick tagging chips

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/tag.dart';
import '../repositories/quick_tagging_repository.dart';

class GetSuggestedTagsUseCase {
  final QuickTaggingRepository _repository;

  const GetSuggestedTagsUseCase({required QuickTaggingRepository repository})
      : _repository = repository;

  Future<Either<AppFailure, List<Tag>>> call({
    required String accountId,
    int limit = 5,
  }) {
    if (accountId.isEmpty) {
      return Future.value(const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      )));
    }
    if (limit <= 0) {
      return Future.value(const Left(AppFailure.validation(
        message: 'Limit must be greater than 0',
        field: 'limit',
      )));
    }
    return _repository.getTopSuggestedTags(accountId: accountId, limit: limit);
  }
}
