import SwiftUI
import WidgetKit

// MARK: - Time Since Last Hit Complication

struct TimeSinceLastHitComplication: Widget {
    let kind = "TimeSinceLastHitComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimeSinceProvider()) { entry in
            TimeSinceView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Since Last Hit")
        .description("Shows elapsed time since your last hit.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular,
        ])
    }
}

// MARK: - Timeline Provider

struct TimeSinceEntry: TimelineEntry {
    let date: Date
    let lastHitDate: Date?
    let formattedElapsed: String
}

struct TimeSinceProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimeSinceEntry {
        TimeSinceEntry(date: .now, lastHitDate: .now.addingTimeInterval(-1800), formattedElapsed: "30m")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimeSinceEntry) -> Void) {
        completion(currentEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TimeSinceEntry>) -> Void) {
        let lastHit = ComplicationDataStore.lastHitDate
        var entries: [TimeSinceEntry] = []
        let now = Date.now
        
        // Generate entries every minute for the next 30 minutes so the display updates
        for minuteOffset in 0..<30 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: now)!
            let elapsed: String
            if let lastHit {
                elapsed = formatElapsed(entryDate.timeIntervalSince(lastHit))
            } else {
                elapsed = "--"
            }
            entries.append(TimeSinceEntry(date: entryDate, lastHitDate: lastHit, formattedElapsed: elapsed))
        }
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: now)!
        completion(Timeline(entries: entries, policy: .after(nextUpdate)))
    }
    
    private func currentEntry() -> TimeSinceEntry {
        let lastHit = ComplicationDataStore.lastHitDate
        let elapsed: String
        if let lastHit {
            elapsed = formatElapsed(Date.now.timeIntervalSince(lastHit))
        } else {
            elapsed = "--"
        }
        return TimeSinceEntry(date: .now, lastHitDate: lastHit, formattedElapsed: elapsed)
    }
    
    private func formatElapsed(_ seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds))
        if total < 60 { return "\(total)s" }
        if total < 3600 { return "\(total / 60)m" }
        let h = total / 3600
        let m = (total % 3600) / 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
}

// MARK: - Views

struct TimeSinceView: View {
    @Environment(\.widgetFamily) var family
    let entry: TimeSinceEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 1) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text(entry.formattedElapsed)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.5)
            }
            .widgetLabel("Since Last")
        
        case .accessoryCorner:
            Text(entry.formattedElapsed)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .widgetLabel {
                    Label("Since Last", systemImage: "clock.arrow.circlepath")
                }
        
        case .accessoryInline:
            Label("\(entry.formattedElapsed) since last hit", systemImage: "clock.arrow.circlepath")
        
        case .accessoryRectangular:
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
        
        default:
            Text(entry.formattedElapsed)
        }
    }
}
