import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logging/app_logger.dart';
import '../models/home_widget_config.dart';
import '../services/error_reporting_service.dart';
import '../widgets/home_widgets/widget_catalog.dart';
import 'account_provider.dart';

/// Key prefix for storing home layout config per account
const String _homeLayoutKeyPrefix = 'home_layout_';

/// Get storage key for an account
String _getStorageKey(String? accountId) {
  return '$_homeLayoutKeyPrefix${accountId ?? 'default'}';
}

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final _log = AppLogger.logger('HomeLayoutConfigNotifier');

/// State notifier for home layout configuration
class HomeLayoutConfigNotifier extends StateNotifier<HomeLayoutConfig> {
  final Ref ref;
  final String? accountId;

  HomeLayoutConfigNotifier(this.ref, this.accountId)
    : super(HomeLayoutConfig.defaultConfig()) {
    _loadConfig();
  }

  /// Load configuration from SharedPreferences
  Future<void> _loadConfig() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final key = _getStorageKey(accountId);
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        state = HomeLayoutConfig.fromJsonString(jsonString);
      } else {
        // First time user - use default config
        state = HomeLayoutConfig.defaultConfig();
        await _saveConfig();
      }
    } catch (e, st) {
      _log.e('Error loading home layout config', error: e, stackTrace: st);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'HomeLayoutConfigNotifier._loadConfig',
      );
      // Fall back to default on error
      state = HomeLayoutConfig.defaultConfig();
    }
  }

  /// Save configuration to SharedPreferences
  Future<void> _saveConfig() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final key = _getStorageKey(accountId);
      await prefs.setString(key, state.toJsonString());
    } catch (e, st) {
      _log.e('Error saving home layout config', error: e, stackTrace: st);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'HomeLayoutConfigNotifier._saveConfig',
      );
    }
  }

  /// Add a new widget to the layout
  Future<void> addWidget(
    HomeWidgetType type, {
    Map<String, dynamic>? settings,
  }) async {
    // Check if widget already exists (for non-multiple types)
    final entry = WidgetCatalog.getEntry(type);
    if (!entry.allowMultiple && state.hasWidgetType(type)) {
      return; // Widget already exists
    }

    state = state.addWidget(type, settings: settings);
    await _saveConfig();
  }

  /// Remove a widget from the layout
  Future<void> removeWidget(String widgetId) async {
    state = state.removeWidget(widgetId);
    await _saveConfig();
  }

  /// Toggle widget visibility
  Future<void> toggleVisibility(String widgetId) async {
    final widget = state.widgets.firstWhere(
      (w) => w.id == widgetId,
      orElse: () => throw Exception('Widget not found'),
    );
    state = state.setWidgetVisibility(widgetId, !widget.isVisible);
    await _saveConfig();
  }

  /// Set widget visibility explicitly
  Future<void> setVisibility(String widgetId, bool isVisible) async {
    state = state.setWidgetVisibility(widgetId, isVisible);
    await _saveConfig();
  }

  /// Reorder widgets after drag-and-drop
  Future<void> reorder(int oldIndex, int newIndex) async {
    state = state.reorder(oldIndex, newIndex);
    await _saveConfig();
  }

  /// Reset to default configuration
  Future<void> resetToDefault() async {
    state = HomeLayoutConfig.defaultConfig();
    await _saveConfig();
  }

  /// Update widget settings
  Future<void> updateWidgetSettings(
    String widgetId,
    Map<String, dynamic> settings,
  ) async {
    state = HomeLayoutConfig(
      widgets:
          state.widgets.map((w) {
            if (w.id == widgetId) {
              return w.copyWith(settings: {...?w.settings, ...settings});
            }
            return w;
          }).toList(),
      version: state.version,
    );
    await _saveConfig();
  }
}

/// Provider for home layout configuration (account-specific)
final homeLayoutConfigProvider =
    StateNotifierProvider<HomeLayoutConfigNotifier, HomeLayoutConfig>((ref) {
      // Watch active account to get account-specific layout
      final accountAsync = ref.watch(activeAccountProvider);
      final accountId = accountAsync.asData?.value?.userId;

      return HomeLayoutConfigNotifier(ref, accountId);
    });

/// Provider for visible widgets only (convenience accessor)
final visibleHomeWidgetsProvider = Provider<List<HomeWidgetConfig>>((ref) {
  final config = ref.watch(homeLayoutConfigProvider);
  return config.visibleWidgets;
});

/// Provider for edit mode state
final homeEditModeProvider = StateProvider<bool>((ref) => false);

/// Provider to check if a widget type is already added
final isWidgetTypeAddedProvider = Provider.family<bool, HomeWidgetType>((
  ref,
  type,
) {
  final config = ref.watch(homeLayoutConfigProvider);
  return config.hasWidgetType(type);
});
