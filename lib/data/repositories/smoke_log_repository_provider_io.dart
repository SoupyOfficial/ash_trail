import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/capture_hit/data/repositories/smoke_log_repository_prefs.dart';
import '../../features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'smoke_log_repository_isar.dart';
import 'smoke_log_repository_memory.dart';

Future<SmokeLogRepository> createSmokeLogRepository(Ref ref) async {
  try {
    return await ref.watch(smokeLogRepositoryIsarProvider.future);
  } on MissingPluginException {
    return await _buildPrefsRepository();
  } on UnsupportedError catch (e) {
    if (e.toString().contains('_Namespace')) {
      return await _buildPrefsRepository();
    }
    rethrow;
  } on IsarError {
    // Any Isar-specific initialization failure → fall back to persisted prefs storage.
    return await _buildPrefsRepository();
  } catch (_) {
    // Last resort fallback.
    return await _buildPrefsRepository();
  }
}

Future<SmokeLogRepository> _buildPrefsRepository() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return SmokeLogRepositoryPrefs(prefs);
  } catch (_) {
    // If even SharedPreferences fails (rare), fall back to volatile in-memory store
    // so the logging UI remains functional for the session.
    return SmokeLogRepositoryMemory();
  }
}
