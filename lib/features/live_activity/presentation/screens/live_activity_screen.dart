// Demo screen for live activity recording functionality.
// Shows the recording interface with proper error handling and feedback.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/live_activity_recording_widget.dart';
import '../../../../core/failures/app_failure.dart';

class LiveActivityScreen extends ConsumerWidget {
  const LiveActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Activity'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Live Activity Recording',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hold the button to start recording. While recording, you\'ll see elapsed time and can cancel anytime.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Recording widget
              Expanded(
                child: Center(
                  child: LiveActivityRecordingWidget(
                    onRecordingComplete: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Recording completed!'),
                          backgroundColor: colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    onRecordingCancelled: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Recording cancelled'),
                          backgroundColor: colorScheme.secondary,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    onError: (AppFailure failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(failure.displayMessage),
                          backgroundColor: colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Footer info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This demo shows the Live Activity recording interface. '
                  'The feature prevents orphaned activities and provides '
                  'real-time feedback during recording sessions.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
