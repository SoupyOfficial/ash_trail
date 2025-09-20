// Spotlight indexing repository interface for managing indexed content.
// Handles indexing, deindexing, and searching spotlight items.

import 'package:fpdart/fpdart.dart';
import '../entities/spotlight_item_entity.dart';
import '../../../../core/failures/app_failure.dart';

abstract class SpotlightIndexingRepository {
  /// Index a single item in iOS Spotlight search
  Future<Either<AppFailure, void>> indexItem(SpotlightItemEntity item);

  /// Index multiple items in a batch operation
  Future<Either<AppFailure, void>> indexItems(List<SpotlightItemEntity> items);

  /// Remove a single item from the spotlight index
  Future<Either<AppFailure, void>> deindexItem(String itemId);

  /// Remove multiple items from the spotlight index
  Future<Either<AppFailure, void>> deindexItems(List<String> itemIds);

  /// Remove all items for a specific account
  Future<Either<AppFailure, void>> deindexAccountItems(String accountId);

  /// Clear all indexed items (typically used on logout)
  Future<Either<AppFailure, void>> clearAllItems();

  /// Get all currently indexed items
  Future<Either<AppFailure, List<SpotlightItemEntity>>> getAllIndexedItems();

  /// Get indexed items by type
  Future<Either<AppFailure, List<SpotlightItemEntity>>> getIndexedItemsByType(
    SpotlightItemType type,
  );

  /// Check if an item is currently indexed
  Future<Either<AppFailure, bool>> isItemIndexed(String itemId);

  /// Get items that need to be updated/reindexed
  Future<Either<AppFailure, List<SpotlightItemEntity>>> getStaleItems();

  /// Synchronize spotlight index with current app data
  /// This is the main sync operation called periodically
  Future<Either<AppFailure, void>> syncIndex();
}
