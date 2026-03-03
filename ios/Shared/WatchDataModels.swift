import Foundation

// MARK: - Shared data models between iOS app and watchOS companion
// These structs are Codable for easy serialization over WatchConnectivity

struct WatchLogEntry: Codable, Identifiable {
    let logId: String
    let eventType: String
    let eventAt: Date
    let duration: Double
    let moodRating: Double?
    let physicalRating: Double?
    let note: String?

    var id: String { logId }

    var formattedDuration: String {
        if duration < 60 {
            return String(format: "%.1fs", duration)
        } else {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return "\(minutes)m \(seconds)s"
        }
    }

    var relativeTime: String {
        let interval = Date().timeIntervalSince(eventAt)
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let mins = Int(interval / 60)
            return "\(mins)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }

    var eventTypeDisplayName: String {
        switch eventType {
        case "vape": return "Vape"
        case "inhale": return "Inhale"
        case "sessionStart": return "Session Start"
        case "sessionEnd": return "Session End"
        case "note": return "Note"
        case "purchase": return "Purchase"
        case "tolerance": return "Tolerance"
        case "symptomRelief": return "Symptom Relief"
        default: return eventType.capitalized
        }
    }

    /// Dictionary representation for WatchConnectivity transfer
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "logId": logId,
            "eventType": eventType,
            "eventAt": eventAt.timeIntervalSince1970,
            "duration": duration,
        ]
        if let moodRating { dict["moodRating"] = moodRating }
        if let physicalRating { dict["physicalRating"] = physicalRating }
        if let note { dict["note"] = note }
        return dict
    }

    /// Initialize from a dictionary received via WatchConnectivity
    init?(dictionary: [String: Any]) {
        guard let logId = dictionary["logId"] as? String,
              let eventType = dictionary["eventType"] as? String,
              let eventAtInterval = dictionary["eventAt"] as? TimeInterval,
              let duration = dictionary["duration"] as? Double else {
            return nil
        }
        self.logId = logId
        self.eventType = eventType
        self.eventAt = Date(timeIntervalSince1970: eventAtInterval)
        self.duration = duration
        self.moodRating = dictionary["moodRating"] as? Double
        self.physicalRating = dictionary["physicalRating"] as? Double
        self.note = dictionary["note"] as? String
    }

    init(logId: String, eventType: String, eventAt: Date, duration: Double,
         moodRating: Double? = nil, physicalRating: Double? = nil, note: String? = nil) {
        self.logId = logId
        self.eventType = eventType
        self.eventAt = eventAt
        self.duration = duration
        self.moodRating = moodRating
        self.physicalRating = physicalRating
        self.note = note
    }
}

struct WatchAnalytics: Codable {
    let hitsToday: Int
    let totalDurationToday: Double
    let timeSinceLastHitSeconds: Double?
    let averageGapSeconds: Double?
    let averageDurationSeconds: Double?
    let lastUpdated: Date

    var formattedTotalDuration: String {
        formatDuration(totalDurationToday)
    }

    var formattedTimeSinceLastHit: String {
        guard let seconds = timeSinceLastHitSeconds else { return "--" }
        return formatDuration(seconds)
    }

    var formattedAverageGap: String {
        guard let seconds = averageGapSeconds else { return "--" }
        return formatDuration(seconds)
    }

    var formattedAverageDuration: String {
        guard let seconds = averageDurationSeconds else { return "--" }
        if seconds < 60 {
            return String(format: "%.1fs", seconds)
        }
        return formatDuration(seconds)
    }

    private func formatDuration(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        } else if totalSeconds < 3600 {
            let m = totalSeconds / 60
            let s = totalSeconds % 60
            return "\(m)m \(s)s"
        } else {
            let h = totalSeconds / 3600
            let m = (totalSeconds % 3600) / 60
            return "\(h)h \(m)m"
        }
    }

    /// Dictionary representation for WatchConnectivity transfer
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "hitsToday": hitsToday,
            "totalDurationToday": totalDurationToday,
            "lastUpdated": lastUpdated.timeIntervalSince1970,
        ]
        if let timeSinceLastHitSeconds { dict["timeSinceLastHitSeconds"] = timeSinceLastHitSeconds }
        if let averageGapSeconds { dict["averageGapSeconds"] = averageGapSeconds }
        if let averageDurationSeconds { dict["averageDurationSeconds"] = averageDurationSeconds }
        return dict
    }

    /// Initialize from a dictionary received via WatchConnectivity
    init?(dictionary: [String: Any]) {
        guard let hitsToday = dictionary["hitsToday"] as? Int,
              let totalDurationToday = dictionary["totalDurationToday"] as? Double,
              let lastUpdatedInterval = dictionary["lastUpdated"] as? TimeInterval else {
            return nil
        }
        self.hitsToday = hitsToday
        self.totalDurationToday = totalDurationToday
        self.timeSinceLastHitSeconds = dictionary["timeSinceLastHitSeconds"] as? Double
        self.averageGapSeconds = dictionary["averageGapSeconds"] as? Double
        self.averageDurationSeconds = dictionary["averageDurationSeconds"] as? Double
        self.lastUpdated = Date(timeIntervalSince1970: lastUpdatedInterval)
    }

    init(hitsToday: Int, totalDurationToday: Double,
         timeSinceLastHitSeconds: Double?, averageGapSeconds: Double?,
         averageDurationSeconds: Double?, lastUpdated: Date = Date()) {
        self.hitsToday = hitsToday
        self.totalDurationToday = totalDurationToday
        self.timeSinceLastHitSeconds = timeSinceLastHitSeconds
        self.averageGapSeconds = averageGapSeconds
        self.averageDurationSeconds = averageDurationSeconds
        self.lastUpdated = lastUpdated
    }

    static let empty = WatchAnalytics(
        hitsToday: 0,
        totalDurationToday: 0,
        timeSinceLastHitSeconds: nil,
        averageGapSeconds: nil,
        averageDurationSeconds: nil
    )
}

// MARK: - Message Keys

enum WatchMessageKey {
    static let action = "action"
    static let duration = "duration"
    static let entries = "entries"
    static let analytics = "analytics"
    static let success = "success"
    static let error = "error"
    static let logId = "logId"
}

enum WatchAction {
    static let createLog = "createLog"
    static let getRecentEntries = "getRecentEntries"
    static let getAnalytics = "getAnalytics"
    static let logCreated = "logCreated"
    static let dataUpdated = "dataUpdated"
}
