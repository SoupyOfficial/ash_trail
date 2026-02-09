# home_widget_config

> **Source:** `lib/models/home_widget_config.dart`

## Purpose

Configuration models for the customizable home dashboard widget grid. `HomeWidgetConfig` represents a single widget instance (type, visibility, order, settings), while `HomeLayoutConfig` manages the full layout with add/remove/reorder/visibility operations and JSON serialization for persistence.

## Dependencies

- `dart:convert` — JSON encode/decode for persistence
- `package:uuid/uuid.dart` — UUID v4 generation for widget instance IDs
- `../widgets/home_widgets/widget_catalog.dart` — HomeWidgetType enum and WidgetCatalog defaults

## Pseudo-Code

### Class: HomeWidgetConfig (immutable)

```
CLASS HomeWidgetConfig

  FIELDS (final):
    id: String                           // unique instance ID (UUID)
    type: HomeWidgetType                 // widget type from catalog
    isVisible: bool = true               // whether shown on dashboard
    order: int                           // display position (lower = higher)
    settings: Map<String, dynamic>?      // widget-specific config (e.g., {"count": 5})

  // ── Constructor ──

  CONST CONSTRUCTOR HomeWidgetConfig({required id, required type, isVisible, required order, settings})

  // ── Factory: create ──

  FACTORY HomeWidgetConfig.create({required type, required order, isVisible, settings})
    GENERATE id = UUID v4
    RETURN HomeWidgetConfig(id, type, isVisible, order, settings)
  END FACTORY

  // ── Type-Safe Setting Access ──

  FUNCTION getSetting<T>(key: String) -> T?
    IF settings IS null THEN RETURN null
    value = settings[key]
    IF value IS T THEN RETURN value
    RETURN null
  END FUNCTION

  // ── Copy With ──

  FUNCTION copyWith({...optional fields}) -> HomeWidgetConfig
    RETURN new HomeWidgetConfig with fallback-to-this pattern
  END FUNCTION

  // ── JSON Serialization ──

  FUNCTION toJson() -> Map
    RETURN { id, type.name, isVisible, order, settings (if not null) }
  END FUNCTION

  FACTORY HomeWidgetConfig.fromJson(json: Map)
    PARSE type by matching name to HomeWidgetType values
      FALLBACK to timeSinceLastHit if unknown
    PARSE isVisible, default true
    PARSE order, default 0
    RETURN HomeWidgetConfig(...)
  END FACTORY

  // ── Equality ──

  operator == : compare by id only
  hashCode   : id.hashCode
END CLASS
```

### Class: HomeLayoutConfig (immutable)

```
CLASS HomeLayoutConfig

  FIELDS (final):
    widgets: List<HomeWidgetConfig>      // all widget configs
    version: int = 1                     // schema version for migration

  // ── Default Config ──

  FACTORY HomeLayoutConfig.defaultConfig()
    GET defaultTypes from WidgetCatalog.defaultWidgets
    CREATE HomeWidgetConfig.create for each type with order = index
    RETURN HomeLayoutConfig(widgets)
  END FACTORY

  // ── Computed Properties ──

  GETTER visibleWidgets -> List<HomeWidgetConfig>
    FILTER widgets WHERE isVisible = true
    SORT by order ascending
    RETURN sorted list
  END GETTER

  FUNCTION hasWidgetType(type: HomeWidgetType) -> bool
    RETURN widgets.any WHERE widget.type == type
  END FUNCTION

  // ── Mutation Methods (return new instances) ──

  FUNCTION addWidget(type, settings?) -> HomeLayoutConfig
    FIND maxOrder among existing widgets (or -1 if empty)
    CREATE new widget with order = maxOrder + 1
    RETURN new HomeLayoutConfig with widget appended
  END FUNCTION

  FUNCTION removeWidget(widgetId: String) -> HomeLayoutConfig
    FILTER OUT widget with matching id
    RETURN new HomeLayoutConfig with filtered list
  END FUNCTION

  FUNCTION setWidgetVisibility(widgetId, isVisible) -> HomeLayoutConfig
    MAP widgets: IF id matches THEN copyWith(isVisible) ELSE keep
    RETURN new HomeLayoutConfig
  END FUNCTION

  FUNCTION reorder(oldIndex, newIndex) -> HomeLayoutConfig
    GET visible = visibleWidgets
    VALIDATE oldIndex and newIndex bounds
      IF out of bounds THEN RETURN this (no-op)

    IF newIndex > oldIndex THEN DECREMENT newIndex (adjust for removal)

    REMOVE widget at oldIndex from visible list
    INSERT widget at newIndex

    UPDATE order for all visible widgets (order = index)

    // Merge back hidden widgets with orders after visible
    GET hidden widgets
    SET hidden orders = maxVisibleOrder + 1 + their index

    RETURN new HomeLayoutConfig([...updatedVisible, ...updatedHidden])
  END FUNCTION

  // ── JSON Serialization ──

  FUNCTION toJson() -> Map
    RETURN { version, widgets: [each widget.toJson()] }
  END FUNCTION

  FACTORY HomeLayoutConfig.fromJson(json: Map)
    PARSE version (default 1)
    PARSE widgets list, map each to HomeWidgetConfig.fromJson
    RETURN HomeLayoutConfig(widgets, version)
  END FACTORY

  FUNCTION toJsonString() -> String
    RETURN jsonEncode(toJson())
  END FUNCTION

  FACTORY HomeLayoutConfig.fromJsonString(jsonString: String)
    TRY
      PARSE jsonString -> Map
      RETURN HomeLayoutConfig.fromJson(parsed)
    CATCH error
      RETURN HomeLayoutConfig.defaultConfig()   // safe fallback
    END TRY
  END FACTORY

END CLASS
```
