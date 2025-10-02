// Functional home screen with integrated record button for smoke logging.
// Replaces placeholder HomeScreen in app_router.dart with working functionality.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../accessibility_foundation/presentation/widgets/semantic_wrappers.dart';
import '../../../capture_hit/presentation/providers/record_button_state_provider.dart';
import '../../../loading_skeletons/presentation/widgets/widgets.dart';
import '../../../responsive/presentation/widgets/responsive_padding.dart';
import '../../../../core/providers/account_providers.dart';
import '../providers/home_providers.dart';
import '../widgets/recording_status_widget.dart';
import '../widgets/welcome_header_widget.dart';
import '../widgets/quick_stats_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordState = ref.watch(recordButtonProvider);
    final activeAccountAsync = ref.watch(activeAccountAsyncProvider);
    final homeState = ref.watch(homeScreenStateProvider);

    return Scaffold(
      body: SafeArea(
        child: ResponsivePadding(
          child: homeState.when(
            loading: () => _buildLoadingState(),
            error: (error, stackTrace) => _buildErrorState(context, ref, error),
            data: (state) => _buildMainContent(
              context,
              ref,
              recordState,
              activeAccountAsync,
              state,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      children: [
        SizedBox(height: 120),
        SkeletonText(width: 200, height: 32),
        SizedBox(height: 16),
        SkeletonText(width: 280, height: 16),
        SizedBox(height: 80),
        SkeletonCircle(size: 200),
        SizedBox(height: 40),
        SkeletonText(width: 150, height: 20),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load home screen',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again or check your connection',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ref.invalidate(homeScreenStateProvider),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    RecordButtonState recordState,
    AsyncValue<String?> activeAccountAsync,
    HomeScreenState homeState,
  ) {
    return Column(
      children: [
        // Welcome header with current account
        WelcomeHeaderWidget(
          accountAsync: activeAccountAsync,
          recordState: recordState,
        ),

        const SizedBox(height: 32),

        // Quick stats (recent activity)
        QuickStatsWidget(
          recentLogsCount: homeState.recentLogsCount,
          todayLogsCount: homeState.todayLogsCount,
        ),

        const SizedBox(height: 48),

        // Main record button
        Expanded(
          child: Center(
            child: _buildRecordButton(
                context, ref, recordState, activeAccountAsync),
          ),
        ),

        // Status and feedback section
        RecordingStatusWidget(
          recordState: recordState,
          onUndoPressed: () => _handleUndo(context, ref),
          onErrorRetry: () => _handleErrorRetry(ref),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecordButton(
    BuildContext context,
    WidgetRef ref,
    RecordButtonState recordState,
    AsyncValue<String?> activeAccountAsync,
  ) {
    return activeAccountAsync.when(
      loading: () => const SkeletonCircle(size: 200),
      error: (error, stackTrace) => _buildAccountErrorState(context),
      data: (accountId) => accountId == null
          ? _buildNoAccountState(context)
          : _buildActiveRecordButton(context, ref, recordState, accountId),
    );
  }

  Widget _buildAccountErrorState(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.errorContainer,
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(height: 8),
          Text(
            'Account Error',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAccountState(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign In',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Required',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRecordButton(
    BuildContext context,
    WidgetRef ref,
    RecordButtonState recordState,
    String accountId,
  ) {
    final isRecording = recordState is RecordButtonRecordingState;
    final isEnabled =
        recordState is! RecordButtonErrorState && accountId.isNotEmpty;

    return AccessibleRecordButton(
      onPressed: isEnabled ? () => _handleQuickRecord(ref, accountId) : null,
      onLongPress:
          isEnabled ? () => _handleStartRecording(ref, accountId) : null,
      isRecording: isRecording,
      semanticLabel: isRecording
          ? 'Recording in progress. Release to save.'
          : isEnabled
              ? 'Record smoking hit. Tap for quick log, hold for timed recording.'
              : 'Record button disabled. Check account status.',
      minTapTarget: 200.0, // Large target for primary action
    );
  }

  void _handleQuickRecord(WidgetRef ref, String accountId) {
    final controller = ref.read(recordButtonProvider.notifier);
    // Quick record - simulate 1 second duration
    controller.startRecording(accountId);

    // Auto-complete after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      controller.stopRecording(
        moodScore: 3, // Default neutral mood
        physicalScore: 3, // Default neutral physical state
      );
    });
  }

  void _handleStartRecording(WidgetRef ref, String accountId) {
    final controller = ref.read(recordButtonProvider.notifier);
    controller.startRecording(accountId);
  }

  void _handleUndo(BuildContext context, WidgetRef ref) {
    // TODO: Implement undo functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Undo feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleErrorRetry(WidgetRef ref) {
    final controller = ref.read(recordButtonProvider.notifier);
    controller.resetToIdle();
  }
}
