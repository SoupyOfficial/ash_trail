import 'dart:async';
import 'package:hive/hive.dart';
import '../models/session.dart';
import '../models/web_models.dart';
import '../models/model_converters.dart';
import 'session_repository.dart';

/// Web implementation of SessionRepository using Hive
class SessionRepositoryHive implements SessionRepository {
  late final Box _box;
  final _controller = StreamController<List<Session>>.broadcast();

  SessionRepositoryHive(Map<String, dynamic> boxes) {
    _box = boxes['sessions'] as Box;
    _box.watch().listen((_) => _emitChanges());
    // Emit initial state
    _emitChanges();
  }

  void _emitChanges() {
    _controller.add(_getAllSessions());
  }

  List<Session> _getAllSessions() {
    final sessions = <Session>[];
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webSession = WebSession.fromJson(json);
      sessions.add(
        SessionWebConversion.fromWebModel(
          webSession,
          id: int.tryParse(webSession.id) ?? 0,
        ),
      );
    }
    return sessions;
  }

  @override
  Future<Session> create(Session session) async {
    final webSession = session.toWebModel();
    await _box.put(session.sessionId, webSession.toJson());
    return session;
  }

  @override
  Future<Session> update(Session session) async {
    final webSession = session.toWebModel();
    await _box.put(session.sessionId, webSession.toJson());
    return session;
  }

  @override
  Future<void> delete(String sessionId) async {
    await _box.delete(sessionId);
  }

  @override
  Future<Session?> getBySessionId(String sessionId) async {
    final json = _box.get(sessionId);
    if (json == null) return null;
    final webSession = WebSession.fromJson(Map<String, dynamic>.from(json));
    return SessionWebConversion.fromWebModel(
      webSession,
      id: int.tryParse(webSession.id) ?? 0,
    );
  }

  @override
  Future<List<Session>> getByAccount(String accountId) async {
    final sessions =
        _getAllSessions()
            .where((s) => s.accountId == accountId && !s.isDeleted)
            .toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  @override
  Future<Session?> getActiveSession(String accountId) async {
    try {
      return _getAllSessions().firstWhere(
        (s) => s.accountId == accountId && s.isActive && !s.isDeleted,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Session>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    final sessions =
        _getAllSessions()
            .where(
              (s) =>
                  s.accountId == accountId &&
                  !s.isDeleted &&
                  s.startedAt.isAfter(start) &&
                  s.startedAt.isBefore(end),
            )
            .toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  @override
  Future<List<Session>> getRecent(String accountId, int limit) async {
    final sessions =
        _getAllSessions()
            .where((s) => s.accountId == accountId && !s.isDeleted)
            .toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions.take(limit).toList();
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return _getAllSessions()
        .where((s) => s.accountId == accountId && !s.isDeleted)
        .length;
  }

  @override
  Stream<List<Session>> watchByAccount(String accountId) {
    return _controller.stream.map(
      (sessions) =>
          sessions
              .where((s) => s.accountId == accountId && !s.isDeleted)
              .toList(),
    );
  }

  @override
  Stream<Session?> watchActiveSession(String accountId) {
    return _controller.stream.map((sessions) {
      try {
        return sessions.firstWhere(
          (s) => s.accountId == accountId && s.isActive && !s.isDeleted,
        );
      } catch (e) {
        return null;
      }
    });
  }
}
