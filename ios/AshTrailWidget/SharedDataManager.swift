import Foundation

// MARK: - Widget Data Model
struct WidgetData: Codable {
    let hitsToday: Int
    let totalDurationToday: TimeInterval
    let timeSinceLastHit: TimeInterval?
    let lastHitTime: Date?
    let weeklyHits: [Int]
    let lastUpdated: Date

    static var empty: WidgetData {
        WidgetData(
            hitsToday: 0,
            totalDurationToday: 0,
            timeSinceLastHit: nil,
            lastHitTime: nil,
            weeklyHits: [0, 0, 0, 0, 0, 0, 0],
            lastUpdated: Date()
        )
    }
}

// MARK: - Shared Data Manager
class SharedDataManager {
    static let shared = SharedDataManager()

    // App Group identifier - must match in both app and widget
    private let appGroupIdentifier = "group.com.soupy.ashtrail"
    private let widgetDataKey = "widgetData"

    private init() {}

    /// Save widget data to shared container
    func saveWidgetData(_ data: WidgetData) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("Failed to access shared UserDefaults")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let encoded = try encoder.encode(data)
            sharedDefaults.set(encoded, forKey: widgetDataKey)
            sharedDefaults.synchronize()
            print("Widget data saved successfully")
        } catch {
            print("Failed to encode widget data: \(error)")
        }
    }

    /// Load widget data from shared container
    func loadWidgetData() -> WidgetData {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("Failed to access shared UserDefaults")
            return .empty
        }

        guard let data = sharedDefaults.data(forKey: widgetDataKey) else {
            print("No widget data found")
            return .empty
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(WidgetData.self, from: data)
            return decoded
        } catch {
            print("Failed to decode widget data: \(error)")
            return .empty
        }
    }

    /// Refresh all widgets
    func reloadAllWidgets() {
        #if os(iOS)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }
}
