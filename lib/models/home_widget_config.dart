import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../widgets/home_widgets/widget_catalog.dart';

/// Configuration for a single home widget instance
class HomeWidgetConfig {
  /// Unique instance ID (allows multiple widgets of same type)
  final String id;

  /// The type of widget
  final HomeWidgetType type;

  /// Whether the widget is visible
  final bool isVisible;

  /// Display order (lower = higher on screen)
  final int order;

  /// Widget-specific settings (optional)
  /// Examples:
  /// - recentEntries: { "count": 5 }
  /// - durationTrend: { "days": 7 }
  final Map<String, dynamic>? settings;

  const HomeWidgetConfig({
    required this.id,
    required this.type,
    this.isVisible = true,
    required this.order,
    this.settings,
  });

  /// Create a new widget config with generated ID
  factory HomeWidgetConfig.create({
    required HomeWidgetType type,
    required int order,
    bool isVisible = true,
    Map<String, dynamic>? settings,
  }) {
    return HomeWidgetConfig(
      id: const Uuid().v4(),
      type: type,
      isVisible: isVisible,
      order: order,
      settings: settings,
    );
  }

  /// Get a setting value with type safety
  T? getSetting<T>(String key) {
    if (settings == null) return null;
    final value = settings![key];
    if (value is T) return value;
    return null;
  }

  /// Copy with new values
  HomeWidgetConfig copyWith({
    String? id,
    HomeWidgetType? type,
    bool? isVisible,
    int? order,
    Map<String, dynamic>? settings,
  }) {
    return HomeWidgetConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
      settings: settings ?? this.settings,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'isVisible': isVisible,
      'order': order,
      if (settings != null) 'settings': settings,
    };
  }

  /// Create from JSON
  factory HomeWidgetConfig.fromJson(Map<String, dynamic> json) {
    return HomeWidgetConfig(
      id: json['id'] as String,
      type: HomeWidgetType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => HomeWidgetType.timeSinceLastHit,
      ),
      isVisible: json['isVisible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeWidgetConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Complete home layout configuration for a user/account
class HomeLayoutConfig {
  /// List of widget configurations in display order
  final List<HomeWidgetConfig> widgets;

  /// Schema version for migration support
  final int version;

  const HomeLayoutConfig({
    required this.widgets,
    this.version = 1,
  });

  /// Create default configuration for new users
  factory HomeLayoutConfig.defaultConfig() {
    final defaultTypes = WidgetCatalog.defaultWidgets;
    return HomeLayoutConfig(
      widgets: defaultTypes.asMap().entries.map((entry) {
        return HomeWidgetConfig.create(
          type: entry.value,
          order: entry.key,
        );
      }).toList(),
    );
  }

  /// Get visible widgets sorted by order
  List<HomeWidgetConfig> get visibleWidgets {
    return widgets
        .where((w) => w.isVisible)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Check if a widget type is already in the layout
  bool hasWidgetType(HomeWidgetType type) {
    return widgets.any((w) => w.type == type);
  }

  /// Add a new widget
  HomeLayoutConfig addWidget(HomeWidgetType type, {Map<String, dynamic>? settings}) {
    final maxOrder = widgets.isEmpty
        ? -1
        : widgets.map((w) => w.order).reduce((a, b) => a > b ? a : b);
    
    final newWidget = HomeWidgetConfig.create(
      type: type,
      order: maxOrder + 1,
      settings: settings,
    );

    return HomeLayoutConfig(
      widgets: [...widgets, newWidget],
      version: version,
    );
  }

  /// Remove a widget by ID
  HomeLayoutConfig removeWidget(String widgetId) {
    return HomeLayoutConfig(
      widgets: widgets.where((w) => w.id != widgetId).toList(),
      version: version,
    );
  }

  /// Update a widget's visibility
  HomeLayoutConfig setWidgetVisibility(String widgetId, bool isVisible) {
    return HomeLayoutConfig(
      widgets: widgets.map((w) {
        if (w.id == widgetId) {
          return w.copyWith(isVisible: isVisible);
        }
        return w;
      }).toList(),
      version: version,
    );
  }

  /// Reorder widgets after drag-and-drop
  HomeLayoutConfig reorder(int oldIndex, int newIndex) {
    final visible = visibleWidgets;
    if (oldIndex < 0 || oldIndex >= visible.length) return this;
    if (newIndex < 0 || newIndex > visible.length) return this;

    // Adjust for removal
    if (newIndex > oldIndex) newIndex--;

    final movedWidget = visible.removeAt(oldIndex);
    visible.insert(newIndex, movedWidget);

    // Update orders for visible widgets
    final updatedVisible = visible.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key);
    }).toList();

    // Merge back with hidden widgets (keep their relative order)
    final hidden = widgets.where((w) => !w.isVisible).toList();
    final maxVisibleOrder = updatedVisible.isEmpty ? -1 : updatedVisible.length - 1;
    final updatedHidden = hidden.asMap().entries.map((entry) {
      return entry.value.copyWith(order: maxVisibleOrder + 1 + entry.key);
    }).toList();

    return HomeLayoutConfig(
      widgets: [...updatedVisible, ...updatedHidden],
      version: version,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'widgets': widgets.map((w) => w.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory HomeLayoutConfig.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 1;
    final widgetsList = json['widgets'] as List<dynamic>? ?? [];

    return HomeLayoutConfig(
      version: version,
      widgets: widgetsList
          .map((w) => HomeWidgetConfig.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Parse from JSON string
  factory HomeLayoutConfig.fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HomeLayoutConfig.fromJson(json);
    } catch (e) {
      // Return default config if parsing fails
      return HomeLayoutConfig.defaultConfig();
    }
  }
}
