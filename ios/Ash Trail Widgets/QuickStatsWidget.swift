import SwiftUI
import WidgetKit

// MARK: - Quick Stats Widget

struct QuickStatsWidget: Widget {
    let kind = "QuickStatsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickStatsProvider()) { entry in
            QuickStatsView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quick Stats")
        .description("Compact overview of today's hit count and time since last hit.")
        .supportedFamilies([
            .systemSmall,
        ])
    }
}

// MARK: - Timeline Entry

struct QuickStatsEntry: TimelineEntry {
    let date: Date
    let hitsToday: Int
    let timeSinceLastHit: String
    let dailyAverageHits: Double?
}

// MARK: - Timeline Provider

struct QuickStatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickStatsEntry {
        QuickStatsEntry(date: .now, hitsToday: 5, timeSinceLastHit: "30m", dailyAverageHits: 8.2)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuickStatsEntry) -> Void) {
        completion(currentEntry(at: .now))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickStatsEntry>) -> Void) {
        var entries: [QuickStatsEntry] = []
        let now = Date.now
        
        // Generate entries every minute for 30 minutes
        for minuteOffset in 0..<30 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: now)!
            entries.append(currentEntry(at: entryDate))
        }
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: now)!
        completion(Timeline(entries: entries, policy: .after(nextUpdate)))
    }
    
    private func currentEntry(at date: Date) -> QuickStatsEntry {
        let lastHit = iOSWidgetDataStore.lastHitDate
        let elapsed: String
        if let lastHit {
            elapsed = iOSWidgetDataStore.formatElapsed(date.timeIntervalSince(lastHit))
        } else {
            elapsed = "--"
        }
        return QuickStatsEntry(
            date: date,
            hitsToday: iOSWidgetDataStore.hitsToday,
            timeSinceLastHit: elapsed,
            dailyAverageHits: iOSWidgetDataStore.dailyAverageHits
        )
    }
}

// MARK: - Views

struct QuickStatsView: View {
    let entry: QuickStatsEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Flame icon
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(.orange)
            
            // Hit count (prominent)
            Text("\(entry.hitsToday)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            // Label
            Text("today")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer(minLength: 0)
            
            // Footer: time since last
            HStack(spacing: 4) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.caption2)
                    .foregroundStyle(.green)
                Text(entry.timeSinceLastHit)
                    .font(.caption.weight(.medium))
            }
            
            // Trend indicator
            if let avg = entry.dailyAverageHits, avg > 0 {
                let diff = Double(entry.hitsToday) - avg
                HStack(spacing: 2) {
                    if diff > 0 {
                        Image(systemName: "arrow.up.right")
                            .font(.caption2)
                            .foregroundStyle(.red)
                        Text("+\(Int(diff))")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    } else if diff < 0 {
                        Image(systemName: "arrow.down.right")
                            .font(.caption2)
                            .foregroundStyle(.green)
                        Text("\(Int(diff))")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else {
                        Text("on avg")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
