import '../models/account.dart';
import 'account_repository.dart';

/// Stub implementation for unsupported platforms
class AccountRepositoryStub implements AccountRepository {
  @override
  Future<List<Account>> getAll() {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<Account?> getByUserId(String userId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<Account?> getActive() {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<Account> save(Account account) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<void> delete(String userId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<void> setActive(String userId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Stream<Account?> watchActive() {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Stream<List<Account>> watchAll() {
    throw UnsupportedError('Platform not supported');
  }
}
