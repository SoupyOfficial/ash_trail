import 'database_service.dart';
import 'package:flutter/foundation.dart';
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
    if (_initialized) {
      debugPrint(
        '🏗️ [HiveDatabaseService.initialize] Already initialized, skipping',
      );
      return;
    }

    debugPrint(
      '\n🏗️ [HiveDatabaseService.initialize] START at ${DateTime.now()}',
    );

    // Initialize Hive for Flutter (works on all platforms)
    debugPrint('   📦 Calling Hive.initFlutter()...');
    await Hive.initFlutter();
    debugPrint('   ✅ Hive.initFlutter() completed');

    // Open boxes for different data types
    debugPrint('   📂 Opening Hive boxes...');
    _accountsBox = await Hive.openBox('accounts');
    debugPrint(
      '      ✅ Opened accounts box with ${_accountsBox!.length} items',
    );

    _logEntriesBox = await Hive.openBox('log_entries');
    debugPrint('      ✅ Opened log_entries box');

    _logRecordsBox = await Hive.openBox('log_records');
    debugPrint('      ✅ Opened log_records box');

    _profilesBox = await Hive.openBox('profiles');
    debugPrint('      ✅ Opened profiles box');

    _userAccountsBox = await Hive.openBox('user_accounts');
    debugPrint('      ✅ Opened user_accounts box');

    _dailyRollupsBox = await Hive.openBox('daily_rollups');
    debugPrint('      ✅ Opened daily_rollups box');

    _sessionsBox = await Hive.openBox('sessions');
    debugPrint('      ✅ Opened sessions box');

    _templatesBox = await Hive.openBox('templates');
    debugPrint('      ✅ Opened templates box');

    _initialized = true;
    debugPrint('   ✅ All boxes opened successfully\n');
  }

  @override
  bool get isInitialized => _initialized;

  @override
  dynamic get boxes {
    debugPrint(
      '🏗️ [HiveDatabaseService.boxes] Accessing boxes at ${DateTime.now()}',
    );
    if (!_initialized) {
      debugPrint('   ❌ CRITICAL: Database not initialized!');
      throw Exception('Database not initialized. Call initialize() first.');
    }
    // Return a map of boxes
    debugPrint(
      '   ✅ Returning boxes map with ${_accountsBox!.length} accounts',
    );
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
