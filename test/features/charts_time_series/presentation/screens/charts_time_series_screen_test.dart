import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ash_trail/features/charts_time_series/presentation/screens/charts_time_series_screen.dart';
import 'package:ash_trail/features/charts_time_series/presentation/providers/charts_time_series_providers.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/time_series_chart.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';

const testAccountId = 'test-account-id';

// Mock data for tests
final mockTimeSeriesChart = TimeSeriesChart(
  id: 'test-chart-id',
  accountId: testAccountId,
  title: 'Test Chart',
  startDate: DateTime.now().subtract(const Duration(days: 7)),
  endDate: DateTime.now(),
  aggregation: ChartAggregation.daily,
  metric: ChartMetric.count,
  smoothing: ChartSmoothing.none,
  smoothingWindow: 1,
  createdAt: DateTime.now(),
  dataPoints: [
    ChartDataPoint(
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      value: 5.0,
      count: 5,
      totalDurationMs: 15000,
      averageMoodScore: 7.5,
      averagePhysicalScore: 8.0,
    ),
    ChartDataPoint(
      timestamp: DateTime.now(),
      value: 3.0,
      count: 3,
      totalDurationMs: 9000,
      averageMoodScore: 6.5,
      averagePhysicalScore: 7.0,
    ),
  ],
);

void main() {
  group('ChartsTimeSeriesScreen Widget Tests', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      // Build the widget with provider scope and mocked providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock the chart data provider to return immediately
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ChartsTimeSeriesScreen(accountId: testAccountId),
            ),
          ),
        ),
      );

      // Verify the screen renders
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Look for app bar and title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Charts'), findsOneWidget);
    });

    testWidgets('has proper widget structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Use pump with timeout to avoid infinite wait
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify basic structure exists
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('handles tap events without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Look for any tappable elements and test them
      final iconButtons = find.byType(IconButton);
      if (iconButtons.evaluate().isNotEmpty) {
        await tester.tap(iconButtons.first);
        await tester.pump();
      }

      // Verify no exceptions were thrown
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('maintains state during widget lifecycle',
        (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);

      // Rebuild widget
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Verify widget still exists after rebuild
      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('displays legend toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pump();

      // Look for legend toggle button in app bar
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));
    });
  });

  group('Basic Functionality Tests', () {
    testWidgets('screen can be navigated to', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider('another-account').overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider('another-account').overrideWith((ref) async {
              return true;
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(tester.element(find.byType(ElevatedButton)))
                        .push(
                      MaterialPageRoute(
                        builder: (context) => const ChartsTimeSeriesScreen(
                            accountId: 'another-account'),
                      ),
                    );
                  },
                  child: const Text('Navigate to Charts'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap the button to navigate
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify navigation succeeded
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('screen handles provider updates', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          chartDataProvider(testAccountId).overrideWith((ref) async {
            return Right(mockTimeSeriesChart);
          }),
          hasChartDataProvider(testAccountId).overrideWith((ref) async {
            return true;
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);

      // Dispose container
      container.dispose();
    });

    testWidgets('handles different account IDs', (WidgetTester tester) async {
      // Test with different account ID
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider('another-account').overrideWith((ref) async {
              return Right(
                  mockTimeSeriesChart.copyWith(accountId: 'another-account'));
            }),
            hasChartDataProvider('another-account').overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: 'another-account'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });

    testWidgets('displays loading or empty state initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      // Initial state - might show loading or empty content
      await tester.pump();
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);

      // Allow providers to settle with timeout
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ChartsTimeSeriesScreen), findsOneWidget);
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('contains expected child widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should have a Column for layout
      expect(find.byType(Column), findsAtLeastNWidgets(1));

      // Should have Padding for controls
      expect(find.byType(Padding), findsAtLeastNWidgets(1));

      // Should have Expanded for chart area
      expect(find.byType(Expanded), findsAtLeastNWidgets(1));
    });

    testWidgets('respects account ID parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart);
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return true;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pump();

      // Widget should be created with the account ID
      final chartScreen = tester.widget<ChartsTimeSeriesScreen>(
        find.byType(ChartsTimeSeriesScreen),
      );
      expect(chartScreen.accountId, equals(testAccountId));
    });

    testWidgets('displays empty state when no data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chartDataProvider(testAccountId).overrideWith((ref) async {
              return Right(mockTimeSeriesChart.copyWith(dataPoints: []));
            }),
            hasChartDataProvider(testAccountId).overrideWith((ref) async {
              return false;
            }),
          ],
          child: const MaterialApp(
            home: ChartsTimeSeriesScreen(accountId: testAccountId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show empty state
      expect(find.text('No data available'), findsOneWidget);
    });
  });
}
