import 'dart:async';
import 'package:hive/hive.dart';
import '../logging/app_logger.dart';
import '../models/account.dart';
import '../models/web_models.dart';
import '../models/model_converters.dart';
import '../services/error_reporting_service.dart';
import 'account_repository.dart';

/// Web implementation of AccountRepository using Hive
class AccountRepositoryHive implements AccountRepository {
  static final _log = AppLogger.logger('AccountRepositoryHive');
  static AccountRepositoryHive? _instance;

  factory AccountRepositoryHive(Map<String, dynamic> boxes) {
    _log.t('Factory creating/returning instance');
    _instance ??= AccountRepositoryHive._internal(boxes);
    return _instance!;
  }

  late final Box _box;
  late final StreamController<List<Account>> _controller;
  bool _initialEmitted = false;

  AccountRepositoryHive._internal(Map<String, dynamic> boxes) {
    _log.d('Initializing with Hive box');
    _box = boxes['accounts'] as Box;
    _controller = StreamController<List<Account>>.broadcast(
      onListen: () {
        _log.t('StreamController listener attached');
        if (!_initialEmitted) {
          _initialEmitted = true;
          _emitChanges();
        }
      },
      onCancel: () => _log.t('StreamController listener cancelled'),
    );
    _box.watch().listen((_) {
      _log.t('Hive box change detected');
      _emitChanges();
    });
    _emitChanges();
    Future.microtask(() {
      if (!_controller.isClosed && _controller.hasListener) {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          if (!_controller.isClosed) _emitChanges();
        });
      }
    });
  }

  void _emitChanges() {
    if (_controller.isClosed) {
      _log.w('Controller is CLOSED - cannot emit');
      return;
    }
    getAll()
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            _log.w('getAll() timed out after 5 seconds');
            return <Account>[];
          },
        )
        .then((accounts) {
          if (_controller.isClosed) return;
          try {
            _controller.add(accounts);
          } catch (addError, addStackTrace) {
            _log.e(
              'Error adding to stream',
              error: addError,
              stackTrace: addStackTrace,
            );
            ErrorReportingService.instance.reportException(
              addError,
              stackTrace: addStackTrace,
              context: 'AccountRepositoryHive._emitChanges.add',
            );
          }
        })
        .catchError((e, stackTrace) {
          _log.e('Error in _emitChanges', error: e, stackTrace: stackTrace);
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: stackTrace,
            context: 'AccountRepositoryHive._emitChanges',
          );
          if (!_controller.isClosed) {
            try {
              _controller.addError(e, stackTrace);
            } catch (addError, addStackTrace) {
              _log.e(
                'Error adding error to stream',
                error: addError,
                stackTrace: addStackTrace,
              );
              ErrorReportingService.instance.reportException(
                addError,
                stackTrace: addStackTrace,
                context: 'AccountRepositoryHive._emitChanges.addError',
              );
            }
          }
        });
  }

  @override
  Future<List<Account>> getAll() async {
    final accounts = <Account>[];
    for (var key in _box.keys) {
      try {
        final json = Map<String, dynamic>.from(_box.get(key));
        final webAccount = WebAccount.fromJson(json);
        final account = AccountWebConversion.fromWebModel(
          webAccount,
          id: int.tryParse(webAccount.id) ?? 0,
        );
        accounts.add(account);
      } catch (e, stackTrace) {
        _log.e('Error processing key "$key"', error: e, stackTrace: stackTrace);
        ErrorReportingService.instance.reportException(
          e,
          stackTrace: stackTrace,
          context: 'AccountRepositoryHive.getAll',
        );
      }
    }
    return accounts;
  }

  @override
  Future<Account?> getByUserId(String userId) async {
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webAccount = WebAccount.fromJson(json);
      if (webAccount.userId == userId) {
        return AccountWebConversion.fromWebModel(
          webAccount,
          id: int.tryParse(webAccount.id) ?? 0,
        );
      }
    }
    return null;
  }

  @override
  Future<Account?> getActive() async {
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webAccount = WebAccount.fromJson(json);
      if (webAccount.isActive) {
        return AccountWebConversion.fromWebModel(
          webAccount,
          id: int.tryParse(webAccount.id) ?? 0,
        );
      }
    }
    return null;
  }

  @override
  Future<Account> save(Account account) async {
    final webAccount = account.toWebModel();
    await _box.put(account.userId, webAccount.toJson());
    // Emit updates so listeners (streams and widgets) see the new account immediately
    _emitChanges();
    return account;
  }

  @override
  Future<void> delete(String userId) async {
    await _box.delete(userId);
    // Emit updates so listeners see removal immediately
    _emitChanges();
  }

  @override
  Future<void> setActive(String userId) async {
    _log.d('setActive($userId)');
    final keysToUpdate = <dynamic>[];
    for (var key in _box.keys) {
      keysToUpdate.add(key);
    }
    for (var key in keysToUpdate) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webAccount = WebAccount.fromJson(json);
      final isTargetAccount = webAccount.userId == userId;
      final updated = WebAccount(
        id: webAccount.id,
        userId: webAccount.userId,
        email: webAccount.email,
        displayName: webAccount.displayName,
        photoUrl: webAccount.photoUrl,
        isActive: isTargetAccount,
        isLoggedIn: webAccount.isLoggedIn,
        authProvider: webAccount.authProvider,
        createdAt: webAccount.createdAt,
        updatedAt: DateTime.now(),
        lastAccessedAt:
            isTargetAccount ? DateTime.now() : webAccount.lastAccessedAt,
        refreshToken: webAccount.refreshToken,
        accessToken: webAccount.accessToken,
        tokenExpiresAt: webAccount.tokenExpiresAt,
      );
      await _box.put(key, updated.toJson());
    }

    _emitChanges();
  }

  @override
  Future<void> clearActive() async {
    // Deactivate all accounts (but preserve isLoggedIn state for multi-account)
    final keysToUpdate = <dynamic>[];
    for (var key in _box.keys) {
      keysToUpdate.add(key);
    }

    for (var key in keysToUpdate) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webAccount = WebAccount.fromJson(json);
      final updated = WebAccount(
        id: webAccount.id,
        userId: webAccount.userId,
        email: webAccount.email,
        displayName: webAccount.displayName,
        photoUrl: webAccount.photoUrl,
        isActive: false,
        isLoggedIn: webAccount.isLoggedIn, // Preserve login state
        authProvider: webAccount.authProvider,
        createdAt: webAccount.createdAt,
        updatedAt: DateTime.now(),
        lastAccessedAt: webAccount.lastAccessedAt,
        refreshToken: webAccount.refreshToken,
        accessToken: webAccount.accessToken,
        tokenExpiresAt: webAccount.tokenExpiresAt,
      );
      await _box.put(key, updated.toJson());
    }

    // Explicitly emit changes after clearActive
    _emitChanges();
  }

  @override
  Stream<Account?> watchActive() {
    // Fetch current active account to emit immediately.
    // This prevents a race condition where invalidated StreamProviders
    // re-subscribe to the broadcast stream AFTER pending emissions have
    // already been delivered (and missed), leaving the provider stuck
    // in AsyncLoading forever.
    final currentAccounts = _getAllAccountsSafe();
    Account? currentActive;
    try {
      currentActive = currentAccounts.firstWhere((a) => a.isActive);
    } catch (_) {
      currentActive = null;
    }

    final mappedStream = _controller.stream.map((accounts) {
      try {
        return accounts.firstWhere((a) => a.isActive);
      } catch (e, st) {
        _log.t(
          'No active account found in watchActive',
          error: e,
          stackTrace: st,
        );
        return null;
      }
    });

    // Emit current state first, then forward broadcast stream updates.
    // Mirrors the pattern used by LogRecordRepositoryHive.watchByAccount().
    return Stream<Account?>.value(currentActive).asyncExpand((initial) async* {
      yield initial;
      yield* mappedStream;
    });
  }

  @override
  Stream<List<Account>> watchAll() {
    // Emit current state immediately, then forward broadcast stream updates.
    final currentAccounts = _getAllAccountsSafe();

    final forwardedStream = _controller.stream.handleError((error, stackTrace) {
      _log.e('watchAll stream error', error: error, stackTrace: stackTrace);
      throw error;
    });

    return Stream<List<Account>>.value(currentAccounts).asyncExpand((
      initial,
    ) async* {
      yield initial;
      yield* forwardedStream;
    });
  }

  /// Safe version of getAll() that doesn't throw on parse errors.
  /// Used for initial stream emissions where we need a best-effort snapshot.
  List<Account> _getAllAccountsSafe() {
    final accounts = <Account>[];
    for (var key in _box.keys) {
      try {
        final json = Map<String, dynamic>.from(_box.get(key));
        final webAccount = WebAccount.fromJson(json);
        final account = AccountWebConversion.fromWebModel(
          webAccount,
          id: int.tryParse(webAccount.id) ?? 0,
        );
        accounts.add(account);
      } catch (e, stackTrace) {
        _log.e('Error processing key "$key"', error: e, stackTrace: stackTrace);
      }
    }
    return accounts;
  }
}
