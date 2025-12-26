/// Abstract database service interface
///
/// This abstraction allows the app to use different database implementations
/// based on the platform:
/// - Native platforms (iOS, Android, macOS, Linux, Windows): Isar
/// - Web: Hive or in-memory storage
abstract class DatabaseService {
  /// Initialize the database
  Future<void> initialize();

  /// Check if database is initialized
  bool get isInitialized;

  /// Close the database
  Future<void> close();

  /// Get database instance (platform-specific)
  dynamic get instance;
}
