import Foundation
import Intents

// MARK: - Widget Configuration Intent
class AshTrailWidgetIntent: INIntent {
    // Intent for configuring widget display options
    // Can be extended to support metric selection, time ranges, etc.
}

// MARK: - Widget Type Enum
@available(iOS 14.0, *)
enum WidgetMetricType: Int, CaseIterable {
    case hitsToday = 0
    case totalDuration = 1
    case timeSinceLast = 2
    case weeklyPattern = 3

    var displayName: String {
        switch self {
        case .hitsToday:
            return "Hits Today"
        case .totalDuration:
            return "Total Duration"
        case .timeSinceLast:
            return "Time Since Last"
        case .weeklyPattern:
            return "Weekly Pattern"
        }
    }
}
