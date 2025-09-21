// Mock implementation of log detail data sources
// TODO: Replace with real Isar and Firestore implementations

import 'package:fpdart/fpdart.dart';
import '../datasources/log_detail_datasource.dart';
import '../models/log_detail_model.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../../../domain/models/tag.dart';
import '../../../../domain/models/reason.dart';
import '../../../../domain/models/method.dart';
import '../../../../core/failures/app_failure.dart';

/// Mock local data source for development
class MockLogDetailLocalDataSource implements LogDetailLocalDataSource {
  // In-memory cache for development
  static final Map<String, LogDetailModel> _cache = {};

  @override
  Future<Either<AppFailure, LogDetailModel>> getLogDetail(String logId) async {
    // No artificial delay to avoid timer issues in tests

    if (_cache.containsKey(logId)) {
      return Right(_cache[logId]!);
    }

    // Check if we can find it in mock data
    final mockLog = _generateMockLog(logId);
    if (mockLog != null) {
      _cache[logId] = mockLog;
      return Right(mockLog);
    }

    return const Left(AppFailure.notFound(message: 'Log not found'));
  }

  @override
  Future<Either<AppFailure, bool>> logExists(String logId) async {
    // No artificial delay to avoid timer issues in tests
    return Right(_cache.containsKey(logId) || _generateMockLog(logId) != null);
  }

  @override
  Future<Either<AppFailure, void>> cacheLogDetail(LogDetailModel model) async {
    // No artificial delay to avoid timer issues in tests
    _cache[model.log.id] = model;
    return const Right(null);
  }

  LogDetailModel? _generateMockLog(String logId) {
    // Generate some mock data for development/testing
    if (logId.startsWith('test-') ||
        ['abc', 'first', 'demo', 'second'].contains(logId)) {
      final now = DateTime.now();
      final log = SmokeLog(
        id: logId,
        accountId: 'test-account-1',
        ts: now.subtract(Duration(hours: logId.hashCode.abs() % 24)),
        durationMs: 15000 + (logId.hashCode % 30000), // 15-45 seconds
        methodId: 'vape-pen',
        potency: 7,
        moodScore: 8,
        physicalScore: 6,
        notes: 'Mock log entry for testing purposes',
        deviceLocalId: 'test-device',
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now,
      );

      final tags = [
        Tag(
          id: 'tag-1',
          accountId: 'test-account-1',
          name: 'Evening',
          color: '#FF6B6B',
          createdAt: now.subtract(const Duration(days: 7)),
          updatedAt: now.subtract(const Duration(days: 7)),
        ),
        Tag(
          id: 'tag-2',
          accountId: 'test-account-1',
          name: 'Stress Relief',
          color: '#4ECDC4',
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
      ];

      final reasons = [
        Reason(
          id: 'reason-1',
          accountId: 'test-account-1',
          name: 'Anxiety',
          enabled: true,
          orderIndex: 1,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 30)),
        ),
      ];

      final method = Method(
        id: 'vape-pen',
        accountId: 'test-account-1',
        name: 'Vape Pen',
        category: 'vaporization',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 60)),
      );

      return LogDetailModel(
        log: log,
        tags: tags,
        reasons: reasons,
        method: method,
      );
    }

    return null;
  }
}

/// Mock remote data source for development
class MockLogDetailRemoteDataSource implements LogDetailRemoteDataSource {
  @override
  Future<Either<AppFailure, LogDetailModel>> getLogDetail(String logId) async {
    // No artificial delay to avoid timer issues in tests

    // Use the same mock data generation as local source
    final mockLocalSource = MockLogDetailLocalDataSource();
    return mockLocalSource.getLogDetail(logId);
  }

  @override
  Future<Either<AppFailure, LogDetailModel>> refreshLogDetail(
      String logId) async {
    // No artificial delay to avoid timer issues in tests
    return getLogDetail(logId);
  }

  @override
  Future<Either<AppFailure, bool>> logExists(String logId) async {
    // No artificial delay to avoid timer issues in tests
    final mockLocalSource = MockLogDetailLocalDataSource();
    return mockLocalSource.logExists(logId);
  }
}
