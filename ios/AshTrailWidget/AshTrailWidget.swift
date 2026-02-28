import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct AshTrailEntry: TimelineEntry {
    let date: Date
    let hitsToday: Int
    let totalDurationToday: TimeInterval
    let timeSinceLastHit: TimeInterval?
    let lastHitTime: Date?
    let weeklyHits: [Int] // Last 7 days
    let configuration: AshTrailWidgetIntent
}

// MARK: - Timeline Provider
struct AshTrailProvider: IntentTimelineProvider {
    typealias Entry = AshTrailEntry
    typealias Intent = AshTrailWidgetIntent

    func placeholder(in context: Context) -> AshTrailEntry {
        AshTrailEntry(
            date: Date(),
            hitsToday: 5,
            totalDurationToday: 1800, // 30 minutes
            timeSinceLastHit: 3600, // 1 hour
            lastHitTime: Date().addingTimeInterval(-3600),
            weeklyHits: [3, 5, 4, 6, 5, 7, 5],
            configuration: AshTrailWidgetIntent()
        )
    }

    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (AshTrailEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<AshTrailEntry>) -> Void) {
        let currentDate = Date()
        let data = SharedDataManager.shared.loadWidgetData()

        let entry = AshTrailEntry(
            date: currentDate,
            hitsToday: data.hitsToday,
            totalDurationToday: data.totalDurationToday,
            timeSinceLastHit: data.timeSinceLastHit,
            lastHitTime: data.lastHitTime,
            weeklyHits: data.weeklyHits,
            configuration: configuration
        )

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

// MARK: - Widget Views
struct AshTrailWidgetEntryView: View {
    var entry: AshTrailProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        @unknown default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (Hits Today)
struct SmallWidgetView: View {
    let entry: AshTrailEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(LinearGradient(
                    colors: [Color(red: 0.3, green: 0.2, blue: 0.4), Color(red: 0.2, green: 0.15, blue: 0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Spacer()
                }

                Spacer()

                Text("\(entry.hitsToday)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Hits Today")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Medium Widget (Hits + Duration)
struct MediumWidgetView: View {
    let entry: AshTrailEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(LinearGradient(
                    colors: [Color(red: 0.3, green: 0.2, blue: 0.4), Color(red: 0.2, green: 0.15, blue: 0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            HStack(spacing: 20) {
                // Hits Today
                VStack(spacing: 4) {
                    Text("\(entry.hitsToday)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Hits Today")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .background(Color.white.opacity(0.3))

                // Total Duration
                VStack(spacing: 4) {
                    Text(formatDuration(entry.totalDurationToday))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}

// MARK: - Large Widget (Full Stats + Weekly Pattern)
struct LargeWidgetView: View {
    let entry: AshTrailEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(LinearGradient(
                    colors: [Color(red: 0.3, green: 0.2, blue: 0.4), Color(red: 0.2, green: 0.15, blue: 0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            VStack(spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text("Ash Trail")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    if let lastHit = entry.lastHitTime {
                        Text(lastHit, style: .relative)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                // Stats Grid
                HStack(spacing: 16) {
                    StatCard(
                        value: "\(entry.hitsToday)",
                        label: "Hits Today",
                        icon: "circle.fill"
                    )

                    StatCard(
                        value: formatDuration(entry.totalDurationToday),
                        label: "Duration",
                        icon: "timer"
                    )
                }

                // Weekly Pattern
                VStack(alignment: .leading, spacing: 8) {
                    Text("7-Day Pattern")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(0..<entry.weeklyHits.count, id: \.self) { index in
                            let maxHits = entry.weeklyHits.max() ?? 1
                            let height = CGFloat(entry.weeklyHits[index]) / CGFloat(maxHits)

                            VStack(spacing: 2) {
                                Spacer()
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.orange.opacity(0.8))
                                    .frame(height: max(4, height * 60))

                                Text(dayLabel(for: index))
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 80)
                }

                Spacer()
            }
            .padding()
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }

    private func dayLabel(for index: Int) -> String {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let today = Calendar.current.component(.weekday, from: Date()) - 1
        let dayIndex = (today - 6 + index + 7) % 7
        return days[dayIndex]
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.orange)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Accessory Widgets (for Lock Screen)
struct CircularWidgetView: View {
    let entry: AshTrailEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("\(entry.hitsToday)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("today")
                    .font(.system(size: 10))
                    .textCase(.uppercase)
            }
        }
    }
}

struct RectangularWidgetView: View {
    let entry: AshTrailEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.hitsToday) hits today")
                    .font(.headline)

                if let lastHit = entry.lastHitTime {
                    Text(lastHit, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct InlineWidgetView: View {
    let entry: AshTrailEntry

    var body: some View {
        if let lastHit = entry.lastHitTime {
            Text("\(entry.hitsToday) hits • \(lastHit, style: .relative)")
        } else {
            Text("\(entry.hitsToday) hits today")
        }
    }
}

// MARK: - Widget Configuration
@main
struct AshTrailWidget: Widget {
    let kind: String = "AshTrailWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: AshTrailWidgetIntent.self,
            provider: AshTrailProvider()
        ) { entry in
            AshTrailWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ash Trail")
        .description("Track your usage statistics right from your home screen")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Preview
struct AshTrailWidget_Previews: PreviewProvider {
    static var previews: some View {
        let entry = AshTrailEntry(
            date: Date(),
            hitsToday: 7,
            totalDurationToday: 2400,
            timeSinceLastHit: 1800,
            lastHitTime: Date().addingTimeInterval(-1800),
            weeklyHits: [3, 5, 4, 6, 5, 7, 5],
            configuration: AshTrailWidgetIntent()
        )

        Group {
            AshTrailWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            AshTrailWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            AshTrailWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
