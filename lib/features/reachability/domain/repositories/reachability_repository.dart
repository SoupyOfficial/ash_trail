// Repository interface for reachability audit functionality
// Handles persistence and retrieval of audit reports and zone configurations

import 'package:fpdart/fpdart.dart';
import 'package:flutter/painting.dart';
import '../entities/reachability_audit_report.dart';
import '../entities/reachability_zone.dart';
import '../entities/ui_element.dart';
import '../../../../core/failures/app_failure.dart';

abstract class ReachabilityRepository {
  /// Get all saved audit reports
  Future<Either<AppFailure, List<ReachabilityAuditReport>>> getAllAuditReports();
  
  /// Get audit report by ID
  Future<Either<AppFailure, ReachabilityAuditReport>> getAuditReport(String id);
  
  /// Save an audit report
  Future<Either<AppFailure, ReachabilityAuditReport>> saveAuditReport(ReachabilityAuditReport report);
  
  /// Delete an audit report
  Future<Either<AppFailure, void>> deleteAuditReport(String id);
  
  /// Get predefined reachability zones for screen size
  Future<Either<AppFailure, List<ReachabilityZone>>> getReachabilityZones(Size screenSize);
  
  /// Save custom reachability zone configuration
  Future<Either<AppFailure, void>> saveZoneConfiguration(Size screenSize, List<ReachabilityZone> zones);
  
  /// Perform real-time audit of UI elements
  Future<Either<AppFailure, ReachabilityAuditReport>> performAudit({
    required String screenName,
    required Size screenSize,
    required List<UiElement> elements,
  });
}