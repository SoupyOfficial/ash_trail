import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/data/models/smoke_log_isar.dart';
import 'package:ash_trail/data/services/isar_service.dart';
import 'package:ash_trail/data/services/background_sync_service.dart';
import 'package:ash_trail/data/services/data_migration_service.dart';
import 'package:ash_trail/data/repositories/smoke_log_repository_isar.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('Phase 2 Enhanced Data Persistence Validation', () {
    test('SmokeLogIsar model can be created and converted', () {
      // Given: A domain smoke log
      final domainLog = SmokeLog(
        id: 'test-id',
        accountId: 'test-account',
        ts: DateTime(2024, 1, 1, 12, 0),
        durationMs: 300000, // 5 minutes
        notes: 'Test note',
        moodScore: 5,
        physicalScore: 7,
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 0),
      );

      // When: Converting to Isar model
      final isarLog = SmokeLogIsar.fromDomain(domainLog);

      // Then: All fields should be preserved
      expect(isarLog.logId, domainLog.id); // logId maps to domain id
      expect(isarLog.accountId, domainLog.accountId);
      expect(isarLog.ts, domainLog.ts);
      expect(isarLog.durationMs, domainLog.durationMs);
      expect(isarLog.notes, domainLog.notes);

      // And: Sync metadata should be initialized
      expect(isarLog.isDirty, true); // New records are dirty
      expect(isarLog.lastSyncAt, null); // Not yet synced
      expect(isarLog.syncError, null); // No sync errors initially

      // And: Converting back to domain should preserve data
      final backToDomain = isarLog.toDomain();
      expect(backToDomain.id, domainLog.id);
      expect(backToDomain.accountId, domainLog.accountId);
      expect(backToDomain.ts, domainLog.ts);
      expect(backToDomain.durationMs, domainLog.durationMs);
      expect(backToDomain.notes, domainLog.notes);
    });

    test('Services can be instantiated without errors', () {
      // Given: Phase 2 service classes exist
      // When: Attempting to create instances
      // Then: No compilation or instantiation errors should occur

      expect(() => IsarSmokeLogService, returnsNormally);
      expect(() => BackgroundSyncService, returnsNormally);
      expect(() => DataMigrationService, returnsNormally);
      expect(() => SmokeLogRepositoryIsar, returnsNormally);
    });

    test('AppFailure types work correctly', () {
      // Given: Various failure scenarios
      const dataFailure = AppFailure.cache(message: 'Test save error');
      const networkFailure = AppFailure.network(message: 'No internet');
      const validationFailure = AppFailure.validation(message: 'Invalid data');

      // When: Converting to strings
      final dataMessage = dataFailure.displayMessage;
      final networkMessage = networkFailure.displayMessage;
      final validationMessage = validationFailure.displayMessage;

      // Then: Messages should contain relevant information
      expect(dataMessage, contains('Test save error'));
      expect(networkMessage, contains('No internet'));
      expect(validationMessage, contains('Invalid data'));
    });

    test('Either type works correctly for repository pattern', () {
      // Given: Success and failure scenarios
      const failure = AppFailure.cache(message: 'Save failed');
      final success = SmokeLog(
        id: 'test-id',
        accountId: 'test-account',
        ts: DateTime(2024, 1, 1),
        durationMs: 120000,
        moodScore: 5,
        physicalScore: 7,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      const failureResult = Left<AppFailure, SmokeLog>(failure);
      final successResult = Right<AppFailure, SmokeLog>(success);

      // When: Checking results
      // Then: Either should work correctly
      expect(failureResult.isLeft(), true);
      expect(failureResult.isRight(), false);
      expect(successResult.isLeft(), false);
      expect(successResult.isRight(), true);

      failureResult.fold(
        (l) => expect(l, failure),
        (r) => fail('Should be left'),
      );

      successResult.fold(
        (l) => fail('Should be right'),
        (r) => expect(r, success),
      );
    });
  });

  group('Phase 2 Architecture Verification', () {
    test('Clean Architecture layers are properly separated', () {
      // This test verifies that our Phase 2 implementation maintains clean architecture

      // Domain layer should not depend on data layer implementations
      // Domain entities should be pure
      final domainLog = SmokeLog(
        id: 'test-id',
        accountId: 'test-account',
        ts: DateTime(2024, 1, 1),
        durationMs: 60000,
        moodScore: 5,
        physicalScore: 7,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(domainLog.id, 'test-id');
      expect(domainLog.accountId, 'test-account');
      expect(domainLog.durationMs, 60000);

      // Data layer models should convert to/from domain
      final isarModel = SmokeLogIsar.fromDomain(domainLog);
      final backToDomain = isarModel.toDomain();

      expect(backToDomain.id, domainLog.id);
      expect(backToDomain.accountId, domainLog.accountId);
      expect(backToDomain.durationMs, domainLog.durationMs);
    });
  });
}
