import SwiftUI
import WidgetKit

@main
struct AshTrailWidgetBundle: WidgetBundle {
    var body: some Widget {
        HitsTodayComplication()
        TimeSinceLastHitComplication()
        AppLaunchComplication()
    }
}
