import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif

@MainActor
public final class LiveActivityCoordinator {
    public static let shared = LiveActivityCoordinator()
    public init() {}

    public func start(for partner: Partner, with heart: Heart) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attrs = HeartActivityAttributes(
            partnerID: partner.id,
            partnerName: partner.displayName,
            initials: partner.initials,
            colorHex: partner.colorHex
        )
        let state = HeartActivityAttributes.ContentState(
            vibe: heart.vibe,
            sentAt: heart.sentAt,
            bpm: heart.pulseBPM,
            direction: heart.direction
        )
        do {
            _ = try Activity.request(
                attributes: attrs,
                content: .init(state: state, staleDate: Date().addingTimeInterval(60 * 5)),
                pushType: nil
            )
        } catch {
            AppLogger.ui.error("Live Activity failed: \(error.localizedDescription)")
        }
        #endif
    }

    public func endAll() async {
        #if canImport(ActivityKit)
        for activity in Activity<HeartActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        #endif
    }
}
