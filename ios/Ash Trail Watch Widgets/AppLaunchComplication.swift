import SwiftUI
import WidgetKit

// MARK: - App Launch Complication (shortcut to open the app)

struct AppLaunchComplication: Widget {
    let kind = "AppLaunchComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AppLaunchProvider()) { entry in
            AppLaunchView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Ash Trail")
        .description("Quick shortcut to open Ash Trail.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
        ])
    }
}

// MARK: - Timeline Provider

struct AppLaunchEntry: TimelineEntry {
    let date: Date
    let hitsToday: Int
}

struct AppLaunchProvider: TimelineProvider {
    func placeholder(in context: Context) -> AppLaunchEntry {
        AppLaunchEntry(date: .now, hitsToday: 3)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AppLaunchEntry) -> Void) {
        completion(AppLaunchEntry(date: .now, hitsToday: ComplicationDataStore.hitsToday))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AppLaunchEntry>) -> Void) {
        let entry = AppLaunchEntry(date: .now, hitsToday: ComplicationDataStore.hitsToday)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Views

struct AppLaunchView: View {
    @Environment(\.widgetFamily) var family
    let entry: AppLaunchEntry
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    Text("\(entry.hitsToday)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                }
            }
        
        case .accessoryCorner:
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(.orange)
                .widgetLabel("\(entry.hitsToday) hits")
        
        case .accessoryInline:
            Label("Ash Trail · \(entry.hitsToday) hits", systemImage: "flame.fill")
        
        default:
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
        }
    }
}
