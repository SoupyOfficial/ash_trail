// Remote data source interface for widget data synchronization.
// Defines contract for remote API operations.

import '../models/widget_data_model.dart';

abstract class HomeWidgetsRemoteDataSource {
  /// Fetches all widget configurations for the given account from remote server
  Future<List<WidgetDataModel>> getAllWidgets(String accountId);

  /// Fetches a specific widget by ID from remote server
  Future<WidgetDataModel> getWidget(String widgetId);

  /// Creates a new widget configuration on remote server
  Future<WidgetDataModel> createWidget(WidgetDataModel widget);

  /// Updates a widget configuration on remote server
  Future<WidgetDataModel> updateWidget(WidgetDataModel widget);

  /// Removes a widget configuration from remote server
  Future<void> deleteWidget(String widgetId);

  /// Fetches current hit count for today for the given account
  Future<int> getTodayHitCount(String accountId);

  /// Fetches current streak for the given account
  Future<int> getCurrentStreak(String accountId);

  /// Syncs widget data with current app statistics
  Future<Map<String, dynamic>> getWidgetStats(String accountId);
}
