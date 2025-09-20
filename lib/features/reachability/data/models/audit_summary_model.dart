// Data model for audit summary persistence
// Maps between domain AuditSummary and storage format

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/reachability_audit_report.dart';

part 'audit_summary_model.freezed.dart';
part 'audit_summary_model.g.dart';

@freezed
class AuditSummaryModel with _$AuditSummaryModel {
  const factory AuditSummaryModel({
    required int totalElements,
    required int interactiveElements,
    required int elementsInEasyReach,
    required int elementsWithIssues,
    required double avgTouchTargetSize,
    required int accessibilityIssues,
  }) = _AuditSummaryModel;

  const AuditSummaryModel._();

  factory AuditSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$AuditSummaryModelFromJson(json);

  AuditSummary toEntity() => AuditSummary(
        totalElements: totalElements,
        interactiveElements: interactiveElements,
        elementsInEasyReach: elementsInEasyReach,
        elementsWithIssues: elementsWithIssues,
        avgTouchTargetSize: avgTouchTargetSize,
        accessibilityIssues: accessibilityIssues,
      );

  factory AuditSummaryModel.fromEntity(AuditSummary entity) =>
      AuditSummaryModel(
        totalElements: entity.totalElements,
        interactiveElements: entity.interactiveElements,
        elementsInEasyReach: entity.elementsInEasyReach,
        elementsWithIssues: entity.elementsWithIssues,
        avgTouchTargetSize: entity.avgTouchTargetSize,
        accessibilityIssues: entity.accessibilityIssues,
      );
}
