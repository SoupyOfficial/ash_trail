// Unit tests for LogFilter entity
// Tests filter criteria validation and helper methods

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_filter.dart';

void main() {
  group('LogFilter', () {
    group('Constructor', () {
      test('should create filter with default values (all null)', () {
        // Act
        const filter = LogFilter();

        // Assert
        expect(filter.startDate, isNull);
        expect(filter.endDate, isNull);
        expect(filter.methodIds, isNull);
        expect(filter.includeTagIds, isNull);
        expect(filter.excludeTagIds, isNull);
        expect(filter.minMoodScore, isNull);
        expect(filter.maxMoodScore, isNull);
        expect(filter.minPhysicalScore, isNull);
        expect(filter.maxPhysicalScore, isNull);
        expect(filter.minDurationMs, isNull);
        expect(filter.maxDurationMs, isNull);
        expect(filter.searchText, isNull);
      });

      test('should create filter with all parameters', () {
        // Arrange
        final startDate = DateTime(2023, 1, 1);
        final endDate = DateTime(2023, 12, 31);
        const methodIds = ['vape', 'joint'];
        const includeTagIds = ['tag1', 'tag2'];
        const excludeTagIds = ['tag3'];
        const minMoodScore = 3;
        const maxMoodScore = 8;
        const minPhysicalScore = 2;
        const maxPhysicalScore = 9;
        const minDurationMs = 1000;
        const maxDurationMs = 600000;
        const searchText = 'great session';

        // Act
        final filter = LogFilter(
          startDate: startDate,
          endDate: endDate,
          methodIds: methodIds,
          includeTagIds: includeTagIds,
          excludeTagIds: excludeTagIds,
          minMoodScore: minMoodScore,
          maxMoodScore: maxMoodScore,
          minPhysicalScore: minPhysicalScore,
          maxPhysicalScore: maxPhysicalScore,
          minDurationMs: minDurationMs,
          maxDurationMs: maxDurationMs,
          searchText: searchText,
        );

        // Assert
        expect(filter.startDate, startDate);
        expect(filter.endDate, endDate);
        expect(filter.methodIds, methodIds);
        expect(filter.includeTagIds, includeTagIds);
        expect(filter.excludeTagIds, excludeTagIds);
        expect(filter.minMoodScore, minMoodScore);
        expect(filter.maxMoodScore, maxMoodScore);
        expect(filter.minPhysicalScore, minPhysicalScore);
        expect(filter.maxPhysicalScore, maxPhysicalScore);
        expect(filter.minDurationMs, minDurationMs);
        expect(filter.maxDurationMs, maxDurationMs);
        expect(filter.searchText, searchText);
      });
    });

    group('hasFilters', () {
      test('should return false when no filters are set', () {
        // Act
        const filter = LogFilter();

        // Assert
        expect(filter.hasFilters, isFalse);
      });

      test('should return true when startDate is set', () {
        // Act
        final filter = LogFilter(startDate: DateTime(2023, 1, 1));

        // Assert
        expect(filter.hasFilters, isTrue);
      });

      test('should return true when endDate is set', () {
        // Act
        final filter = LogFilter(endDate: DateTime(2023, 12, 31));

        // Assert
        expect(filter.hasFilters, isTrue);
      });

      test('should return true when methodIds is not empty', () {
        // Act
        const filter = LogFilter(methodIds: ['vape']);

        // Assert
        expect(filter.hasFilters, isTrue);
      });

      test('should return false when methodIds is empty', () {
        // Act
        const filter = LogFilter(methodIds: []);

        // Assert
        expect(filter.hasFilters, isFalse);
      });

      test('should return true when includeTagIds is not empty', () {
        // Act
        const filter = LogFilter(includeTagIds: ['tag1']);

        // Assert
        expect(filter.hasFilters, isTrue);
      });

      test('should return false when includeTagIds is empty', () {
        // Act
        const filter = LogFilter(includeTagIds: []);

        // Assert
        expect(filter.hasFilters, isFalse);
      });

      test('should return true when excludeTagIds is not empty', () {
        // Act
        const filter = LogFilter(excludeTagIds: ['tag1']);

        // Assert
        expect(filter.hasFilters, isTrue);
      });

      test('should return false when excludeTagIds is empty', () {
        // Act
        const filter = LogFilter(excludeTagIds: []);

        // Assert
        expect(filter.hasFilters, isFalse);
      });

      test('should return true when mood score filters are set', () {
        // Act
        const filter1 = LogFilter(minMoodScore: 5);
        const filter2 = LogFilter(maxMoodScore: 8);

        // Assert
        expect(filter1.hasFilters, isTrue);
        expect(filter2.hasFilters, isTrue);
      });

      test('should return true when physical score filters are set', () {
        // Act
        const filter1 = LogFilter(minPhysicalScore: 3);
        const filter2 = LogFilter(maxPhysicalScore: 7);

        // Assert
        expect(filter1.hasFilters, isTrue);
        expect(filter2.hasFilters, isTrue);
      });

      test('should return true when duration filters are set', () {
        // Act
        const filter1 = LogFilter(minDurationMs: 1000);
        const filter2 = LogFilter(maxDurationMs: 300000);

        // Assert
        expect(filter1.hasFilters, isTrue);
        expect(filter2.hasFilters, isTrue);
      });

      test('should return true when searchText is not empty', () {
        // Act
        const filter = LogFilter(searchText: 'search term');

        // Assert
        expect(filter.hasFilters, isTrue);
      });

      test('should return false when searchText is empty string', () {
        // Act
        const filter = LogFilter(searchText: '');

        // Assert
        expect(filter.hasFilters, isFalse);
      });

      test('should return true when multiple filters are set', () {
        // Act
        final filter = LogFilter(
          startDate: DateTime(2023, 1, 1),
          methodIds: const ['vape'],
          minMoodScore: 5,
        );

        // Assert
        expect(filter.hasFilters, isTrue);
      });
    });

    group('cleared', () {
      test('should return new empty filter', () {
        // Arrange
        final originalFilter = LogFilter(
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 12, 31),
          methodIds: const ['vape', 'joint'],
          includeTagIds: const ['tag1'],
          excludeTagIds: const ['tag2'],
          minMoodScore: 3,
          maxMoodScore: 8,
          minPhysicalScore: 2,
          maxPhysicalScore: 9,
          minDurationMs: 1000,
          maxDurationMs: 600000,
          searchText: 'search term',
        );

        // Act
        final clearedFilter = originalFilter.cleared;

        // Assert
        expect(clearedFilter.startDate, isNull);
        expect(clearedFilter.endDate, isNull);
        expect(clearedFilter.methodIds, isNull);
        expect(clearedFilter.includeTagIds, isNull);
        expect(clearedFilter.excludeTagIds, isNull);
        expect(clearedFilter.minMoodScore, isNull);
        expect(clearedFilter.maxMoodScore, isNull);
        expect(clearedFilter.minPhysicalScore, isNull);
        expect(clearedFilter.maxPhysicalScore, isNull);
        expect(clearedFilter.minDurationMs, isNull);
        expect(clearedFilter.maxDurationMs, isNull);
        expect(clearedFilter.searchText, isNull);
        expect(clearedFilter.hasFilters, isFalse);
      });

      test('should not affect original filter', () {
        // Arrange
        final originalFilter = LogFilter(
          startDate: DateTime(2023, 1, 1),
          minMoodScore: 5,
          searchText: 'search term',
        );

        // Act
        final clearedFilter = originalFilter.cleared;

        // Assert - Original unchanged
        expect(originalFilter.startDate, isNotNull);
        expect(originalFilter.minMoodScore, 5);
        expect(originalFilter.searchText, 'search term');
        expect(originalFilter.hasFilters, isTrue);

        // Assert - Cleared is empty
        expect(clearedFilter.hasFilters, isFalse);
      });
    });

    group('Equality and Hashing', () {
      test('should be equal when all properties match', () {
        // Arrange
        final date1 = DateTime(2023, 1, 1);
        final date2 = DateTime(2023, 1, 1); // Same date, different instance

        final filter1 = LogFilter(
          startDate: date1,
          methodIds: const ['vape'],
          minMoodScore: 5,
        );

        final filter2 = LogFilter(
          startDate: date2,
          methodIds: const ['vape'],
          minMoodScore: 5,
        );

        // Act & Assert
        expect(filter1, equals(filter2));
        expect(filter1.hashCode, equals(filter2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final filter1 = LogFilter(
          startDate: DateTime(2023, 1, 1),
          minMoodScore: 5,
        );

        final filter2 = LogFilter(
          startDate: DateTime(2023, 1, 1),
          minMoodScore: 6, // Different mood score
        );

        // Act & Assert
        expect(filter1, isNot(equals(filter2)));
      });

      test('should handle null list comparisons correctly', () {
        // Arrange
        const filter1 = LogFilter(methodIds: null);
        const filter2 = LogFilter(methodIds: []);
        const filter3 = LogFilter(); // methodIds is null by default

        // Act & Assert
        expect(filter1, equals(filter3)); // Both have null methodIds
        expect(filter1, isNot(equals(filter2))); // null vs empty list
      });
    });

    group('copyWith', () {
      test('should create copy with updated values', () {
        // Arrange
        final originalFilter = LogFilter(
          startDate: DateTime(2023, 1, 1),
          methodIds: const ['vape'],
          minMoodScore: 5,
        );

        // Act
        final updatedFilter = originalFilter.copyWith(
          minMoodScore: 7,
          searchText: 'new search',
        );

        // Assert - Original unchanged
        expect(originalFilter.minMoodScore, 5);
        expect(originalFilter.searchText, isNull);

        // Assert - Updated values
        expect(updatedFilter.startDate, originalFilter.startDate);
        expect(updatedFilter.methodIds, originalFilter.methodIds);
        expect(updatedFilter.minMoodScore, 7);
        expect(updatedFilter.searchText, 'new search');
      });
    });

    group('Edge Cases', () {
      test('should handle extreme date values', () {
        // Arrange
        final veryEarlyDate = DateTime(1900, 1, 1);
        final veryLateDate = DateTime(2100, 12, 31);

        // Act
        final filter = LogFilter(
          startDate: veryEarlyDate,
          endDate: veryLateDate,
        );

        // Assert
        expect(filter.startDate, veryEarlyDate);
        expect(filter.endDate, veryLateDate);
        expect(filter.hasFilters, isTrue);
      });

      test('should handle large lists', () {
        // Arrange
        final largeMethodIds = List.generate(100, (i) => 'method$i');
        final largeTagIds = List.generate(50, (i) => 'tag$i');

        // Act
        final filter = LogFilter(
          methodIds: largeMethodIds,
          includeTagIds: largeTagIds,
        );

        // Assert
        expect(filter.methodIds?.length, 100);
        expect(filter.includeTagIds?.length, 50);
        expect(filter.hasFilters, isTrue);
      });

      test('should handle unicode in search text', () {
        // Arrange
        const unicodeText = '🌿 great session with émojis and ñ special chars';

        // Act
        const filter = LogFilter(searchText: unicodeText);

        // Assert
        expect(filter.searchText, unicodeText);
        expect(filter.hasFilters, isTrue);
      });

      test('should handle boundary score values', () {
        // Act
        const filter = LogFilter(
          minMoodScore: 1,
          maxMoodScore: 10,
          minPhysicalScore: 1,
          maxPhysicalScore: 10,
        );

        // Assert
        expect(filter.minMoodScore, 1);
        expect(filter.maxMoodScore, 10);
        expect(filter.minPhysicalScore, 1);
        expect(filter.maxPhysicalScore, 10);
        expect(filter.hasFilters, isTrue);
      });
    });
  });
}
