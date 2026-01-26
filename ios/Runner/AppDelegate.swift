import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
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
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
