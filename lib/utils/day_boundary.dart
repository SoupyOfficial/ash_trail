/// Utility class for calculating day boundaries.
///
/// This app treats 6am as the start of a new day instead of midnight.
/// This means late-night activity (e.g., 2am) is grouped with the previous
/// calendar day, aligning with natural sleep/wake cycles.
///
/// For example:
/// - 2am on Tuesday is considered "Monday" (previous day's period)
/// - 7am on Tuesday is considered "Tuesday"
class DayBoundary {
  /// The hour at which a new "logical day" begins.
  /// Default is 6am, meaning:
  /// - Times from 6:00am to 5:59am next day belong to the same logical day
  /// - A log at 2am is considered part of the previous day's activity
  static const int dayStartHour = 6;

  /// Private constructor to prevent instantiation
  DayBoundary._();

  /// Gets the start of the logical day for the given [dateTime].
  ///
  /// If [dateTime] is before [dayStartHour], returns the previous calendar
  /// day at [dayStartHour]. Otherwise, returns the current calendar day
  /// at [dayStartHour].
  ///
  /// Example:
  /// - 2am Tuesday → Monday 6am
  /// - 7am Tuesday → Tuesday 6am
  /// - 11pm Tuesday → Tuesday 6am
  static DateTime getDayStart(DateTime dateTime) {
    if (dateTime.hour < dayStartHour) {
      // Before 6am - belongs to previous day
      final previousDay = dateTime.subtract(const Duration(days: 1));
      return DateTime(previousDay.year, previousDay.month, previousDay.day, dayStartHour);
    } else {
      // 6am or later - current day
      return DateTime(dateTime.year, dateTime.month, dateTime.day, dayStartHour);
    }
  }

  /// Gets the start of today's logical day.
  ///
  /// If current time is before [dayStartHour], returns yesterday at [dayStartHour].
  static DateTime getTodayStart() {
    return getDayStart(DateTime.now());
  }

  /// Gets the start of yesterday's logical day.
  static DateTime getYesterdayStart() {
    return getTodayStart().subtract(const Duration(days: 1));
  }

  /// Gets the start of the logical day [daysAgo] days before today.
  ///
  /// [daysAgo] = 0 means today, 1 means yesterday, etc.
  static DateTime getDayStartDaysAgo(int daysAgo) {
    return getTodayStart().subtract(Duration(days: daysAgo));
  }

  /// Gets the end of the logical day for the given [dateTime].
  ///
  /// This is the instant before the next day starts (one day after day start,
  /// minus one microsecond for exclusive end boundaries).
  static DateTime getDayEnd(DateTime dateTime) {
    return getDayStart(dateTime)
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));
  }

  /// Gets the end of today's logical day.
  static DateTime getTodayEnd() {
    return getDayEnd(DateTime.now());
  }

  /// Checks if two [DateTime] values fall within the same logical day.
  static bool isSameDay(DateTime a, DateTime b) {
    final dayA = getDayStart(a);
    final dayB = getDayStart(b);
    return dayA.year == dayB.year &&
        dayA.month == dayB.month &&
        dayA.day == dayB.day;
  }

  /// Checks if [dateTime] is within today's logical day.
  static bool isToday(DateTime dateTime) {
    return isSameDay(dateTime, DateTime.now());
  }

  /// Checks if [dateTime] is within yesterday's logical day.
  static bool isYesterday(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return isSameDay(dateTime, yesterday);
  }

  /// Checks if [dateTime] is within the last [days] logical days (including today).
  ///
  /// For example, `isWithinDays(dateTime, 7)` checks if [dateTime] is within
  /// the last 7 days including today.
  static bool isWithinDays(DateTime dateTime, int days) {
    final todayStart = getTodayStart();
    final rangeStart = todayStart.subtract(Duration(days: days - 1));
    return dateTime.isAfter(rangeStart) ||
        dateTime.isAtSameMomentAs(rangeStart);
  }

  /// Gets the number of logical days between [from] and [to].
  ///
  /// Returns a positive number if [to] is after [from].
  static int daysBetween(DateTime from, DateTime to) {
    final fromStart = getDayStart(from);
    final toStart = getDayStart(to);
    return toStart.difference(fromStart).inDays;
  }

  /// Gets which logical day [dateTime] belongs to, as a calendar date.
  ///
  /// This returns a DateTime at midnight (00:00) of the calendar date
  /// that this logical day represents. Useful for grouping by date.
  ///
  /// For example:
  /// - 2am Tuesday → Monday at midnight (represents Monday)
  /// - 7am Tuesday → Tuesday at midnight (represents Tuesday)
  static DateTime getCalendarDate(DateTime dateTime) {
    final dayStart = getDayStart(dateTime);
    return DateTime(dayStart.year, dayStart.month, dayStart.day);
  }

  /// Gets the start of the logical week containing [dateTime].
  ///
  /// Weeks start on Monday at [dayStartHour].
  static DateTime getWeekStart(DateTime dateTime) {
    final dayStart = getDayStart(dateTime);
    final weekday = dayStart.weekday; // Monday = 1, Sunday = 7
    final daysFromMonday = weekday - 1;
    return dayStart.subtract(Duration(days: daysFromMonday));
  }

  /// Gets the start of the current logical week.
  static DateTime getThisWeekStart() {
    return getWeekStart(DateTime.now());
  }
}
