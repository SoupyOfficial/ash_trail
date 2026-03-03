import Foundation

/// Shared data store for complications to read cached analytics.
/// The watch app writes data here via App Group; the widget reads it.
/// Since both targets are in the same watch app bundle, we use UserDefaults
/// with a suite name matching the app group.
struct ComplicationDataStore {
    static let suiteName = "group.com.soup.smokeLog.watchkitapp"
    
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
    
    // MARK: - Keys
    
    private enum Keys {
        static let hitsToday = "complication_hitsToday"
        static let totalDurationToday = "complication_totalDurationToday"
        static let lastHitTimestamp = "complication_lastHitTimestamp"
        static let averageGapSeconds = "complication_averageGapSeconds"
        static let lastUpdated = "complication_lastUpdated"
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
    
    static var lastUpdated: Date {
        let ts = defaults.double(forKey: Keys.lastUpdated)
        return ts > 0 ? Date(timeIntervalSince1970: ts) : .distantPast
    }
    
    /// Whether the cached data is older than the given interval (default 15 minutes)
    static func isStale(threshold: TimeInterval = 15 * 60) -> Bool {
        Date().timeIntervalSince(lastUpdated) > threshold
    }
    
    // MARK: - Write (called by watch app)
    
    static func update(from analytics: WatchAnalytics) {
        defaults.set(analytics.hitsToday, forKey: Keys.hitsToday)
        defaults.set(analytics.totalDurationToday, forKey: Keys.totalDurationToday)
        defaults.set(analytics.averageGapSeconds ?? 0, forKey: Keys.averageGapSeconds)
        defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastUpdated)
        
        // Compute last hit absolute timestamp from timeSinceLastHit
        if let sinceLast = analytics.timeSinceLastHitSeconds {
            let lastHitDate = analytics.lastUpdated.addingTimeInterval(-sinceLast)
            defaults.set(lastHitDate.timeIntervalSince1970, forKey: Keys.lastHitTimestamp)
        }
    }
}
