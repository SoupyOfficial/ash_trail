// Data source for persisting live activity recording sessions.
// Uses SharedPreferences for local storage.

import 'dart:async';
import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/failures/app_failure.dart';
import '../models/live_activity_model.dart';

class LiveActivityDataSource {
  LiveActivityDataSource(this._prefs);

  final SharedPreferences _prefs;
  
  static const String _currentActivityKey = 'current_live_activity';
  static const String _activityHistoryKey = 'live_activity_history';
  
  // Stream controller for watching current activity changes
  final _currentActivityController = StreamController<LiveActivityModel?>.broadcast();

  /// Get the current active recording session, if any.
  Either<AppFailure, LiveActivityModel?> getCurrentActivity() {
    try {
      final jsonString = _prefs.getString(_currentActivityKey);
      if (jsonString == null) {
        return right(null);
      }
      
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final model = LiveActivityModel.fromJson(jsonMap);
      return right(model);
    } catch (e) {
      return left(AppFailure.cache(
        message: 'Failed to retrieve current activity',
      ));
    }
  }

  /// Save the current activity.
  Future<Either<AppFailure, void>> saveCurrentActivity(LiveActivityModel activity) async {
    try {
      final jsonString = jsonEncode(activity.toJson());
      final success = await _prefs.setString(_currentActivityKey, jsonString);
      
      if (!success) {
        return left(AppFailure.cache(
          message: 'Failed to save current activity',
        ));
      }
      
      // Notify stream listeners
      _currentActivityController.add(activity);
      return right(null);
    } catch (e) {
      return left(AppFailure.cache(
        message: 'Failed to save current activity',
      ));
    }
  }

  /// Clear the current activity.
  Future<Either<AppFailure, void>> clearCurrentActivity() async {
    try {
      final success = await _prefs.remove(_currentActivityKey);
      
      if (!success) {
        return left(AppFailure.cache(
          message: 'Failed to clear current activity',
        ));
      }
      
      // Notify stream listeners
      _currentActivityController.add(null);
      return right(null);
    } catch (e) {
      return left(AppFailure.cache(
        message: 'Failed to clear current activity',
      ));
    }
  }

  /// Get an activity by ID from history.
  Either<AppFailure, LiveActivityModel?> getActivityById(String id) {
    try {
      // First check if it's the current activity
      final currentResult = getCurrentActivity();
      final currentActivity = currentResult.fold(
        (failure) => null,
        (activity) => activity,
      );
      
      if (currentActivity?.id == id) {
        return right(currentActivity);
      }
      
      // Check activity history
      final historyJsonString = _prefs.getString(_activityHistoryKey);
      if (historyJsonString == null) {
        return right(null);
      }
      
      final historyList = jsonDecode(historyJsonString) as List<dynamic>;
      final activities = historyList
          .cast<Map<String, dynamic>>()
          .map((json) => LiveActivityModel.fromJson(json))
          .toList();
      
      final activity = activities.where((a) => a.id == id).firstOrNull;
      return right(activity);
    } catch (e) {
      return left(AppFailure.cache(
        message: 'Failed to retrieve activity by ID',
      ));
    }
  }

  /// Add an activity to history.
  Future<Either<AppFailure, void>> addToHistory(LiveActivityModel activity) async {
    try {
      // Get existing history
      final historyJsonString = _prefs.getString(_activityHistoryKey);
      List<Map<String, dynamic>> historyList = [];
      
      if (historyJsonString != null) {
        final decodedList = jsonDecode(historyJsonString) as List<dynamic>;
        historyList = decodedList.cast<Map<String, dynamic>>();
      }
      
      // Add new activity (replace if exists with same ID)
      historyList.removeWhere((json) => json['id'] == activity.id);
      historyList.add(activity.toJson());
      
      // Keep only last 100 activities to prevent unbounded growth
      if (historyList.length > 100) {
        historyList = historyList.sublist(historyList.length - 100);
      }
      
      // Save updated history
      final updatedJsonString = jsonEncode(historyList);
      final success = await _prefs.setString(_activityHistoryKey, updatedJsonString);
      
      if (!success) {
        return left(AppFailure.cache(
          message: 'Failed to save activity to history',
        ));
      }
      
      return right(null);
    } catch (e) {
      return left(AppFailure.cache(
        message: 'Failed to save activity to history',
      ));
    }
  }

  /// Stream of current activity changes.
  Stream<LiveActivityModel?> watchCurrentActivity() {
    return _currentActivityController.stream;
  }

  /// Clean up resources.
  void dispose() {
    _currentActivityController.close();
  }
}