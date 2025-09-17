// Local data source interface for widget data storage.
// Defines contract for local persistence operations.

import '../models/widget_data_model.dart';

abstract class HomeWidgetsLocalDataSource {
  /// Retrieves all widget configurations for the given account from local storage
  Future<List<WidgetDataModel>> getAllWidgets(String accountId);

  /// Retrieves a specific widget by ID from local storage
  Future<WidgetDataModel?> getWidget(String widgetId);

  /// Stores a widget configuration in local storage
  Future<void> storeWidget(WidgetDataModel widget);

  /// Updates a widget configuration in local storage
  Future<void> updateWidget(WidgetDataModel widget);

  /// Removes a widget configuration from local storage
  Future<void> deleteWidget(String widgetId);

  /// Clears all widget data for an account (useful for account logout)
  Future<void> clearWidgets(String accountId);

  /// Gets the last sync timestamp for widget data
  Future<DateTime?> getLastSyncTimestamp(String accountId);

  /// Stores the last sync timestamp for widget data
  Future<void> setLastSyncTimestamp(String accountId, DateTime timestamp);
}
