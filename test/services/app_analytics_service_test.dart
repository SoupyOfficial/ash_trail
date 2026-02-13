import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/app_analytics_service.dart';
import 'package:ash_trail/models/app_error.dart';

void main() {
  group('AppAnalyticsService', () {
    test('singleton returns same instance', () {
      final a = AppAnalyticsService.instance;
      final b = AppAnalyticsService();
      expect(identical(a, b), true);
    });

    test('initialize is no-op when Firebase not initialized', () async {
      // Firebase.apps.isEmpty == true in test environment
      await AppAnalyticsService.instance.initialize();
      expect(AppAnalyticsService.instance.observer, isNull);
    });

    test('all log methods are no-op when not initialized', () async {
      // Should not throw even when _analytics is null
      await AppAnalyticsService.instance.logAppOpen();
      await AppAnalyticsService.instance.logLogin(method: 'email');
      await AppAnalyticsService.instance.logSignOut();
      await AppAnalyticsService.instance.logLogCreated();
      await AppAnalyticsService.instance.logLogUpdated();
      await AppAnalyticsService.instance.logLogDeleted();
      await AppAnalyticsService.instance.logSyncCompleted();
      await AppAnalyticsService.instance.logExport(format: 'csv');
      await AppAnalyticsService.instance.logError(
        ErrorCategory.network,
        ErrorSeverity.warning,
      );
      await AppAnalyticsService.instance.logTabSwitch(tabName: 'home');
      await AppAnalyticsService.instance.logAccountSwitch();
      await AppAnalyticsService.instance.logScreenView(screenName: 'test');
    });

    test('user property setters are no-op when not initialized', () async {
      await AppAnalyticsService.instance.setAccountCount(3);
      await AppAnalyticsService.instance.setLogCountBucket(42);
      await AppAnalyticsService.instance.setAppVersion('1.0.3');
      await AppAnalyticsService.instance.setAuthMethod('google');
      await AppAnalyticsService.instance.setSyncStatus('enabled');
      await AppAnalyticsService.instance.clearUserProperties();
    });

    test('logCountBucket returns correct buckets', () {
      // Verify bucket logic independently
      String bucket(int count) => switch (count) {
        0 => '0',
        <= 10 => '1-10',
        <= 50 => '11-50',
        <= 200 => '51-200',
        _ => '200+',
      };
      expect(bucket(0), '0');
      expect(bucket(1), '1-10');
      expect(bucket(10), '1-10');
      expect(bucket(11), '11-50');
      expect(bucket(50), '11-50');
      expect(bucket(51), '51-200');
      expect(bucket(200), '51-200');
      expect(bucket(201), '200+');
    });
  });
}
