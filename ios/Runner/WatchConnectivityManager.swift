import Foundation
import WatchConnectivity
import Flutter

/// Manages WatchConnectivity on the iOS (iPhone) side.
/// Receives messages from the Apple Watch and forwards them to Flutter via a MethodChannel.
/// Also pushes application context updates to the watch when Flutter sends new data.
class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    private var methodChannel: FlutterMethodChannel?
    private var session: WCSession?

    @Published var isReachable = false

    private override init() {
        super.init()
    }

    /// Call this from AppDelegate after Flutter engine is ready
    func configure(with controller: FlutterViewController) {
        methodChannel = FlutterMethodChannel(
            name: "com.soup.smokeLog/watch",
            binaryMessenger: controller.binaryMessenger
        )
        setupMethodChannelHandler()
        activateSession()
    }

    private func activateSession() {
        guard WCSession.isSupported() else {
            print("⌚ WatchConnectivity not supported on this device")
            return
        }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        print("⌚ WCSession activation requested")
    }

    // MARK: - Flutter → Watch (push data to watch)

    private func setupMethodChannelHandler() {
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterError(code: "UNAVAILABLE", message: "Manager deallocated", details: nil))
                return
            }

            switch call.method {
            case "pushContext":
                // Flutter pushes updated analytics + recent entries to the watch
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
                    return
                }
                self.pushContextToWatch(args)
                result(true)

            case "isWatchReachable":
                result(self.session?.isReachable ?? false)

            case "isWatchPaired":
                result(self.session?.isPaired ?? false)

            case "sendLogConfirmation":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
                    return
                }
                self.sendMessageToWatch(args)
                result(true)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Push application context to the watch (queued & delivered even if watch app isn't running)
    private func pushContextToWatch(_ context: [String: Any]) {
        guard let session, session.isPaired else {
            print("⌚ Cannot push context: watch not paired")
            return
        }
        do {
            try session.updateApplicationContext(context)
            print("⌚ Application context pushed to watch")
        } catch {
            print("⌚ Failed to push application context: \(error)")
        }
    }

    /// Send a real-time message to the watch (only works when watch app is reachable)
    private func sendMessageToWatch(_ message: [String: Any]) {
        guard let session, session.isReachable else {
            print("⌚ Cannot send message: watch not reachable")
            return
        }
        session.sendMessage(message, replyHandler: nil) { error in
            print("⌚ Failed to send message to watch: \(error)")
        }
    }

    // MARK: - Watch → Flutter (forward watch requests to Flutter)

    private func forwardToFlutter(method: String, arguments: Any?, replyHandler: (([String: Any]) -> Void)?) {
        guard let methodChannel else {
            print("⌚ MethodChannel not configured yet")
            replyHandler?(["error": "Bridge not ready"])
            return
        }

        methodChannel.invokeMethod(method, arguments: arguments) { result in
            if let error = result as? FlutterError {
                print("⌚ Flutter returned error: \(error.message ?? "unknown")")
                replyHandler?(["error": error.message ?? "Unknown error"])
            } else if let response = result as? [String: Any] {
                replyHandler?(response)
            } else {
                replyHandler?(["success": true])
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        if let error {
            print("⌚ WCSession activation failed: \(error)")
        } else {
            print("⌚ WCSession activated: \(activationState.rawValue), paired: \(session.isPaired), reachable: \(session.isReachable)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("⌚ WCSession became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("⌚ WCSession deactivated, reactivating...")
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        print("⌚ Watch reachability changed: \(session.isReachable)")
    }

    /// Handle real-time messages from the watch
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        guard let action = message[WatchMessageKey.action] as? String else {
            replyHandler(["error": "Missing action"])
            return
        }

        print("⌚ Received watch message: \(action)")

        switch action {
        case WatchAction.createLog:
            forwardToFlutter(method: "createLog", arguments: message, replyHandler: replyHandler)

        case WatchAction.getRecentEntries:
            forwardToFlutter(method: "getRecentEntries", arguments: message, replyHandler: replyHandler)

        case WatchAction.getAnalytics:
            forwardToFlutter(method: "getAnalytics", arguments: message, replyHandler: replyHandler)

        default:
            replyHandler(["error": "Unknown action: \(action)"])
        }
    }
}
