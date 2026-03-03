import SwiftUI
import WidgetKit

@main
struct AshTrailIOSWidgetBundle: WidgetBundle {
    var body: some Widget {
        HitsTodayWidget()
        TimeSinceLastHitWidget()
        DailySummaryWidget()
        QuickStatsWidget()
        AppLaunchWidget()
    }
}
