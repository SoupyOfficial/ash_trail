// Tests for Reason model serialization
// Covers generated JSON serialization/deserialization code

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/domain/models/reason.dart';

void main() {
  group('Reason', () {
    late Reason testReason;
    late DateTime testDateTime;

    setUp(() {
      testDateTime = DateTime(2024, 1, 15, 10, 30);
      testReason = Reason(
        id: 'reason-123',
        accountId: 'acc-456',
        name: 'Test Reason',
        enabled: true,
        orderIndex: 5,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // act
        final json = testReason.toJson();

        // assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('reason-123'));
        expect(json['accountId'], equals('acc-456'));
        expect(json['name'], equals('Test Reason'));
        expect(json['enabled'], equals(true));
        expect(json['orderIndex'], equals(5));
        expect(json['createdAt'], equals(testDateTime.toIso8601String()));
        expect(json['updatedAt'], equals(testDateTime.toIso8601String()));
      });

      test('should deserialize from JSON correctly', () {
        // arrange
        final json = {
          'id': 'reason-789',
          'accountId': 'acc-123',
          'name': 'Deserialized Reason',
          'enabled': false,
          'orderIndex': 10,
          'createdAt': '2024-02-15T14:30:00.000Z',
          'updatedAt': '2024-02-15T15:00:00.000Z',
        };

        // act
        final reason = Reason.fromJson(json);

        // assert
        expect(reason.id, equals('reason-789'));
        expect(reason.accountId, equals('acc-123'));
        expect(reason.name, equals('Deserialized Reason'));
        expect(reason.enabled, equals(false));
        expect(reason.orderIndex, equals(10));
        expect(reason.createdAt,
            equals(DateTime.parse('2024-02-15T14:30:00.000Z')));
        expect(reason.updatedAt,
            equals(DateTime.parse('2024-02-15T15:00:00.000Z')));
      });

      test('should handle null accountId', () {
        // arrange
        final json = {
          'id': 'reason-null-account',
          'accountId': null,
          'name': 'Reason with null account',
          'enabled': true,
          'orderIndex': 1,
          'createdAt': '2024-02-15T14:30:00.000Z',
          'updatedAt': '2024-02-15T15:00:00.000Z',
        };

        // act
        final reason = Reason.fromJson(json);

        // assert
        expect(reason.accountId, isNull);
        expect(reason.name, equals('Reason with null account'));
      });

      test('should round-trip JSON serialization/deserialization', () {
        // act
        final json = testReason.toJson();
        final deserializedReason = Reason.fromJson(json);

        // assert
        expect(deserializedReason.id, equals(testReason.id));
        expect(deserializedReason.accountId, equals(testReason.accountId));
        expect(deserializedReason.name, equals(testReason.name));
        expect(deserializedReason.enabled, equals(testReason.enabled));
        expect(deserializedReason.orderIndex, equals(testReason.orderIndex));
        expect(deserializedReason.createdAt, equals(testReason.createdAt));
        expect(deserializedReason.updatedAt, equals(testReason.updatedAt));
      });
    });

    group('Equality and hashCode', () {
      test('should be equal when all properties match', () {
        // arrange
        final reason1 = Reason(
          id: 'same-id',
          accountId: 'same-account',
          name: 'Same Reason',
          enabled: true,
          orderIndex: 1,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );
        final reason2 = Reason(
          id: 'same-id',
          accountId: 'same-account',
          name: 'Same Reason',
          enabled: true,
          orderIndex: 1,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // assert
        expect(reason1, equals(reason2));
        expect(reason1.hashCode, equals(reason2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final reason1 = testReason;
        final reason2 = testReason.copyWith(name: 'Different Name');

        // assert
        expect(reason1, isNot(equals(reason2)));
        expect(reason1.hashCode, isNot(equals(reason2.hashCode)));
      });
    });

    group('copyWith', () {
      test('should create copy with modified properties', () {
        // act
        final modified = testReason.copyWith(
          name: 'Modified Name',
          enabled: false,
          orderIndex: 99,
        );

        // assert
        expect(modified.id, equals(testReason.id));
        expect(modified.accountId, equals(testReason.accountId));
        expect(modified.name, equals('Modified Name'));
        expect(modified.enabled, equals(false));
        expect(modified.orderIndex, equals(99));
        expect(modified.createdAt, equals(testReason.createdAt));
        expect(modified.updatedAt, equals(testReason.updatedAt));
      });

      test('should preserve original properties when not modified', () {
        // act
        final copy = testReason.copyWith();

        // assert
        expect(copy, equals(testReason));
      });
    });
  });
}
