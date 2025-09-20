import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/siri_shortcuts/data/datasources/siri_shortcuts_local_data_source.dart';
import 'package:ash_trail/features/siri_shortcuts/data/models/siri_shortcuts_model.dart';

void main() {
  group('SiriShortcutsLocalDataSourceImpl Real Implementation', () {
    late SiriShortcutsLocalDataSourceImpl dataSource;
    late SharedPreferences prefs;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() {
      dataSource = SiriShortcutsLocalDataSourceImpl(prefs);
    });

    tearDown(() async {
      await dataSource.clearShortcuts();
    });

    test('should save and retrieve shortcuts using SharedPreferences',
        () async {
      // arrange
      final shortcut = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime(2024, 1, 1),
        isDonated: false,
        invocationCount: 0,
      );

      // act
      await dataSource.saveShortcut(shortcut);
      final shortcuts = await dataSource.getShortcuts();

      // assert
      expect(shortcuts, hasLength(1));
      expect(shortcuts.first.id, equals('1'));
      expect(shortcuts.first.type, equals('add_log'));
    });

    test('should handle JSON serialization and deserialization', () async {
      // arrange
      final shortcut = SiriShortcutsModel(
        id: '2',
        type: 'start_timed_log',
        createdAt: DateTime(2024, 1, 2),
        isDonated: true,
        invocationCount: 5,
        customPhrase: 'Test phrase',
        lastInvokedAt: DateTime(2024, 1, 3),
        lastDonatedAt: DateTime(2024, 1, 4),
      );

      // act
      await dataSource.saveShortcut(shortcut);
      final retrieved = await dataSource.getShortcutById('2');

      // assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('2'));
      expect(retrieved.type, equals('start_timed_log'));
      expect(retrieved.isDonated, isTrue);
      expect(retrieved.invocationCount, equals(5));
      expect(retrieved.customPhrase, equals('Test phrase'));
    });

    test('should update existing shortcuts', () async {
      // arrange
      final original = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime(2024, 1, 1),
        isDonated: false,
        invocationCount: 0,
      );
      await dataSource.saveShortcut(original);

      // act
      final updated = original.copyWith(
        isDonated: true,
        invocationCount: 3,
        customPhrase: 'Updated phrase',
      );
      await dataSource.saveShortcut(updated);

      // assert
      final retrieved = await dataSource.getShortcutById('1');
      expect(retrieved!.isDonated, isTrue);
      expect(retrieved.invocationCount, equals(3));
      expect(retrieved.customPhrase, equals('Updated phrase'));
    });

    test('should handle multiple shortcuts batch operations', () async {
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
      final retrieved = await dataSource.getShortcuts();

      // assert
      expect(retrieved, hasLength(2));
      expect(retrieved.map((s) => s.id), containsAll(['1', '2']));
    });

    test('should remove shortcuts correctly', () async {
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
      await dataSource.removeShortcut('1');
      final remaining = await dataSource.getShortcuts();

      // assert
      expect(remaining, hasLength(1));
      expect(remaining.first.id, equals('2'));
    });

    test('should clear all shortcuts', () async {
      // arrange
      await dataSource.saveShortcuts([
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
      ]);

      // act
      await dataSource.clearShortcuts();
      final shortcuts = await dataSource.getShortcuts();

      // assert
      expect(shortcuts, isEmpty);
    });

    test('should return null for non-existent shortcut', () async {
      // act
      final shortcut = await dataSource.getShortcutById('non-existent');

      // assert
      expect(shortcut, isNull);
    });

    test('should handle empty storage', () async {
      // act
      final shortcuts = await dataSource.getShortcuts();

      // assert
      expect(shortcuts, isEmpty);
    });
  });
}
