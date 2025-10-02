import 'dart:convert';

import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/data/repositories/smoke_log_repository_isar.dart';
import 'package:ash_trail/data/services/data_migration_service.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockSmokeLogRepositoryIsar extends Mock
    implements SmokeLogRepositoryIsar {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockSmokeLogRepositoryIsar mockRepository;
  late MockLogger mockLogger;
  late DataMigrationService service;

  SmokeLog buildSmokeLog({
    String id = 'log-1',
    String accountId = 'account-1',
  }) {
    final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
    return SmokeLog(
      id: id,
      accountId: accountId,
      ts: now,
      durationMs: 120000,
      moodScore: 6,
      physicalScore: 5,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUpAll(() {
    registerFallbackValue(buildSmokeLog());
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockRepository = MockSmokeLogRepositoryIsar();
    mockLogger = MockLogger();

    service = DataMigrationService(
      prefs: mockPrefs,
      isarRepository: mockRepository,
      logger: mockLogger,
    );

    when(() => mockLogger.d(any())).thenAnswer((_) {});
    when(() => mockLogger.i(any())).thenAnswer((_) {});
    when(() => mockLogger.w(any())).thenAnswer((_) {});
    when(() => mockLogger.e(
          any(),
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
        )).thenAnswer((_) {});
  });

  group('isMigrationCompleted', () {
    test('returns false when preference is unset', () {
      when(() => mockPrefs.getBool('data_migration_completed_v2'))
          .thenReturn(null);

      expect(service.isMigrationCompleted, isFalse);
    });

    test('returns true when preference is set', () {
      when(() => mockPrefs.getBool('data_migration_completed_v2'))
          .thenReturn(true);

      expect(service.isMigrationCompleted, isTrue);
    });
  });

  group('migrateAllData', () {
    test('skips migration when already completed', () async {
      when(() => mockPrefs.getBool('data_migration_completed_v2'))
          .thenReturn(true);

      final result = await service.migrateAllData();

      expect(result, const Right(null));
      verifyNever(() => mockPrefs.getKeys());
      verifyNever(() => mockRepository.createSmokeLog(any()));
    });

    test('marks migration complete when no account data found', () async {
      when(() => mockPrefs.getBool('data_migration_completed_v2'))
          .thenReturn(false);
      when(() => mockPrefs.getKeys()).thenReturn({'other_key'});
      when(() => mockPrefs.setBool('data_migration_completed_v2', true))
          .thenAnswer((_) async => true);

      final result = await service.migrateAllData();

      expect(result, const Right(null));
      verify(() => mockPrefs.setBool('data_migration_completed_v2', true))
          .called(1);
      verifyNever(() => mockPrefs.remove(any()));
      verifyNever(() => mockRepository.createSmokeLog(any()));
    });

    test('migrates smoke logs and cleans up old data', () async {
      when(() => mockPrefs.getBool('data_migration_completed_v2'))
          .thenReturn(false);
      when(() => mockPrefs.getKeys()).thenReturn({
        'smoke_logs_account-1',
        'last_smoke_log_account-1',
        'unrelated_key',
      });

      final smokeLog = buildSmokeLog();
      when(() => mockPrefs.getStringList('smoke_logs_account-1'))
          .thenReturn([jsonEncode(smokeLog.toJson())]);
      when(() => mockRepository.createSmokeLog(any()))
          .thenAnswer((invocation) async {
        final log = invocation.positionalArguments.first as SmokeLog;
        return Right(log);
      });
      when(() => mockPrefs.setBool('data_migration_completed_v2', true))
          .thenAnswer((_) async => true);
      when(() => mockPrefs.containsKey('smoke_logs_account-1'))
          .thenReturn(true);
      when(() => mockPrefs.containsKey('last_smoke_log_account-1'))
          .thenReturn(true);
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

      final result = await service.migrateAllData();

      expect(result, const Right(null));
      verify(() => mockRepository.createSmokeLog(smokeLog)).called(1);
      verify(() => mockPrefs.setBool('data_migration_completed_v2', true))
          .called(1);
      verify(() => mockPrefs.remove('smoke_logs_account-1')).called(1);
      verify(() => mockPrefs.remove('last_smoke_log_account-1')).called(1);
    });

    test('returns failure when an account migration throws', () async {
      when(() => mockPrefs.getBool('data_migration_completed_v2'))
          .thenReturn(false);
      when(() => mockPrefs.getKeys()).thenReturn({'smoke_logs_account-1'});
      when(() => mockPrefs.getStringList('smoke_logs_account-1'))
          .thenThrow(Exception('read error'));

      final result = await service.migrateAllData();

      expect(result.isLeft(), isTrue);
      result.match(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(
            failure.displayMessage,
            contains('Migration completed with errors'),
          );
          return null;
        },
        (_) => fail('Expected failure'),
      );
      verifyNever(() => mockPrefs.setBool('data_migration_completed_v2', true));
    });
  });

  group('verifyMigration', () {
    test('builds report with successes, mismatches, and errors', () async {
      when(() => mockPrefs.getKeys()).thenReturn({
        'smoke_logs_account-1',
        'smoke_logs_account-2',
        'smoke_logs_account-3',
        'other_key',
      });

      when(() => mockPrefs.getStringList('smoke_logs_account-1'))
          .thenReturn(['{}', '{}']);
      when(() => mockPrefs.getStringList('smoke_logs_account-2'))
          .thenReturn(['{}']);
      when(() => mockPrefs.getStringList('smoke_logs_account-3'))
          .thenReturn(['{}', '{}', '{}']);

      when(() => mockRepository.getSmokeLogsCount('account-1'))
          .thenAnswer((_) async => const Right(2));
      when(() => mockRepository.getSmokeLogsCount('account-2'))
          .thenAnswer((_) async => const Right(0));
      when(() => mockRepository.getSmokeLogsCount('account-3')).thenAnswer(
          (_) async => const Left(AppFailure.cache(message: 'count failure')));

      final result = await service.verifyMigration();

      expect(result.isRight(), isTrue);
      final report = result.getRight().toNullable()!;
      expect(report.totalAccounts, 2);
      expect(report.successfulAccounts, 1);
      expect(report.mismatchAccounts, 1);
      expect(report.accountComparisons.keys, contains('account-1'));
      expect(report.accountComparisons.keys, contains('account-2'));
      expect(report.errors.length, 2);
      expect(report.isSuccessful, isFalse);
    });
  });

  group('resetMigrationFlag', () {
    test('removes completion flag', () async {
      when(() => mockPrefs.remove('data_migration_completed_v2'))
          .thenAnswer((_) async => true);

      await service.resetMigrationFlag();

      verify(() => mockPrefs.remove('data_migration_completed_v2')).called(1);
    });
  });
}
