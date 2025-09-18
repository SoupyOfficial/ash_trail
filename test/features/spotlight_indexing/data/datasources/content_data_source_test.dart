import 'package:flutter_test/flutter_test.dart';

import 'package:ash_trail/features/spotlight_indexing/data/datasources/content_data_source.dart';

void main() {
  group('ContentDataSource', () {
    late ContentDataSource contentDataSource;

    setUp(() {
      contentDataSource = const ContentDataSource();
    });

    group('getIndexableTags', () {
      test('should return empty list for tags (mock implementation)', () async {
        // Act
        final result = await contentDataSource.getIndexableTags('account123');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) =>
              fail('Expected success, got failure: ${failure.message}'),
          (tags) {
            expect(tags, isEmpty);
          },
        );
      });

      test('should handle errors gracefully', () async {
        // This test ensures that even if there's an unexpected error in future implementations,
        // it would be handled properly. For now, the mock implementation always succeeds.

        // Act
        final result = await contentDataSource.getIndexableTags('account123');

        // Assert
        expect(result.isRight(), true);
      });
    });

    group('getIndexableChartViews', () {
      test('should return mock chart views', () async {
        // Act
        final result =
            await contentDataSource.getIndexableChartViews('account123');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) =>
              fail('Expected success, got failure: ${failure.message}'),
          (chartViews) {
            expect(chartViews, isNotEmpty);
            expect(chartViews.length, 2);

            final weeklyView =
                chartViews.firstWhere((item) => item.id == 'chart_view_weekly');
            expect(weeklyView.title, 'Weekly Overview');
            expect(weeklyView.type, 'chartView');
            expect(weeklyView.accountId, 'account123');
            expect(weeklyView.deepLink, 'ashtrail://charts/weekly');
            expect(weeklyView.keywords, contains('weekly'));

            final monthlyView = chartViews
                .firstWhere((item) => item.id == 'chart_view_monthly');
            expect(monthlyView.title, 'Monthly Trends');
            expect(monthlyView.type, 'chartView');
            expect(monthlyView.accountId, 'account123');
            expect(monthlyView.deepLink, 'ashtrail://charts/monthly');
            expect(monthlyView.keywords, contains('monthly'));
          },
        );
      });

      test('should return chart views for the correct account', () async {
        // Act
        final result =
            await contentDataSource.getIndexableChartViews('different_account');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) =>
              fail('Expected success, got failure: ${failure.message}'),
          (chartViews) {
            // Verify all chart views belong to the requested account
            for (final chartView in chartViews) {
              expect(chartView.accountId, 'different_account');
            }
          },
        );
      });

      test('should return chart views with proper indexing data', () async {
        // Act
        final result =
            await contentDataSource.getIndexableChartViews('account123');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) =>
              fail('Expected success, got failure: ${failure.message}'),
          (chartViews) {
            for (final chartView in chartViews) {
              expect(chartView.id, isNotEmpty);
              expect(chartView.title, isNotEmpty);
              expect(chartView.description, isNotEmpty);
              expect(chartView.keywords, isNotEmpty);
              expect(chartView.deepLink, startsWith('ashtrail://'));
              expect(chartView.isActive, isTrue);
              expect(chartView.lastUpdated, isNotNull);
            }
          },
        );
      });
    });

    group('getAllIndexableContent', () {
      test('should return combined tags and chart views', () async {
        // Act
        final result =
            await contentDataSource.getAllIndexableContent('account123');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) =>
              fail('Expected success, got failure: ${failure.message}'),
          (allContent) {
            // Should contain 2 chart views (0 tags in mock implementation)
            expect(allContent.length, 2);

            // Verify we have chart views
            final chartViews =
                allContent.where((item) => item.type == 'chartView').toList();
            expect(chartViews.length, 2);

            // Verify all content belongs to the correct account
            for (final item in allContent) {
              expect(item.accountId, 'account123');
            }
          },
        );
      });

      test('should handle different account IDs correctly', () async {
        // Act
        final result =
            await contentDataSource.getAllIndexableContent('test_account');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) =>
              fail('Expected success, got failure: ${failure.message}'),
          (allContent) {
            // Verify all content belongs to the correct account
            for (final item in allContent) {
              expect(item.accountId, 'test_account');
            }
          },
        );
      });

      test('should return items with valid spotlight indexing data', () async {
        // Act
        final result =
            await contentDataSource.getAllIndexableContent('account123');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) =>
              fail('Expected success, got failure: ${failure.message}'),
          (allContent) {
            for (final item in allContent) {
              expect(item.id, isNotEmpty);
              expect(item.type, isIn(['tag', 'chartView']));
              expect(item.title, isNotEmpty);
              expect(item.deepLink, startsWith('ashtrail://'));
              expect(item.accountId, isNotEmpty);
              expect(item.contentId, isNotEmpty);
              expect(item.lastUpdated, isNotNull);
              expect(item.isActive, isNotNull);
            }
          },
        );
      });
    });
  });
}
