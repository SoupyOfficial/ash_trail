// Local data source for reachability audit reports
// Handles persistent storage and retrieval

import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reachability_audit_report_model.dart';
import '../../domain/entities/reachability_zone.dart';

abstract class ReachabilityLocalDataSource {
  Future<List<ReachabilityAuditReportModel>> getAllAuditReports();
  Future<ReachabilityAuditReportModel?> getAuditReport(String id);
  Future<ReachabilityAuditReportModel> saveAuditReport(ReachabilityAuditReportModel report);
  Future<void> deleteAuditReport(String id);
  Future<void> saveZoneConfiguration(Size screenSize, List<ReachabilityZone> zones);
  Future<List<ReachabilityZone>?> getZoneConfiguration(Size screenSize);
}

class ReachabilityLocalDataSourceImpl implements ReachabilityLocalDataSource {
  const ReachabilityLocalDataSourceImpl(this._prefs);
  
  final SharedPreferences _prefs;
  
  static const _reportsKey = 'reachability_reports';
  static const _zoneConfigPrefix = 'reachability_zones_';

  @override
  Future<List<ReachabilityAuditReportModel>> getAllAuditReports() async {
    try {
      final reportIds = _prefs.getStringList(_reportsKey) ?? [];
      final reports = <ReachabilityAuditReportModel>[];
      
      for (final id in reportIds) {
        final reportJson = _prefs.getString('report_$id');
        if (reportJson != null) {
          final reportData = json.decode(reportJson) as Map<String, dynamic>;
          reports.add(ReachabilityAuditReportModel.fromJson(reportData));
        }
      }
      
      // Sort by timestamp (newest first)
      reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return reports;
    } catch (e) {
      throw Exception('Failed to load audit reports: $e');
    }
  }

  @override
  Future<ReachabilityAuditReportModel?> getAuditReport(String id) async {
    try {
      final reportJson = _prefs.getString('report_$id');
      if (reportJson == null) return null;
      
      final reportData = json.decode(reportJson) as Map<String, dynamic>;
      return ReachabilityAuditReportModel.fromJson(reportData);
    } catch (e) {
      throw Exception('Failed to load audit report: $e');
    }
  }

  @override
  Future<ReachabilityAuditReportModel> saveAuditReport(ReachabilityAuditReportModel report) async {
    try {
      // Save the report data
      final reportJson = json.encode(report.toJson());
      await _prefs.setString('report_${report.id}', reportJson);
      
      // Add to reports list if not already present
      final reportIds = _prefs.getStringList(_reportsKey) ?? [];
      if (!reportIds.contains(report.id)) {
        reportIds.add(report.id);
        await _prefs.setStringList(_reportsKey, reportIds);
      }
      
      return report;
    } catch (e) {
      throw Exception('Failed to save audit report: $e');
    }
  }

  @override
  Future<void> deleteAuditReport(String id) async {
    try {
      // Remove report data
      await _prefs.remove('report_$id');
      
      // Remove from reports list
      final reportIds = _prefs.getStringList(_reportsKey) ?? [];
      reportIds.remove(id);
      await _prefs.setStringList(_reportsKey, reportIds);
    } catch (e) {
      throw Exception('Failed to delete audit report: $e');
    }
  }

  @override
  Future<void> saveZoneConfiguration(Size screenSize, List<ReachabilityZone> zones) async {
    try {
      final configKey = _getZoneConfigKey(screenSize);
      final zonesJson = zones.map((zone) => {
        'id': zone.id,
        'name': zone.name,
        'left': zone.bounds.left,
        'top': zone.bounds.top,
        'width': zone.bounds.width,
        'height': zone.bounds.height,
        'level': zone.level.name,
        'description': zone.description,
      }).toList();
      
      await _prefs.setString(configKey, json.encode(zonesJson));
    } catch (e) {
      throw Exception('Failed to save zone configuration: $e');
    }
  }

  @override
  Future<List<ReachabilityZone>?> getZoneConfiguration(Size screenSize) async {
    try {
      final configKey = _getZoneConfigKey(screenSize);
      final zonesJson = _prefs.getString(configKey);
      
      if (zonesJson == null) return null;
      
      final zonesData = json.decode(zonesJson) as List<dynamic>;
      final zones = zonesData.map((zoneData) {
        final data = zoneData as Map<String, dynamic>;
        return ReachabilityZone(
          id: data['id'] as String,
          name: data['name'] as String,
          bounds: Rect.fromLTWH(
            data['left'] as double,
            data['top'] as double,
            data['width'] as double,
            data['height'] as double,
          ),
          level: ReachabilityLevel.values.firstWhere(
            (level) => level.name == data['level'],
            orElse: () => ReachabilityLevel.easy,
          ),
          description: data['description'] as String,
        );
      }).toList();
      
      return zones;
    } catch (e) {
      throw Exception('Failed to load zone configuration: $e');
    }
  }

  String _getZoneConfigKey(Size screenSize) {
    return '$_zoneConfigPrefix${screenSize.width.round()}x${screenSize.height.round()}';
  }
}