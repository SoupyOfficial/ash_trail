// High-level service for managing spotlight indexing operations.
// Provides a simple interface for other parts of the app to trigger indexing.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/spotlight_indexing_providers.dart';
import '../../domain/entities/spotlight_item_entity.dart';

class SpotlightIndexingService {
  const SpotlightIndexingService(this._ref);

  final WidgetRef _ref;

  /// Sync the complete spotlight index
  /// Call this after major data changes or on app startup
  Future<void> syncIndex() async {
    final controller = _ref.read(spotlightIndexingControllerProvider.notifier);
    await controller.syncIndex();
  }

  /// Index a single item (for immediate indexing after creation)
  Future<void> indexItem(SpotlightItemEntity item) async {
    final controller = _ref.read(spotlightIndexingControllerProvider.notifier);
    await controller.indexItem(item);
  }

  /// Remove a single item from the index (after deletion)
  Future<void> deindexItem(String itemId) async {
    final controller = _ref.read(spotlightIndexingControllerProvider.notifier);
    await controller.deindexItem(itemId);
  }

  /// Remove multiple items from the index
  Future<void> deindexItems(List<String> itemIds) async {
    final controller = _ref.read(spotlightIndexingControllerProvider.notifier);
    await controller.deindexItems(itemIds);
  }

  /// Clear all indexed items (call on user logout)
  Future<void> clearAllItems() async {
    final controller = _ref.read(spotlightIndexingControllerProvider.notifier);
    await controller.clearAllItems();
  }

  /// Create a spotlight item entity for a tag
  SpotlightItemEntity createTagItem({
    required String tagId,
    required String tagName,
    required String accountId,
  }) {
    return SpotlightItemEntity(
      id: 'tag_$tagId',
      type: SpotlightItemType.tag,
      title: tagName,
      description: 'Tag: $tagName',
      keywords: ['tag', 'label', tagName.toLowerCase()],
      deepLink: 'ashtrail://tags/$tagId',
      accountId: accountId,
      contentId: tagId,
      lastUpdated: DateTime.now(),
      isActive: true,
    );
  }

  /// Create a spotlight item entity for a chart view
  SpotlightItemEntity createChartViewItem({
    required String viewId,
    required String title,
    required String accountId,
  }) {
    return SpotlightItemEntity(
      id: 'chart_$viewId',
      type: SpotlightItemType.chartView,
      title: title,
      description: 'Chart: $title',
      keywords: ['chart', 'view', 'analysis', title.toLowerCase()],
      deepLink: 'ashtrail://charts/$viewId',
      accountId: accountId,
      contentId: viewId,
      lastUpdated: DateTime.now(),
      isActive: true,
    );
  }
}

/// Provider for the SpotlightIndexingService
/// This service should be used by other parts of the app to interact with Spotlight
class SpotlightIndexingServiceProvider {
  static SpotlightIndexingService create(WidgetRef ref) {
    return SpotlightIndexingService(ref);
  }
}
