// Use case for performing reachability audit on UI elements
// Analyzes screen elements for thumb zone accessibility

import 'package:fpdart/fpdart.dart';
import 'package:flutter/painting.dart';
import '../entities/reachability_audit_report.dart';
import '../entities/ui_element.dart';
import '../repositories/reachability_repository.dart';
import '../../../../core/failures/app_failure.dart';

class PerformReachabilityAuditUseCase {
  const PerformReachabilityAuditUseCase(this._repository);
  
  final ReachabilityRepository _repository;
  
  Future<Either<AppFailure, ReachabilityAuditReport>> call({
    required String screenName,
    required Size screenSize,
    required List<UiElement> elements,
  }) async {
    return _repository.performAudit(
      screenName: screenName,
      screenSize: screenSize,
      elements: elements,
    );
  }
}