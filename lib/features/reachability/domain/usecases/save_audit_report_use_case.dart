// Use case for saving reachability audit reports
// Persists audit results for future reference

import 'package:fpdart/fpdart.dart';
import '../entities/reachability_audit_report.dart';
import '../repositories/reachability_repository.dart';
import '../../../../core/failures/app_failure.dart';

class SaveAuditReportUseCase {
  const SaveAuditReportUseCase(this._repository);
  
  final ReachabilityRepository _repository;
  
  Future<Either<AppFailure, ReachabilityAuditReport>> call(ReachabilityAuditReport report) async {
    return _repository.saveAuditReport(report);
  }
}