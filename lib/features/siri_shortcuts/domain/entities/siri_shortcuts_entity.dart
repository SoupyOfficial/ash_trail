// Siri Shortcuts entity representing a configured shortcut with its metadata.
// Contains information about donated shortcuts and their usage tracking.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'siri_shortcut_type.dart';

part 'siri_shortcuts_entity.freezed.dart';

@freezed
class SiriShortcutsEntity with _$SiriShortcutsEntity {
  const SiriShortcutsEntity._();

  const factory SiriShortcutsEntity({
    /// Unique identifier for this shortcut configuration
    required String id,
    
    /// The type of shortcut (add log, start timed log, etc.)
    required SiriShortcutType type,
    
    /// When this shortcut configuration was created
    required DateTime createdAt,
    
    /// When this shortcut was last donated to Siri
    DateTime? lastDonatedAt,
    
    /// Number of times this shortcut has been invoked
    @Default(0) int invocationCount,
    
    /// Whether this shortcut is currently active/donated
    @Default(false) bool isDonated,
    
    /// Custom user phrase for this shortcut (optional)
    String? customPhrase,
    
    /// When this shortcut was last successfully invoked
    DateTime? lastInvokedAt,
  }) = _SiriShortcutsEntity;

  /// Check if this shortcut needs to be re-donated
  /// (based on time since last donation or if not donated)
  bool get needsReDonation {
    if (!isDonated) return true;
    if (lastDonatedAt == null) return true;
    
    // Re-donate if it's been more than 7 days since last donation
    final daysSinceLastDonation = DateTime.now().difference(lastDonatedAt!).inDays;
    return daysSinceLastDonation > 7;
  }

  /// Get the phrase to use for this shortcut (custom or default)
  String get effectivePhrase => customPhrase ?? type.suggestedPhrase;

  /// Check if this shortcut has been used recently
  bool get isRecentlyUsed {
    if (lastInvokedAt == null) return false;
    final daysSinceLastInvoked = DateTime.now().difference(lastInvokedAt!).inDays;
    return daysSinceLastInvoked <= 30;
  }

  /// Create a copy with updated invocation tracking
  SiriShortcutsEntity withInvocation() {
    return copyWith(
      invocationCount: invocationCount + 1,
      lastInvokedAt: DateTime.now(),
    );
  }

  /// Create a copy marking as donated
  SiriShortcutsEntity withDonation() {
    return copyWith(
      isDonated: true,
      lastDonatedAt: DateTime.now(),
    );
  }
}