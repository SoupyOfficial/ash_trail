// Data model for reachability audit report persistence
// Maps between domain entities and storage format

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/painting.dart';
import '../../domain/entities/reachability_audit_report.dart';
import 'reachability_zone_model.dart';
import 'ui_element_model.dart';
import 'audit_summary_model.dart';
import 'audit_recommendation_model.dart';

part 'reachability_audit_report_model.freezed.dart';
part 'reachability_audit_report_model.g.dart';

@freezed
class ReachabilityAuditReportModel with _$ReachabilityAuditReportModel {
  const factory ReachabilityAuditReportModel({
    required String id,
    required DateTime timestamp,
    required String screenName,
    required double screenWidth,
    required double screenHeight,
    required List<UiElementModel> elements,
    required List<ReachabilityZoneModel> zones,
    required AuditSummaryModel summary,
    List<AuditRecommendationModel>? recommendations,
  }) = _ReachabilityAuditReportModel;

  const ReachabilityAuditReportModel._();

  factory ReachabilityAuditReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReachabilityAuditReportModelFromJson(json);

  ReachabilityAuditReport toEntity() => ReachabilityAuditReport(
        id: id,
        timestamp: timestamp,
        screenName: screenName,
        screenSize: Size(screenWidth, screenHeight),
        elements: elements.map((e) => e.toEntity()).toList(),
        zones: zones.map((z) => z.toEntity()).toList(),
        summary: summary.toEntity(),
        recommendations: recommendations?.map((r) => r.toEntity()).toList(),
      );

  factory ReachabilityAuditReportModel.fromEntity(
          ReachabilityAuditReport entity) =>
      ReachabilityAuditReportModel(
        id: entity.id,
        timestamp: entity.timestamp,
        screenName: entity.screenName,
        screenWidth: entity.screenSize.width,
        screenHeight: entity.screenSize.height,
        elements:
            entity.elements.map((e) => UiElementModel.fromEntity(e)).toList(),
        zones: entity.zones
            .map((z) => ReachabilityZoneModel.fromEntity(z))
            .toList(),
        summary: AuditSummaryModel.fromEntity(entity.summary),
        recommendations: entity.recommendations
            ?.map((r) => AuditRecommendationModel.fromEntity(r))
            .toList(),
      );
}
