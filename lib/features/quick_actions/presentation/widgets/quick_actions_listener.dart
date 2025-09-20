// Widget that listens for quick action invocations and handles them
// Should be placed high in the widget tree (e.g., in main app)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quick_actions_providers.dart';
import '../handlers/quick_actions_handler.dart';

class QuickActionsListener extends ConsumerWidget {
  const QuickActionsListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize quick actions
    ref.listen(quickActionsControllerProvider, (previous, next) {
      next.when(
        data: (_) {
          // Quick actions initialized successfully
          debugPrint('[QuickActions] Initialized successfully');
        },
        error: (error, stackTrace) {
          // Failed to initialize quick actions
          debugPrint('[QuickActions] Initialization failed: $error');
        },
        loading: () {
          // Still initializing
          debugPrint('[QuickActions] Initializing...');
        },
      );
    });

    // Listen for quick action invocations
    ref.listen(quickActionsStreamProvider, (previous, next) {
      next.when(
        data: (action) {
          // Handle the quick action
          final handler = ref.read(quickActionsHandlerProvider);
          handler.handleQuickAction(context, action);
        },
        error: (error, stackTrace) {
          debugPrint('[QuickActions] Stream error: $error');
        },
        loading: () {
          // Stream is loading
        },
      );
    });

    return child;
  }
}
