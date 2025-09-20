// Riverpod providers for smoke log capture functionality
// Manages repository, use cases, and state for hold-to-record feature

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../data/datasources/smoke_log_local_datasource.dart';
import '../../data/datasources/smoke_log_remote_datasource.dart';
import '../../data/repositories/smoke_log_repository_impl.dart';
import '../../domain/repositories/smoke_log_repository.dart';
import '../../domain/usecases/create_smoke_log_usecase.dart';
import '../../domain/usecases/undo_last_smoke_log_usecase.dart';
import '../../domain/usecases/get_last_smoke_log_usecase.dart';
import '../../domain/usecases/delete_smoke_log_usecase.dart';
// Optional: integrate with quick tagging to attach selected tags after creation
import '../../../quick_tagging/presentation/providers/quick_tagging_providers.dart';

/// Repository providers - Abstract interfaces
/// These should be overridden in main.dart with concrete implementations
final smokeLogLocalDataSourceProvider =
    Provider<SmokeLogLocalDataSource>((ref) {
  throw UnimplementedError(
    'smokeLogLocalDataSourceProvider must be overridden with Isar implementation',
  );
});

final smokeLogRemoteDataSourceProvider =
    Provider<SmokeLogRemoteDataSource>((ref) {
  throw UnimplementedError(
    'smokeLogRemoteDataSourceProvider must be overridden with Firestore implementation',
  );
});

/// Repository implementation provider
final smokeLogRepositoryProvider = Provider<SmokeLogRepository>((ref) {
  return SmokeLogRepositoryImpl(
    localDataSource: ref.watch(smokeLogLocalDataSourceProvider),
    remoteDataSource: ref.watch(smokeLogRemoteDataSourceProvider),
  );
});

/// Use case providers
final createSmokeLogUseCaseProvider = Provider<CreateSmokeLogUseCase>((ref) {
  return CreateSmokeLogUseCase(
    repository: ref.watch(smokeLogRepositoryProvider),
  );
});

final undoLastSmokeLogUseCaseProvider =
    Provider<UndoLastSmokeLogUseCase>((ref) {
  return UndoLastSmokeLogUseCase(
    repository: ref.watch(smokeLogRepositoryProvider),
  );
});

final getLastSmokeLogUseCaseProvider = Provider<GetLastSmokeLogUseCase>((ref) {
  return GetLastSmokeLogUseCase(
    repository: ref.watch(smokeLogRepositoryProvider),
  );
});

final deleteSmokeLogUseCaseProvider = Provider<DeleteSmokeLogUseCase>((ref) {
  return DeleteSmokeLogUseCase(
    repository: ref.watch(smokeLogRepositoryProvider),
  );
});

/// Async providers for fetching data
/// These providers handle the async operations and error states

/// Get the last smoke log for the current account
/// Returns null if no logs exist
final lastSmokeLogProvider =
    FutureProvider.family<SmokeLog?, String>((ref, accountId) async {
  final useCase = ref.watch(getLastSmokeLogUseCaseProvider);
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

    final useCase = ref.read(createSmokeLogUseCaseProvider);
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

    final useCase = ref.read(undoLastSmokeLogUseCaseProvider);
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
