import Foundation

/// Shared data store for iOS home screen widgets to read cached analytics.
/// The Flutter app writes data here via the `home_widget` package using App Group
/// UserDefaults; the widget extension reads it. Mirrors the pattern used by
/// `ComplicationDataStore` in the Watch Widgets extension.
struct iOSWidgetDataStore {
    static let suiteName = "group.com.soup.smokeLog"
    
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
    
    // MARK: - Keys
    
    private enum Keys {
        static let hitsToday = "widget_hitsToday"
        static let totalDurationToday = "widget_totalDurationToday"
        static let lastHitTimestamp = "widget_lastHitTimestamp"
        static let averageGapSeconds = "widget_averageGapSeconds"
        static let averageDurationSeconds = "widget_averageDurationSeconds"
        static let longestGapSeconds = "widget_longestGapSeconds"
        static let dailyAverageHits = "widget_dailyAverageHits"
        static let lastUpdated = "widget_lastUpdated"
    }
    
    // MARK: - Read
    
    static var hitsToday: Int {
        defaults.integer(forKey: Keys.hitsToday)
    }
    
    static var totalDurationToday: Double {
        defaults.double(forKey: Keys.totalDurationToday)
    }
    
    /// The Date of the last hit, or nil if unknown
    static var lastHitDate: Date? {
        let ts = defaults.double(forKey: Keys.lastHitTimestamp)
        return ts > 0 ? Date(timeIntervalSince1970: ts) : nil
    }
    
    static var averageGapSeconds: Double? {
        let v = defaults.double(forKey: Keys.averageGapSeconds)
        return v > 0 ? v : nil
    }
    
    static var averageDurationSeconds: Double? {
        let v = defaults.double(forKey: Keys.averageDurationSeconds)
        return v > 0 ? v : nil
    }
    
    static var longestGapSeconds: Double? {
        let v = defaults.double(forKey: Keys.longestGapSeconds)
        return v > 0 ? v : nil
    }
    
    static var dailyAverageHits: Double? {
        let v = defaults.double(forKey: Keys.dailyAverageHits)
        return v > 0 ? v : nil
    }
    
    static var lastUpdated: Date {
        let ts = defaults.double(forKey: Keys.lastUpdated)
        return ts > 0 ? Date(timeIntervalSince1970: ts) : .distantPast
    }
    
    // MARK: - Formatting Helpers
    
    static func formatDuration(_ seconds: Double) -> String {
        let total = Int(seconds)
        if total < 60 { return "\(total)s" }
        if total < 3600 { return "\(total / 60)m \(total % 60)s" }
        return "\(total / 3600)h \((total % 3600) / 60)m"
    }
    
    static func formatElapsed(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds))
        if total < 60 { return "\(total)s" }
        if total < 3600 { return "\(total / 60)m" }
        let h = total / 3600
        let m = (total % 3600) / 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
    
    static func formatGap(_ seconds: Double) -> String {
        formatElapsed(seconds)
    }
}
