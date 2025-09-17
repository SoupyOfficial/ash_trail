import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/siri_shortcuts/data/repositories/siri_shortcuts_repository_impl.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcuts_entity.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';
import 'package:ash_trail/features/siri_shortcuts/data/datasources/siri_shortcuts_local_data_source.dart';
import 'package:ash_trail/features/siri_shortcuts/data/datasources/siri_shortcuts_remote_data_source.dart';
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

class FakeRemoteDataSource implements SiriShortcutsRemoteDataSource {
  @override
  Future<void> donateShortcut(SiriShortcutsModel shortcut) async {
    // Mock implementation
  }

  @override
  Future<void> donateShortcuts(List<SiriShortcutsModel> shortcuts) async {
    // Mock implementation
  }

  @override
  Future<bool> isSiriShortcutsSupported() async {
    return true; // Mock supported
  }

  @override
  Future<void> recordShortcutInvocation({
    required String shortcutId,
    required SiriShortcutType type,
    required DateTime invokedAt,
  }) async {
    // Mock implementation
  }
}

void main() {
  group('SiriShortcutsRepositoryImpl Integration', () {
    late SiriShortcutsRepositoryImpl repository;
    late FakeLocalDataSource localDataSource;
    late FakeRemoteDataSource remoteDataSource;

    setUp(() {
      localDataSource = FakeLocalDataSource();
      remoteDataSource = FakeRemoteDataSource();
      repository = SiriShortcutsRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );
    });

    test('should create and retrieve shortcuts', () async {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
      );

      // act
      final createResult = await repository.createShortcut(entity);
      final getAllResult = await repository.getShortcuts();

      // assert
      expect(createResult.isRight(), isTrue);
      expect(getAllResult.isRight(), isTrue);
      getAllResult.fold(
        (failure) => fail('Should not fail'),
        (shortcuts) {
          expect(shortcuts, hasLength(1));
          expect(shortcuts.first.id, equals('1'));
        },
      );
    });

    test('should get shortcut by id', () async {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
      );
      await repository.createShortcut(entity);

      // act
      final result = await repository.getShortcutById('1');

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (shortcut) {
          expect(shortcut.id, equals('1'));
          expect(shortcut.type, equals(const SiriShortcutType.addLog()));
        },
      );
    });

    test('should filter shortcuts by type', () async {
      // arrange
      final addLogShortcut = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
      );
      final timedLogShortcut = SiriShortcutsEntity(
        id: '2',
        type: const SiriShortcutType.startTimedLog(),
        createdAt: DateTime.now(),
      );

      await repository.createShortcut(addLogShortcut);
      await repository.createShortcut(timedLogShortcut);

      // act
      final result =
          await repository.getShortcutsByType(const SiriShortcutType.addLog());

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (shortcuts) {
          expect(shortcuts, hasLength(1));
          expect(shortcuts.first.type, equals(const SiriShortcutType.addLog()));
        },
      );
    });

    test('should update shortcut', () async {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
        customPhrase: 'Original phrase',
      );
      await repository.createShortcut(entity);

      final updatedEntity = entity.copyWith(customPhrase: 'Updated phrase');

      // act
      final result = await repository.updateShortcut(updatedEntity);

      // assert
      expect(result.isRight(), isTrue);

      final getResult = await repository.getShortcutById('1');
      getResult.fold(
        (failure) => fail('Should not fail'),
        (shortcut) {
          expect(shortcut.customPhrase, equals('Updated phrase'));
        },
      );
    });

    test('should delete shortcut', () async {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
      );
      await repository.createShortcut(entity);

      // act
      final result = await repository.deleteShortcut('1');

      // assert
      expect(result.isRight(), isTrue);

      final getResult = await repository.getShortcuts();
      getResult.fold(
        (failure) => fail('Should not fail'),
        (shortcuts) {
          expect(shortcuts, isEmpty);
        },
      );
    });

    test('should identify shortcuts needing donation', () async {
      // arrange
      final needsDonation = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
        isDonated: false,
      );

      final alreadyDonated = SiriShortcutsEntity(
        id: '2',
        type: const SiriShortcutType.startTimedLog(),
        createdAt: DateTime.now(),
        isDonated: true,
        lastDonatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      await repository.createShortcut(needsDonation);
      await repository.createShortcut(alreadyDonated);

      // act
      final result = await repository.getShortcutsNeedingDonation();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (shortcuts) {
          expect(shortcuts, hasLength(1));
          expect(shortcuts.first.id, equals('1'));
        },
      );
    });
  });
}
