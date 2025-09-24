import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../capture_hit/presentation/providers/smoke_log_providers.dart';
import '../../domain/entities/chart_data_point.dart';
import '../../domain/entities/time_series_chart.dart';
import '../../domain/repositories/charts_time_series_repository.dart';
import '../../domain/usecases/get_chart_data_points_usecase.dart';
import '../../domain/usecases/generate_chart_usecase.dart';
import '../../domain/usecases/check_data_availability_usecase.dart';
import '../../data/repositories/charts_time_series_repository_impl.dart';
import '../../data/datasources/charts_time_series_local_datasource_impl.dart';
import '../../../../core/failures/app_failure.dart';

// Sentinel value for copyWith methods to distinguish between "not passed" and "explicitly null"
const _noChange = Object();

// Repository dependency providers
final chartsTimeSeriesRepositoryProvider =
    Provider<ChartsTimeSeriesRepository>((ref) {
  return ChartsTimeSeriesRepositoryImpl(
    localDataSource: ChartsTimeSeriesLocalDataSourceImpl(
      smokeLogDataSource: ref.watch(smokeLogLocalDataSourceProvider),
    ),
  );
});

// Use case providers
final getChartDataPointsUseCaseProvider =
    Provider<GetChartDataPointsUseCase>((ref) {
  return GetChartDataPointsUseCase(
    repository: ref.watch(chartsTimeSeriesRepositoryProvider),
  );
});

final generateChartUseCaseProvider = Provider<GenerateChartUseCase>((ref) {
  return GenerateChartUseCase(
    repository: ref.watch(chartsTimeSeriesRepositoryProvider),
  );
});

final checkDataAvailabilityUseCaseProvider =
    Provider<CheckDataAvailabilityUseCase>((ref) {
  return CheckDataAvailabilityUseCase(
    repository: ref.watch(chartsTimeSeriesRepositoryProvider),
  );
});

// Chart configuration state notifier
class ChartConfigNotifier extends StateNotifier<ChartConfig> {
  ChartConfigNotifier(String accountId)
      : super(ChartConfig(
          accountId: accountId,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          smoothing: ChartSmoothing.none,
          smoothingWindow: 7,
          visibleTags: null,
        ));

  void setAggregation(ChartAggregation aggregation) {
    state = state.copyWith(aggregation: aggregation);
  }

  void setMetric(ChartMetric metric) {
    state = state.copyWith(metric: metric);
  }

  void setSmoothing(ChartSmoothing smoothing) {
    state = state.copyWith(smoothing: smoothing);
  }

  void setDateRange(DateTime startDate, DateTime endDate) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
    );
  }

  void setSmoothingWindow(int window) {
    state = state.copyWith(smoothingWindow: window);
  }

  void setVisibleTags(List<String>? tags) {
    state = state.copyWith(visibleTags: tags);
  }
}

final chartConfigNotifierProvider =
    StateNotifierProvider.family<ChartConfigNotifier, ChartConfig, String>(
        (ref, accountId) {
  return ChartConfigNotifier(accountId);
});

// Chart data providers
final chartDataProvider =
    FutureProvider.family<Either<AppFailure, TimeSeriesChart>, String>(
        (ref, accountId) async {
  final config = ref.watch(chartConfigNotifierProvider(accountId));
  final useCase = ref.watch(generateChartUseCaseProvider);

  return useCase(GenerateChartParams(config: config));
});

final chartDataPointsProvider =
    FutureProvider.family<Either<AppFailure, List<ChartDataPoint>>, String>(
        (ref, accountId) async {
  final config = ref.watch(chartConfigNotifierProvider(accountId));
  final useCase = ref.watch(getChartDataPointsUseCaseProvider);

  return useCase(config);
});

final hasChartDataProvider =
    FutureProvider.family<bool, String>((ref, accountId) async {
  final config = ref.watch(chartConfigNotifierProvider(accountId));
  final useCase = ref.watch(checkDataAvailabilityUseCaseProvider);

  final params = CheckDataAvailabilityParams(
    accountId: accountId,
    startDate: config.startDate,
    endDate: config.endDate,
    visibleTags: config.visibleTags,
  );

  final result = await useCase(params);

  return result.fold(
    (failure) => false,
    (hasData) => hasData,
  );
});

// UI state notifier with simplified models
class ChartUIStateNotifier extends StateNotifier<ChartUIState> {
  ChartUIStateNotifier()
      : super(const ChartUIState(
          selectedDataPoint: null,
          isZoomed: false,
          panOffset: 0.0,
          visibleDateRange: null,
          showLegend: true,
          showTooltip: false,
        ));

  void selectDataPoint(ChartDataPoint? dataPoint) {
    state = state.copyWith(selectedDataPoint: dataPoint);
  }

  void setZoom(bool isZoomed) {
    state = state.copyWith(isZoomed: isZoomed);
  }

  void setPanOffset(double offset) {
    state = state.copyWith(panOffset: offset);
  }

  void setVisibleDateRange(DateRange? range) {
    state = state.copyWith(visibleDateRange: range);
  }

  void toggleLegend() {
    state = state.copyWith(showLegend: !state.showLegend);
  }

  void showTooltip(bool show) {
    state = state.copyWith(showTooltip: show);
  }
}

final chartUIStateNotifierProvider =
    StateNotifierProvider<ChartUIStateNotifier, ChartUIState>((ref) {
  return ChartUIStateNotifier();
});

// Data models for UI state - simplified without Freezed for now
class ChartUIState {
  const ChartUIState({
    required this.selectedDataPoint,
    required this.isZoomed,
    required this.panOffset,
    required this.visibleDateRange,
    required this.showLegend,
    required this.showTooltip,
  });

  final ChartDataPoint? selectedDataPoint;
  final bool isZoomed;
  final double panOffset;
  final DateRange? visibleDateRange;
  final bool showLegend;
  final bool showTooltip;

  ChartUIState copyWith({
    Object? selectedDataPoint = _noChange,
    bool? isZoomed,
    double? panOffset,
    Object? visibleDateRange = _noChange,
    bool? showLegend,
    bool? showTooltip,
  }) {
    return ChartUIState(
      selectedDataPoint: selectedDataPoint == _noChange
          ? this.selectedDataPoint
          : selectedDataPoint as ChartDataPoint?,
      isZoomed: isZoomed ?? this.isZoomed,
      panOffset: panOffset ?? this.panOffset,
      visibleDateRange: visibleDateRange == _noChange
          ? this.visibleDateRange
          : visibleDateRange as DateRange?,
      showLegend: showLegend ?? this.showLegend,
      showTooltip: showTooltip ?? this.showTooltip,
    );
  }
}

class DateRange {
  const DateRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}
