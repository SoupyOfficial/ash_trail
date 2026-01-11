import 'dart:async';
import 'package:hive/hive.dart';
import '../models/account.dart';
import '../models/web_models.dart';
import '../models/model_converters.dart';
import 'account_repository.dart';

/// Web implementation of AccountRepository using Hive
class AccountRepositoryHive implements AccountRepository {
  late final Box _box;
  late final StreamController<List<Account>> _controller;

  AccountRepositoryHive(Map<String, dynamic> boxes) {
    _box = boxes['accounts'] as Box;
    // Ensure new subscribers get an immediate snapshot
    _controller = StreamController<List<Account>>.broadcast(
      onListen: _emitChanges,
    );
    _box.watch().listen((_) => _emitChanges());
  }

  void _emitChanges() {
    getAll().then((accounts) => _controller.add(accounts));
  }

  @override
  Future<List<Account>> getAll() async {
    final accounts = <Account>[];
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webAccount = WebAccount.fromJson(json);
      accounts.add(
        AccountWebConversion.fromWebModel(
          webAccount,
          id: int.tryParse(webAccount.id) ?? 0,
        ),
      );
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
    return account;
  }

  @override
  Future<void> delete(String userId) async {
    await _box.delete(userId);
  }

  @override
  Future<void> setActive(String userId) async {
    // Deactivate all accounts first
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webAccount = WebAccount.fromJson(json);
      final updated = WebAccount(
        id: webAccount.id,
        userId: webAccount.userId,
        email: webAccount.email,
        displayName: webAccount.displayName,
        photoUrl: webAccount.photoUrl,
        isActive: webAccount.userId == userId,
        createdAt: webAccount.createdAt,
        updatedAt: DateTime.now(),
      );
      await _box.put(key, updated.toJson());
    }
  }

  @override
  Future<void> clearActive() async {
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webAccount = WebAccount.fromJson(json);
      final updated = WebAccount(
        id: webAccount.id,
        userId: webAccount.userId,
        email: webAccount.email,
        displayName: webAccount.displayName,
        photoUrl: webAccount.photoUrl,
        isActive: false,
        createdAt: webAccount.createdAt,
        updatedAt: DateTime.now(),
      );
      await _box.put(key, updated.toJson());
    }
  }

  @override
  Stream<Account?> watchActive() {
    return _controller.stream.map((accounts) {
      try {
        return accounts.firstWhere((a) => a.isActive);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Stream<List<Account>> watchAll() {
    return _controller.stream;
  }
}
