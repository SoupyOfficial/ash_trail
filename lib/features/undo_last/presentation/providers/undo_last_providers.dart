// Unified providers for undo last log functionality
// Connects to the existing use case from capture_hit and provides clean interface

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../capture_hit/presentation/providers/smoke_log_providers.dart';
import '../../domain/usecases/undo_last_log_use_case.dart';

/// Provider for the unified undo last log use case
/// Uses the existing SmokeLogRepository from capture_hit
final undoLastLogUseCaseProvider = Provider<UndoLastLogUseCase>((ref) {
  return UndoLastLogUseCase(
    smokeLogRepository: ref.watch(smokeLogRepositoryProvider),
  );
});

/// Provider for checking if undo is available for an account
/// Returns true if there's a log that can be undone within the timeout
final canUndoProvider =
    FutureProvider.family<bool, String>((ref, accountId) async {
  final useCase = ref.watch(undoLastLogUseCaseProvider);
  final result = await useCase.canUndo(accountId);

  return result.fold(
    (failure) => false, // Treat failures as "no undo available"
    (canUndo) => canUndo,
  );
});

/// Provider for getting remaining undo time in seconds
/// Returns 0 if no undo is available
final undoTimeRemainingProvider =
    FutureProvider.family<int, String>((ref, accountId) async {
  final useCase = ref.watch(undoLastLogUseCaseProvider);
  final result = await useCase.getUndoTimeRemaining(accountId);

  return result.fold(
    (failure) => 0, // Treat failures as "no time remaining"
    (timeRemaining) => timeRemaining,
  );
});

/// Notifier for executing undo operations
/// Handles the async undo process with proper state management
class UndoLastLogNotifier extends AutoDisposeFamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String accountId) async {
    // Initial state - no operation
  }

  /// Execute the undo operation for the given account
  /// Updates state to show loading, success, or error
  Future<void> executeUndo() async {
    final accountId = arg; // Family parameter
    state = const AsyncLoading();

    final useCase = ref.read(undoLastLogUseCaseProvider);
    final result = await useCase.call(accountId);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        state = const AsyncData(null);

        // Invalidate related providers to refresh UI
        ref.invalidate(canUndoProvider(accountId));
        ref.invalidate(undoTimeRemainingProvider(accountId));

        // Also invalidate the last smoke log provider from capture_hit
        ref.invalidate(lastSmokeLogProvider(accountId));
      },
    );
  }

  /// Check if an undo operation is currently in progress
  bool get isUndoInProgress => state.isLoading;

  /// Get the error message if undo failed
  String? get undoErrorMessage {
    if (state case AsyncError(:final error)) {
      return error.toString();
    }
    return null;
  }
}

/// Provider for undo operations
final undoLastLogNotifierProvider =
    AutoDisposeAsyncNotifierProviderFamily<UndoLastLogNotifier, void, String>(
        () {
  return UndoLastLogNotifier();
});
