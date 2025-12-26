import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/log_entry.dart';
import '../services/logging_service.dart';
import 'account_provider.dart';

/// @deprecated This provider file is deprecated. Use [log_record_provider.dart] instead.
///
/// These providers are being phased out:
/// - loggingServiceProvider -> use logRecordServiceProvider
/// - logEntriesProvider -> use activeAccountLogRecordsProvider or logRecordsProvider
/// - quickLogProvider -> use createLogRecordProvider
/// - statisticsProvider -> use logRecordStatsProvider
///
/// Migration path:
/// 1. Import log_record_provider.dart instead of logging_provider.dart
/// 2. Replace LogEntry with LogRecord in your code
/// 3. Update provider references to use the new providers
/// 4. Use EventType, Unit, and other enums from models/enums.dart

// Service provider
/// @deprecated Use logRecordServiceProvider instead
final loggingServiceProvider = Provider<LoggingService>((ref) {
  return LoggingService();
});

// Log entries for active account
/// @deprecated Use activeAccountLogRecordsProvider or logRecordsProvider instead
final logEntriesProvider = StreamProvider<List<LogEntry>>((ref) {
  final activeAccount = ref.watch(activeAccountProvider);

  return activeAccount.when(
    data: (account) {
      if (account == null) {
        return Stream.value([]);
      }
      final service = ref.watch(loggingServiceProvider);
      return service.watchLogEntries(account.userId);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// Quick log notifier
/// @deprecated Use createLogRecordProvider instead
final quickLogProvider =
    StateNotifierProvider<QuickLogger, AsyncValue<LogEntry?>>((ref) {
      return QuickLogger(ref);
    });

/// @deprecated Use LogRecordService.createLogRecord with createLogRecordProvider instead
class QuickLogger extends StateNotifier<AsyncValue<LogEntry?>> {
  final Ref _ref;

  QuickLogger(this._ref) : super(const AsyncValue.data(null));

  Future<void> log({String? notes, double? amount}) async {
    state = const AsyncValue.loading();
    try {
      final activeAccount = await _ref.read(activeAccountProvider.future);

      if (activeAccount == null) {
        throw Exception('No active account selected');
      }

      final service = _ref.read(loggingServiceProvider);
      final entry = await service.quickLog(
        userId: activeAccount.userId,
        notes: notes,
        amount: amount,
      );

      state = AsyncValue.data(entry);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Date range filter provider
final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange(this.start, this.end);
}

// Filtered log entries provider
final filteredLogEntriesProvider = Provider<List<LogEntry>>((ref) {
  final allEntries = ref.watch(logEntriesProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return allEntries.when(
    data: (entries) {
      if (dateRange == null) return entries;

      return entries.where((entry) {
        return entry.timestamp.isAfter(dateRange.start) &&
            entry.timestamp.isBefore(dateRange.end);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Statistics provider
/// @deprecated Use logRecordStatsProvider instead
final statisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final activeAccount = await ref.watch(activeAccountProvider.future);

  if (activeAccount == null) {
    return {
      'totalEntries': 0,
      'totalAmount': 0.0,
      'firstEntry': null,
      'lastEntry': null,
    };
  }

  final service = ref.watch(loggingServiceProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return await service.getStatistics(
    userId: activeAccount.userId,
    startDate: dateRange?.start,
    endDate: dateRange?.end,
  );
});
