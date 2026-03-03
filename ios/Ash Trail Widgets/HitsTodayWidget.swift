import SwiftUI
import WidgetKit

// MARK: - Hits Today Widget

struct HitsTodayWidget: Widget {
    let kind = "HitsTodayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HitsTodayProvider()) { entry in
            HitsTodayView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Hits Today")
        .description("Shows your hit count and total duration for today.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

// MARK: - Timeline Entry

struct HitsTodayEntry: TimelineEntry {
    let date: Date
    let hitsToday: Int
    let totalDuration: String
    let averageGap: String?
}

// MARK: - Timeline Provider

struct HitsTodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> HitsTodayEntry {
        HitsTodayEntry(date: .now, hitsToday: 5, totalDuration: "2m 30s", averageGap: "45m")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HitsTodayEntry) -> Void) {
        completion(currentEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HitsTodayEntry>) -> Void) {
        let entry = currentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    private func currentEntry() -> HitsTodayEntry {
        let hits = iOSWidgetDataStore.hitsToday
        let duration = iOSWidgetDataStore.formatDuration(iOSWidgetDataStore.totalDurationToday)
        let gap: String? = iOSWidgetDataStore.averageGapSeconds.map { iOSWidgetDataStore.formatGap($0) }
        return HitsTodayEntry(date: .now, hitsToday: hits, totalDuration: duration, averageGap: gap)
    }
}

// MARK: - Views

struct HitsTodayView: View {
    @Environment(\.widgetFamily) var family
    let entry: HitsTodayEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            systemSmallView
        case .systemMedium:
            systemMediumView
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            Text("\(entry.hitsToday)")
        }
    }
    
    // MARK: - System Small
    
    private var systemSmallView: some View {
        VStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.orange)
            Text("\(entry.hitsToday)")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .minimumScaleFactor(0.6)
            Text("hits today")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(entry.totalDuration)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - System Medium
    
    private var systemMediumView: some View {
        HStack(spacing: 0) {
            // Left: hit count
            VStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                Text("\(entry.hitsToday)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text("hits today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .padding(.vertical, 12)
            
            // Right: details
            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text(entry.totalDuration)
                        .font(.subheadline.weight(.medium))
                } icon: {
                    Image(systemName: "timer")
                        .foregroundStyle(.blue)
                }
                
                if let gap = entry.averageGap {
                    Label {
                        Text("avg gap: \(gap)")
                            .font(.subheadline.weight(.medium))
                    } icon: {
                        Image(systemName: "arrow.left.and.right")
                            .foregroundStyle(.green)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Lock Screen: Circular
    
    private var circularView: some View {
        VStack(spacing: 1) {
            Image(systemName: "flame.fill")
                .font(.caption)
                .foregroundStyle(.orange)
            Text("\(entry.hitsToday)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .minimumScaleFactor(0.6)
        }
        .widgetLabel("Hits")
    }
    
    // MARK: - Lock Screen: Rectangular
    
    private var rectangularView: some View {
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
    }
    
    // MARK: - Lock Screen: Inline
    
    private var inlineView: some View {
        Label("\(entry.hitsToday) hits today", systemImage: "flame.fill")
    }
}
