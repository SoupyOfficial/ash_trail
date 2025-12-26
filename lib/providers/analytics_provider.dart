import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/range_query_spec.dart';
import '../models/enums.dart';
import '../models/daily_rollup.dart';
import '../services/analytics_service.dart';

/// Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Provider for current range query spec
final rangeQuerySpecProvider = StateProvider<RangeQuerySpec>((ref) {
  return RangeQuerySpec.week();
});

/// Provider for aggregated data based on current range spec
final aggregatedDataProvider =
    FutureProvider.family<List<AggregatedData>, String>((ref, accountId) async {
      final service = ref.read(analyticsServiceProvider);
      final spec = ref.watch(rangeQuerySpecProvider);

      return await service.aggregateBySpec(spec, accountId);
    });

/// Provider for time series data
final timeSeriesProvider = FutureProvider.family<List<TimeSeriesPoint>, String>(
  (ref, accountId) async {
    final service = ref.read(analyticsServiceProvider);
    final spec = ref.watch(rangeQuerySpecProvider);

    return await service.getTimeSeries(accountId: accountId, spec: spec);
  },
);

/// Provider for event type breakdown
final eventTypeBreakdownProvider = FutureProvider.family<
  Map<EventType, EventTypeStats>,
  EventTypeBreakdownParams
>((ref, params) async {
  final service = ref.read(analyticsServiceProvider);

  return await service.getEventTypeBreakdown(
    accountId: params.accountId,
    profileId: params.profileId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

/// Provider for period summary
final periodSummaryProvider =
    FutureProvider.family<PeriodSummary, PeriodSummaryParams>((
      ref,
      params,
    ) async {
      final service = ref.read(analyticsServiceProvider);

      return await service.getPeriodSummary(
        accountId: params.accountId,
        profileId: params.profileId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });

/// Provider for daily rollup
final dailyRollupProvider =
    FutureProvider.family<DailyRollup, DailyRollupParams>((ref, params) async {
      final service = ref.read(analyticsServiceProvider);

      return await service.getDailyRollup(
        accountId: params.accountId,
        profileId: params.profileId,
        date: params.date,
        forceRecompute: params.forceRecompute,
      );
    });

/// Provider for selected range type (for UI)
final selectedRangeTypeProvider = StateProvider<RangeType>((ref) {
  return RangeType.week;
});

/// Provider for selected group by (for UI)
final selectedGroupByProvider = StateProvider<GroupBy>((ref) {
  return GroupBy.day;
});

/// Provider for custom date range (for UI)
final customDateRangeProvider = StateProvider<DateRange?>((ref) => null);

/// Provider for event type filter (for UI)
final eventTypeFilterProvider = StateProvider<List<EventType>?>((ref) => null);

/// Provider for building a range query spec from UI state
final buildRangeQuerySpecProvider = Provider<RangeQuerySpec>((ref) {
  final rangeType = ref.watch(selectedRangeTypeProvider);
  final groupBy = ref.watch(selectedGroupByProvider);
  final customRange = ref.watch(customDateRangeProvider);
  final eventTypeFilter = ref.watch(eventTypeFilterProvider);

  if (rangeType == RangeType.custom && customRange != null) {
    return RangeQuerySpec.custom(
      startAt: customRange.start,
      endAt: customRange.end,
      groupBy: groupBy,
      eventTypes: eventTypeFilter,
    );
  }

  switch (rangeType) {
    case RangeType.today:
      return RangeQuerySpec.today(groupBy: groupBy);
    case RangeType.week:
      return RangeQuerySpec.week(groupBy: groupBy);
    case RangeType.month:
      return RangeQuerySpec.month(groupBy: groupBy);
    case RangeType.year:
      return RangeQuerySpec.year(groupBy: groupBy);
    case RangeType.ytd:
      return RangeQuerySpec.ytd(groupBy: groupBy);
    default:
      return RangeQuerySpec.week(groupBy: groupBy);
  }
});

/// Parameters for event type breakdown
class EventTypeBreakdownParams {
  final String accountId;
  final String? profileId;
  final DateTime startDate;
  final DateTime endDate;

  const EventTypeBreakdownParams({
    required this.accountId,
    this.profileId,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventTypeBreakdownParams &&
        other.accountId == accountId &&
        other.profileId == profileId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(accountId, profileId, startDate, endDate);
}

/// Parameters for period summary
class PeriodSummaryParams {
  final String accountId;
  final String? profileId;
  final DateTime startDate;
  final DateTime endDate;

  const PeriodSummaryParams({
    required this.accountId,
    this.profileId,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PeriodSummaryParams &&
        other.accountId == accountId &&
        other.profileId == profileId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(accountId, profileId, startDate, endDate);
}

/// Parameters for daily rollup
class DailyRollupParams {
  final String accountId;
  final String? profileId;
  final DateTime date;
  final bool forceRecompute;

  const DailyRollupParams({
    required this.accountId,
    this.profileId,
    required this.date,
    this.forceRecompute = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DailyRollupParams &&
        other.accountId == accountId &&
        other.profileId == profileId &&
        other.date == date &&
        other.forceRecompute == forceRecompute;
  }

  @override
  int get hashCode => Object.hash(accountId, profileId, date, forceRecompute);
}

/// Date range helper class
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}
