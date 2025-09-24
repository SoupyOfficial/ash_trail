import 'package:test/test.dart';
import 'package:ash_trail/domain/models/goal.dart';

void main() {
  group('Goal Entity', () {
    test('should create goal with required fields', () {
      final goal = Goal(
        id: 'goal-1',
        accountId: 'account-123',
        type: 'reduction',
        target: 5,
        window: 'daily',
        startDate: DateTime(2024, 1, 1),
        active: true,
      );

      expect(goal.id, 'goal-1');
      expect(goal.accountId, 'account-123');
      expect(goal.type, 'reduction');
      expect(goal.target, 5);
      expect(goal.window, 'daily');
      expect(goal.startDate, DateTime(2024, 1, 1));
      expect(goal.active, isTrue);
      expect(goal.endDate, isNull);
      expect(goal.progress, isNull);
      expect(goal.achievedAt, isNull);
    });

    test('should create goal with all optional fields', () {
      final goal = Goal(
        id: 'goal-2',
        accountId: 'account-456',
        type: 'cessation',
        target: 0,
        window: 'weekly',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        active: false,
        progress: 3,
        achievedAt: DateTime(2024, 6, 15),
      );

      expect(goal.id, 'goal-2');
      expect(goal.accountId, 'account-456');
      expect(goal.type, 'cessation');
      expect(goal.target, 0);
      expect(goal.window, 'weekly');
      expect(goal.startDate, DateTime(2024, 1, 1));
      expect(goal.endDate, DateTime(2024, 12, 31));
      expect(goal.active, isFalse);
      expect(goal.progress, 3);
      expect(goal.achievedAt, DateTime(2024, 6, 15));
    });
  });

  group('Goal JSON Serialization', () {
    test('should serialize to JSON correctly', () {
      final goal = Goal(
        id: 'goal-1',
        accountId: 'account-123',
        type: 'reduction',
        target: 10,
        window: 'daily',
        startDate: DateTime(2024, 1, 1, 9, 0),
        endDate: DateTime(2024, 12, 31, 23, 59),
        active: true,
        progress: 7,
        achievedAt: DateTime(2024, 6, 15, 14, 30),
      );

      final json = goal.toJson();

      expect(json['id'], 'goal-1');
      expect(json['accountId'], 'account-123');
      expect(json['type'], 'reduction');
      expect(json['target'], 10);
      expect(json['window'], 'daily');
      expect(json['startDate'], '2024-01-01T09:00:00.000');
      expect(json['endDate'], '2024-12-31T23:59:00.000');
      expect(json['active'], true);
      expect(json['progress'], 7);
      expect(json['achievedAt'], '2024-06-15T14:30:00.000');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'goal-2',
        'accountId': 'account-456',
        'type': 'cessation',
        'target': 0,
        'window': 'weekly',
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-12-31T23:59:59.000',
        'active': false,
        'progress': 15,
        'achievedAt': '2024-07-20T10:45:00.000',
      };

      final goal = Goal.fromJson(json);

      expect(goal.id, 'goal-2');
      expect(goal.accountId, 'account-456');
      expect(goal.type, 'cessation');
      expect(goal.target, 0);
      expect(goal.window, 'weekly');
      expect(goal.startDate, DateTime(2024, 1, 1, 0, 0));
      expect(goal.endDate, DateTime(2024, 12, 31, 23, 59, 59));
      expect(goal.active, false);
      expect(goal.progress, 15);
      expect(goal.achievedAt, DateTime(2024, 7, 20, 10, 45));
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'id': 'goal-3',
        'accountId': 'account-789',
        'type': 'maintenance',
        'target': 3,
        'window': 'monthly',
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': null,
        'active': true,
        'progress': null,
        'achievedAt': null,
      };

      final goal = Goal.fromJson(json);

      expect(goal.id, 'goal-3');
      expect(goal.accountId, 'account-789');
      expect(goal.type, 'maintenance');
      expect(goal.target, 3);
      expect(goal.window, 'monthly');
      expect(goal.startDate, DateTime(2024, 1, 1));
      expect(goal.endDate, isNull);
      expect(goal.active, true);
      expect(goal.progress, isNull);
      expect(goal.achievedAt, isNull);
    });

    test('should serialize and deserialize preserving all data', () {
      final original = Goal(
        id: 'goal-roundtrip',
        accountId: 'account-roundtrip',
        type: 'improvement',
        target: 25,
        window: 'yearly',
        startDate: DateTime(2024, 3, 15, 8, 30, 45),
        endDate: DateTime(2024, 9, 20, 17, 45, 30),
        active: true,
        progress: 18,
        achievedAt: DateTime(2024, 8, 10, 12, 15, 0),
      );

      final json = original.toJson();
      final restored = Goal.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.accountId, original.accountId);
      expect(restored.type, original.type);
      expect(restored.target, original.target);
      expect(restored.window, original.window);
      expect(restored.startDate, original.startDate);
      expect(restored.endDate, original.endDate);
      expect(restored.active, original.active);
      expect(restored.progress, original.progress);
      expect(restored.achievedAt, original.achievedAt);
    });

    test('should handle various goal types', () {
      final goalTypes = [
        'reduction',
        'cessation',
        'maintenance',
        'improvement'
      ];

      for (final type in goalTypes) {
        final goal = Goal(
          id: 'goal-$type',
          accountId: 'account-test',
          type: type,
          target: 1,
          window: 'daily',
          startDate: DateTime(2024, 1, 1),
          active: true,
        );

        final json = goal.toJson();
        final restored = Goal.fromJson(json);

        expect(restored.type, type);
      }
    });

    test('should handle various window types', () {
      final windowTypes = ['daily', 'weekly', 'monthly', 'yearly'];

      for (final window in windowTypes) {
        final goal = Goal(
          id: 'goal-$window',
          accountId: 'account-test',
          type: 'reduction',
          target: 5,
          window: window,
          startDate: DateTime(2024, 1, 1),
          active: true,
        );

        final json = goal.toJson();
        final restored = Goal.fromJson(json);

        expect(restored.window, window);
      }
    });

    test('should handle edge case values', () {
      final goal = Goal(
        id: '',
        accountId: '',
        type: '',
        target: 0,
        window: '',
        startDate: DateTime(1970, 1, 1),
        active: false,
        progress: -1,
      );

      final json = goal.toJson();
      final restored = Goal.fromJson(json);

      expect(restored.id, '');
      expect(restored.accountId, '');
      expect(restored.type, '');
      expect(restored.target, 0);
      expect(restored.window, '');
      expect(restored.startDate, DateTime(1970, 1, 1));
      expect(restored.active, false);
      expect(restored.progress, -1);
      expect(restored.endDate, isNull);
      expect(restored.achievedAt, isNull);
    });
  });
}
