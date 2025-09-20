import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/siri_shortcuts/data/models/siri_shortcuts_model.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcuts_entity.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';

void main() {
  group('SiriShortcutsModel Integration', () {
    test('should convert between entity and model correctly', () {
      // arrange
      final entity = SiriShortcutsEntity(
        id: '1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime(2024, 1, 1),
        lastDonatedAt: DateTime(2024, 1, 2),
        invocationCount: 5,
        isDonated: true,
        customPhrase: 'Custom phrase',
        lastInvokedAt: DateTime(2024, 1, 3),
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

    test('should serialize and deserialize JSON correctly', () {
      // arrange
      final model = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime(2024, 1, 1),
        lastDonatedAt: DateTime(2024, 1, 2),
        invocationCount: 5,
        isDonated: true,
        customPhrase: 'Custom phrase',
        lastInvokedAt: DateTime(2024, 1, 3),
      );

      // act
      final json = model.toJson();
      final deserializedModel = SiriShortcutsModel.fromJson(json);

      // assert
      expect(deserializedModel.id, equals(model.id));
      expect(deserializedModel.type, equals(model.type));
      expect(deserializedModel.createdAt, equals(model.createdAt));
      expect(deserializedModel.lastDonatedAt, equals(model.lastDonatedAt));
      expect(deserializedModel.invocationCount, equals(model.invocationCount));
      expect(deserializedModel.isDonated, equals(model.isDonated));
      expect(deserializedModel.customPhrase, equals(model.customPhrase));
      expect(deserializedModel.lastInvokedAt, equals(model.lastInvokedAt));
    });

    test('should handle nullable fields correctly', () {
      // arrange
      final model = SiriShortcutsModel(
        id: '1',
        type: 'start_timed_log',
        createdAt: DateTime(2024, 1, 1),
        // nullable fields omitted
        invocationCount: 0,
        isDonated: false,
      );

      // act
      final entity = model.toEntity();
      final convertedModel = SiriShortcutsModel.fromEntity(entity);

      // assert
      expect(convertedModel.lastDonatedAt, isNull);
      expect(convertedModel.customPhrase, isNull);
      expect(convertedModel.lastInvokedAt, isNull);
    });

    test('should convert type strings correctly', () {
      // arrange & act
      final addLogType = SiriShortcutsModel.stringToType('add_log');
      final timedLogType = SiriShortcutsModel.stringToType('start_timed_log');

      // assert
      expect(addLogType, equals(const SiriShortcutType.addLog()));
      expect(timedLogType, equals(const SiriShortcutType.startTimedLog()));
    });

    test('should throw error for unknown type strings', () {
      // act & assert
      expect(
        () => SiriShortcutsModel.stringToType('unknown_type'),
        throwsArgumentError,
      );
    });

    test('should handle copyWith functionality', () {
      // arrange
      final original = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime(2024, 1, 1),
        invocationCount: 0,
        isDonated: false,
      );

      // act
      final updated = original.copyWith(
        invocationCount: 5,
        isDonated: true,
        customPhrase: 'Updated phrase',
      );

      // assert
      expect(updated.id, equals(original.id));
      expect(updated.type, equals(original.type));
      expect(updated.createdAt, equals(original.createdAt));
      expect(updated.invocationCount, equals(5));
      expect(updated.isDonated, equals(true));
      expect(updated.customPhrase, equals('Updated phrase'));
    });

    test('should handle equality correctly', () {
      // arrange
      final model1 = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime(2024, 1, 1),
        invocationCount: 0,
        isDonated: false,
      );

      final model2 = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime(2024, 1, 1),
        invocationCount: 0,
        isDonated: false,
      );

      final differentModel = model1.copyWith(id: '2');

      // act & assert
      expect(model1, equals(model2));
      expect(model1, isNot(equals(differentModel)));
      expect(model1.hashCode, equals(model2.hashCode));
    });
  });
}
