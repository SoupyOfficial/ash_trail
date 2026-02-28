import Flutter
import UIKit
import GoogleMaps
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let widgetChannelName = "com.soupy.ashtrail/widget"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Google Maps from Info.plist
    // API key should be set in Info.plist as GOOGLE_MAPS_API_KEY
    // For local development, set it via environment variable or xcconfig
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String,
       !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    } else {
      // Fallback: try environment variable (for CI/CD)
      if let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"],
         !apiKey.isEmpty {
        GMSServices.provideAPIKey(apiKey)
      } else {
        print("⚠️ Warning: Google Maps API key not found. Maps functionality may be limited.")
      }
    }

    // Setup widget method channel
    if let controller = window?.rootViewController as? FlutterViewController {
      setupWidgetChannel(controller: controller)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupWidgetChannel(controller: FlutterViewController) {
    let widgetChannel = FlutterMethodChannel(
      name: widgetChannelName,
      binaryMessenger: controller.binaryMessenger
    )

    widgetChannel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "updateWidgetData":
        self?.handleUpdateWidgetData(call: call, result: result)
      case "reloadWidgets":
        self?.handleReloadWidgets(result: result)
      case "isWidgetAvailable":
        self?.handleIsWidgetAvailable(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func handleUpdateWidgetData(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      return
    }

    // Extract widget data
    let hitsToday = args["hitsToday"] as? Int ?? 0
    let totalDurationToday = args["totalDurationToday"] as? Double ?? 0
    let timeSinceLastHit = args["timeSinceLastHit"] as? Double
    let lastHitTimeString = args["lastHitTime"] as? String
    let weeklyHits = args["weeklyHits"] as? [Int] ?? [0, 0, 0, 0, 0, 0, 0]

    // Parse last hit time
    var lastHitTime: Date?
    if let lastHitTimeString = lastHitTimeString {
      let formatter = ISO8601DateFormatter()
      lastHitTime = formatter.date(from: lastHitTimeString)
    }

    // Create widget data object
    let widgetData = WidgetData(
      hitsToday: hitsToday,
      totalDurationToday: totalDurationToday,
      timeSinceLastHit: timeSinceLastHit,
      lastHitTime: lastHitTime,
      weeklyHits: weeklyHits,
      lastUpdated: Date()
    )

    // Save to shared container
    SharedDataManager.shared.saveWidgetData(widgetData)

    // Reload widgets
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }

    result(true)
  }

  private func handleReloadWidgets(result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
      result(true)
    } else {
      result(false)
    }
  }

  private func handleIsWidgetAvailable(result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      result(true)
    } else {
      result(false)
    }
  }
}
