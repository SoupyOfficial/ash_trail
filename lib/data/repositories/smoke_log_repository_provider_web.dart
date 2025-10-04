import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/capture_hit/data/repositories/smoke_log_repository_prefs.dart';
import '../../features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'smoke_log_repository_memory.dart';

Future<SmokeLogRepository> createSmokeLogRepository(Ref ref) async {
  // Isar 3.x currently does not support web (per error message). Persist via SharedPreferences.
  try {
    final prefs = await SharedPreferences.getInstance();
    return SmokeLogRepositoryPrefs(prefs);
  } catch (_) {
    // Last resort: keep session functional with in-memory store.
    return SmokeLogRepositoryMemory();
  }
}
