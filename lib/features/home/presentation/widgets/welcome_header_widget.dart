// Widget displaying welcome message and current account info for home screen.
// Shows personalized greeting and account status.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../capture_hit/presentation/providers/record_button_state_provider.dart';
import '../../../loading_skeletons/presentation/widgets/widgets.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  const WelcomeHeaderWidget({
    super.key,
    required this.accountAsync,
    required this.recordState,
  });

  final AsyncValue<String?> accountAsync;
  final RecordButtonState recordState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Text(
          _getGreeting(),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        // Account status
        accountAsync.when(
          loading: () => SkeletonContainer(
            width: 200,
            height: 20,
            child: const SizedBox(),
          ),
          error: (error, stackTrace) => Text(
            'Account unavailable',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
            ),
          ),
          data: (accountId) => Text(
            accountId != null
                ? 'Ready to log your sessions'
                : 'Sign in to start tracking',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Recording status
        if (recordState is RecordButtonRecordingState)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.radio_button_checked,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Recording in progress...',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else if (recordState is RecordButtonCompletedState)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Session recorded successfully',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
