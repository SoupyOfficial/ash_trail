// Spotlight search item entity representing an indexed item for iOS Spotlight.
// Contains metadata about indexed content with deep link capabilities.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'spotlight_item_entity.freezed.dart';

@freezed
class SpotlightItemEntity with _$SpotlightItemEntity {
  const SpotlightItemEntity._();

  const factory SpotlightItemEntity({
    /// Unique identifier for this spotlight item
    required String id,

    /// The type of content being indexed
    required SpotlightItemType type,

    /// Display title for the spotlight result
    required String title,

    /// Description text shown in spotlight results
    String? description,

    /// Keywords for improving searchability
    List<String>? keywords,

    /// Deep link URL for navigation when item is selected
    required String deepLink,

    /// Account ID this item belongs to
    required String accountId,

    /// Original content ID (tag name, chart view id, etc.)
    required String contentId,

    /// When this item was created/last updated
    required DateTime lastUpdated,

    /// Whether this item should be indexed
    @Default(true) bool isActive,
  }) = _SpotlightItemEntity;

  /// Check if this item needs to be updated in spotlight
  /// (based on last updated time vs current indexed time)
  bool needsUpdate(DateTime? lastIndexedAt) {
    if (lastIndexedAt == null) return true;
    return lastUpdated.isAfter(lastIndexedAt);
  }

  /// Generate searchable content combining title, description, and keywords
  String get searchableContent {
    final parts = <String>[title];
    if (description?.isNotEmpty == true) parts.add(description!);
    if (keywords?.isNotEmpty == true) parts.addAll(keywords!);
    return parts.join(' ');
  }

  /// Check if this item is valid for indexing
  bool get isValidForIndexing {
    return isActive && title.isNotEmpty && deepLink.isNotEmpty;
  }
}

/// Types of content that can be indexed in Spotlight
enum SpotlightItemType {
  tag('Tag'),
  chartView('Chart View');

  const SpotlightItemType(this.displayName);

  final String displayName;

  /// Returns the appropriate content type identifier for Core Spotlight
  String get contentType => switch (this) {
        SpotlightItemType.tag => 'com.ashtrail.tag',
        SpotlightItemType.chartView => 'com.ashtrail.chartview',
      };

  /// Returns suggested keywords for this content type
  List<String> get defaultKeywords => switch (this) {
        SpotlightItemType.tag => ['tag', 'label', 'category'],
        SpotlightItemType.chartView => ['chart', 'view', 'graph', 'analysis'],
      };
}
