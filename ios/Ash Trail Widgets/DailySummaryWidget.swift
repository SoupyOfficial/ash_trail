import SwiftUI
import WidgetKit

// MARK: - Daily Summary Widget

struct DailySummaryWidget: Widget {
    let kind = "DailySummaryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailySummaryProvider()) { entry in
            DailySummaryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Summary")
        .description("Overview of today's stats including hits, duration, and gaps.")
        .supportedFamilies([
            .systemMedium,
            .systemLarge,
        ])
    }
}

// MARK: - Timeline Entry

struct DailySummaryEntry: TimelineEntry {
    let date: Date
    let hitsToday: Int
    let totalDuration: String
    let timeSinceLastHit: String
    let averageGap: String?
    let averageDuration: String?
    let longestGap: String?
    let dailyAverageHits: String?
    let lastHitDate: Date?
}

// MARK: - Timeline Provider

struct DailySummaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailySummaryEntry {
        DailySummaryEntry(
            date: .now,
            hitsToday: 5,
            totalDuration: "2m 30s",
            timeSinceLastHit: "30m",
            averageGap: "45m",
            averageDuration: "28s",
            longestGap: "2h 15m",
            dailyAverageHits: "8.2",
            lastHitDate: .now.addingTimeInterval(-1800)
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DailySummaryEntry) -> Void) {
        completion(currentEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DailySummaryEntry>) -> Void) {
        let entry = currentEntry()
        // Refresh every 15 minutes; views use Text(date, style: .relative) for live countdown
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    private func currentEntry() -> DailySummaryEntry {
        entryFor(date: .now)
    }
    
    private func entryFor(date: Date) -> DailySummaryEntry {
        let lastHit = iOSWidgetDataStore.lastHitDate
        let elapsed: String
        if let lastHit {
            elapsed = iOSWidgetDataStore.formatElapsed(date.timeIntervalSince(lastHit))
        } else {
            elapsed = "--"
        }
        
        return DailySummaryEntry(
            date: date,
            hitsToday: iOSWidgetDataStore.hitsToday,
            totalDuration: iOSWidgetDataStore.formatDuration(iOSWidgetDataStore.totalDurationToday),
            timeSinceLastHit: elapsed,
            averageGap: iOSWidgetDataStore.averageGapSeconds.map { iOSWidgetDataStore.formatGap($0) },
            averageDuration: iOSWidgetDataStore.averageDurationSeconds.map { iOSWidgetDataStore.formatDuration($0) },
            longestGap: iOSWidgetDataStore.longestGapSeconds.map { iOSWidgetDataStore.formatGap($0) },
            dailyAverageHits: iOSWidgetDataStore.dailyAverageHits.map { String(format: "%.1f", $0) },
            lastHitDate: lastHit
        )
    }
}

// MARK: - Views

struct DailySummaryView: View {
    @Environment(\.widgetFamily) var family
    let entry: DailySummaryEntry
    
    var body: some View {
        switch family {
        case .systemMedium:
            systemMediumView
        case .systemLarge:
            systemLargeView
        default:
            Text("Daily Summary")
        }
    }
    
    // MARK: - System Medium
    
    private var systemMediumView: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Today's Summary")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }
            
            // 2×2 grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                StatCell(icon: "flame", label: "Hits", value: "\(entry.hitsToday)", color: .orange)
                StatCell(icon: "timer", label: "Duration", value: entry.totalDuration, color: .blue)
                timeSinceLastStatCell
                StatCell(icon: "arrow.left.and.right", label: "Avg Gap", value: entry.averageGap ?? "--", color: .purple)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Time Since Last (live countdown)
    
    private var timeSinceLastStatCell: some View {
        VStack(alignment: .leading, spacing: 3) {
            Label("Since Last", systemImage: "clock.arrow.circlepath")
                .font(.caption2)
                .foregroundStyle(.green)
                .lineLimit(1)
            if let lastHit = entry.lastHitDate {
                Text(lastHit, style: .relative)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            } else {
                Text("--")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - System Large
    
    private var systemLargeView: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("Today's Summary")
                    .font(.headline)
                Spacer()
                if let lastHit = entry.lastHitDate {
                    Text("Last: ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    + Text(lastHit, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Primary stats: 2×2
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                StatCell(icon: "flame", label: "Hits", value: "\(entry.hitsToday)", color: .orange)
                StatCell(icon: "timer", label: "Total Duration", value: entry.totalDuration, color: .blue)
                timeSinceLastStatCell
                StatCell(icon: "arrow.left.and.right", label: "Avg Gap", value: entry.averageGap ?? "--", color: .purple)
            }
            
            Divider()
            
            // Secondary stats
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                StatCell(icon: "stopwatch", label: "Avg Duration", value: entry.averageDuration ?? "--", color: .cyan)
                StatCell(icon: "arrow.up.and.down", label: "Longest Gap", value: entry.longestGap ?? "--", color: .teal)
            }
            
            // Daily average comparison
            if let avg = entry.dailyAverageHits {
                HStack {
                    Image(systemName: "chart.bar")
                        .foregroundStyle(.secondary)
                    Text("Daily average: \(avg) hits")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    let diff = entry.hitsToday - Int(Double(avg) ?? 0)
                    if diff > 0 {
                        Text("+\(diff)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.red)
                    } else if diff < 0 {
                        Text("\(diff)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.green)
                    } else {
                        Text("on avg")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 4)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Stat Cell Component

struct StatCell: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Label(label, systemImage: icon)
                .font(.caption2)
                .foregroundStyle(color)
                .lineLimit(1)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
