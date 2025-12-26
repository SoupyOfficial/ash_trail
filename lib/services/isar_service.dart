import 'database_service_stub.dart'
    if (dart.library.io) 'database_service_native.dart'
    if (dart.library.js_interop) 'database_service_web.dart';

class IsarService {
  static final dynamic _db = IsarDatabaseService();

  /// Initialize database (uses Isar on native, Hive on web)
  static Future<void> initialize() async {
    await _db.initialize();
  }

  /// Get the database instance
  /// On native: returns Isar instance
  /// On web: returns null (use Firestore instead)
  static dynamic get instance => _db.instance;

  /// Check if database is initialized
  static bool get isInitialized => _db.isInitialized;

  /// Close the database
  static Future<void> close() async {
    await _db.close();
  }
}
