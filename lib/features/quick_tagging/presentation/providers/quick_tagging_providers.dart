// Riverpod providers for Quick Tagging feature

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/tag.dart';
import '../../domain/repositories/quick_tagging_repository.dart';
import '../../domain/usecases/attach_tags_to_log_usecase.dart';
import '../../domain/usecases/get_all_tags_usecase.dart';
import '../../domain/usecases/get_suggested_tags_usecase.dart';

/// Abstract providers to be overridden with concrete implementations in main.dart
final quickTaggingRepositoryProvider = Provider<QuickTaggingRepository>((ref) {
  throw UnimplementedError('quickTaggingRepositoryProvider must be overridden');
});

final getSuggestedTagsUseCaseProvider =
    Provider<GetSuggestedTagsUseCase>((ref) {
  return GetSuggestedTagsUseCase(
      repository: ref.watch(quickTaggingRepositoryProvider));
});

final getAllTagsUseCaseProvider = Provider<GetAllTagsUseCase>((ref) {
  return GetAllTagsUseCase(
      repository: ref.watch(quickTaggingRepositoryProvider));
});

final attachTagsToLogUseCaseProvider = Provider<AttachTagsToLogUseCase>((ref) {
  return AttachTagsToLogUseCase(
      repository: ref.watch(quickTaggingRepositoryProvider));
});

/// Async suggested tags for account
final suggestedTagsProvider =
    FutureProvider.family<List<Tag>, String>((ref, accountId) async {
  final useCase = ref.watch(getSuggestedTagsUseCaseProvider);
  final result = await useCase(accountId: accountId, limit: 5);
  return result.fold((f) => throw f, (tags) => tags);
});

/// All tags for account (for infrequent list)
final allTagsProvider =
    FutureProvider.family<List<Tag>, String>((ref, accountId) async {
  final useCase = ref.watch(getAllTagsUseCaseProvider);
  final result = await useCase(accountId: accountId);
  return result.fold((f) => throw f, (tags) => tags);
});

/// State notifier to manage currently selected tag IDs before creating log
class SelectedTagsNotifier extends AutoDisposeNotifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String tagId) {
    final next = {...state};
    if (next.contains(tagId)) {
      next.remove(tagId);
    } else {
      next.add(tagId);
    }
    state = next;
  }

  void clear() => state = <String>{};
}

final selectedTagsProvider =
    AutoDisposeNotifierProvider<SelectedTagsNotifier, Set<String>>(
  SelectedTagsNotifier.new,
);

/// Controller to apply selected tags to a newly created SmokeLog
class QuickTaggingController
    extends AutoDisposeFamilyAsyncNotifier<void, String> {
  // arg is accountId
  @override
  Future<void> build(String accountId) async {}

  Future<void> attachSelectedToLog({
    required String smokeLogId,
    required DateTime ts,
  }) async {
    final accountId = arg;
    final tagIds = ref.read(selectedTagsProvider).toList(growable: false);
    if (tagIds.isEmpty) return; // Nothing to do

    state = const AsyncLoading();
    final useCase = ref.read(attachTagsToLogUseCaseProvider);
    final res = await useCase(
      accountId: accountId,
      smokeLogId: smokeLogId,
      ts: ts,
      tagIds: tagIds,
    );

    res.match(
      (f) {
        state = AsyncError(f, StackTrace.current);
      },
      (_) {
        // Clear selection on success
        ref.read(selectedTagsProvider.notifier).clear();
        state = const AsyncData(null);
      },
    );
  }
}

final quickTaggingControllerProvider = AutoDisposeAsyncNotifierProviderFamily<
    QuickTaggingController, void, String>(QuickTaggingController.new);
