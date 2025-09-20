// Use case: fetch all tags for an account

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/tag.dart';
import '../repositories/quick_tagging_repository.dart';

class GetAllTagsUseCase {
  final QuickTaggingRepository _repository;

  const GetAllTagsUseCase({required QuickTaggingRepository repository})
      : _repository = repository;

  Future<Either<AppFailure, List<Tag>>> call({
    required String accountId,
  }) {
    if (accountId.isEmpty) {
      return Future.value(const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      )));
    }
    return _repository.getAllTags(accountId: accountId);
  }
}
