import 'package:flutter_test/flutter_test.dart';

import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/data/models/smoke_log_dto.dart';

void main() {
  // Test data
  final testDateTime = DateTime.now();
  final baseTestSmokeLog = SmokeLog(
    id: 'test-id',
    accountId: 'test-account',
    ts: testDateTime,
    durationMs: 30000,
    methodId: 'test-method',
    potency: 7,
    moodScore: 8,
    physicalScore: 6,
    notes: 'Test notes',
    deviceLocalId: 'device-123',
    createdAt: testDateTime,
    updatedAt: testDateTime,
  );

  final baseTestSmokeLogDto = SmokeLogDto(
    id: 'test-id',
    accountId: 'test-account',
    ts: testDateTime,
    durationMs: 30000,
    methodId: 'test-method',
    potency: 7,
    moodScore: 8,
    physicalScore: 6,
    notes: 'Test notes',
    deviceLocalId: 'device-123',
    createdAt: testDateTime,
    updatedAt: testDateTime,
    isDeleted: false,
    isPendingSync: true,
  );

  group('SmokeLogDto', () {
    group('constructor', () {
      test('creates dto with all required fields', () {
        // Act
        final dto = SmokeLogDto(
          id: 'test-id',
          accountId: 'test-account',
          ts: testDateTime,
          durationMs: 30000,
          moodScore: 8,
          physicalScore: 6,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // Assert
        expect(dto.id, equals('test-id'));
        expect(dto.accountId, equals('test-account'));
        expect(dto.ts, equals(testDateTime));
        expect(dto.durationMs, equals(30000));
        expect(dto.moodScore, equals(8));
        expect(dto.physicalScore, equals(6));
        expect(dto.createdAt, equals(testDateTime));
        expect(dto.updatedAt, equals(testDateTime));
        expect(dto.isDeleted, isFalse); // Default value
        expect(dto.isPendingSync, isFalse); // Default value
      });

      test('creates dto with optional fields', () {
        // Act
        final dto = SmokeLogDto(
          id: 'test-id',
          accountId: 'test-account',
          ts: testDateTime,
          durationMs: 30000,
          methodId: 'test-method',
          potency: 7,
          moodScore: 8,
          physicalScore: 6,
          notes: 'Test notes',
          deviceLocalId: 'device-123',
          createdAt: testDateTime,
          updatedAt: testDateTime,
          isDeleted: true,
          isPendingSync: true,
        );

        // Assert
        expect(dto.methodId, equals('test-method'));
        expect(dto.potency, equals(7));
        expect(dto.notes, equals('Test notes'));
        expect(dto.deviceLocalId, equals('device-123'));
        expect(dto.isDeleted, isTrue);
        expect(dto.isPendingSync, isTrue);
      });

      test('creates dto with null optional fields', () {
        // Act
        final dto = SmokeLogDto(
          id: 'test-id',
          accountId: 'test-account',
          ts: testDateTime,
          durationMs: 30000,
          moodScore: 8,
          physicalScore: 6,
          createdAt: testDateTime,
          updatedAt: testDateTime,
          methodId: null,
          potency: null,
          notes: null,
          deviceLocalId: null,
        );

        // Assert
        expect(dto.methodId, isNull);
        expect(dto.potency, isNull);
        expect(dto.notes, isNull);
        expect(dto.deviceLocalId, isNull);
      });
    });

    group('equality and hashing', () {
      test('identical dtos are equal', () {
        // Arrange
        final dto1 = baseTestSmokeLogDto;
        final dto2 = baseTestSmokeLogDto.copyWith();

        // Act & Assert
        expect(dto1, equals(dto2));
        expect(dto1.hashCode, equals(dto2.hashCode));
      });

      test('dtos with different ids are not equal', () {
        // Arrange
        final dto1 = baseTestSmokeLogDto;
        final dto2 = dto1.copyWith(id: 'different-id');

        // Act & Assert
        expect(dto1, isNot(equals(dto2)));
        expect(dto1.hashCode, isNot(equals(dto2.hashCode)));
      });

      test('dtos with different sync states are not equal', () {
        // Arrange
        final dto1 = baseTestSmokeLogDto;
        final dto2 = dto1.copyWith(isPendingSync: false);

        // Act & Assert
        expect(dto1, isNot(equals(dto2)));
      });
    });

    group('copyWith', () {
      test('copyWith creates new instance with modified fields', () {
        // Arrange
        final original = baseTestSmokeLogDto;

        // Act
        final modified = original.copyWith(
          notes: 'Updated notes',
          isDeleted: true,
          isPendingSync: false,
        );

        // Assert
        expect(modified.id, equals(original.id));
        expect(modified.notes, equals('Updated notes'));
        expect(modified.isDeleted, isTrue);
        expect(modified.isPendingSync, isFalse);
        expect(original.notes, equals('Test notes')); // Original unchanged
      });

      test('copyWith with no parameters returns identical dto', () {
        // Arrange
        final original = baseTestSmokeLogDto;

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy, equals(original));
        expect(copy, isNot(same(original))); // Different instance
      });
    });

    group('JSON serialization', () {
      test('fromJson creates correct dto', () {
        // Arrange
        final json = <String, dynamic>{
          'id': 'test-id',
          'accountId': 'test-account',
          'ts': testDateTime.toIso8601String(),
          'durationMs': 30000,
          'methodId': 'test-method',
          'potency': 7,
          'moodScore': 8,
          'physicalScore': 6,
          'notes': 'Test notes',
          'deviceLocalId': 'device-123',
          'createdAt': testDateTime.toIso8601String(),
          'updatedAt': testDateTime.toIso8601String(),
          'isDeleted': false,
          'isPendingSync': true,
        };

        // Act
        final dto = SmokeLogDto.fromJson(json);

        // Assert
        expect(dto.id, equals('test-id'));
        expect(dto.accountId, equals('test-account'));
        expect(dto.ts, equals(testDateTime));
        expect(dto.durationMs, equals(30000));
        expect(dto.methodId, equals('test-method'));
        expect(dto.potency, equals(7));
        expect(dto.moodScore, equals(8));
        expect(dto.physicalScore, equals(6));
        expect(dto.notes, equals('Test notes'));
        expect(dto.deviceLocalId, equals('device-123'));
        expect(dto.createdAt, equals(testDateTime));
        expect(dto.updatedAt, equals(testDateTime));
        expect(dto.isDeleted, isFalse);
        expect(dto.isPendingSync, isTrue);
      });

      test('toJson creates correct json', () {
        // Arrange
        final dto = baseTestSmokeLogDto;

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['accountId'], equals('test-account'));
        expect(json['ts'], equals(testDateTime.toIso8601String()));
        expect(json['durationMs'], equals(30000));
        expect(json['methodId'], equals('test-method'));
        expect(json['potency'], equals(7));
        expect(json['moodScore'], equals(8));
        expect(json['physicalScore'], equals(6));
        expect(json['notes'], equals('Test notes'));
        expect(json['deviceLocalId'], equals('device-123'));
        expect(json['createdAt'], equals(testDateTime.toIso8601String()));
        expect(json['updatedAt'], equals(testDateTime.toIso8601String()));
        expect(json['isDeleted'], isFalse);
        expect(json['isPendingSync'], isTrue);
      });

      test('fromJson handles null optional fields', () {
        // Arrange
        final json = <String, dynamic>{
          'id': 'test-id',
          'accountId': 'test-account',
          'ts': testDateTime.toIso8601String(),
          'durationMs': 30000,
          'moodScore': 8,
          'physicalScore': 6,
          'createdAt': testDateTime.toIso8601String(),
          'updatedAt': testDateTime.toIso8601String(),
          'isDeleted': false,
          'isPendingSync': false,
        };

        // Act
        final dto = SmokeLogDto.fromJson(json);

        // Assert
        expect(dto.methodId, isNull);
        expect(dto.potency, isNull);
        expect(dto.notes, isNull);
        expect(dto.deviceLocalId, isNull);
      });

      test('roundtrip json serialization preserves data', () {
        // Arrange
        final original = baseTestSmokeLogDto;

        // Act
        final json = original.toJson();
        final restored = SmokeLogDto.fromJson(json);

        // Assert
        expect(restored, equals(original));
      });
    });
  });

  group('SmokeLogDtoMapper extension', () {
    test('toEntity converts dto to domain entity correctly', () {
      // Arrange
      final dto = baseTestSmokeLogDto;

      // Act
      final entity = dto.toEntity();

      // Assert
      expect(entity.id, equals(dto.id));
      expect(entity.accountId, equals(dto.accountId));
      expect(entity.ts, equals(dto.ts));
      expect(entity.durationMs, equals(dto.durationMs));
      expect(entity.methodId, equals(dto.methodId));
      expect(entity.potency, equals(dto.potency));
      expect(entity.moodScore, equals(dto.moodScore));
      expect(entity.physicalScore, equals(dto.physicalScore));
      expect(entity.notes, equals(dto.notes));
      expect(entity.deviceLocalId, equals(dto.deviceLocalId));
      expect(entity.createdAt, equals(dto.createdAt));
      expect(entity.updatedAt, equals(dto.updatedAt));
    });

    test('toEntity handles null optional fields', () {
      // Arrange
      final dto = SmokeLogDto(
        id: 'test-id',
        accountId: 'test-account',
        ts: testDateTime,
        durationMs: 30000,
        moodScore: 8,
        physicalScore: 6,
        createdAt: testDateTime,
        updatedAt: testDateTime,
        methodId: null,
        potency: null,
        notes: null,
        deviceLocalId: null,
      );

      // Act
      final entity = dto.toEntity();

      // Assert
      expect(entity.methodId, isNull);
      expect(entity.potency, isNull);
      expect(entity.notes, isNull);
      expect(entity.deviceLocalId, isNull);
    });
  });

  group('SmokeLogEntityMapper extension', () {
    test('toDto converts entity to dto with default flags', () {
      // Arrange
      final entity = baseTestSmokeLog;

      // Act
      final dto = entity.toDto();

      // Assert
      expect(dto.id, equals(entity.id));
      expect(dto.accountId, equals(entity.accountId));
      expect(dto.ts, equals(entity.ts));
      expect(dto.durationMs, equals(entity.durationMs));
      expect(dto.methodId, equals(entity.methodId));
      expect(dto.potency, equals(entity.potency));
      expect(dto.moodScore, equals(entity.moodScore));
      expect(dto.physicalScore, equals(entity.physicalScore));
      expect(dto.notes, equals(entity.notes));
      expect(dto.deviceLocalId, equals(entity.deviceLocalId));
      expect(dto.createdAt, equals(entity.createdAt));
      expect(dto.updatedAt, equals(entity.updatedAt));
      expect(dto.isDeleted, isFalse); // Default value
      expect(dto.isPendingSync, isFalse); // Default value
    });

    test('toDto converts entity with custom flags', () {
      // Arrange
      final entity = baseTestSmokeLog;

      // Act
      final dto = entity.toDto(isDeleted: true, isPendingSync: true);

      // Assert
      expect(dto.isDeleted, isTrue);
      expect(dto.isPendingSync, isTrue);
      expect(dto.id, equals(entity.id)); // Other fields preserved
    });

    test('toDto handles null optional fields', () {
      // Arrange
      final entity = SmokeLog(
        id: 'test-id',
        accountId: 'test-account',
        ts: testDateTime,
        durationMs: 30000,
        moodScore: 8,
        physicalScore: 6,
        createdAt: testDateTime,
        updatedAt: testDateTime,
        methodId: null,
        potency: null,
        notes: null,
        deviceLocalId: null,
      );

      // Act
      final dto = entity.toDto();

      // Assert
      expect(dto.methodId, isNull);
      expect(dto.potency, isNull);
      expect(dto.notes, isNull);
      expect(dto.deviceLocalId, isNull);
    });
  });

  group('Bi-directional mapping', () {
    test('entity -> dto -> entity preserves data', () {
      // Arrange
      final originalEntity = baseTestSmokeLog;

      // Act
      final dto = originalEntity.toDto(isDeleted: false, isPendingSync: true);
      final restoredEntity = dto.toEntity();

      // Assert
      expect(restoredEntity, equals(originalEntity));
    });

    test('dto -> entity -> dto preserves core data', () {
      // Arrange
      final originalDto = baseTestSmokeLogDto;

      // Act
      final entity = originalDto.toEntity();
      final restoredDto = entity.toDto(
        isDeleted: originalDto.isDeleted,
        isPendingSync: originalDto.isPendingSync,
      );

      // Assert
      expect(restoredDto, equals(originalDto));
    });

    test('mapping preserves all field values correctly', () {
      // Arrange - Entity with various field states
      final entity = SmokeLog(
        id: 'complex-test-id',
        accountId: 'complex-account',
        ts: testDateTime.subtract(const Duration(minutes: 5)),
        durationMs: 45000,
        methodId: 'vaporizer',
        potency: 9,
        moodScore: 7,
        physicalScore: 8,
        notes: 'Complex test with special chars: éñ中文',
        deviceLocalId: 'iphone-xyz',
        createdAt: testDateTime.subtract(const Duration(minutes: 10)),
        updatedAt: testDateTime,
      );

      // Act
      final dto = entity.toDto(isDeleted: false, isPendingSync: true);
      final restoredEntity = dto.toEntity();

      // Assert - Every field should be preserved
      expect(restoredEntity.id, equals(entity.id));
      expect(restoredEntity.accountId, equals(entity.accountId));
      expect(restoredEntity.ts, equals(entity.ts));
      expect(restoredEntity.durationMs, equals(entity.durationMs));
      expect(restoredEntity.methodId, equals(entity.methodId));
      expect(restoredEntity.potency, equals(entity.potency));
      expect(restoredEntity.moodScore, equals(entity.moodScore));
      expect(restoredEntity.physicalScore, equals(entity.physicalScore));
      expect(restoredEntity.notes, equals(entity.notes));
      expect(restoredEntity.deviceLocalId, equals(entity.deviceLocalId));
      expect(restoredEntity.createdAt, equals(entity.createdAt));
      expect(restoredEntity.updatedAt, equals(entity.updatedAt));
    });
  });
}
