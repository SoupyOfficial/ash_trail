// Providers for inline editing within the undo snackbar window
// Allows quick +/- duration and notes edit, replacing a pending write

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../../capture_hit/presentation/providers/smoke_log_providers.dart';
import '../../../../core/failures/app_failure.dart';

/// State for inline edit controls during snackbar window
class InlineEditState {
  final SmokeLog baseLog;
  final int adjustedDurationMs; // editable
  final String notes; // editable
  final bool isSaving;
  final AppFailure? error;

  const InlineEditState({
    required this.baseLog,
    required this.adjustedDurationMs,
    required this.notes,
    this.isSaving = false,
    this.error,
  });

  InlineEditState copyWith({
    SmokeLog? baseLog,
    int? adjustedDurationMs,
    String? notes,
    bool? isSaving,
    AppFailure? error, // pass null explicitly to clear
  }) {
    return InlineEditState(
      baseLog: baseLog ?? this.baseLog,
      adjustedDurationMs: adjustedDurationMs ?? this.adjustedDurationMs,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

/// Family provider keyed by smokeLog.id to manage its inline edit state
class InlineEditController
    extends AutoDisposeFamilyNotifier<InlineEditState?, SmokeLog> {
  @override
  InlineEditState? build(SmokeLog arg) {
    // Initialize with the provided log as base
    return InlineEditState(
      baseLog: arg,
      adjustedDurationMs: arg.durationMs,
      notes: arg.notes ?? '',
    );
  }

  void incrementDuration(int stepMs) {
    final stateNow = state;
    if (stateNow == null) return;
    final next = (stateNow.adjustedDurationMs + stepMs).clamp(1, 1800000);
    state = stateNow.copyWith(adjustedDurationMs: next);
  }

  void decrementDuration(int stepMs) {
    incrementDuration(-stepMs);
  }

  void setNotes(String value) {
    final stateNow = state;
    if (stateNow == null) return;
    state = stateNow.copyWith(notes: value);
  }

  /// Save updates via repository, replacing any pending write
  Future<SmokeLog?> save() async {
    final stateNow = state;
    if (stateNow == null) return null;

    // Build updated entity
    final updated = stateNow.baseLog.copyWith(
      durationMs: stateNow.adjustedDurationMs,
      notes: stateNow.notes.isEmpty ? null : stateNow.notes,
      updatedAt: DateTime.now(),
    );

    state = stateNow.copyWith(isSaving: true, error: null);

    final repo = await ref.read(smokeLogRepositoryProvider.future);
    final result = await repo.updateSmokeLog(updated);

    return result.fold(
      (failure) {
        state = stateNow.copyWith(isSaving: false, error: failure);
        return null;
      },
      (saved) {
        state = InlineEditState(
          baseLog: saved,
          adjustedDurationMs: saved.durationMs,
          notes: saved.notes ?? '',
          isSaving: false,
          error: null,
        );
        return saved;
      },
    );
  }
}

final inlineEditControllerProvider = AutoDisposeNotifierProviderFamily<
    InlineEditController, InlineEditState?, SmokeLog>(
  () => InlineEditController(),
);
