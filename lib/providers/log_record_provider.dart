import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../services/log_record_service.dart';
import 'account_provider.dart';

/// Provider for LogRecordService
final logRecordServiceProvider = Provider<LogRecordService>((ref) {
  return LogRecordService();
});

/// Provider for active account ID (derived from activeAccountProvider)
final activeAccountIdProvider = Provider<String?>((ref) {
  final activeAccount = ref.watch(activeAccountProvider);
  return activeAccount.when(
    data: (account) => account?.userId,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for active profile ID
final activeProfileIdProvider = StateProvider<String?>((ref) => null);

/// Provider for watching log records for active account (convenience wrapper)
final activeAccountLogRecordsProvider = StreamProvider<List<LogRecord>>((ref) {
  final accountId = ref.watch(activeAccountIdProvider);

  if (accountId == null) {
    return Stream.value([]);
  }

  return ref
      .watch(logRecordsProvider(const LogRecordsParams()))
      .when(
        data: (records) => Stream.value(records),
        loading: () => Stream.value([]),
        error: (_, __) => Stream.value([]),
      );
});

/// Provider for creating a new log record
final createLogRecordProvider =
    FutureProvider.family<LogRecord, CreateLogRecordParams>((
      ref,
      params,
    ) async {
      final service = ref.read(logRecordServiceProvider);
      final accountId = ref.read(activeAccountIdProvider);

      if (accountId == null) {
        throw Exception('No active account selected');
      }

      return await service.createLogRecord(
        accountId: accountId,
        profileId: params.profileId,
        eventType: params.eventType,
        eventAt: params.eventAt,
        value: params.value,
        unit: params.unit,
        note: params.note,
        tags: params.tags,
        sessionId: params.sessionId,
        source: params.source,
      );
    });

/// Provider for watching log records
final logRecordsProvider =
    StreamProvider.family<List<LogRecord>, LogRecordsParams>((ref, params) {
      final service = ref.read(logRecordServiceProvider);
      final accountId = params.accountId ?? ref.read(activeAccountIdProvider);

      if (accountId == null) {
        return Stream.value([]);
      }

      return service.watchLogRecords(
        accountId: accountId,
        profileId: params.profileId,
        startDate: params.startDate,
        endDate: params.endDate,
        includeDeleted: params.includeDeleted,
      );
    });

/// Provider for getting log records (one-time fetch)
final getLogRecordsProvider =
    FutureProvider.family<List<LogRecord>, LogRecordsParams>((
      ref,
      params,
    ) async {
      final service = ref.read(logRecordServiceProvider);
      final accountId = params.accountId ?? ref.read(activeAccountIdProvider);

      if (accountId == null) {
        return [];
      }

      return await service.getLogRecords(
        accountId: accountId,
        profileId: params.profileId,
        startDate: params.startDate,
        endDate: params.endDate,
        eventTypes: params.eventTypes,
        includeDeleted: params.includeDeleted,
      );
    });

/// Provider for getting a specific log record by logId
final logRecordByIdProvider = FutureProvider.family<LogRecord?, String>((
  ref,
  logId,
) async {
  final service = ref.read(logRecordServiceProvider);
  return await service.getLogRecordByLogId(logId);
});

/// Provider for log record statistics
final logRecordStatsProvider =
    FutureProvider.family<Map<String, dynamic>, LogRecordsParams>((
      ref,
      params,
    ) async {
      final service = ref.read(logRecordServiceProvider);
      final accountId = params.accountId ?? ref.read(activeAccountIdProvider);

      if (accountId == null) {
        return {};
      }

      return await service.getStatistics(
        accountId: accountId,
        profileId: params.profileId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });

/// Provider for pending sync count
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(logRecordServiceProvider);
  final accountId = ref.read(activeAccountIdProvider);

  if (accountId == null) {
    return 0;
  }

  return await service.countLogRecords(accountId: accountId);
});

/// Parameters for creating a log record
class CreateLogRecordParams {
  final String? profileId;
  final EventType eventType;
  final DateTime? eventAt;
  final double? value;
  final Unit unit;
  final String? note;
  final List<String>? tags;
  final String? sessionId;
  final Source source;

  CreateLogRecordParams({
    this.profileId,
    required this.eventType,
    this.eventAt,
    this.value,
    this.unit = Unit.none,
    this.note,
    this.tags,
    this.sessionId,
    this.source = Source.manual,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreateLogRecordParams &&
        other.profileId == profileId &&
        other.eventType == eventType &&
        other.eventAt == eventAt &&
        other.value == value &&
        other.unit == unit &&
        other.note == note &&
        other.sessionId == sessionId &&
        other.source == source;
  }

  @override
  int get hashCode {
    return Object.hash(
      profileId,
      eventType,
      eventAt,
      value,
      unit,
      note,
      sessionId,
      source,
    );
  }
}

/// Parameters for querying log records
class LogRecordsParams {
  final String? accountId;
  final String? profileId;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<EventType>? eventTypes;
  final bool includeDeleted;

  const LogRecordsParams({
    this.accountId,
    this.profileId,
    this.startDate,
    this.endDate,
    this.eventTypes,
    this.includeDeleted = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LogRecordsParams &&
        other.accountId == accountId &&
        other.profileId == profileId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.includeDeleted == includeDeleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      accountId,
      profileId,
      startDate,
      endDate,
      includeDeleted,
    );
  }
}
