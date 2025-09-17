// Riverpod providers for home widgets feature.
// Manages state and dependencies for widget data.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/home_widgets_repository.dart';
import '../../domain/usecases/get_all_widgets_usecase.dart';
import '../../domain/usecases/create_widget_usecase.dart';
import '../../domain/usecases/update_widget_stats_usecase.dart';
import '../../domain/usecases/refresh_widget_data_usecase.dart';
import '../../data/repositories/home_widgets_repository_impl.dart';
import '../../data/datasources/home_widgets_local_datasource.dart';
import '../../data/datasources/home_widgets_local_datasource_impl.dart';
import '../../data/datasources/home_widgets_remote_datasource.dart';

// For now, create a mock remote data source since we don't have Firestore/API setup yet
import '../../data/models/widget_data_model.dart';

// Mock implementation for demonstration - replace with real API implementation later
class HomeWidgetsMockRemoteDataSource implements HomeWidgetsRemoteDataSource {
  @override
  Future<List<WidgetDataModel>> getAllWidgets(String accountId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<WidgetDataModel> getWidget(String widgetId) async {
    throw Exception('Widget not found');
  }

  @override
  Future<WidgetDataModel> createWidget(WidgetDataModel widget) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return widget;
  }

  @override
  Future<WidgetDataModel> updateWidget(WidgetDataModel widget) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return widget;
  }

  @override
  Future<void> deleteWidget(String widgetId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<int> getTodayHitCount(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock data - in real implementation this would come from smoke logs
    return DateTime.now().day % 10; // Vary by day for demo
  }

  @override
  Future<int> getCurrentStreak(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Mock data - in real implementation this would be calculated from logs
    return DateTime.now().weekday; // Vary by weekday for demo
  }

  @override
  Future<Map<String, dynamic>> getWidgetStats(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'todayHitCount': DateTime.now().day % 10,
      'currentStreak': DateTime.now().weekday,
    };
  }
}

// Data source providers
final homeWidgetsLocalDataSourceProvider =
    Provider<HomeWidgetsLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HomeWidgetsLocalDataSourceImpl(prefs);
});

final homeWidgetsRemoteDataSourceProvider =
    Provider<HomeWidgetsRemoteDataSource>((ref) {
  // TODO: Replace with real implementation when API is available
  return HomeWidgetsMockRemoteDataSource();
});

// Repository provider
final homeWidgetsRepositoryProvider = Provider<HomeWidgetsRepository>((ref) {
  final localDataSource = ref.watch(homeWidgetsLocalDataSourceProvider);
  final remoteDataSource = ref.watch(homeWidgetsRemoteDataSourceProvider);

  return HomeWidgetsRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

// Use case providers
final getAllWidgetsUseCaseProvider = Provider<GetAllWidgetsUseCase>((ref) {
  final repository = ref.watch(homeWidgetsRepositoryProvider);
  return GetAllWidgetsUseCase(repository);
});

final createWidgetUseCaseProvider = Provider<CreateWidgetUseCase>((ref) {
  final repository = ref.watch(homeWidgetsRepositoryProvider);
  return CreateWidgetUseCase(repository);
});

final updateWidgetStatsUseCaseProvider =
    Provider<UpdateWidgetStatsUseCase>((ref) {
  final repository = ref.watch(homeWidgetsRepositoryProvider);
  return UpdateWidgetStatsUseCase(repository);
});

final refreshWidgetDataUseCaseProvider =
    Provider<RefreshWidgetDataUseCase>((ref) {
  final repository = ref.watch(homeWidgetsRepositoryProvider);
  return RefreshWidgetDataUseCase(repository);
});

// Shared preferences provider (should be defined in core but adding here for completeness)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'SharedPreferences must be overridden at app startup');
});
