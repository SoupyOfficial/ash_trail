// Repository interface for log detail data access
// Provides methods to retrieve log details with related entities

import 'package:fpdart/fpdart.dart';
import '../entities/log_detail_entity.dart';
import '../../../../core/failures/app_failure.dart';

abstract class LogDetailRepository {
  /// Retrieves a log with its complete detail information
  /// Returns LogDetailEntity with log, tags, reasons, and method
  Future<Either<AppFailure, LogDetailEntity>> getLogDetail(String logId);

  /// Checks if a log exists
  Future<Either<AppFailure, bool>> logExists(String logId);

  /// Refreshes log detail data from remote source if available
  Future<Either<AppFailure, LogDetailEntity>> refreshLogDetail(String logId);
}