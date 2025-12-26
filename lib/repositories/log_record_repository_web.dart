import 'dart:async';
import 'package:hive/hive.dart';
import '../models/log_record.dart';
import '../models/web_models.dart';
import '../models/model_converters.dart';
import '../models/enums.dart';
import 'log_record_repository.dart';

/// Web implementation of LogRecordRepository using Hive
class LogRecordRepositoryWeb implements LogRecordRepository {
  late final Box _box;
  final _controller = StreamController<List<LogRecord>>.broadcast();

  LogRecordRepositoryWeb(Map<String, dynamic> boxes) {
    _box = boxes['logRecords'] as Box;
    _box.watch().listen((_) => _emitChanges());
  }

  void _emitChanges() {
    _controller.add(_getAllRecords());
  }

  List<LogRecord> _getAllRecords() {
    final records = <LogRecord>[];
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webRecord = WebLogRecord.fromJson(json);
      records.add(
        LogRecordWebConversion.fromWebModel(
          webRecord,
          id: int.tryParse(webRecord.id) ?? 0,
        ),
      );
    }
    return records;
  }

  @override
  Future<LogRecord> create(LogRecord record) async {
    final webRecord = record.toWebModel();
    await _box.put(record.logId, webRecord.toJson());
    return record;
  }

  @override
  Future<LogRecord> update(LogRecord record) async {
    final webRecord = record.toWebModel();
    await _box.put(record.logId, webRecord.toJson());
    return record;
  }

  @override
  Future<void> delete(String logId) async {
    await _box.delete(logId);
  }

  @override
  Future<LogRecord?> getByLogId(String logId) async {
    final json = _box.get(logId);
    if (json == null) return null;
    final webRecord = WebLogRecord.fromJson(Map<String, dynamic>.from(json));
    return LogRecordWebConversion.fromWebModel(
      webRecord,
      id: int.tryParse(webRecord.id) ?? 0,
    );
  }

  @override
  Future<List<LogRecord>> getByAccount(String accountId) async {
    final records =
        _getAllRecords()
            .where((r) => r.accountId == accountId && !r.isDeleted)
            .toList();
    records.sort((a, b) => b.eventAt.compareTo(a.eventAt));
    return records;
  }

  @override
  Future<List<LogRecord>> getBySession(String sessionId) async {
    final records =
        _getAllRecords()
            .where((r) => r.sessionId == sessionId && !r.isDeleted)
            .toList();
    records.sort((a, b) => a.eventAt.compareTo(b.eventAt));
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
  Stream<List<LogRecord>> watchByAccount(String accountId) {
    return _controller.stream.map(
      (records) =>
          records
              .where((r) => r.accountId == accountId && !r.isDeleted)
              .toList(),
    );
  }

  @override
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    return _controller.stream.map(
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
  }
}
