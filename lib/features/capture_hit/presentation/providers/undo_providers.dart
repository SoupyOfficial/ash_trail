// Provider for undo functionality in capture hit feature
// Manages undo state and displays snackbar for user interaction

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/smoke_log.dart';
import 'smoke_log_providers.dart';

part 'undo_providers.freezed.dart';

/// State for the undo functionality
@freezed
sealed class UndoState with _$UndoState {
  /// No pending undo operation
  const factory UndoState.idle() = UndoIdleState;

  /// Undo window is active - showing snackbar with countdown
  const factory UndoState.pendingUndo({
    required SmokeLog undoableLog,
    required int remainingSeconds,
  }) = UndoPendingState;

  /// Undo operation in progress
  const factory UndoState.undoing({
    required SmokeLog targetLog,
  }) = UndoInProgressState;

  /// Undo completed successfully
  const factory UndoState.undoCompleted({
    required SmokeLog undoneLog,
  }) = UndoCompletedState;

  /// Undo failed with error
  const factory UndoState.undoFailed({
    required String message,
  }) = UndoFailedState;
}

/// Controller for managing undo functionality
/// Handles the 6-second undo window and user interactions
class UndoController extends AutoDisposeNotifier<UndoState> {
  Timer? _undoTimer;
  static const int _undoWindowSeconds = 6;

  @override
  UndoState build() {
    // Clean up timer when provider is disposed
    ref.onDispose(() {
      _undoTimer?.cancel();
    });

    return const UndoState.idle();
  }

  /// Start undo countdown after a smoke log is created
  /// Shows snackbar with countdown timer
  void startUndoWindow(SmokeLog smokeLog) {
    // Cancel any existing timer
    _undoTimer?.cancel();

    state = UndoState.pendingUndo(
      undoableLog: smokeLog,
      remainingSeconds: _undoWindowSeconds,
    );

    // Start countdown timer (updates every second)
    var remainingSeconds = _undoWindowSeconds;
    _undoTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        remainingSeconds--;

        if (remainingSeconds <= 0) {
          // Undo window expired
          timer.cancel();
          state = const UndoState.idle();
        } else {
          // Update countdown
          if (state case UndoPendingState pendingState) {
            state = pendingState.copyWith(remainingSeconds: remainingSeconds);
          }
        }
      },
    );
  }

  /// Execute the undo operation
  /// Called when user taps the undo button in the snackbar
  Future<void> executeUndo(String accountId) async {
    if (state case UndoPendingState pendingState) {
      // Cancel countdown timer
      _undoTimer?.cancel();
      _undoTimer = null;

      // Update state to show undo in progress
      state = UndoState.undoing(targetLog: pendingState.undoableLog);

      try {
        // Execute undo via use case
        final undoNotifier = ref.read(undoSmokeLogProvider(accountId).notifier);
        final undoneLog = await undoNotifier.undoLast(accountId: accountId);

        // Update state to show undo completed
        state = UndoState.undoCompleted(undoneLog: undoneLog);

        // Return to idle after brief feedback
        Timer(const Duration(seconds: 2), () {
          state = const UndoState.idle();
        });
      } catch (error) {
        // Handle undo error
        state = UndoState.undoFailed(message: error.toString());

        // Return to idle after showing error
        Timer(const Duration(seconds: 3), () {
          state = const UndoState.idle();
        });
      }
    }
  }

  /// Cancel the undo window (e.g., when user dismisses snackbar)
  void cancelUndo() {
    _undoTimer?.cancel();
    _undoTimer = null;
    state = const UndoState.idle();
  }

  /// Check if undo window is currently active
  bool get isUndoAvailable => state is UndoPendingState;

  /// Get remaining seconds for undo (0 if not available)
  int get remainingUndoSeconds {
    return switch (state) {
      UndoPendingState pendingState => pendingState.remainingSeconds,
      _ => 0,
    };
  }

  /// Get the log that can be undone (null if not available)
  SmokeLog? get undoableLog {
    return switch (state) {
      UndoPendingState pendingState => pendingState.undoableLog,
      UndoInProgressState inProgressState => inProgressState.targetLog,
      _ => null,
    };
  }

  /// Check if undo operation is currently in progress
  bool get isUndoInProgress => state is UndoInProgressState;

  /// Get undo error message (null if no error)
  String? get undoErrorMessage {
    return switch (state) {
      UndoFailedState failedState => failedState.message,
      _ => null,
    };
  }
}

/// Provider for undo functionality
final undoControllerProvider =
    AutoDisposeNotifierProvider<UndoController, UndoState>(() {
  return UndoController();
});

/// Computed provider for undo button text with countdown
/// Returns text like "UNDO (5s)" or "UNDO" if not in countdown
final undoButtonTextProvider = Provider.autoDispose<String>((ref) {
  final undoState = ref.watch(undoControllerProvider);

  return switch (undoState) {
    UndoPendingState pendingState => 'UNDO (${pendingState.remainingSeconds}s)',
    UndoInProgressState _ => 'UNDOING...',
    _ => 'UNDO',
  };
});

/// Provider for determining if undo snackbar should be visible
final shouldShowUndoSnackbarProvider = Provider.autoDispose<bool>((ref) {
  final undoState = ref.watch(undoControllerProvider);
  return undoState is UndoPendingState;
});

/// Provider for undo snackbar message content
final undoSnackbarMessageProvider = Provider.autoDispose<String>((ref) {
  final undoState = ref.watch(undoControllerProvider);

  return switch (undoState) {
    UndoPendingState pendingState =>
      'Hit logged (${(pendingState.undoableLog.durationMs / 1000).toStringAsFixed(1)}s)',
    UndoCompletedState _ => 'Hit undone',
    UndoFailedState failedState => 'Undo failed: ${failedState.message}',
    _ => '',
  };
});

/// Provider for determining if undo action should be enabled
final isUndoEnabledProvider = Provider.autoDispose<bool>((ref) {
  final undoState = ref.watch(undoControllerProvider);
  return undoState is UndoPendingState;
});
