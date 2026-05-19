import WidgetKit
import SwiftUI
import LoveBirdsKit

@main
struct LoveBirdsWidgetBundle: WidgetBundle {
    var body: some Widget {
        HeartComplication()
        HeartLockScreenWidget()
        StreakWidget()
        HeartLiveActivityWidget()
    }
}
