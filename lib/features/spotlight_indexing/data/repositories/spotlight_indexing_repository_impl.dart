// Repository implementation for spotlight indexing.
// Coordinates between content data source and spotlight service.

import 'package:fpdart/fpdart.dart';
import '../../domain/entities/spotlight_item_entity.dart';
import '../../domain/repositories/spotlight_indexing_repository.dart';
import '../datasources/content_data_source.dart';
import '../datasources/spotlight_service.dart';
import '../models/spotlight_item_model.dart';
import '../../../../core/failures/app_failure.dart';

class SpotlightIndexingRepositoryImpl implements SpotlightIndexingRepository {
  const SpotlightIndexingRepositoryImpl({
    required ContentDataSource contentDataSource,
    required SpotlightService spotlightService,
  })  : _contentDataSource = contentDataSource,
        _spotlightService = spotlightService;

  final ContentDataSource _contentDataSource;
  final SpotlightService _spotlightService;

  @override
  Future<Either<AppFailure, void>> indexItem(SpotlightItemEntity item) async {
    // Check if Spotlight is available before attempting to index
    final isAvailable = await _spotlightService.isSpotlightAvailable();
    if (!isAvailable) {
      return left(const AppFailure.unexpected(
        message: 'Spotlight indexing is not available on this platform',
      ));
    }

    final model = SpotlightItemModel.fromEntity(item);
    return _spotlightService.indexItem(model);
  }

  @override
  Future<Either<AppFailure, void>> indexItems(
      List<SpotlightItemEntity> items) async {
    // Check if Spotlight is available before attempting to index
    final isAvailable = await _spotlightService.isSpotlightAvailable();
    if (!isAvailable) {
      return left(const AppFailure.unexpected(
        message: 'Spotlight indexing is not available on this platform',
      ));
    }

    final models = items.map(SpotlightItemModel.fromEntity).toList();
    return _spotlightService.indexItems(models);
  }

  @override
  Future<Either<AppFailure, void>> deindexItem(String itemId) async {
    return _spotlightService.deindexItem(itemId);
  }

  @override
  Future<Either<AppFailure, void>> deindexItems(List<String> itemIds) async {
    return _spotlightService.deindexItems(itemIds);
  }

  @override
  Future<Either<AppFailure, void>> deindexAccountItems(String accountId) async {
    try {
      // Get all current indexed items for the account
      final allItemsResult = await getAllIndexedItems();

      if (allItemsResult.isLeft()) {
        return allItemsResult.map((_) {});
      }

      final allItems = allItemsResult.getRight().getOrElse(() => []);
      final accountItems = allItems
          .where((item) => item.accountId == accountId)
          .map((item) => item.id)
          .toList();

      if (accountItems.isEmpty) {
        return right(null);
      }

      return deindexItems(accountItems);
    } catch (e) {
      return left(AppFailure.unexpected(
        message: 'Failed to deindex account items: $e',
        cause: e,
      ));
    }
  }

  @override
  Future<Either<AppFailure, void>> clearAllItems() async {
    return _spotlightService.clearAllItems();
  }

  @override
  Future<Either<AppFailure, List<SpotlightItemEntity>>>
      getAllIndexedItems() async {
    // This implementation maintains a conceptual list of indexed items
    // In reality, we reconstruct this from content sources since
    // iOS Spotlight doesn't provide a way to query indexed items

    // For now, return empty list - this would be enhanced to track
    // indexed items in a more sophisticated way
    return right([]);
  }

  @override
  Future<Either<AppFailure, List<SpotlightItemEntity>>> getIndexedItemsByType(
    SpotlightItemType type,
  ) async {
    final allItemsResult = await getAllIndexedItems();
    return allItemsResult
        .map((items) => items.where((item) => item.type == type).toList());
  }

  @override
  Future<Either<AppFailure, bool>> isItemIndexed(String itemId) async {
    final allItemsResult = await getAllIndexedItems();
    return allItemsResult
        .map((items) => items.any((item) => item.id == itemId));
  }

  @override
  Future<Either<AppFailure, List<SpotlightItemEntity>>> getStaleItems() async {
    // This would compare currently indexed items with current content
    // and return items that need updating. For now, return empty list.
    return right([]);
  }

  @override
  Future<Either<AppFailure, void>> syncIndex() async {
    try {
      // Check if Spotlight is available
      final isAvailable = await _spotlightService.isSpotlightAvailable();
      if (!isAvailable) {
        // Not an error - just not available on this platform
        return right(null);
      }

      // TODO: Get current active account ID from account service
      // For now, use a placeholder account ID
      const accountId = 'current_account';

      // Get all indexable content
      final contentResult =
          await _contentDataSource.getAllIndexableContent(accountId);

      if (contentResult.isLeft()) {
        return contentResult.map((_) {});
      }

      final content = contentResult.getRight().getOrElse(() => []);
      if (content.isEmpty) {
        return right(null);
      }

      // Convert models to entities
      final entities = content.map((model) => model.toEntity()).toList();

      // Index all content
      return indexItems(entities);
    } catch (e) {
      return left(AppFailure.unexpected(
        message: 'Failed to sync spotlight index: $e',
        cause: e,
      ));
    }
  }
}
