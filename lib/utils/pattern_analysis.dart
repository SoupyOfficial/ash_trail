import '../models/log_record.dart';

/// Peak hour data
class PeakHourData {
  final int hour; // 0-23
  final int count;
  final double percentage;

  const PeakHourData({
    required this.hour,
    required this.count,
    required this.percentage,
  });

  String get formattedHour {
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '$hour12 $period';
  }
}

/// Day of week data
class DayPatternData {
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final String dayName;
  final int count;
  final double average;

  const DayPatternData({
    required this.dayOfWeek,
    required this.dayName,
    required this.count,
    required this.average,
  });

  static String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}

/// Pattern analysis utilities for identifying usage trends
class PatternAnalysis {
  /// Analyze peak usage hours for a given period
  /// Returns peak hour info or null if no data
  static PeakHourData? getPeakHour(List<LogRecord> records) {
    if (records.isEmpty) return null;

    final hourCounts = <int, int>{};

    // Count hits per hour
    for (final record in records) {
      final hour = record.eventAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    // Find peak hour
    int peakHour = 0;
    int maxCount = 0;

    hourCounts.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        peakHour = hour;
      }
    });

    final percentage = (maxCount / records.length) * 100;

    return PeakHourData(
      hour: peakHour,
      count: maxCount,
      percentage: percentage,
    );
  }

  /// Get hour distribution for the period
  /// Useful for creating charts
  static Map<int, int> getHourDistribution(List<LogRecord> records) {
    final hourCounts = <int, int>{};

    for (final record in records) {
      final hour = record.eventAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    // Fill missing hours with 0
    for (int i = 0; i < 24; i++) {
      hourCounts.putIfAbsent(i, () => 0);
    }

    return hourCounts;
  }

  /// Analyze day-of-week patterns
  /// Returns list of day patterns sorted by count (highest first)
  static List<DayPatternData> getDayPatterns(List<LogRecord> records) {
    if (records.isEmpty) {
      return _emptyDayPatterns();
    }

    // Group by day of week
    final dayCounts = <int, List<LogRecord>>{};

    for (final record in records) {
      final dayOfWeek = record.eventAt.weekday; // 1=Monday, 7=Sunday
      dayCounts.putIfAbsent(dayOfWeek, () => []);
      dayCounts[dayOfWeek]!.add(record);
    }

    // Calculate statistics per day
    final dayPatterns = <DayPatternData>[];

    for (int day = 1; day <= 7; day++) {
      final recordsForDay = dayCounts[day] ?? [];
      final count = recordsForDay.length;

      // Calculate average (count / number of weeks this day appears)
      // For simplicity, we use count directly; average is same as count for single week
      final average = count.toDouble();

      dayPatterns.add(
        DayPatternData(
          dayOfWeek: day,
          dayName: DayPatternData.getDayName(day),
          count: count,
          average: average,
        ),
      );
    }

    // Sort by count (descending)
    dayPatterns.sort((a, b) => b.count.compareTo(a.count));

    return dayPatterns;
  }

  /// Get detailed day patterns over multiple weeks
  /// More accurate average calculation
  static List<DayPatternData> getDayPatternsDetailed(List<LogRecord> records) {
    if (records.isEmpty) {
      return _emptyDayPatterns();
    }

    // Find date range
    DateTime earliest = records.first.eventAt;
    DateTime latest = records.last.eventAt;

    for (final record in records) {
      if (record.eventAt.isBefore(earliest)) {
        earliest = record.eventAt;
      }
      if (record.eventAt.isAfter(latest)) {
        latest = record.eventAt;
      }
    }

    final daysBetween = latest.difference(earliest).inDays + 1;
    final weeksInRange = daysBetween / 7.0;

    // Group by day of week and count
    final dayCounts = <int, int>{};

    for (final record in records) {
      final dayOfWeek = record.eventAt.weekday;
      dayCounts[dayOfWeek] = (dayCounts[dayOfWeek] ?? 0) + 1;
    }

    // Calculate average per week for each day
    final dayPatterns = <DayPatternData>[];

    for (int day = 1; day <= 7; day++) {
      final count = dayCounts[day] ?? 0;
      final average = count / weeksInRange;

      dayPatterns.add(
        DayPatternData(
          dayOfWeek: day,
          dayName: DayPatternData.getDayName(day),
          count: count,
          average: average,
        ),
      );
    }

    // Sort by average (descending)
    dayPatterns.sort((a, b) => b.average.compareTo(a.average));

    return dayPatterns;
  }

  /// Get weekday vs weekend comparison
  static ({double weekdayAvg, double weekendAvg, String trend})
  getWeekdayWeekendComparison(List<LogRecord> records) {
    final dayPatterns = getDayPatternsDetailed(records);

    // Weekday: Monday-Friday (days 1-5)
    // Weekend: Saturday-Sunday (days 6-7)
    final weekdayDays = dayPatterns.where((d) => d.dayOfWeek <= 5).toList();
    final weekendDays = dayPatterns.where((d) => d.dayOfWeek > 5).toList();

    final weekdayAvg =
        weekdayDays.isEmpty
            ? 0.0
            : weekdayDays.fold<double>(0, (sum, d) => sum + d.average) /
                weekdayDays.length;
    final weekendAvg =
        weekendDays.isEmpty
            ? 0.0
            : weekendDays.fold<double>(0, (sum, d) => sum + d.average) /
                weekendDays.length;

    String trend = '→';
    if (weekendAvg > weekdayAvg * 1.1) {
      trend = 'weekends higher';
    } else if (weekdayAvg > weekendAvg * 1.1) {
      trend = 'weekdays higher';
    }

    return (weekdayAvg: weekdayAvg, weekendAvg: weekendAvg, trend: trend);
  }

  /// Helper: return empty day patterns for all 7 days
  static List<DayPatternData> _emptyDayPatterns() {
    return [
      DayPatternData(dayOfWeek: 1, dayName: 'Monday', count: 0, average: 0),
      DayPatternData(dayOfWeek: 2, dayName: 'Tuesday', count: 0, average: 0),
      DayPatternData(dayOfWeek: 3, dayName: 'Wednesday', count: 0, average: 0),
      DayPatternData(dayOfWeek: 4, dayName: 'Thursday', count: 0, average: 0),
      DayPatternData(dayOfWeek: 5, dayName: 'Friday', count: 0, average: 0),
      DayPatternData(dayOfWeek: 6, dayName: 'Saturday', count: 0, average: 0),
      DayPatternData(dayOfWeek: 7, dayName: 'Sunday', count: 0, average: 0),
    ];
  }
}
