// Local data source interface for Quick Tagging
// Responsible for reading tags and writing SmokeLogTag edges offline-first

import '../../../../domain/models/tag.dart';

abstract class QuickTaggingLocalDataSource {
  Future<List<Tag>> getAllTags({required String accountId});

  /// Returns top tags by recent/frequent usage for account
  Future<List<Tag>> getSuggestedTags(
      {required String accountId, int limit = 5});

  /// Create local SmokeLogTag edges for selected tags (enqueue for sync)
  Future<void> attachTagsToSmokeLog({
    required String accountId,
    required String smokeLogId,
    required DateTime ts,
    required List<String> tagIds,
  });
}
