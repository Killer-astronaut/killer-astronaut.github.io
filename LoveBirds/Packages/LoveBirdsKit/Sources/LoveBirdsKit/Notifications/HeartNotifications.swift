import Foundation
import UserNotifications

@MainActor
public final class HeartNotifications {
    public static let shared = HeartNotifications()

    public init() {}

    public func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .providesAppNotificationSettings])
        } catch {
            return false
        }
    }

    public func scheduleIncoming(heart: Heart, from partner: Partner) async {
        if let quiet = partner.quietHours, quiet.isActive() {
            AppLogger.ui.info("Suppressed haptic for \(partner.displayName) — quiet hours active")
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "\(partner.initials) sent \(heart.vibe.emoji)"
        content.body = "Tap to send one back."
        content.interruptionLevel = .active
        content.sound = nil
        content.threadIdentifier = "lovebirds-\(partner.id.uuidString)"
        content.categoryIdentifier = "INCOMING_HEART"
        content.userInfo = [
            "partnerID": partner.id.uuidString,
            "heartID": heart.id.uuidString,
            "vibe": heart.vibe.rawValue
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: heart.id.uuidString, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            AppLogger.ui.error("Schedule notification failed: \(error.localizedDescription)")
        }
    }

    public func registerCategories() {
        let sendBack = UNNotificationAction(
            identifier: "SEND_BACK",
            title: "Send back ❤️",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: "INCOMING_HEART",
            actions: [sendBack],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
