import 'dart:async';
import 'package:hive/hive.dart';
import '../models/log_record.dart';
import '../models/web_models.dart';
import '../models/model_converters.dart';
import '../models/enums.dart';
import 'log_record_repository.dart';

/// Hive implementation of LogRecordRepository for all platforms
class LogRecordRepositoryHive implements LogRecordRepository {
  late final Box _box;
  final _controller = StreamController<List<LogRecord>>.broadcast();
  StreamSubscription? _boxWatchSubscription;
  int _nextId = 1;

  LogRecordRepositoryHive(Map<String, dynamic> boxes) {
    _box = boxes['logRecords'] as Box;
    _boxWatchSubscription = _box.watch().listen((_) => _emitChanges());
    // Initialize _nextId based on existing records
    _nextId = _getAllRecords().fold(0, (max, r) => r.id > max ? r.id : max) + 1;
    // Emit initial state
    _emitChanges();
  }

  void dispose() {
    _boxWatchSubscription?.cancel();
    _controller.close();
  }

  void _emitChanges() {
    if (!_box.isOpen) return; // Don't emit if box is closed
    _controller.add(_getAllRecords());
  }

  List<LogRecord> _getAllRecords() {
    final records = <LogRecord>[];
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webRecord = WebLogRecord.fromJson(json);
      // Use stored ID or assign new one
      final id = json['_internalId'] as int? ?? _nextId++;
      records.add(
        LogRecordWebConversion.fromWebModel(
          webRecord,
          id: id,
          extraFields: json, // Pass full JSON for extra fields
        ),
      );
    }
    return records;
  }

  @override
  Future<LogRecord> create(LogRecord record) async {
    // Assign unique internal ID if not set
    if (record.id == 0) {
      record.id = _nextId++;
    }
    final webRecord = record.toWebModel();
    final json = webRecord.toJson();
    // Store additional fields not in WebLogRecord
    json['_internalId'] = record.id;
    json['syncState'] = record.syncState.name;
    json['revision'] = record.revision;
    json['deletedAt'] = record.deletedAt?.toIso8601String();
    json['syncedAt'] = record.syncedAt?.toIso8601String();
    json['syncError'] = record.syncError;
    json['lastRemoteUpdateAt'] = record.lastRemoteUpdateAt?.toIso8601String();
    await _box.put(record.logId, json);
    return record;
  }

  @override
  Future<LogRecord> update(LogRecord record) async {
    final webRecord = record.toWebModel();
    final json = webRecord.toJson();
    // Store additional fields not in WebLogRecord
    json['_internalId'] = record.id;
    json['syncState'] = record.syncState.name;
    json['revision'] = record.revision;
    json['deletedAt'] = record.deletedAt?.toIso8601String();
    json['syncedAt'] = record.syncedAt?.toIso8601String();
    json['syncError'] = record.syncError;
    json['lastRemoteUpdateAt'] = record.lastRemoteUpdateAt?.toIso8601String();
    await _box.put(record.logId, json);
    // Fetch and return the updated record to ensure consistency
    return (await getByLogId(record.logId))!;
  }

  @override
  Future<void> delete(String logId) async {
    await _box.delete(logId);
  }

  @override
  Future<LogRecord?> getByLogId(String logId) async {
    final json = _box.get(logId);
    if (json == null) return null;
    final jsonMap = Map<String, dynamic>.from(json);
    final webRecord = WebLogRecord.fromJson(jsonMap);
    final id = jsonMap['_internalId'] as int? ?? 0;
    return LogRecordWebConversion.fromWebModel(
      webRecord,
      id: id,
      extraFields: jsonMap, // Pass full JSON for extra fields
    );
  }

  @override
  Future<List<LogRecord>> getAll() async {
    return _getAllRecords();
  }

  @override
  Future<List<LogRecord>> getByAccount(String accountId) async {
    final records =
        _getAllRecords().where((r) => r.accountId == accountId).toList();
    records.sort((a, b) => b.eventAt.compareTo(a.eventAt));
    return records;
  }

  @override
  Future<List<LogRecord>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    final records =
        _getAllRecords()
            .where(
              (r) =>
                  r.accountId == accountId &&
                  !r.isDeleted &&
                  r.eventAt.isAfter(start) &&
                  r.eventAt.isBefore(end),
            )
            .toList();
    records.sort((a, b) => b.eventAt.compareTo(a.eventAt));
    return records;
  }

  @override
  Future<List<LogRecord>> getByEventType(
    String accountId,
    EventType eventType,
  ) async {
    final records =
        _getAllRecords()
            .where(
              (r) =>
                  r.accountId == accountId &&
                  !r.isDeleted &&
                  r.eventType == eventType,
            )
            .toList();
    records.sort((a, b) => b.eventAt.compareTo(a.eventAt));
    return records;
  }

  @override
  Future<List<LogRecord>> getPendingSync() async {
    return _getAllRecords()
        .where(
          (r) =>
              r.syncState == SyncState.pending ||
              r.syncState == SyncState.error,
        )
        .toList();
  }

  @override
  Future<List<LogRecord>> getDeleted(String accountId) async {
    return _getAllRecords()
        .where((r) => r.accountId == accountId && r.isDeleted)
        .toList();
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return _getAllRecords()
        .where((r) => r.accountId == accountId && !r.isDeleted)
        .length;
  }

  @override
  Future<void> deleteByAccount(String accountId) async {
    final records = _getAllRecords().where((r) => r.accountId == accountId);
    for (final record in records) {
      await _box.delete(record.logId);
    }
  }

  @override
  Stream<List<LogRecord>> watchByAccount(String accountId) {
    final allRecords = _getAllRecords();
    final matchingRecords =
        allRecords
            .where((r) => r.accountId == accountId && !r.isDeleted)
            .toList();
    final mappedStream = _controller.stream.map((records) =>
        records
            .where((r) => r.accountId == accountId && !r.isDeleted)
            .toList());
    return Stream.value(matchingRecords).asyncExpand((initial) async* {
      yield initial;
      yield* mappedStream;
    });
  }

  @override
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    // Get initial data
    final allRecords = _getAllRecords();
    final initialRecords =
        allRecords
            .where(
              (r) =>
                  r.accountId == accountId &&
                  !r.isDeleted &&
                  r.eventAt.isAfter(start) &&
                  r.eventAt.isBefore(end),
            )
            .toList();

    final mappedStream = _controller.stream.map(
      (records) =>
          records
              .where(
                (r) =>
                    r.accountId == accountId &&
                    !r.isDeleted &&
                    r.eventAt.isAfter(start) &&
                    r.eventAt.isBefore(end),
              )
              .toList(),
    );

    // Start with current data, then continue with updates
    return Stream.value(initialRecords).asyncExpand((initial) async* {
      yield initial;
      yield* mappedStream;
    });
  }
}
