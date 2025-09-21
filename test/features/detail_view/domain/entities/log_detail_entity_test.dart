// Tests for LogDetailEntity domain entity
// Validates business logic and formatting methods

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/detail_view/domain/entities/log_detail_entity.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/domain/models/tag.dart';
import 'package:ash_trail/domain/models/reason.dart';
import 'package:ash_trail/domain/models/method.dart';

void main() {
  group('LogDetailEntity', () {
    late SmokeLog testLog;
    late List<Tag> testTags;
    late List<Reason> testReasons;
    late Method testMethod;
    late LogDetailEntity entity;

    setUp(() {
      final now = DateTime.now();
      testLog = SmokeLog(
        id: 'log-123',
        accountId: 'acc-456',
        ts: DateTime(2023, 10, 15, 14, 30, 45),
        durationMs: 7500, // 7.5 seconds
        moodScore: 7,
        physicalScore: 8,
        potency: 6,
        notes: 'Test notes for the log',
        createdAt: now,
        updatedAt: now,
      );

      testTags = [
        Tag(
          id: 'tag-1',
          accountId: 'acc-456',
          name: 'relaxing',
          createdAt: now,
          updatedAt: now,
        ),
        Tag(
          id: 'tag-2',
          accountId: 'acc-456',
          name: 'social',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testReasons = [
        Reason(
          id: 'reason-1',
          name: 'stress',
          enabled: true,
          orderIndex: 1,
          createdAt: now,
          updatedAt: now,
        ),
        Reason(
          id: 'reason-2',
          name: 'anxiety',
          enabled: true,
          orderIndex: 2,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      testMethod = Method(
        id: 'method-1',
        name: 'vaping',
        category: 'electronic',
        createdAt: now,
        updatedAt: now,
      );

      entity = LogDetailEntity(
        log: testLog,
        tags: testTags,
        reasons: testReasons,
        method: testMethod,
      );
    });

    group('getters', () {
      test('should return true for hasTags when tags exist', () {
        expect(entity.hasTags, isTrue);
      });

      test('should return false for hasTags when tags are empty', () {
        final emptyTagsEntity = LogDetailEntity(log: testLog);
        expect(emptyTagsEntity.hasTags, isFalse);
      });

      test('should return true for hasReasons when reasons exist', () {
        expect(entity.hasReasons, isTrue);
      });

      test('should return false for hasReasons when reasons are empty', () {
        final emptyReasonsEntity = LogDetailEntity(log: testLog);
        expect(emptyReasonsEntity.hasReasons, isFalse);
      });

      test('should return true for hasMethod when method exists', () {
        expect(entity.hasMethod, isTrue);
      });

      test('should return false for hasMethod when method is null', () {
        final noMethodEntity = LogDetailEntity(log: testLog);
        expect(noMethodEntity.hasMethod, isFalse);
      });

      test('should return true for hasNotes when notes exist', () {
        expect(entity.hasNotes, isTrue);
      });

      test('should return false for hasNotes when notes are empty', () {
        final logWithoutNotes = testLog.copyWith(notes: null);
        final noNotesEntity = LogDetailEntity(log: logWithoutNotes);
        expect(noNotesEntity.hasNotes, isFalse);
      });

      test('should return method name when method exists', () {
        expect(entity.methodName, equals('vaping'));
      });

      test('should return null method name when method is null', () {
        final noMethodEntity = LogDetailEntity(log: testLog);
        expect(noMethodEntity.methodName, isNull);
      });
    });

    group('formattedDuration', () {
      test('should format duration in seconds only', () {
        expect(entity.formattedDuration, equals('7s'));
      });

      test('should format duration with minutes and seconds', () {
        final longLog = testLog.copyWith(durationMs: 125000); // 2m 5s
        final longEntity = LogDetailEntity(log: longLog);
        expect(longEntity.formattedDuration, equals('2m 5s'));
      });

      test('should format duration with hours, minutes and seconds', () {
        final veryLongLog = testLog.copyWith(durationMs: 3725000); // 1h 2m 5s
        final veryLongEntity = LogDetailEntity(log: veryLongLog);
        expect(veryLongEntity.formattedDuration, equals('1h 2m 5s'));
      });

      test('should handle zero duration', () {
        final zeroLog = testLog.copyWith(durationMs: 0);
        final zeroEntity = LogDetailEntity(log: zeroLog);
        expect(zeroEntity.formattedDuration, equals('0s'));
      });
    });

    group('formattedTimestamp', () {
      test('should format timestamp correctly', () {
        expect(entity.formattedTimestamp, equals('15/10/2023 at 14:30'));
      });

      test('should pad single digit days and months', () {
        final earlyLog = testLog.copyWith(ts: DateTime(2023, 1, 5, 9, 5));
        final earlyEntity = LogDetailEntity(log: earlyLog);
        expect(earlyEntity.formattedTimestamp, equals('05/01/2023 at 09:05'));
      });
    });

    group('mood score description', () {
      test('should describe very low mood score', () {
        final lowMoodLog = testLog.copyWith(moodScore: 1);
        final lowMoodEntity = LogDetailEntity(log: lowMoodLog);
        expect(lowMoodEntity.moodScoreDescription, equals('Very Low (1/10)'));
      });

      test('should describe low mood score', () {
        final lowMoodLog = testLog.copyWith(moodScore: 3);
        final lowMoodEntity = LogDetailEntity(log: lowMoodLog);
        expect(lowMoodEntity.moodScoreDescription, equals('Low (3/10)'));
      });

      test('should describe moderate mood score', () {
        final moderateMoodLog = testLog.copyWith(moodScore: 5);
        final moderateEntity = LogDetailEntity(log: moderateMoodLog);
        expect(moderateEntity.moodScoreDescription, equals('Moderate (5/10)'));
      });

      test('should describe good mood score', () {
        expect(entity.moodScoreDescription, equals('Good (7/10)'));
      });

      test('should describe excellent mood score', () {
        final excellentLog = testLog.copyWith(moodScore: 10);
        final excellentEntity = LogDetailEntity(log: excellentLog);
        expect(
            excellentEntity.moodScoreDescription, equals('Excellent (10/10)'));
      });

      test('should handle unknown mood score', () {
        final unknownLog = testLog.copyWith(moodScore: 15);
        final unknownEntity = LogDetailEntity(log: unknownLog);
        expect(unknownEntity.moodScoreDescription, equals('Unknown (15/10)'));
      });
    });

    group('physical score description', () {
      test('should describe very low physical score', () {
        final lowPhysicalLog = testLog.copyWith(physicalScore: 2);
        final lowPhysicalEntity = LogDetailEntity(log: lowPhysicalLog);
        expect(lowPhysicalEntity.physicalScoreDescription,
            equals('Very Low (2/10)'));
      });

      test('should describe good physical score', () {
        expect(entity.physicalScoreDescription, equals('Good (8/10)'));
      });

      test('should describe excellent physical score', () {
        final excellentLog = testLog.copyWith(physicalScore: 9);
        final excellentEntity = LogDetailEntity(log: excellentLog);
        expect(excellentEntity.physicalScoreDescription,
            equals('Excellent (9/10)'));
      });
    });

    group('potency description', () {
      test('should describe moderate potency', () {
        expect(entity.potencyDescription, equals('Moderate (6/10)'));
      });

      test('should return null for no potency', () {
        final noPotencyLog = testLog.copyWith(potency: null);
        final noPotencyEntity = LogDetailEntity(log: noPotencyLog);
        expect(noPotencyEntity.potencyDescription, isNull);
      });

      test('should describe high potency', () {
        final highPotencyLog = testLog.copyWith(potency: 9);
        final highPotencyEntity = LogDetailEntity(log: highPotencyLog);
        expect(
            highPotencyEntity.potencyDescription, equals('Very High (9/10)'));
      });
    });

    group('score getters', () {
      test('should return correct mood score', () {
        expect(entity.moodScore, equals(7));
      });

      test('should return correct physical score', () {
        expect(entity.physicalScore, equals(8));
      });
    });

    group('equality and hashing', () {
      test('should be equal with same data', () {
        final entity1 = LogDetailEntity(
          log: testLog,
          tags: testTags,
          reasons: testReasons,
          method: testMethod,
        );

        final entity2 = LogDetailEntity(
          log: testLog,
          tags: testTags,
          reasons: testReasons,
          method: testMethod,
        );

        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('should not be equal with different data', () {
        final entity1 = LogDetailEntity(log: testLog);
        final entity2 = LogDetailEntity(
          log: testLog.copyWith(id: 'different-id'),
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });
  });
}
