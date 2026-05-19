import Foundation
import SwiftUI
import LoveBirdsKit

@MainActor
final class PairingCoordinator {
    static let shared = PairingCoordinator()

    func handle(url: URL, into store: HeartStore) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.path.contains("/lovebirds/pair"),
              let token = components.queryItems?.first(where: { $0.name == "t" })?.value,
              let invite = PairingInvite.decode(token) else {
            return
        }
        let partner = Partner(
            displayName: invite.inviterName,
            initials: invite.inviterInitials,
            colorHex: invite.colorHex,
            cloudKitShareURL: invite.shareURL
        )
        store.addPartner(partner)
        HapticEngine.shared.play(pattern: HapticPattern.builtIn.rise)
    }
}
