import 'hive_database_service.dart';

/// Abstract database service interface
///
/// This abstraction allows for different database implementations.
/// Currently uses Hive on all platforms (web, iOS, Android, desktop).
/// Can be extended to support Firestore for cloud sync.
abstract class DatabaseService {
  /// Get the singleton database service instance
  static DatabaseService get instance => HiveDatabaseService.instance;

  /// Initialize the database
  Future<void> initialize();

  /// Check if database is initialized
  bool get isInitialized;

  /// Close the database
  Future<void> close();

  /// Get database boxes (Hive boxes map)
  dynamic get boxes;
}
