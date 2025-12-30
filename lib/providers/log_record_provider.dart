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
  final double? value;
  final Unit unit;
  final DateTime eventTime;
  final String? note;
  final List<String> tags;
  final double? mood;
  final double? craving;
  final LogReason? reason;
  final String? location;
  final bool isValid;

  const LogDraft({
    this.eventType = EventType.inhale,
    this.value,
    this.unit = Unit.hits,
    DateTime? eventTime,
    this.note,
    this.tags = const [],
    this.mood,
    this.craving,
    this.reason,
    this.location,
  }) : eventTime = eventTime ?? const _DefaultDateTime(),
       isValid = true;

  // Private constructor for validation state
  const LogDraft._({
    required this.eventType,
    this.value,
    required this.unit,
    required DateTime eventTime,
    this.note,
    required this.tags,
    this.mood,
    this.craving,
    this.reason,
    this.location,
    required this.isValid,
  }) : eventTime = eventTime;

  /// Create a default draft with current time
  factory LogDraft.empty() => LogDraft(eventTime: DateTime.now());

  /// Copy with validation
  LogDraft copyWith({
    EventType? eventType,
    double? Function()? value,
    Unit? unit,
    DateTime? eventTime,
    String? Function()? note,
    List<String>? tags,
    double? Function()? mood,
    double? Function()? craving,
    LogReason? Function()? reason,
    String? Function()? location,
  }) {
    return LogDraft._(
      eventType: eventType ?? this.eventType,
      value: value != null ? value() : this.value,
      unit: unit ?? this.unit,
      eventTime: eventTime ?? this.eventTime,
      note: note != null ? note() : this.note,
      tags: tags ?? this.tags,
      mood: mood != null ? mood() : this.mood,
      craving: craving != null ? craving() : this.craving,
      reason: reason != null ? reason() : this.reason,
      location: location != null ? location() : this.location,
      isValid: _validate(
        eventType ?? this.eventType,
        value != null ? value() : this.value,
        unit ?? this.unit,
        mood != null ? mood() : this.mood,
        craving != null ? craving() : this.craving,
      ),
    );
  }

  /// Validation logic for draft
  static bool _validate(
    EventType eventType,
    double? value,
    Unit unit,
    double? mood,
    double? craving,
  ) {
    // Value must be non-negative if provided
    if (value != null && value < 0) return false;

    // Mood/craving must be in 0-10 range if provided
    if (mood != null && (mood < 0 || mood > 10)) return false;
    if (craving != null && (craving < 0 || craving > 10)) return false;

    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogDraft &&
        other.eventType == eventType &&
        other.value == value &&
        other.unit == unit &&
        other.eventTime == eventTime &&
        other.note == note &&
        listEquals(other.tags, tags) &&
        other.mood == mood &&
        other.craving == craving &&
        other.reason == reason &&
        other.location == location;
  }

  @override
  int get hashCode => Object.hash(
    eventType,
    value,
    unit,
    eventTime,
    note,
    Object.hashAll(tags),
    mood,
    craving,
    reason,
    location,
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

  /// Update value
  void setValue(double? value) {
    state = state.copyWith(value: () => value);
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

  /// Update tags
  void setTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  /// Add a tag
  void addTag(String tag) {
    if (tag.isNotEmpty && !state.tags.contains(tag)) {
      state = state.copyWith(tags: [...state.tags, tag]);
    }
  }

  /// Remove a tag
  void removeTag(String tag) {
    state = state.copyWith(tags: state.tags.where((t) => t != tag).toList());
  }

  /// Update mood (0-10 scale)
  void setMood(double? mood) {
    state = state.copyWith(mood: () => mood);
  }

  /// Update craving (0-10 scale)
  void setCraving(double? craving) {
    state = state.copyWith(craving: () => craving);
  }

  /// Update reason
  void setReason(LogReason? reason) {
    state = state.copyWith(reason: () => reason);
  }

  /// Update location
  void setLocation(String? location) {
    state = state.copyWith(
      location: () => location?.isEmpty == true ? null : location,
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
        state.value != null ||
        state.unit != empty.unit ||
        state.note != null ||
        state.tags.isNotEmpty ||
        state.mood != null ||
        state.craving != null ||
        state.reason != null ||
        state.location != null;
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
    double? value,
    Unit? unit,
    String? note,
    List<String>? tags,
    String? sessionId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(logRecordServiceProvider);
      final updated = await service.updateLogRecord(
        record,
        eventType: eventType,
        eventAt: eventAt,
        value: value,
        unit: unit,
        note: note,
        tags: tags,
        sessionId: sessionId,
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
