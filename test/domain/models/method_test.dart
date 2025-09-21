// Tests for Method model serialization
// Covers generated JSON serialization/deserialization code

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/domain/models/method.dart';

void main() {
  group('Method', () {
    late Method testMethod;
    late DateTime testDateTime;

    setUp(() {
      testDateTime = DateTime(2024, 1, 15, 10, 30);
      testMethod = Method(
        id: 'method-123',
        accountId: 'acc-456',
        name: 'Test Method',
        category: 'test-category',
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // act
        final json = testMethod.toJson();

        // assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('method-123'));
        expect(json['accountId'], equals('acc-456'));
        expect(json['name'], equals('Test Method'));
        expect(json['category'], equals('test-category'));
        expect(json['createdAt'], equals(testDateTime.toIso8601String()));
        expect(json['updatedAt'], equals(testDateTime.toIso8601String()));
      });

      test('should deserialize from JSON correctly', () {
        // arrange
        final json = {
          'id': 'method-789',
          'accountId': 'acc-123',
          'name': 'Deserialized Method',
          'category': 'deserialized-category',
          'createdAt': '2024-02-15T14:30:00.000Z',
          'updatedAt': '2024-02-15T15:00:00.000Z',
        };

        // act
        final method = Method.fromJson(json);

        // assert
        expect(method.id, equals('method-789'));
        expect(method.accountId, equals('acc-123'));
        expect(method.name, equals('Deserialized Method'));
        expect(method.category, equals('deserialized-category'));
        expect(method.createdAt,
            equals(DateTime.parse('2024-02-15T14:30:00.000Z')));
        expect(method.updatedAt,
            equals(DateTime.parse('2024-02-15T15:00:00.000Z')));
      });

      test('should handle null accountId', () {
        // arrange
        final json = {
          'id': 'method-null-account',
          'accountId': null,
          'name': 'Method with null account',
          'category': 'no-account-category',
          'createdAt': '2024-02-15T14:30:00.000Z',
          'updatedAt': '2024-02-15T15:00:00.000Z',
        };

        // act
        final method = Method.fromJson(json);

        // assert
        expect(method.accountId, isNull);
        expect(method.name, equals('Method with null account'));
        expect(method.category, equals('no-account-category'));
      });

      test('should round-trip JSON serialization/deserialization', () {
        // act
        final json = testMethod.toJson();
        final deserializedMethod = Method.fromJson(json);

        // assert
        expect(deserializedMethod.id, equals(testMethod.id));
        expect(deserializedMethod.accountId, equals(testMethod.accountId));
        expect(deserializedMethod.name, equals(testMethod.name));
        expect(deserializedMethod.category, equals(testMethod.category));
        expect(deserializedMethod.createdAt, equals(testMethod.createdAt));
        expect(deserializedMethod.updatedAt, equals(testMethod.updatedAt));
      });
    });

    group('Equality and hashCode', () {
      test('should be equal when all properties match', () {
        // arrange
        final method1 = Method(
          id: 'same-id',
          accountId: 'same-account',
          name: 'Same Method',
          category: 'same-category',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );
        final method2 = Method(
          id: 'same-id',
          accountId: 'same-account',
          name: 'Same Method',
          category: 'same-category',
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        // assert
        expect(method1, equals(method2));
        expect(method1.hashCode, equals(method2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final method1 = testMethod;
        final method2 = testMethod.copyWith(name: 'Different Name');

        // assert
        expect(method1, isNot(equals(method2)));
        expect(method1.hashCode, isNot(equals(method2.hashCode)));
      });
    });

    group('copyWith', () {
      test('should create copy with modified properties', () {
        // act
        final modified = testMethod.copyWith(
          name: 'Modified Method',
          category: 'modified-category',
        );

        // assert
        expect(modified.id, equals(testMethod.id));
        expect(modified.accountId, equals(testMethod.accountId));
        expect(modified.name, equals('Modified Method'));
        expect(modified.category, equals('modified-category'));
        expect(modified.createdAt, equals(testMethod.createdAt));
        expect(modified.updatedAt, equals(testMethod.updatedAt));
      });

      test('should preserve original properties when not modified', () {
        // act
        final copy = testMethod.copyWith();

        // assert
        expect(copy, equals(testMethod));
      });
    });
  });
}
