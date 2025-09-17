// Shared preferences implementation of local data source.
// Provides simple key-value storage for widget configurations.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/widget_data_model.dart';
import 'home_widgets_local_datasource.dart';

class HomeWidgetsLocalDataSourceImpl implements HomeWidgetsLocalDataSource {
  const HomeWidgetsLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _widgetsKey = 'home_widgets_data';
  static const String _syncTimestampKey = 'home_widgets_sync_timestamp';

  @override
  Future<List<WidgetDataModel>> getAllWidgets(String accountId) async {
    final widgetsJson = _prefs.getString('${_widgetsKey}_$accountId');
    if (widgetsJson == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(widgetsJson);
      return jsonList
          .map((json) => WidgetDataModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list if parsing fails
      return [];
    }
  }

  @override
  Future<WidgetDataModel?> getWidget(String widgetId) async {
    // For simplicity, we need to search through all accounts
    // In a real implementation, this would be more efficient with a proper database
    final allKeys =
        _prefs.getKeys().where((key) => key.startsWith(_widgetsKey));

    for (final key in allKeys) {
      final widgetsJson = _prefs.getString(key);
      if (widgetsJson == null) continue;

      try {
        final List<dynamic> jsonList = json.decode(widgetsJson);
        final widgets = jsonList
            .map((json) =>
                WidgetDataModel.fromJson(json as Map<String, dynamic>))
            .toList();

        final widget = widgets.where((w) => w.id == widgetId).firstOrNull;
        if (widget != null) return widget;
      } catch (e) {
        continue;
      }
    }

    return null;
  }

  @override
  Future<void> storeWidget(WidgetDataModel widget) async {
    final widgets = await getAllWidgets(widget.accountId);
    widgets.add(widget);
    await _saveWidgets(widget.accountId, widgets);
  }

  @override
  Future<void> updateWidget(WidgetDataModel widget) async {
    final widgets = await getAllWidgets(widget.accountId);
    final index = widgets.indexWhere((w) => w.id == widget.id);

    if (index != -1) {
      widgets[index] = widget;
      await _saveWidgets(widget.accountId, widgets);
    }
  }

  @override
  Future<void> deleteWidget(String widgetId) async {
    final allKeys =
        _prefs.getKeys().where((key) => key.startsWith(_widgetsKey));

    for (final key in allKeys) {
      final accountId = key.substring('${_widgetsKey}_'.length);
      final widgets = await getAllWidgets(accountId);
      final filtered = widgets.where((w) => w.id != widgetId).toList();

      if (filtered.length != widgets.length) {
        await _saveWidgets(accountId, filtered);
        break;
      }
    }
  }

  @override
  Future<void> clearWidgets(String accountId) async {
    await _prefs.remove('${_widgetsKey}_$accountId');
  }

  @override
  Future<DateTime?> getLastSyncTimestamp(String accountId) async {
    final timestamp = _prefs.getString('${_syncTimestampKey}_$accountId');
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  @override
  Future<void> setLastSyncTimestamp(
      String accountId, DateTime timestamp) async {
    await _prefs.setString(
        '${_syncTimestampKey}_$accountId', timestamp.toIso8601String());
  }

  Future<void> _saveWidgets(
      String accountId, List<WidgetDataModel> widgets) async {
    final jsonString = json.encode(widgets.map((w) => w.toJson()).toList());
    await _prefs.setString('${_widgetsKey}_$accountId', jsonString);
  }
}
