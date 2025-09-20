// Use case for retrieving saved reachability audit reports
// Provides access to historical audit data

import 'package:fpdart/fpdart.dart';
import '../entities/reachability_audit_report.dart';
import '../repositories/reachability_repository.dart';
import '../../../../core/failures/app_failure.dart';

class GetAuditReportsUseCase {
  const GetAuditReportsUseCase(this._repository);
  
  final ReachabilityRepository _repository;
  
  Future<Either<AppFailure, List<ReachabilityAuditReport>>> call() async {
    return _repository.getAllAuditReports();
  }
}