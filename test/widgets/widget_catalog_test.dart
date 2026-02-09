import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/widgets/home_widgets/widget_catalog.dart';

void main() {
  group('HomeWidgetType enum', () {
    test('has all expected time-based widget types', () {
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.timeSinceLastHit),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.avgTimeBetween),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.longestGapToday),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.firstHitToday),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.lastHitTime),
        isTrue,
      );
      expect(HomeWidgetType.values.contains(HomeWidgetType.peakHour), isTrue);
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.activeHoursToday),
        isTrue,
      );
    });

    test('has all expected duration-based widget types', () {
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.totalDurationToday),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.avgDurationPerHit),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.longestHitToday),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.shortestHitToday),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.totalDurationWeek),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.durationTrend),
        isTrue,
      );
    });

    test('has all expected count-based widget types', () {
      expect(HomeWidgetType.values.contains(HomeWidgetType.hitsToday), isTrue);
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.hitsThisWeek),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.dailyAvgHits),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.hitsPerActiveHour),
        isTrue,
      );
    });

    test('has all expected comparison widget types', () {
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.todayVsYesterday),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.todayVsWeekAvg),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.weekdayVsWeekend),
        isTrue,
      );
    });

    test('has all expected pattern widget types', () {
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.weeklyPattern),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.weekdayHeatmap),
        isTrue,
      );
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.weekendHeatmap),
        isTrue,
      );
    });

    test('has all expected secondary data widget types', () {
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.moodPhysicalAvg),
        isTrue,
      );
      expect(HomeWidgetType.values.contains(HomeWidgetType.topReasons), isTrue);
    });

    test('has all expected action widget types', () {
      expect(HomeWidgetType.values.contains(HomeWidgetType.quickLog), isTrue);
      expect(
        HomeWidgetType.values.contains(HomeWidgetType.recentEntries),
        isTrue,
      );
    });
  });

  group('WidgetSize enum', () {
    test('has three size categories', () {
      expect(WidgetSize.values.length, equals(3));
      expect(WidgetSize.values.contains(WidgetSize.compact), isTrue);
      expect(WidgetSize.values.contains(WidgetSize.standard), isTrue);
      expect(WidgetSize.values.contains(WidgetSize.large), isTrue);
    });
  });

  group('WidgetCategory enum', () {
    test('has all expected categories', () {
      expect(WidgetCategory.values.length, equals(7));
      expect(WidgetCategory.values.contains(WidgetCategory.time), isTrue);
      expect(WidgetCategory.values.contains(WidgetCategory.duration), isTrue);
      expect(WidgetCategory.values.contains(WidgetCategory.count), isTrue);
      expect(WidgetCategory.values.contains(WidgetCategory.comparison), isTrue);
      expect(WidgetCategory.values.contains(WidgetCategory.pattern), isTrue);
      expect(WidgetCategory.values.contains(WidgetCategory.secondary), isTrue);
      expect(WidgetCategory.values.contains(WidgetCategory.action), isTrue);
    });

    test('time category has correct display name and icon', () {
      expect(WidgetCategory.time.displayName, equals('Time'));
      expect(WidgetCategory.time.icon, equals(Icons.schedule));
    });

    test('duration category has correct display name and icon', () {
      expect(WidgetCategory.duration.displayName, equals('Duration'));
      expect(WidgetCategory.duration.icon, equals(Icons.timer));
    });

    test('count category has correct display name and icon', () {
      expect(WidgetCategory.count.displayName, equals('Count'));
      expect(WidgetCategory.count.icon, equals(Icons.numbers));
    });

    test('comparison category has correct display name and icon', () {
      expect(WidgetCategory.comparison.displayName, equals('Comparison'));
      expect(WidgetCategory.comparison.icon, equals(Icons.compare_arrows));
    });

    test('pattern category has correct display name and icon', () {
      expect(WidgetCategory.pattern.displayName, equals('Pattern'));
      expect(WidgetCategory.pattern.icon, equals(Icons.insights));
    });

    test('secondary category has correct display name and icon', () {
      expect(WidgetCategory.secondary.displayName, equals('Ratings & Reasons'));
      expect(WidgetCategory.secondary.icon, equals(Icons.star_outline));
    });

    test('action category has correct display name and icon', () {
      expect(WidgetCategory.action.displayName, equals('Actions'));
      expect(WidgetCategory.action.icon, equals(Icons.touch_app));
    });
  });

  group('WidgetCatalogEntry', () {
    test('creates entry with required fields', () {
      const entry = WidgetCatalogEntry(
        type: HomeWidgetType.hitsToday,
        displayName: 'Test Widget',
        description: 'A test widget description',
        icon: Icons.home,
        category: WidgetCategory.count,
      );

      expect(entry.type, equals(HomeWidgetType.hitsToday));
      expect(entry.displayName, equals('Test Widget'));
      expect(entry.description, equals('A test widget description'));
      expect(entry.icon, equals(Icons.home));
      expect(entry.category, equals(WidgetCategory.count));
      expect(entry.allowMultiple, isFalse); // default
      expect(entry.size, equals(WidgetSize.standard)); // default
    });

    test('creates entry with custom allowMultiple', () {
      const entry = WidgetCatalogEntry(
        type: HomeWidgetType.recentEntries,
        displayName: 'Recent',
        description: 'Recent entries',
        icon: Icons.list,
        category: WidgetCategory.action,
        allowMultiple: true,
      );

      expect(entry.allowMultiple, isTrue);
    });

    test('creates entry with custom size', () {
      const entry = WidgetCatalogEntry(
        type: HomeWidgetType.weekdayHeatmap,
        displayName: 'Weekday Heatmap',
        description: 'Weekday hourly heatmap',
        icon: Icons.grid_on,
        category: WidgetCategory.pattern,
        size: WidgetSize.large,
      );

      expect(entry.size, equals(WidgetSize.large));
    });
  });

  group('WidgetCatalog', () {
    test('entries map contains all HomeWidgetType values', () {
      for (final type in HomeWidgetType.values) {
        expect(
          WidgetCatalog.entries.containsKey(type),
          isTrue,
          reason: 'Missing catalog entry for $type',
        );
      }
    });

    test('entries count matches HomeWidgetType count', () {
      expect(
        WidgetCatalog.entries.length,
        equals(HomeWidgetType.values.length),
      );
    });

    test('each entry has non-empty displayName', () {
      for (final entry in WidgetCatalog.entries.values) {
        expect(
          entry.displayName.isNotEmpty,
          isTrue,
          reason: '${entry.type} has empty displayName',
        );
      }
    });

    test('each entry has non-empty description', () {
      for (final entry in WidgetCatalog.entries.values) {
        expect(
          entry.description.isNotEmpty,
          isTrue,
          reason: '${entry.type} has empty description',
        );
      }
    });

    test('each entry type matches its key', () {
      for (final entry in WidgetCatalog.entries.entries) {
        expect(
          entry.key,
          equals(entry.value.type),
          reason:
              'Key ${entry.key} does not match entry type ${entry.value.type}',
        );
      }
    });

    group('time-based widget entries', () {
      test('timeSinceLastHit has correct metadata', () {
        final entry = WidgetCatalog.entries[HomeWidgetType.timeSinceLastHit]!;
        expect(entry.category, equals(WidgetCategory.time));
        expect(entry.displayName, contains('Time'));
      });

      test('avgTimeBetween has compact size', () {
        final entry = WidgetCatalog.entries[HomeWidgetType.avgTimeBetween]!;
        expect(entry.category, equals(WidgetCategory.time));
        expect(entry.size, equals(WidgetSize.compact));
      });

      test('all time widgets belong to time category', () {
        final timeWidgets = [
          HomeWidgetType.timeSinceLastHit,
          HomeWidgetType.avgTimeBetween,
          HomeWidgetType.longestGapToday,
          HomeWidgetType.firstHitToday,
          HomeWidgetType.lastHitTime,
          HomeWidgetType.peakHour,
          HomeWidgetType.activeHoursToday,
        ];

        for (final type in timeWidgets) {
          final entry = WidgetCatalog.entries[type]!;
          expect(
            entry.category,
            equals(WidgetCategory.time),
            reason: '$type should be in time category',
          );
        }
      });
    });

    group('duration-based widget entries', () {
      test('all duration widgets belong to duration category', () {
        final durationWidgets = [
          HomeWidgetType.totalDurationToday,
          HomeWidgetType.avgDurationPerHit,
          HomeWidgetType.longestHitToday,
          HomeWidgetType.shortestHitToday,
          HomeWidgetType.totalDurationWeek,
          HomeWidgetType.durationTrend,
        ];

        for (final type in durationWidgets) {
          final entry = WidgetCatalog.entries[type]!;
          expect(
            entry.category,
            equals(WidgetCategory.duration),
            reason: '$type should be in duration category',
          );
        }
      });
    });

    group('count-based widget entries', () {
      test('all count widgets belong to count category', () {
        final countWidgets = [
          HomeWidgetType.hitsToday,
          HomeWidgetType.hitsThisWeek,
          HomeWidgetType.dailyAvgHits,
          HomeWidgetType.hitsPerActiveHour,
        ];

        for (final type in countWidgets) {
          final entry = WidgetCatalog.entries[type]!;
          expect(
            entry.category,
            equals(WidgetCategory.count),
            reason: '$type should be in count category',
          );
        }
      });
    });

    group('comparison widget entries', () {
      test('all comparison widgets belong to comparison category', () {
        final comparisonWidgets = [
          HomeWidgetType.todayVsYesterday,
          HomeWidgetType.todayVsWeekAvg,
          HomeWidgetType.weekdayVsWeekend,
        ];

        for (final type in comparisonWidgets) {
          final entry = WidgetCatalog.entries[type]!;
          expect(
            entry.category,
            equals(WidgetCategory.comparison),
            reason: '$type should be in comparison category',
          );
        }
      });
    });

    group('pattern widget entries', () {
      test('all pattern widgets belong to pattern category', () {
        final patternWidgets = [
          HomeWidgetType.weeklyPattern,
          HomeWidgetType.weekdayHeatmap,
          HomeWidgetType.weekendHeatmap,
        ];

        for (final type in patternWidgets) {
          final entry = WidgetCatalog.entries[type]!;
          expect(
            entry.category,
            equals(WidgetCategory.pattern),
            reason: '$type should be in pattern category',
          );
        }
      });
    });

    group('action widget entries', () {
      test('quickLog belongs to action category', () {
        final entry = WidgetCatalog.entries[HomeWidgetType.quickLog]!;
        expect(entry.category, equals(WidgetCategory.action));
      });

      test('recentEntries belongs to action category', () {
        final entry = WidgetCatalog.entries[HomeWidgetType.recentEntries]!;
        expect(entry.category, equals(WidgetCategory.action));
      });
    });

    test('getEntry returns correct entry for type', () {
      final entry = WidgetCatalog.getEntry(HomeWidgetType.hitsToday);
      expect(entry.type, equals(HomeWidgetType.hitsToday));
      expect(entry.category, equals(WidgetCategory.count));
    });

    test('getByCategory returns all entries for category', () {
      final timeEntries = WidgetCatalog.getByCategory(WidgetCategory.time);
      expect(timeEntries.length, greaterThanOrEqualTo(7));
      for (final entry in timeEntries) {
        expect(entry.category, equals(WidgetCategory.time));
      }
    });

    test('getByCategory returns entries for all categories', () {
      // All categories should have at least one widget in this catalog
      for (final category in WidgetCategory.values) {
        final entries = WidgetCatalog.getByCategory(category);
        expect(
          entries.isNotEmpty,
          isTrue,
          reason: 'Expected at least one widget in $category',
        );
      }
    });

    test('getAllGrouped returns map with all categories', () {
      final grouped = WidgetCatalog.getAllGrouped();
      expect(grouped.length, equals(WidgetCategory.values.length));
      for (final category in WidgetCategory.values) {
        expect(grouped.containsKey(category), isTrue);
        expect(grouped[category], isNotEmpty);
      }
    });

    test('defaultWidgets returns non-empty list', () {
      final defaults = WidgetCatalog.defaultWidgets;
      expect(defaults.isNotEmpty, isTrue);
    });

    test('defaultWidgets contains expected essential widgets', () {
      final defaults = WidgetCatalog.defaultWidgets;
      // These are likely default widgets based on the app's focus
      expect(defaults.contains(HomeWidgetType.quickLog), isTrue);
      expect(defaults.contains(HomeWidgetType.timeSinceLastHit), isTrue);
      expect(defaults.contains(HomeWidgetType.hitsToday), isTrue);
    });

    test('defaultWidgets contains 6 widgets', () {
      final defaults = WidgetCatalog.defaultWidgets;
      expect(defaults.length, equals(6));
    });

    test('defaultWidgets all have valid catalog entries', () {
      for (final type in WidgetCatalog.defaultWidgets) {
        expect(
          WidgetCatalog.entries.containsKey(type),
          isTrue,
          reason: 'Default widget $type not in catalog',
        );
      }
    });
  });

  group('WidgetCatalog consistency checks', () {
    test('no duplicate display names within same category', () {
      for (final category in WidgetCategory.values) {
        final entries = WidgetCatalog.getByCategory(category);
        final displayNames = entries.map((e) => e.displayName).toList();
        final uniqueNames = displayNames.toSet();

        expect(
          displayNames.length,
          equals(uniqueNames.length),
          reason: 'Duplicate display names found in $category',
        );
      }
    });

    test('all compact widgets are stat-like (not action)', () {
      for (final entry in WidgetCatalog.entries.values) {
        if (entry.size == WidgetSize.compact) {
          expect(
            entry.category != WidgetCategory.action,
            isTrue,
            reason: '${entry.type} is compact but in action category',
          );
        }
      }
    });

    test('action widgets default to not allowing multiple', () {
      final actionEntries = WidgetCatalog.getByCategory(WidgetCategory.action);
      for (final entry in actionEntries) {
        // Most action widgets should be singletons
        // Only specific ones like recentEntries might allow multiple
        if (entry.type == HomeWidgetType.quickLog) {
          expect(entry.allowMultiple, isFalse);
        }
      }
    });
  });
}
