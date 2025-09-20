// Remote data source interface for Quick Tagging
// Responsible for syncing SmokeLogTag edges and fetching tags from Firestore

import '../../../../domain/models/tag.dart';

abstract class QuickTaggingRemoteDataSource {
  Future<List<Tag>> getAllTags({required String accountId});

  /// Upload SmokeLogTag edges to remote store
  Future<void> createSmokeLogTags({
    required String accountId,
    required String smokeLogId,
    required DateTime ts,
    required List<String> tagIds,
  });
}
