// Repository implementation for Quick Tagging
// Bridges domain repository to local/remote data sources with offline-first semantics

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/tag.dart';
import '../../domain/repositories/quick_tagging_repository.dart';
import '../datasources/quick_tagging_local_datasource.dart';
import '../datasources/quick_tagging_remote_datasource.dart';

class QuickTaggingRepositoryImpl implements QuickTaggingRepository {
  final QuickTaggingLocalDataSource _local;
  final QuickTaggingRemoteDataSource _remote;

  const QuickTaggingRepositoryImpl({
    required QuickTaggingLocalDataSource local,
    required QuickTaggingRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  @override
  Future<Either<AppFailure, List<Tag>>> getTopSuggestedTags({
    required String accountId,
    int limit = 5,
  }) async {
    try {
      final tags =
          await _local.getSuggestedTags(accountId: accountId, limit: limit);
      return Right(tags);
    } catch (e) {
      return Left(AppFailure.cache(
          message: 'Failed to get suggested tags: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, List<Tag>>> getAllTags({
    required String accountId,
  }) async {
    try {
      // Prefer local cache; fall back to remote if local empty
      final localTags = await _local.getAllTags(accountId: accountId);
      if (localTags.isNotEmpty) return Right(localTags);

      try {
        final remoteTags = await _remote.getAllTags(accountId: accountId);
        return Right(remoteTags);
      } catch (e) {
        // Remote fetch failure; return local (empty) with network failure
        return Left(AppFailure.network(
            message: 'Failed to fetch tags from remote: ${e.toString()}'));
      }
    } catch (e) {
      return Left(
          AppFailure.cache(message: 'Failed to read tags: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AppFailure, void>> attachTagsToSmokeLog({
    required String accountId,
    required String smokeLogId,
    required DateTime ts,
    required List<String> tagIds,
  }) async {
    try {
      // Write locally first (queue for sync)
      await _local.attachTagsToSmokeLog(
        accountId: accountId,
        smokeLogId: smokeLogId,
        ts: ts,
        tagIds: tagIds,
      );

      // Best-effort remote sync (fire-and-forget)
      _remote
          .createSmokeLogTags(
        accountId: accountId,
        smokeLogId: smokeLogId,
        ts: ts,
        tagIds: tagIds,
      )
          .catchError((_) {
        // Leave queued; background sync will retry
      });

      return const Right(null);
    } catch (e) {
      return Left(
          AppFailure.cache(message: 'Failed to attach tags: ${e.toString()}'));
    }
  }
}
