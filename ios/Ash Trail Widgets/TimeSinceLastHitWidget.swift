import SwiftUI
import WidgetKit

// MARK: - Time Since Last Hit Widget

struct TimeSinceLastHitWidget: Widget {
    let kind = "TimeSinceLastHitWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeSinceProvider()) { entry in
            TimeSinceView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Since Last Hit")
        .description("Shows elapsed time since your last hit.")
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

struct TimeSinceEntry: TimelineEntry {
    let date: Date
    let lastHitDate: Date?
    let formattedElapsed: String
    let averageGap: String?
}

// MARK: - Timeline Provider

struct TimeSinceProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimeSinceEntry {
        TimeSinceEntry(date: .now, lastHitDate: .now.addingTimeInterval(-1800), formattedElapsed: "30m", averageGap: "45m")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimeSinceEntry) -> Void) {
        completion(currentEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeSinceEntry>) -> Void) {
        let lastHit = iOSWidgetDataStore.lastHitDate
        let gap: String? = iOSWidgetDataStore.averageGapSeconds.map { iOSWidgetDataStore.formatGap($0) }
        var entries: [TimeSinceEntry] = []
        let now = Date.now
        
        // Generate entries every minute for the next 30 minutes so the display updates
        for minuteOffset in 0..<30 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: now)!
            let elapsed: String
            if let lastHit {
                elapsed = iOSWidgetDataStore.formatElapsed(entryDate.timeIntervalSince(lastHit))
            } else {
                elapsed = "--"
            }
            entries.append(TimeSinceEntry(date: entryDate, lastHitDate: lastHit, formattedElapsed: elapsed, averageGap: gap))
        }
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: now)!
        completion(Timeline(entries: entries, policy: .after(nextUpdate)))
    }
    
    private func currentEntry() -> TimeSinceEntry {
        let lastHit = iOSWidgetDataStore.lastHitDate
        let gap: String? = iOSWidgetDataStore.averageGapSeconds.map { iOSWidgetDataStore.formatGap($0) }
        let elapsed: String
        if let lastHit {
            elapsed = iOSWidgetDataStore.formatElapsed(Date.now.timeIntervalSince(lastHit))
        } else {
            elapsed = "--"
        }
        return TimeSinceEntry(date: .now, lastHitDate: lastHit, formattedElapsed: elapsed, averageGap: gap)
    }
}

// MARK: - Views

struct TimeSinceView: View {
    @Environment(\.widgetFamily) var family
    let entry: TimeSinceEntry
    
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
            Text(entry.formattedElapsed)
        }
    }
    
    // MARK: - System Small
    
    private var systemSmallView: some View {
        VStack(spacing: 6) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title2)
                .foregroundStyle(.green)
            Text(entry.formattedElapsed)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .minimumScaleFactor(0.5)
            Text("since last hit")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let lastHit = entry.lastHitDate {
                Text(lastHit, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - System Medium
    
    private var systemMediumView: some View {
        HStack(spacing: 0) {
            // Left: elapsed time
            VStack(spacing: 4) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title3)
                    .foregroundStyle(.green)
                Text(entry.formattedElapsed)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.6)
                Text("since last hit")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .padding(.vertical, 12)
            
            // Right: details
            VStack(alignment: .leading, spacing: 8) {
                if let lastHit = entry.lastHitDate {
                    Label {
                        Text(lastHit, style: .time)
                            .font(.subheadline.weight(.medium))
                    } icon: {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                    }
                }
                
                if let gap = entry.averageGap {
                    Label {
                        Text("avg gap: \(gap)")
                            .font(.subheadline.weight(.medium))
                    } icon: {
                        Image(systemName: "arrow.left.and.right")
                            .foregroundStyle(.blue)
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
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption)
                .foregroundStyle(.green)
            Text(entry.formattedElapsed)
                .font(.system(.body, design: .rounded, weight: .bold))
                .minimumScaleFactor(0.5)
        }
        .widgetLabel("Since Last")
    }
    
    // MARK: - Lock Screen: Rectangular
    
    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("Since Last Hit", systemImage: "clock.arrow.circlepath")
                .font(.caption)
                .foregroundStyle(.green)
            Text(entry.formattedElapsed)
                .font(.system(.title2, design: .rounded, weight: .bold))
            if let lastHit = entry.lastHitDate {
                Text(lastHit, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Lock Screen: Inline
    
    private var inlineView: some View {
        Label("\(entry.formattedElapsed) since last hit", systemImage: "clock.arrow.circlepath")
    }
}
