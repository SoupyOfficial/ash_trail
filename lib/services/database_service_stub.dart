/// Stub database service implementation for unsupported platforms
library;

import 'database_service.dart';

class IsarDatabaseService implements DatabaseService {
  @override
  Future<void> initialize() async {
    throw UnsupportedError('Database not available on this platform');
  }

  @override
  bool get isInitialized => false;

  @override
  dynamic get instance =>
      throw UnsupportedError('Database not available on this platform');

  @override
  Future<void> close() async {}
}
