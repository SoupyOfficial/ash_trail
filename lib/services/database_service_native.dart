import 'database_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/account.dart';
import '../models/log_entry.dart';
import '../models/sync_metadata.dart';
import '../models/user_account.dart';
import '../models/profile.dart';
import '../models/log_record.dart';
import '../models/daily_rollup.dart';
import '../models/log_template.dart';
import '../models/session.dart';

/// Isar implementation for native platforms
class IsarDatabaseService implements DatabaseService {
  Isar? _isar;

  @override
  Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        AccountSchema,
        LogEntrySchema,
        SyncMetadataSchema,
        UserAccountSchema,
        ProfileSchema,
        LogRecordSchema,
        DailyRollupSchema,
        LogTemplateSchema,
        SessionSchema,
      ],
      directory: dir.path,
      name: 'ash_trail',
    );
  }

  @override
  bool get isInitialized => _isar != null;

  @override
  Isar get instance {
    if (_isar == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  @override
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
