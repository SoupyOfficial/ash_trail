// Unit tests for LogSort entity and related enums
// Tests sorting criteria and extension methods

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_sort.dart';

void main() {
  group('LogSort', () {
    group('Constructor', () {
      test('should create with default values', () {
        // Act
        const sort = LogSort();

        // Assert
        expect(sort.field, LogSortField.timestamp);
        expect(sort.order, LogSortOrder.descending);
      });

      test('should create with custom values', () {
        // Act
        const sort = LogSort(
          field: LogSortField.duration,
          order: LogSortOrder.ascending,
        );

        // Assert
        expect(sort.field, LogSortField.duration);
        expect(sort.order, LogSortOrder.ascending);
      });
    });

    group('Static constructors', () {
      test('defaultSort should sort by timestamp descending', () {
        // Act
        const sort = LogSort.defaultSort;

        // Assert
        expect(sort.field, LogSortField.timestamp);
        expect(sort.order, LogSortOrder.descending);
      });

      test('dateAscending should sort by timestamp ascending', () {
        // Act
        const sort = LogSort.dateAscending;

        // Assert
        expect(sort.field, LogSortField.timestamp);
        expect(sort.order, LogSortOrder.ascending);
      });

      test('durationDescending should sort by duration descending', () {
        // Act
        const sort = LogSort.durationDescending;

        // Assert
        expect(sort.field, LogSortField.duration);
        expect(sort.order, LogSortOrder.descending);
      });

      test('durationAscending should sort by duration ascending', () {
        // Act
        const sort = LogSort.durationAscending;

        // Assert
        expect(sort.field, LogSortField.duration);
        expect(sort.order, LogSortOrder.ascending);
      });
    });

    group('Equality and Hashing', () {
      test('should be equal when field and order match', () {
        // Arrange
        const sort1 = LogSort(
          field: LogSortField.moodScore,
          order: LogSortOrder.ascending,
        );
        const sort2 = LogSort(
          field: LogSortField.moodScore,
          order: LogSortOrder.ascending,
        );

        // Act & Assert
        expect(sort1, equals(sort2));
        expect(sort1.hashCode, equals(sort2.hashCode));
      });

      test('should not be equal when field differs', () {
        // Arrange
        const sort1 = LogSort(field: LogSortField.timestamp);
        const sort2 = LogSort(field: LogSortField.duration);

        // Act & Assert
        expect(sort1, isNot(equals(sort2)));
      });

      test('should not be equal when order differs', () {
        // Arrange
        const sort1 = LogSort(order: LogSortOrder.ascending);
        const sort2 = LogSort(order: LogSortOrder.descending);

        // Act & Assert
        expect(sort1, isNot(equals(sort2)));
      });
    });

    group('copyWith', () {
      test('should create copy with updated field', () {
        // Arrange
        const original = LogSort();

        // Act
        final updated = original.copyWith(field: LogSortField.duration);

        // Assert
        expect(original.field, LogSortField.timestamp); // Original unchanged
        expect(updated.field, LogSortField.duration);
        expect(updated.order, LogSortOrder.descending); // Order preserved
      });

      test('should create copy with updated order', () {
        // Arrange
        const original = LogSort();

        // Act
        final updated = original.copyWith(order: LogSortOrder.ascending);

        // Assert
        expect(original.order, LogSortOrder.descending); // Original unchanged
        expect(updated.field, LogSortField.timestamp); // Field preserved
        expect(updated.order, LogSortOrder.ascending);
      });

      test('should create copy with both field and order updated', () {
        // Arrange
        const original = LogSort();

        // Act
        final updated = original.copyWith(
          field: LogSortField.physicalScore,
          order: LogSortOrder.ascending,
        );

        // Assert
        expect(updated.field, LogSortField.physicalScore);
        expect(updated.order, LogSortOrder.ascending);
      });
    });
  });

  group('LogSortField', () {
    test('should have all expected values', () {
      // Act & Assert
      expect(LogSortField.values, contains(LogSortField.timestamp));
      expect(LogSortField.values, contains(LogSortField.duration));
      expect(LogSortField.values, contains(LogSortField.moodScore));
      expect(LogSortField.values, contains(LogSortField.physicalScore));
      expect(LogSortField.values, contains(LogSortField.createdAt));
      expect(LogSortField.values, contains(LogSortField.updatedAt));
      expect(LogSortField.values.length, 6);
    });
  });

  group('LogSortOrder', () {
    test('should have all expected values', () {
      // Act & Assert
      expect(LogSortOrder.values, contains(LogSortOrder.ascending));
      expect(LogSortOrder.values, contains(LogSortOrder.descending));
      expect(LogSortOrder.values.length, 2);
    });
  });

  group('LogSortFieldExtension', () {
    test('timestamp should have correct display name', () {
      // Act & Assert
      expect(LogSortField.timestamp.displayName, 'Date');
    });

    test('duration should have correct display name', () {
      // Act & Assert
      expect(LogSortField.duration.displayName, 'Duration');
    });

    test('moodScore should have correct display name', () {
      // Act & Assert
      expect(LogSortField.moodScore.displayName, 'Mood');
    });

    test('physicalScore should have correct display name', () {
      // Act & Assert
      expect(LogSortField.physicalScore.displayName, 'Physical');
    });

    test('createdAt should have correct display name', () {
      // Act & Assert
      expect(LogSortField.createdAt.displayName, 'Created');
    });

    test('updatedAt should have correct display name', () {
      // Act & Assert
      expect(LogSortField.updatedAt.displayName, 'Updated');
    });

    test('should handle all enum values', () {
      // Act & Assert - Ensure all enum values have display names
      for (final field in LogSortField.values) {
        expect(field.displayName, isNotEmpty);
        expect(field.displayName, isA<String>());
      }
    });
  });

  group('LogSortOrderExtension', () {
    test('ascending should have correct display name', () {
      // Act & Assert
      expect(LogSortOrder.ascending.displayName, 'Ascending');
    });

    test('descending should have correct display name', () {
      // Act & Assert
      expect(LogSortOrder.descending.displayName, 'Descending');
    });

    test('ascending should be ascending', () {
      // Act & Assert
      expect(LogSortOrder.ascending.isAscending, isTrue);
      expect(LogSortOrder.ascending.isDescending, isFalse);
    });

    test('descending should be descending', () {
      // Act & Assert
      expect(LogSortOrder.descending.isAscending, isFalse);
      expect(LogSortOrder.descending.isDescending, isTrue);
    });

    test('should handle all enum values', () {
      // Act & Assert - Ensure all enum values have display names
      for (final order in LogSortOrder.values) {
        expect(order.displayName, isNotEmpty);
        expect(order.displayName, isA<String>());

        // Each order should be either ascending or descending, but not both
        expect(order.isAscending != order.isDescending, isTrue);
      }
    });
  });

  group('Integration Tests', () {
    test('should work with all field and order combinations', () {
      // Arrange
      final combinations = <LogSort>[];

      // Act - Create all possible combinations
      for (final field in LogSortField.values) {
        for (final order in LogSortOrder.values) {
          combinations.add(LogSort(field: field, order: order));
        }
      }

      // Assert
      expect(combinations.length,
          LogSortField.values.length * LogSortOrder.values.length);

      // Each combination should be valid
      for (final sort in combinations) {
        expect(sort.field, isA<LogSortField>());
        expect(sort.order, isA<LogSortOrder>());
        expect(sort.field.displayName, isNotEmpty);
        expect(sort.order.displayName, isNotEmpty);
      }
    });

    test('should create distinct objects for different combinations', () {
      // Arrange
      const sort1 = LogSort(
        field: LogSortField.timestamp,
        order: LogSortOrder.ascending,
      );
      const sort2 = LogSort(
        field: LogSortField.timestamp,
        order: LogSortOrder.descending,
      );
      const sort3 = LogSort(
        field: LogSortField.duration,
        order: LogSortOrder.ascending,
      );

      // Act & Assert
      expect(sort1, isNot(equals(sort2))); // Different order
      expect(sort1, isNot(equals(sort3))); // Different field
      expect(sort2, isNot(equals(sort3))); // Different field and order
    });

    test('should work with copyWith for all fields', () {
      // Arrange
      const original = LogSort();

      // Act & Assert - Test copying with each field
      for (final field in LogSortField.values) {
        final updated = original.copyWith(field: field);
        expect(updated.field, field);
        expect(updated.order, original.order); // Order should be preserved
      }

      // Act & Assert - Test copying with each order
      for (final order in LogSortOrder.values) {
        final updated = original.copyWith(order: order);
        expect(updated.field, original.field); // Field should be preserved
        expect(updated.order, order);
      }
    });
  });
}
