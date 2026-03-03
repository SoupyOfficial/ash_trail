import Foundation
import WatchConnectivity
import WidgetKit

/// Manages WatchConnectivity on the watchOS side.
/// Sends requests to the iPhone and receives application context updates.
/// Caches last-known data for offline viewing.
class WatchSessionManager: NSObject, ObservableObject {
    static let shared = WatchSessionManager()

    @Published var recentEntries: [WatchLogEntry] = []
    @Published var analytics: WatchAnalytics = .empty
    @Published var isReachable = false
    @Published var isLoading = false
    @Published var lastError: String?

    private var session: WCSession?

    private override init() {
        super.init()
        activateSession()
    }

    private func activateSession() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    // MARK: - Send requests to iPhone

    /// Request the iPhone to create a log with the given duration
    func createLog(duration: Double, completion: @escaping (Bool, String?) -> Void) {
        guard let session, session.isReachable else {
            completion(false, "iPhone not reachable")
            return
        }

        let message: [String: Any] = [
            WatchMessageKey.action: WatchAction.createLog,
            WatchMessageKey.duration: duration,
        ]

        session.sendMessage(message, replyHandler: { reply in
            DispatchQueue.main.async {
                if let error = reply[WatchMessageKey.error] as? String {
                    self.lastError = error
                    completion(false, error)
                } else {
                    self.lastError = nil
                    completion(true, reply[WatchMessageKey.logId] as? String)
                }
            }
        }, errorHandler: { error in
            DispatchQueue.main.async {
                self.lastError = error.localizedDescription
                completion(false, error.localizedDescription)
            }
        })
    }

    /// Request fresh recent entries from the iPhone
    func refreshRecentEntries() {
        guard let session, session.isReachable else {
            // Reload complications with whatever cached data we have
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        isLoading = true
        let message: [String: Any] = [
            WatchMessageKey.action: WatchAction.getRecentEntries,
        ]

        session.sendMessage(message, replyHandler: { [weak self] reply in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.parseEntries(from: reply)
            }
        }, errorHandler: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.lastError = error.localizedDescription
            }
        })
    }

    /// Request fresh analytics from the iPhone
    func refreshAnalytics() {
        guard let session, session.isReachable else {
            // Reload complications with whatever cached data we have
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        isLoading = true
        let message: [String: Any] = [
            WatchMessageKey.action: WatchAction.getAnalytics,
        ]

        session.sendMessage(message, replyHandler: { [weak self] reply in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.parseAnalytics(from: reply)
            }
        }, errorHandler: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.lastError = error.localizedDescription
            }
        })
    }

    /// Refresh all data from the iPhone
    func refreshAll() {
        refreshRecentEntries()
        refreshAnalytics()
    }

    /// Called from background tasks — ensures session is active and attempts to fetch
    func backgroundRefresh() {
        if session == nil || session?.activationState != .activated {
            activateSession()
        }
        refreshAll()
    }

    // MARK: - Parse incoming data

    private func parseEntries(from data: [String: Any]) {
        guard let entriesData = data[WatchMessageKey.entries] as? [[String: Any]] else { return }
        recentEntries = entriesData.compactMap { WatchLogEntry(dictionary: $0) }
    }

    private func parseAnalytics(from data: [String: Any]) {
        guard let analyticsData = data[WatchMessageKey.analytics] as? [String: Any],
              let parsed = WatchAnalytics(dictionary: analyticsData) else { return }
        analytics = parsed
        updateComplications(with: parsed)
    }

    /// Write analytics to shared data store and reload complications
    private func updateComplications(with analytics: WatchAnalytics) {
        ComplicationDataStore.update(from: analytics)
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Parse combined context (analytics + entries) from applicationContext
    private func parseContext(from context: [String: Any]) {
        if let entriesData = context[WatchMessageKey.entries] as? [[String: Any]] {
            recentEntries = entriesData.compactMap { WatchLogEntry(dictionary: $0) }
        }
        if let analyticsData = context[WatchMessageKey.analytics] as? [String: Any],
           let parsed = WatchAnalytics(dictionary: analyticsData) {
            analytics = parsed
            updateComplications(with: parsed)
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }

        // Load any existing application context
        if !session.receivedApplicationContext.isEmpty {
            DispatchQueue.main.async {
                self.parseContext(from: session.receivedApplicationContext)
            }
        }

        // Request fresh data if reachable
        if session.isReachable {
            refreshAll()
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        if session.isReachable {
            refreshAll()
        }
    }

    /// Receive application context updates pushed from the iPhone
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.parseContext(from: applicationContext)
        }
    }

    /// Receive real-time messages from the iPhone (e.g., log confirmation)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let action = message[WatchMessageKey.action] as? String else { return }

        if action == WatchAction.dataUpdated {
            DispatchQueue.main.async {
                self.parseContext(from: message)
            }
        }
    }
}
