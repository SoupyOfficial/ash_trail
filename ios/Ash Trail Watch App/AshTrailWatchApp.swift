import SwiftUI

@main
struct AshTrailWatchApp: App {
    @StateObject private var sessionManager = WatchSessionManager.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                QuickLogView()
                    .environmentObject(sessionManager)

                QuickAnalyticsView()
                    .environmentObject(sessionManager)

                RecentEntriesView()
                    .environmentObject(sessionManager)
            }
            .tabViewStyle(.verticalPage)
        }
    }
}
