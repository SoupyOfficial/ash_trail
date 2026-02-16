import '../models/log_record.dart';
import '../models/enums.dart';
import '../utils/day_boundary.dart';

/// Centralized service for computing home widget metrics
/// Focuses on time and duration as primary data dimensions
class HomeMetricsService {
  // ===== SHARED FILTERING =====

  /// Apply time window and/or event type filtering in one call.
  ///
  /// [days] — restrict to the last N days (using 6am day boundary). Null = no
  /// time restriction.
  /// [eventTypes] — restrict to specific event types. Null or empty = all.
  List<LogRecord> filterRecords(
    List<LogRecord> records, {
    int? days,
    List<EventType>? eventTypes,
  }) {
    var result = records;

    if (days != null) {
      result = _filterByDays(result, days);
    }

    if (eventTypes != null && eventTypes.isNotEmpty) {
      result = result.where((r) => eventTypes.contains(r.eventType)).toList();
    }

    return result;
  }

  // ===== TIME-BASED METRICS =====

  /// Get time since the last hit
  Duration? getTimeSinceLastHit(List<LogRecord> records) {
    if (records.isEmpty) return null;

    final sorted = _getNonDeletedSorted(records);
    if (sorted.isEmpty) return null;

    return DateTime.now().difference(sorted.first.eventAt);
  }

  /// Get the most recent record
  LogRecord? getLastRecord(List<LogRecord> records) {
    final sorted = _getNonDeletedSorted(records);
    return sorted.isEmpty ? null : sorted.first;
  }

  /// Get average time gap between hits
  /// Returns null if less than 2 records
  Duration? getAverageGap(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final sorted = _getNonDeletedSorted(filtered);

    if (sorted.length < 2) return null;

    final gaps = <Duration>[];
    for (int i = 0; i < sorted.length - 1; i++) {
      gaps.add(sorted[i].eventAt.difference(sorted[i + 1].eventAt));
    }

    final totalMs = gaps.fold<int>(0, (sum, gap) => sum + gap.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ gaps.length);
  }

  /// Get average time gap for today, calculated from first hit of the day
  /// Returns null if less than 2 records today
  Duration? getAverageGapToday(List<LogRecord> records) {
    final todayRecords = _filterToday(records);
    final sorted = _getNonDeletedSorted(todayRecords);

    if (sorted.length < 2) return null;

    // sorted is newest first, so .last is the first hit of the day
    final firstHit = sorted.last.eventAt;
    final lastHit = sorted.first.eventAt;

    // Total time span from first to last hit, divided by number of gaps
    final totalSpan = lastHit.difference(firstHit);
    final numberOfGaps = sorted.length - 1;

    return Duration(milliseconds: totalSpan.inMilliseconds ~/ numberOfGaps);
  }

  /// Get longest gap between hits for a period
  ({Duration gap, DateTime startTime, DateTime endTime})? getLongestGap(
    List<LogRecord> records, {
    int? days,
  }) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final sorted = _getNonDeletedSorted(filtered);

    if (sorted.length < 2) return null;

    Duration longestGap = Duration.zero;
    DateTime? gapStart;
    DateTime? gapEnd;

    for (int i = 0; i < sorted.length - 1; i++) {
      final gap = sorted[i].eventAt.difference(sorted[i + 1].eventAt);
      if (gap > longestGap) {
        longestGap = gap;
        gapStart = sorted[i + 1].eventAt;
        gapEnd = sorted[i].eventAt;
      }
    }

