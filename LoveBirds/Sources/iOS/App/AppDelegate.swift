import UIKit
import LoveBirdsKit

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        await SyncEngine.shared.handleRemoteNotification()
        return .newData
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list]
    }

    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard response.actionIdentifier == "SEND_BACK" else { return }
        let info = response.notification.request.content.userInfo
        guard
            let partnerString = info["partnerID"] as? String,
            let partnerID = UUID(uuidString: partnerString),
            let partner = HeartStore.shared.partners.first(where: { $0.id == partnerID })
        else { return }
        let store = HeartStore.shared
        let heart = store.recordSent(partnerID: partner.id, vibe: partner.preferredVibe)
        HapticEngine.shared.play(pattern: store.pattern(id: heart.hapticPatternID))
        LiveActivityCoordinator.shared.start(for: partner, with: heart)
    }
}
