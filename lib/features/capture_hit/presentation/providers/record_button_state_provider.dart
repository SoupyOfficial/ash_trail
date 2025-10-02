// State management for hold-to-record button functionality
// Handles press detection, duration tracking, and haptic feedback

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/providers/account_providers.dart';
import '../../../haptics_baseline/presentation/providers/haptics_providers.dart';
import 'smoke_log_providers.dart';

part 'record_button_state_provider.freezed.dart';

/// State for the record button functionality
@freezed
sealed class RecordButtonState with _$RecordButtonState {
  const factory RecordButtonState.idle() = RecordButtonIdleState;

  const factory RecordButtonState.recording({
    required DateTime startTime,
    required int currentDurationMs,
  }) = RecordButtonRecordingState;

  const factory RecordButtonState.completed({
    required int durationMs,
    required String smokeLogId,
  }) = RecordButtonCompletedState;

  const factory RecordButtonState.error({
    required String message,
  }) = RecordButtonErrorState;
}

/// Controller for managing record button state and interactions
class RecordButtonController extends AutoDisposeNotifier<RecordButtonState> {
  Timer? _durationTimer;
  String? _currentAccountId;

  @override
  RecordButtonState build() {
    // Clean up timer when provider is disposed
    ref.onDispose(() {
      _durationTimer?.cancel();
    });

    return const RecordButtonState.idle();
  }

  /// Start recording - called when user presses and holds the button
  /// Triggers haptic feedback and starts duration tracking
  Future<void> startRecording(String accountId) async {
    if (state is! RecordButtonIdleState) {
      return; // Already recording or in another state
    }

    _currentAccountId = accountId;
    final startTime = DateTime.now();

    // Trigger haptic feedback for press start
    final hapticNotifier = ref.read(hapticTriggerProvider.notifier);
    await hapticNotifier.impactLight();

    // Update state to recording
    state = RecordButtonState.recording(
      startTime: startTime,
      currentDurationMs: 0,
    );

    // Start duration timer (updates every 100ms for smooth UI)
    _durationTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (state case RecordButtonRecordingState recordingState) {
          final currentDuration =
              DateTime.now().difference(recordingState.startTime);
          state = recordingState.copyWith(
            currentDurationMs: currentDuration.inMilliseconds,
          );
        } else {
          // State changed, cancel timer
          timer.cancel();
        }
      },
    );
  }

  /// Stop recording - called when user releases the button
  /// Triggers haptic feedback and creates smoke log entry
  Future<void> stopRecording({
    String? methodId,
    int? potency,
    required int moodScore,
    required int physicalScore,
    String? notes,
  }) async {
    if (state case RecordButtonRecordingState recordingState) {
      final endTime = DateTime.now();
      final durationMs =
          endTime.difference(recordingState.startTime).inMilliseconds;

      // Stop timer
      _durationTimer?.cancel();
      _durationTimer = null;

      // Trigger haptic feedback for release
      final hapticNotifier = ref.read(hapticTriggerProvider.notifier);
      await hapticNotifier.success();

      try {
        // Create smoke log entry
        final createNotifier = ref.read(createSmokeLogProvider({}).notifier);
        final smokeLog = await createNotifier.createSmokeLog(
          accountId: _currentAccountId!,
          durationMs: durationMs,
          methodId: methodId,
          potency: potency,
          moodScore: moodScore,
          physicalScore: physicalScore,
          notes: notes,
        );

        // Update state to completed
        state = RecordButtonState.completed(
          durationMs: durationMs,
          smokeLogId: smokeLog.id,
        );

        // Return to idle after a brief moment
        Timer(const Duration(milliseconds: 1500), () {
          state = const RecordButtonState.idle();
        });
      } catch (error) {
        // Handle creation error
        await hapticNotifier.error();
        state = RecordButtonState.error(
          message: error.toString(),
        );

        // Return to idle after error
        Timer(const Duration(seconds: 3), () {
          state = const RecordButtonState.idle();
        });
      }
    }
  }

  /// Cancel recording - called if user cancels before release
  /// Returns to idle state without creating a log entry
  Future<void> cancelRecording() async {
    if (state is RecordButtonRecordingState) {
      _durationTimer?.cancel();
      _durationTimer = null;

      // Trigger warning haptic
      final hapticNotifier = ref.read(hapticTriggerProvider.notifier);
      await hapticNotifier.warning();

      state = const RecordButtonState.idle();
    }
  }

  /// Reset to idle state (useful for error recovery)
  void resetToIdle() {
    _durationTimer?.cancel();
    _durationTimer = null;
    state = const RecordButtonState.idle();
  }

  /// Get current duration in milliseconds (for real-time display)
  int get currentDurationMs {
    return switch (state) {
      RecordButtonRecordingState recordingState =>
        recordingState.currentDurationMs,
      RecordButtonCompletedState completedState => completedState.durationMs,
      _ => 0,
    };
  }

  /// Check if currently recording
  bool get isRecording => state is RecordButtonRecordingState;

  /// Check if in error state
  bool get hasError => state is RecordButtonErrorState;

  /// Get error message if in error state
  String? get errorMessage {
    return switch (state) {
      RecordButtonErrorState errorState => errorState.message,
      _ => null,
    };
  }
}

/// Provider for record button state and controller
final recordButtonProvider =
    AutoDisposeNotifierProvider<RecordButtonController, RecordButtonState>(() {
  return RecordButtonController();
});

/// Computed provider for formatted duration display
/// Returns human-readable duration string (e.g., "1.2s", "15.6s")
final formattedDurationProvider = Provider.autoDispose<String>((ref) {
  final buttonState = ref.watch(recordButtonProvider);

  final durationMs = switch (buttonState) {
    RecordButtonRecordingState recordingState =>
      recordingState.currentDurationMs,
    RecordButtonCompletedState completedState => completedState.durationMs,
    _ => 0,
  };

  if (durationMs < 1000) {
    return '${(durationMs / 100).floor() / 10}s';
  } else {
    return '${(durationMs / 100).round() / 10}s';
  }
});

/// Provider for determining if recording is active (for UI styling)
final isRecordingActiveProvider = Provider.autoDispose<bool>((ref) {
  final buttonState = ref.watch(recordButtonProvider);
  return buttonState is RecordButtonRecordingState;
});

/// Provider for determining if record button should be enabled
/// Considers various factors like network state, permissions, etc.
final recordButtonEnabledProvider = Provider.autoDispose<bool>((ref) {
  final buttonState = ref.watch(recordButtonProvider);

  // Disabled if currently recording or in error state
  if (buttonState is RecordButtonRecordingState ||
      buttonState is RecordButtonErrorState) {
    return false;
  }

  // TODO: Add additional checks:
  // - Network connectivity (for eventual sync)
  // - Storage space availability
  // - User permissions

  return true;
});

/// Provider for current account ID (to be integrated with account system)
/// This is a placeholder - should be replaced with actual account provider
final currentAccountIdProvider = Provider<String?>((ref) {
  // Phase 1: Use the mock account provider
  return ref.watch(activeAccountProvider)?.id;
});
