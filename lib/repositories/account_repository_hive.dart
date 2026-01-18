import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/account.dart';
import '../models/web_models.dart';
import '../models/model_converters.dart';
import 'account_repository.dart';

/// Web implementation of AccountRepository using Hive
class AccountRepositoryHive implements AccountRepository {
  // Singleton instance
  static AccountRepositoryHive? _instance;

  factory AccountRepositoryHive(Map<String, dynamic> boxes) {
    debugPrint(
      '🏭 [AccountRepositoryHive.factory] Creating/returning instance at ${DateTime.now()}',
    );
    if (_instance == null) {
      debugPrint('   🆕 Instance is null, creating new instance...');
      _instance = AccountRepositoryHive._internal(boxes);
    } else {
      debugPrint('   ♻️ Instance already exists, reusing...');
    }
    return _instance!;
  }

  late final Box _box;
  late final StreamController<List<Account>> _controller;
  bool _initialEmitted = false;

  AccountRepositoryHive._internal(Map<String, dynamic> boxes) {
    debugPrint(
      '\n🏗️ [AccountRepositoryHive._internal] Initializing at ${DateTime.now()}',
    );
    _box = boxes['accounts'] as Box;
    debugPrint('   ✅ Got Hive box: ${_box.name}');
    debugPrint('   📊 Box has ${_box.length} items');
    debugPrint('   🔑 Box keys: ${_box.keys.toList()}');

    // Create broadcast stream controller with onListen callback to emit on first subscription
    _controller = StreamController<List<Account>>.broadcast(
      onListen: () {
        debugPrint(
          '   👂 [StreamController.onListen] LISTENER ATTACHED at ${DateTime.now()}',
        );
        // Emit initial data when first listener attaches
        if (!_initialEmitted) {
          debugPrint(
            '   🔄 [onListen] First listener - triggering initial _emitChanges()',
          );
          _initialEmitted = true;
          _emitChanges();
        }
      },
      onCancel: () {
        debugPrint(
          '   👋 [StreamController] LISTENER CANCELLED at ${DateTime.now()}',
        );
      },
    );
    debugPrint(
      '   ✅ Created broadcast StreamController with onListen callback',
    );

    // Listen to box changes and emit updates
    _box.watch().listen((_) {
      debugPrint('   🔔 [Hive Box] Change detected at ${DateTime.now()}');
      _emitChanges();
    });
    debugPrint('   ✅ Set up Hive box watch listener');

    // Seed initial snapshot so StreamProvider leaves loading state
    debugPrint('   🌱 Emitting initial snapshot...');
    _emitChanges();

    // Also emit immediately on next microtask to ensure data is sent
    Future.microtask(() {
      debugPrint('   ⏰ [microtask] Checking if data was emitted...');
      if (!_controller.isClosed && _controller.hasListener) {
        debugPrint(
          '   ⏰ [microtask] Controller has listeners, verifying emission...',
        );
        // Trigger another emission to ensure data gets through
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          if (!_controller.isClosed) {
            debugPrint('   ⏰ [delayed] Forcing re-emission after 100ms');
            _emitChanges();
          }
        });
      }
    });

    debugPrint('   ✅ Initial snapshot emission queued\n');
  }

  void _emitChanges() {
    debugPrint('\n🔄 [_emitChanges] START at ${DateTime.now()}');
    debugPrint('   🔍 Controller closed? ${_controller.isClosed}');
    debugPrint('   🔍 Controller hasListener? ${_controller.hasListener}');

    if (_controller.isClosed) {
      debugPrint('   ⚠️ CRITICAL: Controller is CLOSED - cannot emit!');
      return;
    }

    // Wrap getAll() with a timeout to catch hanging calls
    Future<List<Account>> getAllWithTimeout() {
      debugPrint('   ⏱️ Starting getAll() with 5 second timeout...');
      return getAll().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('   ⚠️ CRITICAL: getAll() timed out after 5 seconds!');
          return <Account>[];
        },
      );
    }

    getAllWithTimeout()
        .then((accounts) {
          debugPrint(
            '   ✅ getAll() completed with ${accounts.length} accounts',
          );
          for (var i = 0; i < accounts.length; i++) {
            debugPrint(
              '      $i: ${accounts[i].userId} - ${accounts[i].email} (active: ${accounts[i].isActive})',
            );
          }

          if (_controller.isClosed) {
            debugPrint(
              '   ⚠️ CRITICAL: Controller became CLOSED between getAll and add!',
            );
            return;
          }

          debugPrint('   📤 Adding ${accounts.length} accounts to stream');
          try {
            _controller.add(accounts);
            debugPrint(
              '   ✅ Successfully added to stream at ${DateTime.now()}',
            );
          } catch (addError, addStackTrace) {
            debugPrint('   ❌ ERROR adding to stream: $addError');
            debugPrint('   StackTrace: $addStackTrace');
          }
        })
        .catchError((e, stackTrace) {
          debugPrint('   ❌ Error in _emitChanges: $e');
          debugPrint('   StackTrace: $stackTrace');
          if (!_controller.isClosed) {
            try {
              _controller.addError(e, stackTrace);
              debugPrint('   ❌ Error added to stream');
            } catch (addError, addStackTrace) {
              debugPrint('   ❌ ERROR adding error to stream: $addError');
              debugPrint('   StackTrace: $addStackTrace');
            }
          }
        });
  }

  @override
  Future<List<Account>> getAll() async {
    debugPrint('\n📖 [getAll] START at ${DateTime.now()}');
    debugPrint('   📦 Box length: ${_box.length}');
    debugPrint('   🔑 Box keys: ${_box.keys.toList()}');

    final accounts = <Account>[];
    for (var key in _box.keys) {
      try {
        final json = Map<String, dynamic>.from(_box.get(key));
        debugPrint('   🔍 Processing key "$key": ${json.keys.toList()}');
        final webAccount = WebAccount.fromJson(json);
        final account = AccountWebConversion.fromWebModel(
          webAccount,
          id: int.tryParse(webAccount.id) ?? 0,
        );
        accounts.add(account);
        debugPrint('      ✅ Added: ${account.userId} - ${account.email}');
      } catch (e, stackTrace) {
        debugPrint('   ❌ Error processing key "$key": $e');
        debugPrint('   StackTrace: $stackTrace');
      }
    }

    debugPrint('   ✅ getAll() returning ${accounts.length} accounts\n');
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
    // Deactivate all accounts first, then activate the target one
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

    // Explicitly emit changes after setActive
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
    debugPrint('🔴 [watchActive] Creating stream at ${DateTime.now()}');
    return _controller.stream.map((accounts) {
      debugPrint('🔴 [watchActive.map] Processing ${accounts.length} accounts');
      try {
        final active = accounts.firstWhere((a) => a.isActive);
        debugPrint('   ✅ Found active account: ${active.userId}');
        return active;
      } catch (e) {
        debugPrint('   ⚠️ No active account found');
        return null;
      }
    });
  }

  @override
  Stream<List<Account>> watchAll() {
    debugPrint('🟢 [watchAll] CREATING STREAM at ${DateTime.now()}');
    debugPrint('   🔍 Controller closed? ${_controller.isClosed}');
    debugPrint('   🔍 Controller hasListener? ${_controller.hasListener}');

    // Return the raw controller stream wrapped with logging
    // DO NOT use asBroadcastStream - the controller is already broadcast
    return _controller.stream
        .map((accounts) {
          debugPrint(
            '🟢 [watchAll.map] DATA RECEIVED: ${accounts.length} accounts at ${DateTime.now()}',
          );
          return accounts;
        })
        .handleError((error, stackTrace) {
          debugPrint('🟢 [watchAll.map] ERROR RECEIVED: $error');
          throw error;
        });
  }
}
