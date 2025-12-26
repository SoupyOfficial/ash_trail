import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../services/session_service.dart';
import 'account_provider.dart';

/// Session service provider
final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService();
});

/// Active session stream for current account
final activeSessionProvider = StreamProvider<Session?>((ref) {
  final activeAccount = ref.watch(activeAccountProvider);

  return activeAccount.when(
    data: (account) {
      if (account == null) {
        return Stream.value(null);
      }
      final service = ref.watch(sessionServiceProvider);
      return service.watchActiveSession(accountId: account.userId);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// All sessions for active account
final sessionsProvider = StreamProvider<List<Session>>((ref) {
  final activeAccount = ref.watch(activeAccountProvider);

  return activeAccount.when(
    data: (account) {
      if (account == null) {
        return Stream.value([]);
      }
      final service = ref.watch(sessionServiceProvider);
      return service.watchSessions(
        accountId: account.userId,
        activeOnly: false,
      );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Session statistics
final sessionStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final activeAccount = await ref.watch(activeAccountProvider.future);

  if (activeAccount == null) {
    return {};
  }

  final service = ref.watch(sessionServiceProvider);
  return service.getSessionStatistics(
    accountId: activeAccount.userId,
    startDate: DateTime.now().subtract(const Duration(days: 30)),
  );
});

/// Session notifier for CRUD operations
final sessionNotifierProvider =
    StateNotifierProvider<SessionNotifier, AsyncValue<Session?>>((ref) {
      return SessionNotifier(ref);
    });

class SessionNotifier extends StateNotifier<AsyncValue<Session?>> {
  final Ref _ref;

  SessionNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<Session?> startSession({
    String? name,
    String? notes,
    List<String>? tags,
    String? location,
  }) async {
    state = const AsyncValue.loading();
    try {
      final activeAccount = await _ref.read(activeAccountProvider.future);

      if (activeAccount == null) {
        throw Exception('No active account selected');
      }

      final service = _ref.read(sessionServiceProvider);
      final session = await service.startSession(
        accountId: activeAccount.userId,
        name: name,
        notes: notes,
        tags: tags,
        location: location,
      );

      state = AsyncValue.data(session);
      return session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Session?> endSession(Session session) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(sessionServiceProvider);
      final ended = await service.endSession(session);

      state = AsyncValue.data(ended);
      return ended;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> updateSession(
    Session session, {
    String? name,
    String? notes,
    List<String>? tags,
    String? location,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(sessionServiceProvider);
      final updated = await service.updateSession(
        session,
        name: name,
        notes: notes,
        tags: tags,
        location: location,
      );

      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSession(Session session) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(sessionServiceProvider);
      await service.deleteSession(session);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Session?> refreshMetrics(Session session) async {
    try {
      final service = _ref.read(sessionServiceProvider);
      final refreshed = await service.refreshMetrics(session);

      state = AsyncValue.data(refreshed);
      return refreshed;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}
