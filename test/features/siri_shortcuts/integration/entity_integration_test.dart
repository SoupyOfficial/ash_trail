import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcuts_entity.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';

void main() {
  group('SiriShortcutsEntity', () {
    test('should determine if shortcut needs re-donation when not donated', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
        isDonated: false,
      );

      // act & assert
      expect(entity.needsReDonation, isTrue);
    });

    test('should determine if shortcut needs re-donation when never donated',
        () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
        isDonated: true,
        lastDonatedAt: null,
      );

      // act & assert
      expect(entity.needsReDonation, isTrue);
    });

    test('should determine if shortcut needs re-donation after 7 days', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isDonated: true,
        lastDonatedAt: DateTime.now().subtract(const Duration(days: 8)),
      );

      // act & assert
      expect(entity.needsReDonation, isTrue);
    });

    test('should not need re-donation when recently donated', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isDonated: true,
        lastDonatedAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      // act & assert
      expect(entity.needsReDonation, isFalse);
    });

    test('should get effective phrase from custom phrase', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
        customPhrase: 'My custom phrase',
      );

      // act & assert
      expect(entity.effectivePhrase, equals('My custom phrase'));
    });

    test('should get effective phrase from default when no custom', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
      );

      // act & assert
      expect(entity.effectivePhrase, isNotEmpty);
    });

    test('should determine if recently used within 30 days', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
        lastInvokedAt: DateTime.now().subtract(const Duration(days: 15)),
      );

      // act & assert
      expect(entity.isRecentlyUsed, isTrue);
    });

    test('should not be recently used when over 30 days', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
        lastInvokedAt: DateTime.now().subtract(const Duration(days: 35)),
      );

      // act & assert
      expect(entity.isRecentlyUsed, isFalse);
    });

    test('should not be recently used when never invoked', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now(),
      );

      // act & assert
      expect(entity.isRecentlyUsed, isFalse);
    });

    test('should create copy with invocation tracking', () {
      // arrange
      final originalTime = DateTime.now().subtract(const Duration(hours: 1));
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: originalTime,
        invocationCount: 2,
      );

      // act
      final updated = entity.withInvocation();

      // assert
      expect(updated.invocationCount, equals(3));
      expect(updated.lastInvokedAt, isNotNull);
      expect(updated.lastInvokedAt!.isAfter(originalTime), isTrue);
    });

    test('should create copy with donation tracking', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isDonated: false,
      );

      // act
      final updated = entity.withDonation();

      // assert
      expect(updated.isDonated, isTrue);
      expect(updated.lastDonatedAt, isNotNull);
    });
  });

  group('SiriShortcutType', () {
    test('should have correct display name for addLog', () {
      // arrange
      const type = SiriShortcutType.addLog();

      // act & assert
      expect(type.displayName, equals('Add Log'));
    });

    test('should have correct display name for startTimedLog', () {
      // arrange
      const type = SiriShortcutType.startTimedLog();

      // act & assert
      expect(type.displayName, equals('Start Timed Log'));
    });

    test('should have correct intent identifier for addLog', () {
      // arrange
      const type = SiriShortcutType.addLog();

      // act & assert
      expect(type.intentIdentifier, equals('AddLogIntent'));
    });

    test('should have correct intent identifier for startTimedLog', () {
      // arrange
      const type = SiriShortcutType.startTimedLog();

      // act & assert
      expect(type.intentIdentifier, equals('StartTimedLogIntent'));
    });

    test('should have suggested phrases for addLog', () {
      // arrange
      const type = SiriShortcutType.addLog();

      // act & assert
      expect(type.suggestedPhrase, isNotEmpty);
    });

    test('should have suggested phrases for startTimedLog', () {
      // arrange
      const type = SiriShortcutType.startTimedLog();

      // act & assert
      expect(type.suggestedPhrase, isNotEmpty);
    });
  });
}
