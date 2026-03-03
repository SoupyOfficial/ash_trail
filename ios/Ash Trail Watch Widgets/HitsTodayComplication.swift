import SwiftUI
import WidgetKit

// MARK: - Hits Today Complication

struct HitsTodayComplication: Widget {
    let kind = "HitsTodayComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HitsTodayProvider()) { entry in
            HitsTodayView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Hits Today")
        .description("Shows your hit count for today.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular,
        ])
    }
}

// MARK: - Timeline Provider

struct HitsTodayEntry: TimelineEntry {
    let date: Date
    let hitsToday: Int
    let totalDuration: String
}

struct HitsTodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> HitsTodayEntry {
        HitsTodayEntry(date: .now, hitsToday: 5, totalDuration: "2m 30s")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HitsTodayEntry) -> Void) {
        completion(currentEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HitsTodayEntry>) -> Void) {
        let entry = currentEntry()
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    private func currentEntry() -> HitsTodayEntry {
        let hits = ComplicationDataStore.hitsToday
        let duration = ComplicationDataStore.totalDurationToday
        let formatted = formatDuration(duration)
        return HitsTodayEntry(date: .now, hitsToday: hits, totalDuration: formatted)
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        let total = Int(seconds)
        if total < 60 { return "\(total)s" }
        if total < 3600 { return "\(total / 60)m \(total % 60)s" }
        return "\(total / 3600)h \((total % 3600) / 60)m"
    }
}

// MARK: - Views

struct HitsTodayView: View {
    @Environment(\.widgetFamily) var family
    let entry: HitsTodayEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 1) {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("\(entry.hitsToday)")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.6)
            }
            .widgetLabel("Hits")
        
        case .accessoryCorner:
            Text("\(entry.hitsToday)")
                .font(.system(.title, design: .rounded, weight: .bold))
                .widgetLabel {
                    Label("Hits", systemImage: "flame.fill")
                }
        
        case .accessoryInline:
            Label("\(entry.hitsToday) hits today", systemImage: "flame.fill")
        
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Label("Hits Today", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("\(entry.hitsToday)")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Text(entry.totalDuration)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        
        default:
            Text("\(entry.hitsToday)")
        }
    }
}
