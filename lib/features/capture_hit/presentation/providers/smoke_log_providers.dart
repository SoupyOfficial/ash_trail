// Riverpod providers for smoke log capture functionality
// Manages repository, use cases, and state for hold-to-record feature

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../../../data/repositories/smoke_log_repository_isar.dart';
import '../../../../data/services/isar_service.dart';
import '../../data/datasources/smoke_log_local_datasource_impl.dart';
import '../../data/datasources/smoke_log_local_datasource.dart';
import '../../domain/usecases/create_smoke_log_usecase.dart';
import '../../domain/usecases/undo_last_smoke_log_usecase.dart';
import '../../domain/usecases/get_last_smoke_log_usecase.dart';
import '../../domain/usecases/delete_smoke_log_usecase.dart';
// Optional: integrate with quick tagging to attach selected tags after creation
import '../../../quick_tagging/presentation/providers/quick_tagging_providers.dart';

// Export the repository provider from the Isar implementation
export '../../../../data/repositories/smoke_log_repository_isar.dart'
    show smokeLogRepositoryProvider;

/// Local data source provider
final smokeLogLocalDataSourceProvider =
    FutureProvider<SmokeLogLocalDataSource>((ref) async {
  final isarService = await ref.watch(isarSmokeLogServiceProvider.future);
  return SmokeLogLocalDataSourceImpl(isarService);
});

/// Use case providers - now using async repository
final createSmokeLogUseCaseProvider =
    FutureProvider<CreateSmokeLogUseCase>((ref) async {
  final repository = await ref.watch(smokeLogRepositoryProvider.future);
  return CreateSmokeLogUseCase(repository: repository);
});

final undoLastSmokeLogUseCaseProvider =
    FutureProvider<UndoLastSmokeLogUseCase>((ref) async {
  final repository = await ref.watch(smokeLogRepositoryProvider.future);
  return UndoLastSmokeLogUseCase(repository: repository);
});

final getLastSmokeLogUseCaseProvider =
    FutureProvider<GetLastSmokeLogUseCase>((ref) async {
  final repository = await ref.watch(smokeLogRepositoryProvider.future);
  return GetLastSmokeLogUseCase(repository: repository);
});

final deleteSmokeLogUseCaseProvider =
    FutureProvider<DeleteSmokeLogUseCase>((ref) async {
  final repository = await ref.watch(smokeLogRepositoryProvider.future);
  return DeleteSmokeLogUseCase(repository: repository);
});

/// Async providers for fetching data
/// These providers handle the async operations and error states

/// Get the last smoke log for the current account
/// Returns null if no logs exist
final lastSmokeLogProvider =
    FutureProvider.family<SmokeLog?, String>((ref, accountId) async {
  final useCase = await ref.watch(getLastSmokeLogUseCaseProvider.future);
  final result = await useCase(accountId: accountId);

  return result.fold(
    (failure) => throw failure,
    (smokeLog) => smokeLog,
  );
});

/// Provider for creating smoke logs
/// Returns the created smoke log or throws an AppFailure
class CreateSmokeLogNotifier
    extends AutoDisposeFamilyAsyncNotifier<SmokeLog, Map<String, dynamic>> {
  @override
  Future<SmokeLog> build(Map<String, dynamic> arg) {
    // Return a never-completing future initially
    return Future<SmokeLog>(() => throw UnimplementedError());
  }

  /// Create a new smoke log with the given parameters
  Future<SmokeLog> createSmokeLog({
    required String accountId,
    required int durationMs,
    String? methodId,
    int? potency,
    required int moodScore,
    required int physicalScore,
    String? notes,
  }) async {
    state = const AsyncLoading();

    final useCase = await ref.read(createSmokeLogUseCaseProvider.future);
    final result = await useCase(
      accountId: accountId,
      durationMs: durationMs,
      methodId: methodId,
      potency: potency,
      moodScore: moodScore,
      physicalScore: physicalScore,
      notes: notes,
    );

    final created = result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw failure;
      },
      (smokeLog) {
        state = AsyncData(smokeLog);
        return smokeLog;
      },
    );

    // Best-effort: attach any selected quick tags
    try {
      final controller =
          ref.read(quickTaggingControllerProvider(accountId).notifier);
      await controller.attachSelectedToLog(
        smokeLogId: created.id,
        ts: created.ts,
      );
    } catch (_) {
      // If provider not set or fails, ignore; tagging is optional
    }

    return created;
  }
}

final createSmokeLogProvider = AutoDisposeAsyncNotifierProviderFamily<
    CreateSmokeLogNotifier, SmokeLog, Map<String, dynamic>>(() {
  return CreateSmokeLogNotifier();
});

/// Provider for undo functionality
class UndoSmokeLogNotifier
    extends AutoDisposeFamilyAsyncNotifier<SmokeLog, String> {
  @override
  Future<SmokeLog> build(String arg) {
    return Future<SmokeLog>(() => throw UnimplementedError());
  }

  /// Undo the last smoke log for the given account
  Future<SmokeLog> undoLast({
    required String accountId,
    int undoWindowSeconds = 6,
  }) async {
    state = const AsyncLoading();

    final useCase = await ref.read(undoLastSmokeLogUseCaseProvider.future);
    final result = await useCase(
      accountId: accountId,
      undoWindowSeconds: undoWindowSeconds,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw failure;
      },
      (smokeLog) {
        state = AsyncData(smokeLog);

        // Invalidate related providers to refresh UI
        ref.invalidate(lastSmokeLogProvider(accountId));

        return smokeLog;
      },
    );
  }
}

final undoSmokeLogProvider = AutoDisposeAsyncNotifierProviderFamily<
    UndoSmokeLogNotifier, SmokeLog, String>(() {
  return UndoSmokeLogNotifier();
});
