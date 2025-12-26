import '../models/session.dart';
import 'session_repository_stub.dart'
    if (dart.library.io) 'session_repository_native.dart'
    if (dart.library.js_interop) 'session_repository_web.dart';

/// Abstract repository interface for Session data access
/// Platform-specific implementations handle Isar (native) or Hive (web)
abstract class SessionRepository {
  /// Create a new session
  Future<Session> create(Session session);

  /// Update an existing session
  Future<Session> update(Session session);

  /// Delete a session by sessionId
  Future<void> delete(String sessionId);

  /// Get session by sessionId
  Future<Session?> getBySessionId(String sessionId);

  /// Get all sessions for an account
  Future<List<Session>> getByAccount(String accountId);

  /// Get active session for account
  Future<Session?> getActiveSession(String accountId);

  /// Get sessions by date range
  Future<List<Session>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  );

  /// Get recent sessions
  Future<List<Session>> getRecent(String accountId, int limit);

  /// Count sessions for account
  Future<int> countByAccount(String accountId);

  /// Watch all sessions for account
  Stream<List<Session>> watchByAccount(String accountId);

  /// Watch active session
  Stream<Session?> watchActiveSession(String accountId);
}

/// Factory to create platform-specific SessionRepository
SessionRepository createSessionRepository([dynamic context]) {
  if (context is Map<String, dynamic>) {
    return SessionRepositoryWeb(context);
  }
  return SessionRepositoryNative();
}
