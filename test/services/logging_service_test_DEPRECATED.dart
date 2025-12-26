// DEPRECATED: This test file uses the old Isar database
// These services were removed during Hive migration
// See log_record_service_test.dart for current Hive-based tests

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('⚠️ Legacy test - service no longer exists', () {
    print(
      'LoggingService was replaced with LogRecordService during Hive migration',
    );
    print('See test/services/log_record_service_test.dart for current tests');
    print('These tests work on ALL platforms: web, iOS, Android, desktop');
  });
}
