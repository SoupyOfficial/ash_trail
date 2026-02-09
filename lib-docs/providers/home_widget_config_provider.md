# home_widget_config_provider

> **Source:** `lib/providers/home_widget_config_provider.dart`

## Purpose

Riverpod state management for the home dashboard widget layout. Provides account-specific widget configuration loaded from/saved to SharedPreferences. Includes a `HomeLayoutConfigNotifier` for add, remove, reorder, visibility toggle, settings update, and reset operations. Also exposes convenience providers for visible widgets, edit mode, and widget-type-exists checks.

## Dependencies

- `package:flutter_riverpod/flutter_riverpod.dart` — StateNotifierProvider, Provider, StateProvider
- `package:shared_preferences/shared_preferences.dart` — Persistence backend
- `../models/home_widget_config.dart` — HomeWidgetConfig, HomeLayoutConfig models
- `../widgets/home_widgets/widget_catalog.dart` — WidgetCatalog, HomeWidgetType
- `account_provider.dart` — activeAccountProvider for per-account layout

## Pseudo-Code

### Constants

```
CONSTANT _homeLayoutKeyPrefix = "home_layout_"

FUNCTION _getStorageKey(accountId: String?) -> String
  RETURN "{_homeLayoutKeyPrefix}{accountId OR 'default'}"
END
```

### Provider: sharedPreferencesProvider

```
PROVIDER sharedPreferencesProvider -> SharedPreferences
  THROW UnimplementedError
  // Must be overridden in main.dart with actual SharedPreferences instance
END
```

### Class: HomeLayoutConfigNotifier (StateNotifier\<HomeLayoutConfig\>)

```
CLASS HomeLayoutConfigNotifier EXTENDS StateNotifier<HomeLayoutConfig>

  FIELDS:
    ref: Ref
    accountId: String?

  CONSTRUCTOR(ref, accountId)
    INITIAL STATE = HomeLayoutConfig.defaultConfig()
    CALL _loadConfig()
  END

  // ── Load ──

  ASYNC FUNCTION _loadConfig() -> void
    TRY
      READ prefs from sharedPreferencesProvider
      key = _getStorageKey(accountId)
      jsonString = prefs.getString(key)

      IF jsonString != null THEN
        SET state = HomeLayoutConfig.fromJsonString(jsonString)
      ELSE
        SET state = HomeLayoutConfig.defaultConfig()
        AWAIT _saveConfig()    // persist default for first-time user
      END IF
    CATCH
      SET state = HomeLayoutConfig.defaultConfig()  // safe fallback
    END TRY
  END FUNCTION

  // ── Save ──

  ASYNC FUNCTION _saveConfig() -> void
    TRY
      READ prefs from sharedPreferencesProvider
      key = _getStorageKey(accountId)
      AWAIT prefs.setString(key, state.toJsonString())
    CATCH
      // silently fail on save error
    END TRY
  END FUNCTION

  // ── Add Widget ──

  ASYNC FUNCTION addWidget(type: HomeWidgetType, settings?: Map) -> void
    entry = WidgetCatalog.getEntry(type)
    IF NOT entry.allowMultiple AND state.hasWidgetType(type) THEN
      RETURN    // widget type already exists, skip
    END IF
    SET state = state.addWidget(type, settings)
    AWAIT _saveConfig()
  END FUNCTION

  // ── Remove Widget ──

  ASYNC FUNCTION removeWidget(widgetId: String) -> void
    SET state = state.removeWidget(widgetId)
    AWAIT _saveConfig()
  END FUNCTION

  // ── Toggle Visibility ──

  ASYNC FUNCTION toggleVisibility(widgetId: String) -> void
    FIND widget by id (throw if not found)
    SET state = state.setWidgetVisibility(widgetId, !widget.isVisible)
    AWAIT _saveConfig()
  END FUNCTION

  // ── Set Visibility ──

  ASYNC FUNCTION setVisibility(widgetId: String, isVisible: bool) -> void
    SET state = state.setWidgetVisibility(widgetId, isVisible)
    AWAIT _saveConfig()
  END FUNCTION

  // ── Reorder ──

  ASYNC FUNCTION reorder(oldIndex: int, newIndex: int) -> void
    SET state = state.reorder(oldIndex, newIndex)
    AWAIT _saveConfig()
  END FUNCTION

  // ── Reset to Default ──

  ASYNC FUNCTION resetToDefault() -> void
    SET state = HomeLayoutConfig.defaultConfig()
    AWAIT _saveConfig()
  END FUNCTION

  // ── Update Widget Settings ──

  ASYNC FUNCTION updateWidgetSettings(widgetId: String, settings: Map) -> void
    MAP widgets: IF id matches THEN merge settings ELSE keep
    SET state = new HomeLayoutConfig(updatedWidgets, version)
    AWAIT _saveConfig()
  END FUNCTION

END CLASS
```

### Derived Providers

```
STATE_NOTIFIER_PROVIDER homeLayoutConfigProvider -> HomeLayoutConfig
  WATCH activeAccountProvider to get accountId
  RETURN new HomeLayoutConfigNotifier(ref, accountId)
END

PROVIDER visibleHomeWidgetsProvider -> List<HomeWidgetConfig>
  WATCH homeLayoutConfigProvider
  RETURN config.visibleWidgets
END

STATE_PROVIDER homeEditModeProvider -> bool
  INITIAL VALUE = false
END

PROVIDER.FAMILY isWidgetTypeAddedProvider(type: HomeWidgetType) -> bool
  WATCH homeLayoutConfigProvider
  RETURN config.hasWidgetType(type)
END
```
