import SwiftUI
import LoveBirdsKit

@main
struct LoveBirdsWatchApp: App {
    @State private var store = HeartStore.shared
    @State private var pulse = PulseShare()
    @WKApplicationDelegateAdaptor private var delegate: WatchDelegate

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environment(store)
                .environment(pulse)
                .task {
                    HapticEngine.shared.prepare()
                    await SyncEngine.shared.bootstrap()
                }
        }
    }
}

final class WatchDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        AppLogger.ui.info("Watch app launched")
    }

    func handleBackgroundTasks(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        Task {
            await SyncEngine.shared.handleRemoteNotification()
            for task in backgroundTasks {
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any]) async -> WKBackgroundFetchResult {
        await SyncEngine.shared.handleRemoteNotification()
        return .newData
    }
}
