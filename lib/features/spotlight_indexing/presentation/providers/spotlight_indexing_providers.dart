// Riverpod providers for spotlight indexing feature.
// Provides dependency injection and state management for spotlight operations.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/spotlight_item_entity.dart';
import '../../domain/repositories/spotlight_indexing_repository.dart';
import '../../domain/usecases/sync_spotlight_index_usecase.dart';
import '../../domain/usecases/index_spotlight_item_usecase.dart';
import '../../domain/usecases/deindex_spotlight_item_usecase.dart';
import '../../domain/usecases/get_indexed_items_usecase.dart';
import '../../data/repositories/spotlight_indexing_repository_impl.dart';
import '../../data/datasources/content_data_source.dart';
import '../../data/datasources/spotlight_service.dart';

part 'spotlight_indexing_providers.g.dart';

/// Provides the ContentDataSource
@riverpod
ContentDataSource contentDataSource(ContentDataSourceRef ref) {
  return const ContentDataSource();
}

/// Provides the SpotlightService
@riverpod
SpotlightService spotlightService(SpotlightServiceRef ref) {
  return SpotlightService();
}

/// Provides the SpotlightIndexingRepository
@riverpod
SpotlightIndexingRepository spotlightIndexingRepository(
    SpotlightIndexingRepositoryRef ref) {
  return SpotlightIndexingRepositoryImpl(
    contentDataSource: ref.watch(contentDataSourceProvider),
    spotlightService: ref.watch(spotlightServiceProvider),
  );
}

/// Provides the SyncSpotlightIndexUseCase
@riverpod
SyncSpotlightIndexUseCase syncSpotlightIndexUseCase(
    SyncSpotlightIndexUseCaseRef ref) {
  return SyncSpotlightIndexUseCase(
    ref.watch(spotlightIndexingRepositoryProvider),
  );
}

/// Provides the IndexSpotlightItemUseCase
@riverpod
IndexSpotlightItemUseCase indexSpotlightItemUseCase(
    IndexSpotlightItemUseCaseRef ref) {
  return IndexSpotlightItemUseCase(
    ref.watch(spotlightIndexingRepositoryProvider),
  );
}

/// Provides the DeindexSpotlightItemUseCase
@riverpod
DeindexSpotlightItemUseCase deindexSpotlightItemUseCase(
    DeindexSpotlightItemUseCaseRef ref) {
  return DeindexSpotlightItemUseCase(
    ref.watch(spotlightIndexingRepositoryProvider),
  );
}

/// Provides the DeindexSpotlightItemsUseCase
@riverpod
DeindexSpotlightItemsUseCase deindexSpotlightItemsUseCase(
    DeindexSpotlightItemsUseCaseRef ref) {
  return DeindexSpotlightItemsUseCase(
    ref.watch(spotlightIndexingRepositoryProvider),
  );
}

/// Provides the GetIndexedItemsUseCase
@riverpod
GetIndexedItemsUseCase getIndexedItemsUseCase(GetIndexedItemsUseCaseRef ref) {
  return GetIndexedItemsUseCase(
    ref.watch(spotlightIndexingRepositoryProvider),
  );
}

/// Provides the GetIndexedItemsByTypeUseCase
@riverpod
GetIndexedItemsByTypeUseCase getIndexedItemsByTypeUseCase(
    GetIndexedItemsByTypeUseCaseRef ref) {
  return GetIndexedItemsByTypeUseCase(
    ref.watch(spotlightIndexingRepositoryProvider),
  );
}

/// Controller for managing spotlight indexing operations
@riverpod
class SpotlightIndexingController extends _$SpotlightIndexingController {
  @override
  FutureOr<void> build() async {
    // Initialize - this controller doesn't need to return data
    // It's primarily for managing state and operations
  }

  /// Sync the spotlight index with current app data
  Future<void> syncIndex() async {
    state = const AsyncLoading();

    final useCase = ref.read(syncSpotlightIndexUseCaseProvider);
    final result = await useCase();

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  /// Index a single spotlight item
  Future<void> indexItem(SpotlightItemEntity item) async {
    final useCase = ref.read(indexSpotlightItemUseCaseProvider);
    final result = await useCase(item);

    // Handle result but don't update state for individual item operations
    result.fold(
      (failure) {
        // TODO: Log error or show user feedback
      },
      (_) {
        // Success - maybe trigger a refresh or log success
      },
    );
  }

  /// Deindex a single spotlight item
  Future<void> deindexItem(String itemId) async {
    final useCase = ref.read(deindexSpotlightItemUseCaseProvider);
    final result = await useCase(itemId);

    result.fold(
      (failure) {
        // TODO: Log error or show user feedback
      },
      (_) {
        // Success
      },
    );
  }

  /// Deindex multiple spotlight items
  Future<void> deindexItems(List<String> itemIds) async {
    final useCase = ref.read(deindexSpotlightItemsUseCaseProvider);
    final result = await useCase(itemIds);

    result.fold(
      (failure) {
        // TODO: Log error or show user feedback
      },
      (_) {
        // Success
      },
    );
  }

  /// Clear all indexed items (used on logout)
  Future<void> clearAllItems() async {
    final repository = ref.read(spotlightIndexingRepositoryProvider);
    final result = await repository.clearAllItems();

    result.fold(
      (failure) {
        // TODO: Log error
      },
      (_) {
        // Success
      },
    );
  }
}

/// Provider for getting indexed items
@riverpod
Future<List<SpotlightItemEntity>> indexedItems(IndexedItemsRef ref) async {
  final useCase = ref.watch(getIndexedItemsUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => throw failure,
    (items) => items,
  );
}

/// Provider for getting indexed items by type
@riverpod
Future<List<SpotlightItemEntity>> indexedItemsByType(
  IndexedItemsByTypeRef ref,
  SpotlightItemType type,
) async {
  final useCase = ref.watch(getIndexedItemsByTypeUseCaseProvider);
  final result = await useCase(type);

  return result.fold(
    (failure) => throw failure,
    (items) => items,
  );
}
