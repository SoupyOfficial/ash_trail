import SwiftUI
import WatchKit
import WidgetKit

@main
struct AshTrailWatchApp: App {
    @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    @StateObject private var sessionManager = WatchSessionManager.shared
    @Environment(\.scenePhase) private var scenePhase

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
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    // Fetch fresh data from phone whenever the watch app opens
                    sessionManager.refreshAll()
                    // Also reload complication timelines so they show fresh data
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }
}

// MARK: - Extension Delegate for Background Refresh

class ExtensionDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        scheduleNextBackgroundRefresh()
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let refreshTask as WKApplicationRefreshBackgroundTask:
                // Trigger data fetch from phone
                WatchSessionManager.shared.backgroundRefresh()
                // Reload complications with latest cached data
                WidgetCenter.shared.reloadAllTimelines()
                // Schedule the next background refresh
                scheduleNextBackgroundRefresh()
                refreshTask.setTaskCompletedWithSnapshot(false)

            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: .distantFuture, userInfo: nil)

            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Data arrived via WatchConnectivity while app was in background
                WidgetCenter.shared.reloadAllTimelines()
                connectivityTask.setTaskCompletedWithSnapshot(false)

            case let urlTask as WKURLSessionRefreshBackgroundTask:
                urlTask.setTaskCompletedWithSnapshot(false)

            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    private func scheduleNextBackgroundRefresh() {
        // Schedule a background refresh 15 minutes from now
        let preferredDate = Date().addingTimeInterval(15 * 60)
        WKApplication.shared().scheduleBackgroundRefresh(
            withPreferredDate: preferredDate,
            userInfo: nil
        ) { error in
            if let error {
                print("⌚ Failed to schedule background refresh: \(error)")
            } else {
                print("⌚ Background refresh scheduled for \(preferredDate)")
            }
        }
    }
}
