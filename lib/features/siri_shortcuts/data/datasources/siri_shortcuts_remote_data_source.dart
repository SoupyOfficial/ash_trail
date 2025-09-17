// Remote data source for Siri shortcuts interaction and platform-specific features.
// Handles iOS Siri shortcuts integration and donation.

import 'dart:io';
import '../models/siri_shortcuts_model.dart';
import '../../domain/entities/siri_shortcut_type.dart';

abstract interface class SiriShortcutsRemoteDataSource {
  /// Check if Siri shortcuts are supported on current platform
  Future<bool> isSiriShortcutsSupported();

  /// Donate a shortcut to Siri (iOS only)
  Future<void> donateShortcut(SiriShortcutsModel shortcut);

  /// Donate multiple shortcuts to Siri
  Future<void> donateShortcuts(List<SiriShortcutsModel> shortcuts);

  /// Record telemetry for shortcut invocation
  Future<void> recordShortcutInvocation({
    required String shortcutId,
    required SiriShortcutType type,
    required DateTime invokedAt,
  });
}

class SiriShortcutsRemoteDataSourceImpl implements SiriShortcutsRemoteDataSource {
  const SiriShortcutsRemoteDataSourceImpl();

  @override
  Future<bool> isSiriShortcutsSupported() async {
    // Siri shortcuts are only supported on iOS
    return Platform.isIOS;
  }

  @override
  Future<void> donateShortcut(SiriShortcutsModel shortcut) async {
    if (!await isSiriShortcutsSupported()) {
      throw UnsupportedError('Siri shortcuts not supported on this platform');
    }

    // TODO: Implement actual Siri shortcuts donation
    // This would use a platform channel or plugin like siri_shortcuts
    // For now, we simulate the donation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> donateShortcuts(List<SiriShortcutsModel> shortcuts) async {
    for (final shortcut in shortcuts) {
      await donateShortcut(shortcut);
    }
  }

  @override
  Future<void> recordShortcutInvocation({
    required String shortcutId,
    required SiriShortcutType type,
    required DateTime invokedAt,
  }) async {
    // TODO: Implement telemetry recording
    // This could integrate with Firebase Analytics or other telemetry services
    await Future.delayed(const Duration(milliseconds: 50));
  }
}