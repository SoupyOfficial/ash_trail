import '../models/session.dart';
import 'session_repository_hive.dart';

/// Abstract repository interface for Session data access
/// Uses Hive for local storage on all platforms
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

/// Factory to create SessionRepository using Hive
SessionRepository createSessionRepository([dynamic context]) {
  return SessionRepositoryHive(context as Map<String, dynamic>);
}
