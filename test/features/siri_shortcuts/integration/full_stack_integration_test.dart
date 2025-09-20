import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/siri_shortcuts/data/datasources/siri_shortcuts_local_data_source.dart';
import 'package:ash_trail/features/siri_shortcuts/data/datasources/siri_shortcuts_remote_data_source.dart';
import 'package:ash_trail/features/siri_shortcuts/data/repositories/siri_shortcuts_repository_impl.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/usecases/get_siri_shortcuts_use_case.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/usecases/donate_shortcuts_use_case.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/usecases/handle_shortcut_invocation_use_case.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/usecases/initialize_default_shortcuts_use_case.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcuts_entity.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';

void main() {
  group('Full Siri Shortcuts Integration', () {
    late SiriShortcutsLocalDataSourceImpl localDataSource;
    late SiriShortcutsRemoteDataSourceImpl remoteDataSource;
    late SiriShortcutsRepositoryImpl repository;
    late SharedPreferences prefs;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() {
      localDataSource = SiriShortcutsLocalDataSourceImpl(prefs);
      remoteDataSource = const SiriShortcutsRemoteDataSourceImpl();
      repository = SiriShortcutsRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('should create and retrieve shortcuts end-to-end', () async {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
      );

      // act - create shortcut
      final createResult = await repository.createShortcut(entity);

      // assert create succeeded
      expect(createResult.isRight(), isTrue);

      // act - retrieve shortcuts
      final getResult = await repository.getShortcuts();

      // assert retrieve succeeded
      expect(getResult.isRight(), isTrue);
      getResult.fold(
        (failure) => fail('Should not fail'),
        (shortcuts) {
          expect(shortcuts, hasLength(1));
          expect(shortcuts.first.id, equals('1'));
        },
      );
    });

    test('should test get shortcuts use case', () async {
      // arrange
      final useCase = GetSiriShortcutsUseCase(repository);
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.startTimedLog(),
        createdAt: DateTime.now(),
      );
      await repository.createShortcut(entity);

      // act
      final result = await useCase.call();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (shortcuts) {
          expect(shortcuts, hasLength(1));
          expect(shortcuts.first.type,
              equals(const SiriShortcutType.startTimedLog()));
        },
      );
    });

    test('should test donate shortcuts use case', () async {
      // arrange
      final useCase = DonateShortcutsUseCase(repository);

      // act
      final result = await useCase.call();

      // assert - will likely fail due to platform not being iOS, but this exercises the code
      expect(result.isLeft(), isTrue);
    });

    test('should test handle shortcut invocation use case', () async {
      // arrange
      final useCase = HandleShortcutInvocationUseCase(repository);

      // act
      final result = await useCase.call(const SiriShortcutType.addLog());

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (route) {
          expect(route, isNotNull);
        },
      );
    });

    test('should test initialize default shortcuts use case', () async {
      // arrange
      final useCase = InitializeDefaultShortcutsUseCase(repository);

      // act
      final result = await useCase.call();

      // assert
      expect(result.isRight(), isTrue);

      // Note: On test platform (non-iOS), no shortcuts will be created
      // because platform support returns false, which is expected behavior
      final getResult = await repository.getShortcuts();
      getResult.fold(
        (failure) => fail('Should not fail'),
        (shortcuts) {
          // On non-iOS platforms, shortcuts list remains empty
          expect(shortcuts, isEmpty);
        },
      );
    });

    test('should handle repository error cases', () async {
      // Test getting non-existent shortcut
      final result = await repository.getShortcutById('non-existent');
      expect(result.isLeft(), isTrue);
    });

    test('should handle shortcuts needing donation', () async {
      // arrange
      final entity1 = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
        isDonated: false,
      );
      final entity2 = SiriShortcutsEntity(
        id: '2',
        type: const SiriShortcutType.startTimedLog(),
        createdAt: DateTime.now(),
        isDonated: true,
        lastDonatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      await repository.createShortcut(entity1);
      await repository.createShortcut(entity2);

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

    test('should handle shortcuts by type filtering', () async {
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

    test('should handle shortcut updates', () async {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
        customPhrase: 'Original phrase',
      );
      await repository.createShortcut(entity);

      // act
      final updatedEntity = entity.copyWith(customPhrase: 'Updated phrase');
      final updateResult = await repository.updateShortcut(updatedEntity);

      // assert
      expect(updateResult.isRight(), isTrue);

      final getResult = await repository.getShortcutById('1');
      getResult.fold(
        (failure) => fail('Should not fail'),
        (shortcut) {
          expect(shortcut.customPhrase, equals('Updated phrase'));
        },
      );
    });

    test('should handle shortcut deletion', () async {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
      );
      await repository.createShortcut(entity);

      // act
      final deleteResult = await repository.deleteShortcut('1');

      // assert
      expect(deleteResult.isRight(), isTrue);

      final getResult = await repository.getShortcuts();
      getResult.fold(
        (failure) => fail('Should not fail'),
        (shortcuts) {
          expect(shortcuts, isEmpty);
        },
      );
    });

    test('should check platform support', () async {
      // act
      final result = await repository.isSiriShortcutsSupported();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (isSupported) {
          // Will be false on test platform (not iOS)
          expect(isSupported, isFalse);
        },
      );
    });
  });
}
