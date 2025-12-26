import '../models/session.dart';
import 'session_repository.dart';

class SessionRepositoryStub implements SessionRepository {
  @override
  Future<Session> create(Session session) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<Session> update(Session session) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<void> delete(String sessionId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<Session?> getBySessionId(String sessionId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<Session>> getByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<Session?> getActiveSession(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<Session>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<Session>> getRecent(String accountId, int limit) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<int> countByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Stream<List<Session>> watchByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Stream<Session?> watchActiveSession(String accountId) {
    throw UnsupportedError('Platform not supported');
  }
}
