// Handler for quick action invocations
// Coordinates routing and telemetry for quick actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/quick_action_entity.dart';
import '../../../../core/telemetry/telemetry_service.dart';

// Provider for quick actions handler
final quickActionsHandlerProvider = Provider<QuickActionsHandler>((ref) {
  final telemetry = ref.watch(telemetryServiceProvider);
  return QuickActionsHandler(telemetry);
});

class QuickActionsHandler {
  const QuickActionsHandler(this._telemetry);

  final TelemetryService _telemetry;

  void handleQuickAction(BuildContext context, QuickActionEntity action) {
    // Log telemetry event for quick action invocation
    _telemetry.logEvent('quick_action_invoked', {
      'action_type': action.type,
      'action_title': action.localizedTitle,
    });

    // Handle navigation based on action type
    switch (action.type) {
      case QuickActionTypes.logHit:
        _handleLogHit(context);
        break;
      case QuickActionTypes.viewLogs:
        _handleViewLogs(context);
        break;
      case QuickActionTypes.startTimedLog:
        _handleStartTimedLog(context);
        break;
      default:
        _telemetry.logEvent('quick_action_unknown', {
          'action_type': action.type,
        });
    }
  }

  void _handleLogHit(BuildContext context) {
    // For now, show the record action (same as FAB in app shell)
    // In a real implementation, this would open a record overlay or screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quick Log Hit - Opening record screen'),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to home if not already there
    final router = GoRouter.of(context);
    router.go('/');
  }

  void _handleViewLogs(BuildContext context) {
    // Navigate to logs screen
    final router = GoRouter.of(context);
    router.go('/logs');
  }

  void _handleStartTimedLog(BuildContext context) {
    // For now, show a placeholder - this would start a timed log session
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quick Start Timed Log - Feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to home
    final router = GoRouter.of(context);
    router.go('/');
  }
}
