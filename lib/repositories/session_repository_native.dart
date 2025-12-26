import 'package:isar/isar.dart';
import '../models/session.dart';
import '../services/isar_service.dart';
import 'session_repository.dart';

/// Native implementation of SessionRepository using Isar
class SessionRepositoryNative implements SessionRepository {
  final Isar _isar = IsarService.instance;

  @override
  Future<Session> create(Session session) async {
    await _isar.writeTxn(() async {
      await _isar.sessions.put(session);
    });
    return session;
  }

  @override
  Future<Session> update(Session session) async {
    await _isar.writeTxn(() async {
      await _isar.sessions.put(session);
    });
    return session;
  }

  @override
  Future<void> delete(String sessionId) async {
    await _isar.writeTxn(() async {
      final session = await getBySessionId(sessionId);
      if (session != null) {
        await _isar.sessions.delete(session.id);
      }
    });
  }

  @override
  Future<Session?> getBySessionId(String sessionId) async {
    return await _isar.sessions
        .filter()
        .sessionIdEqualTo(sessionId)
        .findFirst();
  }

  @override
  Future<List<Session>> getByAccount(String accountId) async {
    return await _isar.sessions
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .sortByStartedAtDesc()
        .findAll();
  }

  @override
  Future<Session?> getActiveSession(String accountId) async {
    return await _isar.sessions
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .isActiveEqualTo(true)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .findFirst();
  }

  @override
  Future<List<Session>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return await _isar.sessions
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .startedAtBetween(start, end)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .sortByStartedAtDesc()
        .findAll();
  }

  @override
  Future<List<Session>> getRecent(String accountId, int limit) async {
    return await _isar.sessions
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .sortByStartedAtDesc()
        .limit(limit)
        .findAll();
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return await _isar.sessions
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .count();
  }

  @override
  Stream<List<Session>> watchByAccount(String accountId) {
    return _isar.sessions
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .watch(fireImmediately: true);
  }

  @override
  Stream<Session?> watchActiveSession(String accountId) {
    return _isar.sessions
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .isActiveEqualTo(true)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .watch(fireImmediately: true)
        .map((sessions) => sessions.isEmpty ? null : sessions.first);
  }
}
