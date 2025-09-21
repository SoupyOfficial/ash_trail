// Data source interface for log detail operations
// Abstracts data access from local and remote sources

import 'package:fpdart/fpdart.dart';
import '../models/log_detail_model.dart';
import '../../../../core/failures/app_failure.dart';

abstract class LogDetailDataSource {
  /// Get log detail from data source
  Future<Either<AppFailure, LogDetailModel>> getLogDetail(String logId);

  /// Check if log exists
  Future<Either<AppFailure, bool>> logExists(String logId);
}

/// Local data source (offline-first)
abstract class LogDetailLocalDataSource extends LogDetailDataSource {
  /// Cache log detail locally
  Future<Either<AppFailure, void>> cacheLogDetail(LogDetailModel model);
}

/// Remote data source (Firestore)
abstract class LogDetailRemoteDataSource extends LogDetailDataSource {
  /// Fetch fresh data from remote source
  Future<Either<AppFailure, LogDetailModel>> refreshLogDetail(String logId);
}