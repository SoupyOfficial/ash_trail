// Use case for removing tags from multiple smoke logs in batch

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../repositories/logs_table_repository.dart';

class RemoveTagsFromLogsBatchUseCase {
  final LogsTableRepository _repository;

  const RemoveTagsFromLogsBatchUseCase({
    required LogsTableRepository repository,
  }) : _repository = repository;

  Future<Either<AppFailure, int>> call({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }
    if (smokeLogIds.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'At least one smoke log ID is required',
        field: 'smokeLogIds',
      ));
    }
    if (tagIds.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'At least one tag ID is required',
        field: 'tagIds',
      ));
    }

    final uniqueLogIds =
        smokeLogIds.where((e) => e.isNotEmpty).toSet().toList();
    final uniqueTagIds = tagIds.where((e) => e.isNotEmpty).toSet().toList();

    if (uniqueLogIds.isEmpty || uniqueTagIds.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'IDs must be non-empty',
        field: 'smokeLogIds/tagIds',
      ));
    }

    if (uniqueLogIds.length > 1000) {
      return const Left(AppFailure.validation(
        message: 'Cannot modify more than 1000 logs at once',
        field: 'smokeLogIds',
      ));
    }
    if (uniqueTagIds.length > 100) {
      return const Left(AppFailure.validation(
        message: 'Too many tags (max 100)',
        field: 'tagIds',
      ));
    }

    return _repository.removeTagsFromLogsBatch(
      accountId: accountId,
      smokeLogIds: uniqueLogIds,
      tagIds: uniqueTagIds,
    );
  }
}
