import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/siri_shortcuts/data/datasources/siri_shortcuts_local_data_source.dart';
import 'package:ash_trail/features/siri_shortcuts/data/models/siri_shortcuts_model.dart';

class FakeLocalDataSource implements SiriShortcutsLocalDataSource {
  final List<SiriShortcutsModel> _shortcuts = [];

  @override
  Future<List<SiriShortcutsModel>> getShortcuts() async {
    return List.from(_shortcuts);
  }

  @override
  Future<void> saveShortcuts(List<SiriShortcutsModel> shortcuts) async {
    _shortcuts.clear();
    _shortcuts.addAll(shortcuts);
  }

  @override
  Future<SiriShortcutsModel?> getShortcutById(String id) async {
    return _shortcuts.where((s) => s.id == id).firstOrNull;
  }

  @override
  Future<void> saveShortcut(SiriShortcutsModel shortcut) async {
    _shortcuts.removeWhere((s) => s.id == shortcut.id);
    _shortcuts.add(shortcut);
  }

  @override
  Future<void> removeShortcut(String id) async {
    _shortcuts.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> clearShortcuts() async {
    _shortcuts.clear();
  }
}

void main() {
  group('SiriShortcutsLocalDataSource Integration', () {
    late FakeLocalDataSource dataSource;

    setUp(() {
      dataSource = FakeLocalDataSource();
    });

    test('should save and retrieve shortcuts', () async {
      // arrange
      final shortcut = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime.now(),
        isDonated: false,
        invocationCount: 0,
      );

      // act
      await dataSource.saveShortcut(shortcut);
      final shortcuts = await dataSource.getShortcuts();

      // assert
      expect(shortcuts, hasLength(1));
      expect(shortcuts.first.id, equals('1'));
    });

    test('should get shortcut by id', () async {
      // arrange
      final shortcut = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime.now(),
        isDonated: false,
        invocationCount: 0,
      );
      await dataSource.saveShortcut(shortcut);

      // act
      final result = await dataSource.getShortcutById('1');

      // assert
      expect(result, isNotNull);
      expect(result!.id, equals('1'));
    });

    test('should return null for non-existent shortcut', () async {
      // act
      final result = await dataSource.getShortcutById('non-existent');

      // assert
      expect(result, isNull);
    });

    test('should remove shortcut', () async {
      // arrange
      final shortcut = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime.now(),
        isDonated: false,
        invocationCount: 0,
      );
      await dataSource.saveShortcut(shortcut);

      // act
      await dataSource.removeShortcut('1');
      final shortcuts = await dataSource.getShortcuts();

      // assert
      expect(shortcuts, isEmpty);
    });

    test('should clear all shortcuts', () async {
      // arrange
      final shortcut1 = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime.now(),
        isDonated: false,
        invocationCount: 0,
      );
      final shortcut2 = SiriShortcutsModel(
        id: '2',
        type: 'start_timed_log',
        createdAt: DateTime.now(),
        isDonated: false,
        invocationCount: 0,
      );
      await dataSource.saveShortcut(shortcut1);
      await dataSource.saveShortcut(shortcut2);

      // act
      await dataSource.clearShortcuts();
      final shortcuts = await dataSource.getShortcuts();

      // assert
      expect(shortcuts, isEmpty);
    });

    test('should save multiple shortcuts at once', () async {
      // arrange
      final shortcuts = [
        SiriShortcutsModel(
          id: '1',
          type: 'add_log',
          createdAt: DateTime.now(),
          isDonated: false,
          invocationCount: 0,
        ),
        SiriShortcutsModel(
          id: '2',
          type: 'start_timed_log',
          createdAt: DateTime.now(),
          isDonated: false,
          invocationCount: 0,
        ),
      ];

      // act
      await dataSource.saveShortcuts(shortcuts);
      final result = await dataSource.getShortcuts();

      // assert
      expect(result, hasLength(2));
      expect(result.map((s) => s.id), containsAll(['1', '2']));
    });
  });
}
