// AshTrail Widget Extension Bundle
// Main entry point for the iOS home screen widget extension.

import WidgetKit
import SwiftUI

@main
struct AshTrailWidgetBundle: WidgetBundle {
    var body: some Widget {
        AshTrailWidget()
    }
}

struct AshTrailWidget: Widget {
    let kind: String = "AshTrailWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AshTrailTimelineProvider()) { entry in
            AshTrailWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("AshTrail")
        .description("Track your daily hits and streaks right from your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct AshTrailEntry: TimelineEntry {
    let date: Date
    let todayHitCount: Int
    let currentStreak: Int
    let lastSyncAt: Date
    let configuration: WidgetConfiguration?
}

struct WidgetConfiguration {
    let showStreak: Bool
    let showLastSync: Bool
    let tapAction: String
}

struct AshTrailTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> AshTrailEntry {
        AshTrailEntry(
            date: Date(),
            todayHitCount: 3,
            currentStreak: 7,
            lastSyncAt: Date(),
            configuration: WidgetConfiguration(
                showStreak: true,
                showLastSync: true,
                tapAction: "openApp"
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (AshTrailEntry) -> ()) {
        let entry = AshTrailEntry(
            date: Date(),
            todayHitCount: 5,
            currentStreak: 3,
            lastSyncAt: Date(),
            configuration: WidgetConfiguration(
                showStreak: context.family != .systemSmall,
                showLastSync: context.family == .systemMedium,
                tapAction: "openApp"
            )
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Load data from shared user defaults (app group)
        let userDefaults = UserDefaults(suiteName: "group.com.ashtrail.shared")
        
        let todayHitCount = userDefaults?.integer(forKey: "todayHitCount") ?? 0
        let currentStreak = userDefaults?.integer(forKey: "currentStreak") ?? 0
        let lastSyncTimestamp = userDefaults?.double(forKey: "lastSyncTimestamp") ?? Date().timeIntervalSince1970
        let lastSyncAt = Date(timeIntervalSince1970: lastSyncTimestamp)
        
        let showStreak = userDefaults?.bool(forKey: "widgetShowStreak") ?? true
        let showLastSync = userDefaults?.bool(forKey: "widgetShowLastSync") ?? true
        let tapAction = userDefaults?.string(forKey: "widgetTapAction") ?? "openApp"
        
        let currentDate = Date()
        let entry = AshTrailEntry(
            date: currentDate,
            todayHitCount: todayHitCount,
            currentStreak: currentStreak,
            lastSyncAt: lastSyncAt,
            configuration: WidgetConfiguration(
                showStreak: showStreak && context.family != .systemSmall,
                showLastSync: showLastSync && context.family == .systemMedium,
                tapAction: tapAction
            )
        )

        // Refresh every 15 minutes to keep data reasonably fresh
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))

        completion(timeline)
    }
}

struct AshTrailWidgetEntryView: View {
    var entry: AshTrailTimelineProvider.Entry

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width < 170 {
                // Small widget
                SmallWidgetView(entry: entry)
            } else {
                // Medium widget
                MediumWidgetView(entry: entry)
            }
        }
        .widgetURL(deepLinkURL)
    }
    
    private var deepLinkURL: URL? {
        let tapAction = entry.configuration?.tapAction ?? "openApp"
        switch tapAction {
        case "recordOverlay":
            return URL(string: "ashtrail://record")
        case "viewLogs":
            return URL(string: "ashtrail://logs")
        case "quickRecord":
            return URL(string: "ashtrail://record?quick=true")
        default:
            return URL(string: "ashtrail://")
        }
    }
}

struct SmallWidgetView: View {
    let entry: AshTrailEntry
    
    var body: some View {
        VStack(spacing: 4) {
            Spacer()
            
            Text("\(entry.todayHitCount)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("today")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MediumWidgetView: View {
    let entry: AshTrailEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("AshTrail")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Spacer()
            
            // Main stats
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.todayHitCount) hits")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let config = entry.configuration, config.showStreak && entry.currentStreak > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(entry.currentStreak) day\(entry.currentStreak != 1 ? "s" : "")")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        Text("streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Last sync info (if enabled and space permits)
            if let config = entry.configuration, config.showLastSync {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatLastSync(entry.lastSyncAt))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
    }
    
    private func formatLastSync(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

#Preview(as: .systemSmall) {
    AshTrailWidget()
} timeline: {
    AshTrailEntry(
        date: .now,
        todayHitCount: 3,
        currentStreak: 5,
        lastSyncAt: .now,
        configuration: WidgetConfiguration(
            showStreak: true,
            showLastSync: false,
            tapAction: "openApp"
        )
    )
}

#Preview(as: .systemMedium) {
    AshTrailWidget()
} timeline: {
    AshTrailEntry(
        date: .now,
        todayHitCount: 7,
        currentStreak: 12,
        lastSyncAt: Date().addingTimeInterval(-1800), // 30 minutes ago
        configuration: WidgetConfiguration(
            showStreak: true,
            showLastSync: true,
            tapAction: "recordOverlay"
        )
    )
}