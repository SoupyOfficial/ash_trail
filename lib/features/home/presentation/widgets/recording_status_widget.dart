// Widget displaying current recording status and action buttons.
// Handles feedback for recording state and provides undo/retry actions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../capture_hit/presentation/providers/record_button_state_provider.dart';

class RecordingStatusWidget extends ConsumerWidget {
  const RecordingStatusWidget({
    super.key,
    required this.recordState,
    required this.onUndoPressed,
    required this.onErrorRetry,
  });

  final RecordButtonState recordState;
  final VoidCallback onUndoPressed;
  final VoidCallback onErrorRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return switch (recordState) {
      RecordButtonRecordingState recordingState =>
        _buildRecordingStatus(context, textTheme, colorScheme, recordingState),
      RecordButtonCompletedState completedState =>
        _buildCompletedStatus(context, textTheme, colorScheme, completedState),
      RecordButtonErrorState errorState =>
        _buildErrorStatus(context, textTheme, colorScheme, errorState),
      RecordButtonIdleState() =>
        _buildIdleStatus(context, textTheme, colorScheme),
    };
  }

  Widget _buildRecordingStatus(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    RecordButtonRecordingState state,
  ) {
    final formattedDuration = _formatDuration(state.currentDurationMs);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recording: $formattedDuration',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Release the button to save your session',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedStatus(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    RecordButtonCompletedState state,
  ) {
    final formattedDuration = _formatDuration(state.durationMs);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Session saved ($formattedDuration)',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onUndoPressed,
            icon: const Icon(Icons.undo, size: 16),
            label: const Text('Undo'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStatus(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
    RecordButtonErrorState state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                color: colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recording failed',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onErrorRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleStatus(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap for quick log • Hold for timed recording',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds / 1000;
    if (seconds < 10) {
      return '${seconds.toStringAsFixed(1)}s';
    } else {
      return '${seconds.round()}s';
    }
  }
}
