// Use case: attach a set of tags to a SmokeLog

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../repositories/quick_tagging_repository.dart';

class AttachTagsToLogUseCase {
  final QuickTaggingRepository _repository;

  const AttachTagsToLogUseCase({required QuickTaggingRepository repository})
      : _repository = repository;

  Future<Either<AppFailure, void>> call({
    required String accountId,
    required String smokeLogId,
    required DateTime ts,
    required List<String> tagIds,
  }) {
    if (accountId.isEmpty) {
      return Future.value(const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      )));
    }
    if (smokeLogId.isEmpty) {
      return Future.value(const Left(AppFailure.validation(
        message: 'SmokeLog ID is required',
        field: 'smokeLogId',
      )));
    }
    if (tagIds.isEmpty) {
      return Future.value(const Left(AppFailure.validation(
        message: 'At least one tag is required',
        field: 'tagIds',
      )));
    }
    return _repository.attachTagsToSmokeLog(
      accountId: accountId,
      smokeLogId: smokeLogId,
      ts: ts,
      tagIds: tagIds,
    );
  }
}
