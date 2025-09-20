// Unit tests for QuickActionEntity
// Tests business logic and validation methods

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/quick_actions/domain/entities/quick_action_entity.dart';

void main() {
  group('QuickActionEntity', () {
    test('should create a valid QuickActionEntity', () {
      // arrange
      const entity = QuickActionEntity(
        type: 'log_hit',
        localizedTitle: 'Log Hit',
        localizedSubtitle: 'Quick record smoking session',
        icon: 'add',
      );

      // assert
      expect(entity.type, equals('log_hit'));
      expect(entity.localizedTitle, equals('Log Hit'));
      expect(entity.localizedSubtitle, equals('Quick record smoking session'));
      expect(entity.icon, equals('add'));
    });

    test('isValid should return true for valid entity', () {
      // arrange
      const entity = QuickActionEntity(
        type: 'log_hit',
        localizedTitle: 'Log Hit',
        localizedSubtitle: 'Quick record smoking session',
      );

      // act & assert
      expect(entity.isValid, isTrue);
    });

    test('isValid should return false for empty type', () {
      // arrange
      const entity = QuickActionEntity(
        type: '',
        localizedTitle: 'Log Hit',
        localizedSubtitle: 'Quick record smoking session',
      );

      // act & assert
      expect(entity.isValid, isFalse);
    });

    test('isValid should return false for empty localizedTitle', () {
      // arrange
      const entity = QuickActionEntity(
        type: 'log_hit',
        localizedTitle: '',
        localizedSubtitle: 'Quick record smoking session',
      );

      // act & assert
      expect(entity.isValid, isFalse);
    });

    group('action type helpers', () {
      test('isLogHit should return true for log_hit type', () {
        // arrange
        const entity = QuickActionEntity(
          type: QuickActionTypes.logHit,
          localizedTitle: 'Log Hit',
          localizedSubtitle: 'Quick record smoking session',
        );

        // act & assert
        expect(entity.isLogHit, isTrue);
        expect(entity.isViewLogs, isFalse);
        expect(entity.isStartTimedLog, isFalse);
      });

      test('isViewLogs should return true for view_logs type', () {
        // arrange
        const entity = QuickActionEntity(
          type: QuickActionTypes.viewLogs,
          localizedTitle: 'View Logs',
          localizedSubtitle: 'See your smoking history',
        );

        // act & assert
        expect(entity.isViewLogs, isTrue);
        expect(entity.isLogHit, isFalse);
        expect(entity.isStartTimedLog, isFalse);
      });

      test('isStartTimedLog should return true for start_timed_log type', () {
        // arrange
        const entity = QuickActionEntity(
          type: QuickActionTypes.startTimedLog,
          localizedTitle: 'Start Timed Log',
          localizedSubtitle: 'Begin timing session',
        );

        // act & assert
        expect(entity.isStartTimedLog, isTrue);
        expect(entity.isLogHit, isFalse);
        expect(entity.isViewLogs, isFalse);
      });
    });

    group('QuickActionTypes constants', () {
      test('should have correct constant values', () {
        expect(QuickActionTypes.logHit, equals('log_hit'));
        expect(QuickActionTypes.viewLogs, equals('view_logs'));
        expect(QuickActionTypes.startTimedLog, equals('start_timed_log'));
      });
    });
  });
}
