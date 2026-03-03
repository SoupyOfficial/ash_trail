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
        let entry = currentEntry()
        // Refresh every 15 minutes; views use Text(date, style: .relative) for live countdown
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
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
            if let lastHit = entry.lastHitDate {
                Text(lastHit, style: .relative)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
            } else {
                Text("--")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
            }
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
                if let lastHit = entry.lastHitDate {
                    Text(lastHit, style: .relative)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .minimumScaleFactor(0.6)
                        .multilineTextAlignment(.center)
                } else {
                    Text("--")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                }
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
            if let lastHit = entry.lastHitDate {
                Text(lastHit, style: .relative)
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
            } else {
                Text("--")
                    .font(.system(.body, design: .rounded, weight: .bold))
            }
        }
        .widgetLabel("Since Last")
    }
    
    // MARK: - Lock Screen: Rectangular
    
    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label("Since Last Hit", systemImage: "clock.arrow.circlepath")
                .font(.caption)
                .foregroundStyle(.green)
            if let lastHit = entry.lastHitDate {
                Text(lastHit, style: .relative)
                    .font(.system(.title3, design: .rounded, weight: .bold))
            } else {
                Text("--")
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }
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
        if let lastHit = entry.lastHitDate {
            Label {
                Text(lastHit, style: .relative)
                + Text(" since last hit")
            } icon: {
                Image(systemName: "clock.arrow.circlepath")
            }
        } else {
            Label("-- since last hit", systemImage: "clock.arrow.circlepath")
        }
    }
}
