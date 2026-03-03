import SwiftUI
import WidgetKit

// MARK: - App Launch Widget (Lock Screen shortcut)

struct AppLaunchWidget: Widget {
    let kind = "AppLaunchWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AppLaunchProvider()) { entry in
            AppLaunchView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Ash Trail")
        .description("Quick shortcut to open Ash Trail with your hit count.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryInline,
        ])
    }
}

// MARK: - Timeline Entry

struct AppLaunchEntry: TimelineEntry {
    let date: Date
    let hitsToday: Int
}

// MARK: - Timeline Provider

struct AppLaunchProvider: TimelineProvider {
    func placeholder(in context: Context) -> AppLaunchEntry {
        AppLaunchEntry(date: .now, hitsToday: 3)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AppLaunchEntry) -> Void) {
        completion(AppLaunchEntry(date: .now, hitsToday: iOSWidgetDataStore.hitsToday))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AppLaunchEntry>) -> Void) {
        let entry = AppLaunchEntry(date: .now, hitsToday: iOSWidgetDataStore.hitsToday)
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
            circularView
        case .accessoryInline:
            inlineView
        default:
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
        }
    }
    
    // MARK: - Lock Screen: Circular
    
    private var circularView: some View {
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
    }
    
    // MARK: - Lock Screen: Inline
    
    private var inlineView: some View {
        Label("Ash Trail · \(entry.hitsToday) hits", systemImage: "flame.fill")
    }
}