    if (gapStart == null || gapEnd == null) return null;
    return (gap: longestGap, startTime: gapStart, endTime: gapEnd);
  }

  /// Get time of first hit today
  DateTime? getFirstHitToday(List<LogRecord> records) {
    final today = _filterToday(records);
    if (today.isEmpty) return null;

    final sorted = _getNonDeletedSorted(today);
    return sorted.isEmpty ? null : sorted.last.eventAt;
  }

  /// Get time of first hit yesterday
  DateTime? getFirstHitYesterday(List<LogRecord> records) {
    final yesterday = _filterYesterday(records);
    if (yesterday.isEmpty) return null;

    final sorted = _getNonDeletedSorted(yesterday);
    return sorted.isEmpty ? null : sorted.last.eventAt;
  }

  /// Get time of last hit today
  DateTime? getLastHitToday(List<LogRecord> records) {
    final today = _filterToday(records);
    if (today.isEmpty) return null;

    final sorted = _getNonDeletedSorted(today);
    return sorted.isEmpty ? null : sorted.first.eventAt;
  }

  /// Get peak hour (most active hour of day)
  ({int hour, int count, double percentage})? getPeakHour(
    List<LogRecord> records, {
    int? days,
  }) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final nonDeleted = filtered.where((r) => !r.isDeleted).toList();

    if (nonDeleted.isEmpty) return null;

    final hourCounts = <int, int>{};
    for (final record in nonDeleted) {
      final hour = record.eventAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    int peakHour = 0;
    int maxCount = 0;
    hourCounts.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        peakHour = hour;
      }
    });

    final percentage = (maxCount / nonDeleted.length) * 100;
    return (hour: peakHour, count: maxCount, percentage: percentage);
  }

  /// Get count of active hours (hours with at least one hit)
  int getActiveHoursCount(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final nonDeleted = filtered.where((r) => !r.isDeleted).toList();

    final activeHours = <int>{};
    for (final record in nonDeleted) {
      activeHours.add(record.eventAt.hour);
    }

    return activeHours.length;
  }

  /// Get active hours for today
  int getActiveHoursToday(List<LogRecord> records) {
    final today = _filterToday(records);
    return getActiveHoursCount(today);
  }

  // ===== DURATION-BASED METRICS =====

  /// Get total duration for a period
  double getTotalDuration(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    return filtered
        .where((r) => !r.isDeleted)
        .fold<double>(0, (sum, r) => sum + _getDurationInSeconds(r));
  }

  /// Get total duration today
  double getTotalDurationToday(List<LogRecord> records) {
    return getTotalDuration(_filterToday(records));
  }

  /// Today's duration accumulated up to [asOf] (default: now).
  /// Only includes records with eventAt <= asOf. Used for hour-block
  /// trend and "Total up to X" labels that update with time.
  ({
    double duration,
    String timeLabel,
    double trendVsYesterday,
    double? trendVsWeekAvg,
    int count,
  })
  getTodayDurationUpTo(List<LogRecord> records, {DateTime? asOf}) {
    final cutoff = asOf ?? DateTime.now();
    final todayStart = DayBoundary.getTodayStart();

    if (cutoff.isBefore(todayStart)) {
      return (
        duration: 0,
        timeLabel: formatTimeLabel(cutoff),
        trendVsYesterday: 0,
        trendVsWeekAvg: null,
        count: 0,
      );
    }

    final todayRecords = _filterToday(records);
    final upToRecords =
        todayRecords
            .where((r) => !r.isDeleted && !r.eventAt.isAfter(cutoff))
            .toList();
    final duration = getTotalDuration(upToRecords);
    final count = upToRecords.length;

    final yesterdayRecords = _filterYesterday(records);
    final yesterdayDuration = getTotalDuration(yesterdayRecords);

    const secondsPerDay = 24 * 60 * 60;
    final elapsed = cutoff
        .difference(todayStart)
        .inSeconds
        .clamp(0, secondsPerDay);
    final fraction = elapsed / secondsPerDay;
    final expectedByNow = yesterdayDuration * fraction;

    double trendVsYesterday = 0;
    if (expectedByNow > 0) {
      trendVsYesterday = ((duration - expectedByNow) / expectedByNow) * 100;
    }

    final weekRecords = _filterByDays(records, 7);
    final weekTotal = getTotalDuration(weekRecords);
    final weekAvgPerDay = weekTotal / 7;
    final expectedByNowWeek = weekAvgPerDay * fraction;
    double? trendVsWeekAvg;
    if (expectedByNowWeek > 0) {
      trendVsWeekAvg =
          ((duration - expectedByNowWeek) / expectedByNowWeek) * 100;
    }

    return (
      duration: duration,
      timeLabel: formatTimeLabel(cutoff),
      trendVsYesterday: trendVsYesterday,
      trendVsWeekAvg: trendVsWeekAvg,
      count: count,
    );
  }

  /// Get average duration per hit
  double? getAverageDuration(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final nonDeleted = filtered.where((r) => !r.isDeleted).toList();

    if (nonDeleted.isEmpty) return null;

    final total = nonDeleted.fold<double>(
      0,
      (sum, r) => sum + _getDurationInSeconds(r),
    );
    return total / nonDeleted.length;
  }

  /// Get average duration today
  double? getAverageDurationToday(List<LogRecord> records) {
    return getAverageDuration(_filterToday(records));
  }

  /// Get longest hit (maximum single duration)
  LogRecord? getLongestHit(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final nonDeleted = filtered.where((r) => !r.isDeleted).toList();

    if (nonDeleted.isEmpty) return null;

    return nonDeleted.reduce(
      (a, b) => _getDurationInSeconds(a) > _getDurationInSeconds(b) ? a : b,
    );
  }

  /// Get shortest hit (minimum single duration)
  LogRecord? getShortestHit(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final nonDeleted = filtered.where((r) => !r.isDeleted).toList();

    if (nonDeleted.isEmpty) return null;

    return nonDeleted.reduce(
      (a, b) => _getDurationInSeconds(a) < _getDurationInSeconds(b) ? a : b,
    );
  }

  // ===== COUNT-BASED METRICS =====

  /// Get hit count for a period
  int getHitCount(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    return filtered.where((r) => !r.isDeleted).length;
  }

  /// Get hit count today
  int getHitCountToday(List<LogRecord> records) {
    return getHitCount(_filterToday(records));
  }

  /// Get daily average hits over a period
  double getDailyAverageHits(List<LogRecord> records, {int days = 7}) {
    final filtered = _filterByDays(records, days);
    final count = filtered.where((r) => !r.isDeleted).length;

    // Count unique days with data (using 6am day boundary)
    final daysWithData = <int>{};
    final todayStart = DayBoundary.getTodayStart();

    for (final record in filtered.where((r) => !r.isDeleted)) {
      final recordDayStart = DayBoundary.getDayStart(record.eventAt);
      final dayOffset = todayStart.difference(recordDayStart).inDays;
      if (dayOffset >= 0 && dayOffset < days) {
        daysWithData.add(dayOffset);
      }
    }

    final activeDays = daysWithData.isEmpty ? 1 : daysWithData.length;
    return count / activeDays;
  }

  /// Get hits per active hour
  double? getHitsPerActiveHour(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final hitCount = getHitCount(filtered);
    final activeHours = getActiveHoursCount(filtered);

    if (activeHours == 0) return null;
    return hitCount / activeHours;
  }

  // ===== COMPARISON METRICS =====

  /// Compare a metric between two periods
  ({double current, double previous, double percentChange}) comparePeriods({
    required List<LogRecord> records,
    required String metric,
    required int currentDays,
    required int previousDays,
  }) {
    // Use 6am day boundary for more natural period comparisons
    // Current period
    final currentStart = DayBoundary.getDayStartDaysAgo(currentDays - 1);
    final currentRecords =
        records
            .where(
              (r) =>
                  !r.isDeleted &&
                  r.eventAt.isAfter(
                    currentStart.subtract(const Duration(seconds: 1)),
                  ),
            )
            .toList();

    // Previous period
    final previousStart = currentStart.subtract(Duration(days: previousDays));
    final previousEnd = currentStart.subtract(const Duration(seconds: 1));
    final previousRecords =
        records
            .where(
              (r) =>
                  !r.isDeleted &&
                  r.eventAt.isAfter(
                    previousStart.subtract(const Duration(seconds: 1)),
                  ) &&
                  r.eventAt.isBefore(
                    previousEnd.add(const Duration(seconds: 1)),
                  ),
            )
            .toList();

    double current = 0;
    double previous = 0;

    switch (metric) {
      case 'count':
        current = currentRecords.length.toDouble();
        previous = previousRecords.length.toDouble();
        break;
      case 'duration':
        current = getTotalDuration(currentRecords);
        previous = getTotalDuration(previousRecords);
        break;
      case 'avgDuration':
        current = getAverageDuration(currentRecords) ?? 0;
        previous = getAverageDuration(previousRecords) ?? 0;
        break;
    }

    final percentChange =
        previous > 0
            ? ((current - previous) / previous) * 100
            : (current > 0 ? 100.0 : 0.0);

    return (current: current, previous: previous, percentChange: percentChange);
  }

  /// Get today vs yesterday comparison
  ({
    int todayCount,
    int yesterdayCount,
    double todayDuration,
    double yesterdayDuration,
    double countChange,
    double durationChange,
  })
  getTodayVsYesterday(List<LogRecord> records) {
    final todayRecords = _filterToday(records);
    final yesterdayRecords = _filterYesterday(records);

    final todayCount = todayRecords.where((r) => !r.isDeleted).length;
    final yesterdayCount = yesterdayRecords.where((r) => !r.isDeleted).length;
    final todayDuration = getTotalDuration(todayRecords);
    final yesterdayDuration = getTotalDuration(yesterdayRecords);

    final countChange =
        yesterdayCount > 0
            ? ((todayCount - yesterdayCount) / yesterdayCount) * 100
            : (todayCount > 0 ? 100.0 : 0.0);
    final durationChange =
        yesterdayDuration > 0
            ? ((todayDuration - yesterdayDuration) / yesterdayDuration) * 100
            : (todayDuration > 0 ? 100.0 : 0.0);

    return (
      todayCount: todayCount,
      yesterdayCount: yesterdayCount,
      todayDuration: todayDuration,
      yesterdayDuration: yesterdayDuration,
      countChange: countChange,
      durationChange: durationChange,
    );
  }

  /// Get weekday vs weekend comparison
  ({
    double weekdayAvgCount,
    double weekendAvgCount,
    double weekdayAvgDuration,
    double weekendAvgDuration,
  })
  getWeekdayVsWeekend(List<LogRecord> records, {int days = 7}) {
    final filtered = _filterByDays(records, days);
    final nonDeleted = filtered.where((r) => !r.isDeleted).toList();

    final weekdayRecords =
        nonDeleted.where((r) => r.eventAt.weekday <= 5).toList();
    final weekendRecords =
        nonDeleted.where((r) => r.eventAt.weekday > 5).toList();

    // Count unique weekdays and weekend days (using 6am day boundary)
    final weekdayDays = <int>{};
    final weekendDays = <int>{};
    final todayStart = DayBoundary.getTodayStart();

    for (int i = 0; i < days; i++) {
      final day = todayStart.subtract(Duration(days: i));
      if (day.weekday <= 5) {
        weekdayDays.add(i);
      } else {
        weekendDays.add(i);
      }
    }

    final weekdayCount = weekdayDays.isEmpty ? 1 : weekdayDays.length;
    final weekendCount = weekendDays.isEmpty ? 1 : weekendDays.length;

    return (
      weekdayAvgCount: weekdayRecords.length / weekdayCount,
      weekendAvgCount: weekendRecords.length / weekendCount,
      weekdayAvgDuration: getTotalDuration(weekdayRecords) / weekdayCount,
      weekendAvgDuration: getTotalDuration(weekendRecords) / weekendCount,
    );
  }

  // ===== SECONDARY DATA METRICS =====

  /// Get average mood rating
  double? getAverageMood(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final withMood =
        filtered.where((r) => !r.isDeleted && r.moodRating != null).toList();

    if (withMood.isEmpty) return null;
    return withMood.map((r) => r.moodRating!).reduce((a, b) => a + b) /
        withMood.length;
  }

  /// Get average physical rating
  double? getAveragePhysical(List<LogRecord> records, {int? days}) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final withPhysical =
        filtered
            .where((r) => !r.isDeleted && r.physicalRating != null)
            .toList();

    if (withPhysical.isEmpty) return null;
    return withPhysical.map((r) => r.physicalRating!).reduce((a, b) => a + b) /
        withPhysical.length;
  }

  /// Get top reasons
  List<({LogReason reason, int count})> getTopReasons(
    List<LogRecord> records, {
    int? days,
    int limit = 3,
  }) {
    final filtered = days != null ? _filterByDays(records, days) : records;
    final reasonCounts = <LogReason, int>{};

    for (final record in filtered.where((r) => !r.isDeleted)) {
      if (record.reasons != null) {
        for (final reason in record.reasons!) {
          reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
        }
      }
    }

    final sorted =
        reasonCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(limit)
        .map((e) => (reason: e.key, count: e.value))
        .toList();
  }

  // ===== HELPER METHODS =====

  /// Get non-deleted records sorted by eventAt (newest first)
  List<LogRecord> _getNonDeletedSorted(List<LogRecord> records) {
    return records.where((r) => !r.isDeleted).toList()
      ..sort((a, b) => b.eventAt.compareTo(a.eventAt));
  }

  /// Filter records to today only (using 6am day boundary)
  List<LogRecord> _filterToday(List<LogRecord> records) {
    final todayStart = DayBoundary.getTodayStart();
    return records
        .where(
          (r) =>
              r.eventAt.isAfter(
                todayStart.subtract(const Duration(seconds: 1)),
              ) ||
              r.eventAt.isAtSameMomentAs(todayStart),
        )
        .toList();
  }

  /// Filter records to yesterday only (using 6am day boundary)
  List<LogRecord> _filterYesterday(List<LogRecord> records) {
    final todayStart = DayBoundary.getTodayStart();
    final yesterdayStart = DayBoundary.getYesterdayStart();
    return records
        .where(
          (r) =>
              (r.eventAt.isAfter(
                    yesterdayStart.subtract(const Duration(seconds: 1)),
                  ) ||
                  r.eventAt.isAtSameMomentAs(yesterdayStart)) &&
              r.eventAt.isBefore(todayStart),
        )
        .toList();
  }

  /// Filter records to last N days (using 6am day boundary)
  List<LogRecord> _filterByDays(List<LogRecord> records, int days) {
    final startDate = DayBoundary.getDayStartDaysAgo(days - 1);
    return records
        .where(
          (r) =>
              r.eventAt.isAfter(
                startDate.subtract(const Duration(seconds: 1)),
              ) ||
              r.eventAt.isAtSameMomentAs(startDate),
        )
        .toList();
  }

  /// Get duration in seconds regardless of unit
  double _getDurationInSeconds(LogRecord record) {
    switch (record.unit) {
      case Unit.seconds:
        return record.duration;
      case Unit.minutes:
        return record.duration * 60;
      default:
        return record.duration;
    }
  }

  // ===== FORMATTING HELPERS =====

  /// Format duration to readable string
  static String formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final secs = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Format Duration object to readable string
  static String formatDurationObject(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format hour to 12-hour format
  static String formatHour(int hour) {
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '$hour12 $period';
  }

  /// Format time for "Total up to X" label (e.g. "3pm", "10am")
  static String formatTimeLabel(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour < 12 ? 'am' : 'pm';
    return '$hour12$period';
  }

  /// Format time as relative ("2h ago", "Just now", etc.)
  static String formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w ago';
    }
  }
}
