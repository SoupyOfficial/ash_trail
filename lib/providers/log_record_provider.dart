import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../services/log_record_service.dart';
import 'account_provider.dart';

// ===== DRAFT STATE MANAGEMENT =====

/// Represents the temporary state of a log entry form
/// Never persisted automatically - only saved when user explicitly submits
@immutable
class LogDraft {
  final EventType eventType;
  final double? duration;
  final Unit unit;
  final DateTime eventTime;
  final String? note;
  final double? moodRating;
  final double? physicalRating;
  final LogReason? reason;
  final double? latitude;
  final double? longitude;
  final bool isValid;

  const LogDraft({
    this.eventType = EventType.inhale,
    this.duration,
    this.unit = Unit.hits,
    DateTime? eventTime,
    this.note,
    this.moodRating,
    this.physicalRating,
    this.reason,
    this.latitude,
    this.longitude,
  }) : eventTime = eventTime ?? const _DefaultDateTime(),
       isValid = true;

  // Private constructor for validation state
  const LogDraft._({
    required this.eventType,
    this.duration,
    required this.unit,
    required DateTime eventTime,
    this.note,
    this.moodRating,
    this.physicalRating,
    this.reason,
    this.latitude,
    this.longitude,
    required this.isValid,
  }) : eventTime = eventTime;

  /// Create a default draft with current time
  factory LogDraft.empty() => LogDraft(eventTime: DateTime.now());

  /// Copy with validation
  LogDraft copyWith({
    EventType? eventType,
    double? Function()? duration,
    Unit? unit,
    DateTime? eventTime,
    String? Function()? note,
    double? Function()? moodRating,
    double? Function()? physicalRating,
    LogReason? Function()? reason,
    double? Function()? latitude,
    double? Function()? longitude,
  }) {
    return LogDraft._(
      eventType: eventType ?? this.eventType,
      duration: duration != null ? duration() : this.duration,
      unit: unit ?? this.unit,
      eventTime: eventTime ?? this.eventTime,
      note: note != null ? note() : this.note,
      moodRating: moodRating != null ? moodRating() : this.moodRating,
      physicalRating:
          physicalRating != null ? physicalRating() : this.physicalRating,
      reason: reason != null ? reason() : this.reason,
      latitude: latitude != null ? latitude() : this.latitude,
      longitude: longitude != null ? longitude() : this.longitude,
      isValid: _validate(
        eventType ?? this.eventType,
        duration != null ? duration() : this.duration,
        unit ?? this.unit,
        moodRating != null ? moodRating() : this.moodRating,
        physicalRating != null ? physicalRating() : this.physicalRating,
      ),
    );
  }

  /// Validation logic for draft
  static bool _validate(
    EventType eventType,
    double? duration,
    Unit unit,
    double? moodRating,
    double? physicalRating,
  ) {
    // Duration must be non-negative if provided
    if (duration != null && duration < 0) return false;

    // Mood/physical rating must be in 0-10 range if provided
    if (moodRating != null && (moodRating < 0 || moodRating > 10)) return false;
    if (physicalRating != null && (physicalRating < 0 || physicalRating > 10))
      return false;

    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogDraft &&
        other.eventType == eventType &&
        other.duration == duration &&
        other.unit == unit &&
        other.eventTime == eventTime &&
        other.note == note &&
        other.moodRating == moodRating &&
        other.physicalRating == physicalRating &&
        other.reason == reason &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(
    eventType,
    duration,
    unit,
    eventTime,
    note,
    moodRating,
    physicalRating,
    reason,
    latitude,
    longitude,
  );
}

/// Helper class for default DateTime in const constructor
class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();

  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}

/// StateNotifier for managing log draft state
class LogDraftNotifier extends StateNotifier<LogDraft> {
  LogDraftNotifier() : super(LogDraft.empty());

  /// Update event type and auto-select appropriate unit
  void setEventType(EventType type) {
    Unit defaultUnit;
    switch (type) {
      case EventType.inhale:
        defaultUnit = Unit.hits;
        break;
      case EventType.sessionStart:
      case EventType.sessionEnd:
        defaultUnit = Unit.seconds;
        break;
      default:
        defaultUnit = state.unit;
    }
    state = state.copyWith(eventType: type, unit: defaultUnit);
  }

  /// Update duration
  void setDuration(double? duration) {
    state = state.copyWith(duration: () => duration);
  }

  /// Update unit
  void setUnit(Unit unit) {
    state = state.copyWith(unit: unit);
  }

  /// Update event time
  void setEventTime(DateTime time) {
    state = state.copyWith(eventTime: time);
  }

