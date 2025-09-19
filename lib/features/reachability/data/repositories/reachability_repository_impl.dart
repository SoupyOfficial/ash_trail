// Repository implementation for reachability audit functionality
// Handles persistence and business logic for audit data

import 'package:fpdart/fpdart.dart';
import 'package:flutter/painting.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/reachability_audit_report.dart';
import '../../domain/entities/reachability_zone.dart';
import '../../domain/entities/ui_element.dart';
import '../../domain/repositories/reachability_repository.dart';
import '../../../../core/failures/app_failure.dart';
import '../models/reachability_audit_report_model.dart';
import '../datasources/reachability_local_datasource.dart';
import '../datasources/reachability_zone_factory.dart';

class ReachabilityRepositoryImpl implements ReachabilityRepository {
  const ReachabilityRepositoryImpl(
    this._localDataSource,
    this._zoneFactory,
  );

  final ReachabilityLocalDataSource _localDataSource;
  final ReachabilityZoneFactory _zoneFactory;
  final _uuid = const Uuid();

  @override
  Future<Either<AppFailure, List<ReachabilityAuditReport>>>
      getAllAuditReports() async {
    try {
      final models = await _localDataSource.getAllAuditReports();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.cache(message: 'Failed to load audit reports'));
    }
  }

  @override
  Future<Either<AppFailure, ReachabilityAuditReport>> getAuditReport(
      String id) async {
    try {
      final model = await _localDataSource.getAuditReport(id);
      if (model == null) {
        return Left(AppFailure.notFound(
            message: 'Audit report not found', resourceId: id));
      }
      return Right(model.toEntity());
    } catch (e, stack) {
      return Left(AppFailure.cache(message: 'Failed to load audit report'));
    }
  }

  @override
  Future<Either<AppFailure, ReachabilityAuditReport>> saveAuditReport(
      ReachabilityAuditReport report) async {
    try {
      final model = ReachabilityAuditReportModel.fromEntity(report);
      final savedModel = await _localDataSource.saveAuditReport(model);
      return Right(savedModel.toEntity());
    } catch (e, stack) {
      return Left(AppFailure.cache(message: 'Failed to save audit report'));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteAuditReport(String id) async {
    try {
      await _localDataSource.deleteAuditReport(id);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.cache(message: 'Failed to delete audit report'));
    }
  }

  @override
  Future<Either<AppFailure, List<ReachabilityZone>>> getReachabilityZones(
      Size screenSize) async {
    try {
      final zones = _zoneFactory.createZonesForScreen(screenSize);
      return Right(zones);
    } catch (e, stack) {
      return Left(AppFailure.unexpected(
          message: 'Failed to generate reachability zones'));
    }
  }

  @override
  Future<Either<AppFailure, void>> saveZoneConfiguration(
      Size screenSize, List<ReachabilityZone> zones) async {
    try {
      await _localDataSource.saveZoneConfiguration(screenSize, zones);
      return const Right(null);
    } catch (e, stack) {
      return Left(
          AppFailure.cache(message: 'Failed to save zone configuration'));
    }
  }

  @override
  Future<Either<AppFailure, ReachabilityAuditReport>> performAudit({
    required String screenName,
    required Size screenSize,
    required List<UiElement> elements,
  }) async {
    try {
      // Get reachability zones for screen size
      final zonesResult = await getReachabilityZones(screenSize);
      if (zonesResult.isLeft()) {
        return zonesResult.fold(
          (failure) => Left(failure),
          (_) => Left(AppFailure.unexpected(message: 'Unexpected error')),
        );
      }

      final zones = zonesResult.getRight().getOrElse(() => []);

      // Generate audit summary
      final summary = _generateAuditSummary(elements, zones);

      // Generate recommendations
      final recommendations = _generateRecommendations(elements, zones);

      // Create audit report
      final report = ReachabilityAuditReport(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        screenName: screenName,
        screenSize: screenSize,
        elements: elements,
        zones: zones,
        summary: summary,
        recommendations: recommendations,
      );

      // Save the report
      return saveAuditReport(report);
    } catch (e, stack) {
      return Left(AppFailure.unexpected(
        message: 'Failed to perform audit',
        cause: e,
        stackTrace: stack,
      ));
    }
  }

  AuditSummary _generateAuditSummary(
      List<UiElement> elements, List<ReachabilityZone> zones) {
    final interactiveElements = elements.where((e) => e.isInteractive).toList();
    final elementsInEasyReach = interactiveElements
        .where((e) => e.getReachabilityLevel(zones) == ReachabilityLevel.easy)
        .length;

    final elementsWithIssues = interactiveElements
        .where((e) =>
            e.getReachabilityLevel(zones) != ReachabilityLevel.easy ||
            !e.meetsTouchTargetSize ||
            e.needsAccessibilityImprovement)
        .length;

    final accessibilityIssues =
        elements.where((e) => e.needsAccessibilityImprovement).length;

    // Calculate average touch target size for interactive elements
    double avgTouchTargetSize = 0.0;
    if (interactiveElements.isNotEmpty) {
      final totalSize = interactiveElements
          .map((e) =>
              (e.bounds.width + e.bounds.height) /
              2) // Average of width and height
          .reduce((a, b) => a + b);
      avgTouchTargetSize = totalSize / interactiveElements.length;
    }

    return AuditSummary(
      totalElements: elements.length,
      interactiveElements: interactiveElements.length,
      elementsInEasyReach: elementsInEasyReach,
      elementsWithIssues: elementsWithIssues,
      avgTouchTargetSize: avgTouchTargetSize,
      accessibilityIssues: accessibilityIssues,
    );
  }

  List<AuditRecommendation> _generateRecommendations(
      List<UiElement> elements, List<ReachabilityZone> zones) {
    final recommendations = <AuditRecommendation>[];

    for (final element in elements) {
      if (!element.isInteractive) continue;

      // Check reachability
      final reachabilityLevel = element.getReachabilityLevel(zones);
      if (reachabilityLevel != ReachabilityLevel.easy) {
        recommendations.add(AuditRecommendation(
          elementId: element.id,
          type: RecommendationType.moveToEasyReach,
          description:
              'Move "${element.label}" to easy reach zone for better accessibility',
          priority: RecommendationType.moveToEasyReach.defaultPriority,
          suggestedFix:
              'Consider repositioning this element to the lower 60% of the screen',
        ));
      }

      // Check touch target size
      if (!element.meetsTouchTargetSize) {
        recommendations.add(AuditRecommendation(
          elementId: element.id,
          type: RecommendationType.increaseTouchTarget,
          description: 'Increase touch target size for "${element.label}"',
          priority: RecommendationType.increaseTouchTarget.defaultPriority,
          suggestedFix: 'Ensure minimum 48dp touch target size',
        ));
      }

      // Check accessibility
      if (element.needsAccessibilityImprovement) {
        if (element.semanticLabel == null || element.semanticLabel!.isEmpty) {
          recommendations.add(AuditRecommendation(
            elementId: element.id,
            type: RecommendationType.addAccessibilityLabel,
            description: 'Add accessibility label for "${element.label}"',
            priority: RecommendationType.addAccessibilityLabel.defaultPriority,
            suggestedFix: 'Add meaningful semantic label for screen readers',
          ));
        }

        if (element.hasAlternativeAccess != true) {
          recommendations.add(AuditRecommendation(
            elementId: element.id,
            type: RecommendationType.addAlternativeAccess,
            description:
                'Consider alternative access method for "${element.label}"',
            priority: RecommendationType.addAlternativeAccess.defaultPriority,
            suggestedFix: 'Add keyboard navigation or gesture alternative',
          ));
        }
      }
    }

    // Sort by priority (ascending - lower number = higher priority)
    recommendations.sort((a, b) => a.priority.compareTo(b.priority));

    return recommendations;
  }
}
