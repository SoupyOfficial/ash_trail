import 'database_service.dart';
import 'package:hive/hive.dart';

/// Web implementation using Hive (web-compatible)
/// Uses IndexedDB for storage in the browser
class IsarDatabaseService implements DatabaseService {
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

    // On web, Hive automatically uses IndexedDB - no path needed
    // No need to call Hive.init() on web

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
    print('✅ Hive database initialized for web');
  }

  @override
  bool get isInitialized => _initialized;

  @override
  dynamic get instance {
    if (!_initialized) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    // Return a map of boxes for web
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
