import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/siri_shortcuts/data/models/siri_shortcuts_model.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcuts_entity.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';

void main() {
  group('SiriShortcutsModel Integration', () {
    test('should convert entity to model and back correctly', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime(2023, 1, 1),
        lastDonatedAt: DateTime(2023, 1, 2),
        invocationCount: 3,
        isDonated: true,
        customPhrase: 'Add a log entry',
        lastInvokedAt: DateTime(2023, 1, 3),
      );

      // act
      final model = SiriShortcutsModel.fromEntity(entity);
      final convertedEntity = model.toEntity();

      // assert
      expect(convertedEntity.id, equals(entity.id));
      expect(convertedEntity.type, equals(entity.type));
      expect(convertedEntity.createdAt, equals(entity.createdAt));
      expect(convertedEntity.lastDonatedAt, equals(entity.lastDonatedAt));
      expect(convertedEntity.invocationCount, equals(entity.invocationCount));
      expect(convertedEntity.isDonated, equals(entity.isDonated));
      expect(convertedEntity.customPhrase, equals(entity.customPhrase));
      expect(convertedEntity.lastInvokedAt, equals(entity.lastInvokedAt));
    });

    test('should handle startTimedLog type', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '2',
        type: const SiriShortcutType.startTimedLog(),
        createdAt: DateTime(2023, 1, 1),
      );

      // act
      final model = SiriShortcutsModel.fromEntity(entity);
      final convertedEntity = model.toEntity();

      // assert
      expect(
          convertedEntity.type, equals(const SiriShortcutType.startTimedLog()));
    });

    test('should handle null optional values', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '3',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime(2023, 1, 1),
      );

      // act
      final model = SiriShortcutsModel.fromEntity(entity);
      final convertedEntity = model.toEntity();

      // assert
      expect(convertedEntity.lastDonatedAt, isNull);
      expect(convertedEntity.customPhrase, isNull);
      expect(convertedEntity.lastInvokedAt, isNull);
      expect(convertedEntity.invocationCount, equals(0));
      expect(convertedEntity.isDonated, isFalse);
    });
  });
}
