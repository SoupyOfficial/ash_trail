// Platform data source for quick actions
// Handles interaction with the quick_actions package

import 'dart:async';
import 'package:quick_actions/quick_actions.dart';
import '../models/quick_action_model.dart';
import '../../domain/entities/quick_action_entity.dart';

abstract class QuickActionsDataSource {
  Future<void> initialize();
  Future<void> setShortcutItems(List<QuickActionModel> actions);
  Future<void> clearShortcutItems();
  Stream<QuickActionEntity> get actionStream;
}

class QuickActionsDataSourceImpl implements QuickActionsDataSource {
  QuickActionsDataSourceImpl() : _quickActions = const QuickActions();

  final QuickActions _quickActions;
  final StreamController<QuickActionEntity> _actionController =
      StreamController<QuickActionEntity>.broadcast();

  @override
  Future<void> initialize() async {
    // Set up the handler for quick action invocations
    _quickActions.initialize((type) {
      // Convert the string type to a QuickActionEntity
      final action = _mapTypeToEntity(type);
      if (action != null) {
        _actionController.add(action);
      }
    });
  }

  @override
  Future<void> setShortcutItems(List<QuickActionModel> actions) async {
    final shortcutItems = actions
        .map((action) => ShortcutItem(
              type: action.type,
              localizedTitle: action.localizedTitle,
              icon: action.icon,
            ))
        .toList();

    await _quickActions.setShortcutItems(shortcutItems);
  }

  @override
  Future<void> clearShortcutItems() async {
    await _quickActions.clearShortcutItems();
  }

  @override
  Stream<QuickActionEntity> get actionStream => _actionController.stream;

  // Helper method to map action type to entity
  QuickActionEntity? _mapTypeToEntity(String type) {
    return switch (type) {
      QuickActionTypes.logHit => const QuickActionEntity(
          type: QuickActionTypes.logHit,
          localizedTitle: 'Log Hit',
          localizedSubtitle: 'Quick record smoking session',
          icon: 'add',
        ),
      QuickActionTypes.viewLogs => const QuickActionEntity(
          type: QuickActionTypes.viewLogs,
          localizedTitle: 'View Logs',
          localizedSubtitle: 'See your smoking history',
          icon: 'list',
        ),
      QuickActionTypes.startTimedLog => const QuickActionEntity(
          type: QuickActionTypes.startTimedLog,
          localizedTitle: 'Start Timed Log',
          localizedSubtitle: 'Begin timing session',
          icon: 'timer',
        ),
      _ => null,
    };
  }

  void dispose() {
    _actionController.close();
  }
}
