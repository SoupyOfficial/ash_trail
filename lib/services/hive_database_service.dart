import 'database_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive implementation for all platforms (web, iOS, Android, desktop)
/// Uses IndexedDB on web, native storage on mobile/desktop
class HiveDatabaseService implements DatabaseService {
  // Singleton instance
  static final HiveDatabaseService _instance = HiveDatabaseService._internal();
  static HiveDatabaseService get instance => _instance;

  factory HiveDatabaseService() => _instance;

  HiveDatabaseService._internal();

  bool _initialized = false;

  // Hive boxes for different data types
  Box? _accountsBox;
  Box? _logEntriesBox;
  Box? _logRecordsBox;
  Box? _profilesBox;
  Box? _userAccountsBox;
  Box? _dailyRollupsBox;
  Box? _sessionsBox;
  Box? _templatesBox;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Hive for Flutter (works on all platforms)
    await Hive.initFlutter();

    // Open boxes for different data types
    _accountsBox = await Hive.openBox('accounts');
    _logEntriesBox = await Hive.openBox('log_entries');
    _logRecordsBox = await Hive.openBox('log_records');
    _profilesBox = await Hive.openBox('profiles');
    _userAccountsBox = await Hive.openBox('user_accounts');
    _dailyRollupsBox = await Hive.openBox('daily_rollups');
    _sessionsBox = await Hive.openBox('sessions');
    _templatesBox = await Hive.openBox('templates');

    _initialized = true;
  }

  @override
  bool get isInitialized => _initialized;

  @override
  dynamic get boxes {
    if (!_initialized) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    // Return a map of boxes
    return {
      'accounts': _accountsBox,
      'logEntries': _logEntriesBox,
      'logRecords': _logRecordsBox,
      'profiles': _profilesBox,
      'userAccounts': _userAccountsBox,
      'dailyRollups': _dailyRollupsBox,
      'sessions': _sessionsBox,
      'templates': _templatesBox,
    };
  }

  @override
  Future<void> close() async {
    await _accountsBox?.close();
    await _logEntriesBox?.close();
    await _logRecordsBox?.close();
    await _profilesBox?.close();
    await _userAccountsBox?.close();
    await _dailyRollupsBox?.close();
    await _sessionsBox?.close();
    await _templatesBox?.close();
    _initialized = false;
  }
}
