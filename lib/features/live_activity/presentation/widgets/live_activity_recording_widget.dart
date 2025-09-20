// Live activity recording widget with hold-to-record functionality.
// Displays elapsed time and provides cancel option during recording.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/live_activity_providers.dart';
import '../../../../core/failures/app_failure.dart';

class LiveActivityRecordingWidget extends ConsumerStatefulWidget {
  const LiveActivityRecordingWidget({
    super.key,
    this.onRecordingComplete,
    this.onRecordingCancelled,
    this.onError,
  });

  final VoidCallback? onRecordingComplete;
  final VoidCallback? onRecordingCancelled;
  final void Function(AppFailure)? onError;

  @override
  ConsumerState<LiveActivityRecordingWidget> createState() =>
      _LiveActivityRecordingWidgetState();
}

class _LiveActivityRecordingWidgetState
    extends ConsumerState<LiveActivityRecordingWidget> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _startRecording();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _completeRecording();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _completeRecording();
  }

  void _startRecording() {
    HapticFeedback.mediumImpact();
    final controller = ref.read(liveActivityControllerProvider.notifier);
    controller.startRecording();
  }

  void _completeRecording() {
    HapticFeedback.lightImpact();
    final controller = ref.read(liveActivityControllerProvider.notifier);
    controller.completeRecording();
    widget.onRecordingComplete?.call();
  }

  void _cancelRecording() {
    HapticFeedback.mediumImpact();
    final controller = ref.read(liveActivityControllerProvider.notifier);
    controller.cancelRecording(reason: 'User cancelled');
    widget.onRecordingCancelled?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final activityState = ref.watch(liveActivityControllerProvider);

    return activityState.when(
      loading: () => _buildLoadingState(context, colorScheme, textTheme),
      error: (error, stackTrace) {
        // Handle errors
        if (error is AppFailure) {
          widget.onError?.call(error);
        }
        return _buildErrorState(context, colorScheme, textTheme, error);
      },
      data: (activity) {
        if (activity == null || !activity.isActive) {
          // No active recording - show record button
          return _buildRecordButton(context, colorScheme, textTheme);
        }

        // Active recording - show recording interface
        return _buildRecordingInterface(
            context, colorScheme, textTheme, activity);
      },
    );
  }

  Widget _buildLoadingState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.outline,
          width: 2,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Object error,
  ) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.error,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onErrorContainer,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Error',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Semantics(
      label: 'Hold to record activity. Press and hold to start timing.',
      button: true,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: _isPressed
                ? colorScheme.primaryContainer.withOpacity(0.8)
                : colorScheme.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary,
              width: _isPressed ? 4 : 2,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isPressed ? Icons.stop : Icons.play_arrow,
                color: colorScheme.onPrimaryContainer,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                _isPressed ? 'Recording...' : 'Hold to Record',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingInterface(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    activity,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Elapsed time display
        Consumer(
          builder: (context, ref, child) {
            final elapsedTimeAsync =
                ref.watch(elapsedTimeProvider(activity.id));
            return elapsedTimeAsync.when(
              data: (duration) => _buildTimeDisplay(
                context,
                colorScheme,
                textTheme,
                duration,
              ),
              loading: () => _buildTimeDisplay(
                context,
                colorScheme,
                textTheme,
                activity.elapsedDuration,
              ),
              error: (_, __) => _buildTimeDisplay(
                context,
                colorScheme,
                textTheme,
                activity.elapsedDuration,
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Recording indicator and cancel button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recording indicator
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.error.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    color: colorScheme.onError,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'REC',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 32),

            // Cancel button
            Semantics(
              label: 'Cancel recording',
              button: true,
              child: GestureDetector(
                onTap: _cancelRecording,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close,
                        color: colorScheme.onSurface,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cancel',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeDisplay(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Duration duration,
  ) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Semantics(
        liveRegion: true,
        label: 'Elapsed time: $minutes minutes and $seconds seconds',
        child: Text(
          timeString,
          style: textTheme.displayMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w300,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
