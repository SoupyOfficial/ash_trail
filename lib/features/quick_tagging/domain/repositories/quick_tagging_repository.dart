// Domain repository contract for Quick Tagging feature
// Provides operations to fetch suggested tags and attach tags to a SmokeLog

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/tag.dart';

/// Repository interface for quick tagging operations
/// Presentation depends on this; data layer provides implementation.
abstract class QuickTaggingRepository {
  /// Get top suggested tags for the account.
  /// Suggestion strategy: recent or frequent usage (data layer decides).
  Future<Either<AppFailure, List<Tag>>> getTopSuggestedTags({
    required String accountId,
    int limit = 5,
  });

  /// Get all tags for the account. Used to display infrequent tags list.
  Future<Either<AppFailure, List<Tag>>> getAllTags({
    required String accountId,
  });

  /// Attach selected tags to a SmokeLog by creating SmokeLogTag edges.
  /// Writes are offline-first and queued for remote sync.
  Future<Either<AppFailure, void>> attachTagsToSmokeLog({
    required String accountId,
    required String smokeLogId,
    required DateTime ts,
    required List<String> tagIds,
  });
}