  /// Update note
  void setNote(String? note) {
    state = state.copyWith(note: () => note?.isEmpty == true ? null : note);
  }

  /// Update mood rating (0-10 scale)
  void setMoodRating(double? moodRating) {
    state = state.copyWith(moodRating: () => moodRating);
  }

  /// Update physical rating (0-10 scale)
  void setPhysicalRating(double? physicalRating) {
    state = state.copyWith(physicalRating: () => physicalRating);
  }

  /// Update reason
  void setReason(LogReason? reason) {
    state = state.copyWith(reason: () => reason);
  }

  /// Update latitude
  void setLatitude(double? latitude) {
    state = state.copyWith(latitude: () => latitude);
  }

  /// Update longitude
  void setLongitude(double? longitude) {
    state = state.copyWith(longitude: () => longitude);
  }

  /// Set both latitude and longitude at once
  void setLocation(double? latitude, double? longitude) {
    state = state.copyWith(
      latitude: () => latitude,
      longitude: () => longitude,
    );
  }

  /// Reset draft to defaults
  void reset() {
    state = LogDraft.empty();
  }

  /// Check if draft has been modified from defaults
  bool get isDirty {
    final empty = LogDraft.empty();
    return state.eventType != empty.eventType ||
        state.duration != null ||
        state.unit != empty.unit ||
        state.note != null ||
        state.moodRating != null ||
        state.physicalRating != null ||
        state.reason != null ||
        state.latitude != null ||
        state.longitude != null;
  }
}

/// Provider for log draft state
final logDraftProvider = StateNotifierProvider<LogDraftNotifier, LogDraft>((
  ref,
) {
  return LogDraftNotifier();
});

// ===== EXISTING PROVIDERS =====

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
        eventType: params.eventType,
        eventAt: params.eventAt,
        duration: params.duration ?? 0,
        unit: params.unit,
        note: params.note,
        source: params.source,
        moodRating: params.moodRating,
        physicalRating: params.physicalRating,
        reason: params.reason,
        latitude: params.latitude,
        longitude: params.longitude,
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
  final EventType eventType;
  final DateTime? eventAt;
  final double? duration;
  final Unit unit;
  final String? note;
  final Source source;
  final double? moodRating;
  final double? physicalRating;
  final LogReason? reason;
  final double? latitude;
  final double? longitude;

  CreateLogRecordParams({
    required this.eventType,
    this.eventAt,
    this.duration,
    this.unit = Unit.none,
    this.note,
    this.source = Source.manual,
    this.moodRating,
    this.physicalRating,
    this.reason,
    this.latitude,
    this.longitude,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreateLogRecordParams &&
        other.eventType == eventType &&
        other.eventAt == eventAt &&
        other.duration == duration &&
        other.unit == unit &&
        other.note == note &&
        other.source == source &&
        other.moodRating == moodRating &&
        other.physicalRating == physicalRating &&
        other.reason == reason &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      eventType,
      eventAt,
      duration,
      unit,
      note,
      source,
      moodRating,
      physicalRating,
      reason,
      latitude,
      longitude,
    );
  }
}

/// Parameters for querying log records
class LogRecordsParams {
  final String? accountId;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<EventType>? eventTypes;
  final bool includeDeleted;

  const LogRecordsParams({
    this.accountId,
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
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.includeDeleted == includeDeleted;
  }

  @override
  int get hashCode {
    return Object.hash(accountId, startDate, endDate, includeDeleted);
  }
}

/// Provider for log record mutations (update/delete)
final logRecordNotifierProvider =
    StateNotifierProvider<LogRecordNotifier, AsyncValue<LogRecord?>>((ref) {
      return LogRecordNotifier(ref);
    });

/// StateNotifier for handling log record mutations
class LogRecordNotifier extends StateNotifier<AsyncValue<LogRecord?>> {
  final Ref _ref;

  LogRecordNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Update a log record
  Future<void> updateLogRecord(
    LogRecord record, {
    EventType? eventType,
    DateTime? eventAt,
    double? duration,
    Unit? unit,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(logRecordServiceProvider);
      final updated = await service.updateLogRecord(
        record,
        eventType: eventType,
        eventAt: eventAt,
        duration: duration,
        unit: unit,
        note: note,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete a log record (soft delete)
  Future<void> deleteLogRecord(LogRecord record) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(logRecordServiceProvider);
      await service.deleteLogRecord(record);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Restore a deleted log record
  Future<void> restoreLogRecord(LogRecord record) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(logRecordServiceProvider);
      await service.restoreDeleted(record);
      state = AsyncValue.data(record);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}
