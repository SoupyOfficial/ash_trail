// Local data source for Siri shortcuts using SharedPreferences.
// Handles local storage and retrieval of shortcut configurations.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/siri_shortcuts_model.dart';

abstract interface class SiriShortcutsLocalDataSource {
  /// Get all stored shortcuts from local storage
  Future<List<SiriShortcutsModel>> getShortcuts();

  /// Store shortcuts in local storage
  Future<void> saveShortcuts(List<SiriShortcutsModel> shortcuts);

  /// Get a specific shortcut by ID
  Future<SiriShortcutsModel?> getShortcutById(String id);

  /// Save or update a single shortcut
  Future<void> saveShortcut(SiriShortcutsModel shortcut);

  /// Remove a shortcut by ID
  Future<void> removeShortcut(String id);

  /// Clear all shortcuts
  Future<void> clearShortcuts();
}

class SiriShortcutsLocalDataSourceImpl implements SiriShortcutsLocalDataSource {
  const SiriShortcutsLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const String _shortcutsKey = 'siri_shortcuts';

  @override
  Future<List<SiriShortcutsModel>> getShortcuts() async {
    final shortcutsJson = _prefs.getStringList(_shortcutsKey) ?? [];
    return shortcutsJson
        .map((jsonString) => SiriShortcutsModel.fromJson(
              json.decode(jsonString) as Map<String, dynamic>,
            ))
        .toList();
  }

  @override
  Future<void> saveShortcuts(List<SiriShortcutsModel> shortcuts) async {
    final shortcutsJson = shortcuts
        .map((shortcut) => json.encode(shortcut.toJson()))
        .toList();
    await _prefs.setStringList(_shortcutsKey, shortcutsJson);
  }

  @override
  Future<SiriShortcutsModel?> getShortcutById(String id) async {
    final shortcuts = await getShortcuts();
    try {
      return shortcuts.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveShortcut(SiriShortcutsModel shortcut) async {
    final shortcuts = await getShortcuts();
    final existingIndex = shortcuts.indexWhere((s) => s.id == shortcut.id);
    
    if (existingIndex >= 0) {
      shortcuts[existingIndex] = shortcut;
    } else {
      shortcuts.add(shortcut);
    }
    
    await saveShortcuts(shortcuts);
  }

  @override
  Future<void> removeShortcut(String id) async {
    final shortcuts = await getShortcuts();
    shortcuts.removeWhere((s) => s.id == id);
    await saveShortcuts(shortcuts);
  }

  @override
  Future<void> clearShortcuts() async {
    await _prefs.remove(_shortcutsKey);
  }
}