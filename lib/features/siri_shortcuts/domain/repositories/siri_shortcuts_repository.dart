// Siri Shortcuts repository interface for managing shortcut configurations and donations.
// Abstracts Siri shortcuts management from implementation details.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/siri_shortcuts_entity.dart';
import '../entities/siri_shortcut_type.dart';

abstract interface class SiriShortcutsRepository {
  /// Get all configured Siri shortcuts
  Future<Either<AppFailure, List<SiriShortcutsEntity>>> getShortcuts();

  /// Get a specific shortcut by its ID
  Future<Either<AppFailure, SiriShortcutsEntity>> getShortcutById(String id);

  /// Get shortcuts by type
  Future<Either<AppFailure, List<SiriShortcutsEntity>>> getShortcutsByType(
    SiriShortcutType type,
  );

  /// Create a new shortcut configuration
  Future<Either<AppFailure, SiriShortcutsEntity>> createShortcut(
    SiriShortcutsEntity shortcut,
  );

  /// Update an existing shortcut configuration
  Future<Either<AppFailure, SiriShortcutsEntity>> updateShortcut(
    SiriShortcutsEntity shortcut,
  );

  /// Delete a shortcut configuration
  Future<Either<AppFailure, void>> deleteShortcut(String id);

  /// Donate a shortcut to Siri (iOS only)
  Future<Either<AppFailure, void>> donateShortcut(
    SiriShortcutsEntity shortcut,
  );

  /// Donate multiple shortcuts to Siri
  Future<Either<AppFailure, void>> donateShortcuts(
    List<SiriShortcutsEntity> shortcuts,
  );

  /// Check if Siri shortcuts are supported on the current platform
  Future<Either<AppFailure, bool>> isSiriShortcutsSupported();

  /// Record telemetry for shortcut invocation
  Future<Either<AppFailure, void>> recordShortcutInvocation({
    required String shortcutId,
    required SiriShortcutType type,
    required DateTime invokedAt,
  });

  /// Get shortcuts that need to be re-donated
  Future<Either<AppFailure, List<SiriShortcutsEntity>>> getShortcutsNeedingDonation();
}