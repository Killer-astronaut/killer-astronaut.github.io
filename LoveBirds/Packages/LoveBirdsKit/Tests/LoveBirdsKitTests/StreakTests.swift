import XCTest
@testable import LoveBirdsKit

final class StreakTests: XCTestCase {
    func testStreakCountsConsecutiveDays() throws {
        let partner = Partner(displayName: "Test", initials: "T")
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        let hearts: [Heart] = (0..<5).map { offset in
            Heart(
                partnerID: partner.id,
                vibe: .heart,
                sentAt: calendar.date(byAdding: .day, value: -offset, to: today)!,
                direction: .sent,
                hapticPatternID: HapticPattern.builtIn.tap.id
            )
        }
        let streak = Streak.current(from: hearts, for: partner.id, calendar: calendar, today: today)
        XCTAssertEqual(streak, 5)
    }

    func testStreakIsZeroWhenStaleTwoDays() throws {
        let partner = Partner(displayName: "Test", initials: "T")
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        let heart = Heart(
            partnerID: partner.id,
            vibe: .heart,
            sentAt: calendar.date(byAdding: .day, value: -2, to: today)!,
            direction: .sent,
            hapticPatternID: HapticPattern.builtIn.tap.id
        )
        let streak = Streak.current(from: [heart], for: partner.id, calendar: calendar, today: today)
        XCTAssertEqual(streak, 0)
    }
}

final class HapticPatternTests: XCTestCase {
    func testBuiltInLookupFallsBack() {
        let pattern = HapticPattern.builtIn.by(id: "nonsense")
        XCTAssertEqual(pattern.id, HapticPattern.builtIn.tap.id)
    }

    func testHeartbeatHasFourEvents() {
        XCTAssertEqual(HapticPattern.builtIn.heartbeat.events.count, 4)
    }

    func testEventClampsIntensity() {
        let event = HapticPattern.Event(time: 0, intensity: 2.5, sharpness: -0.5)
        XCTAssertEqual(event.intensity, 1)
        XCTAssertEqual(event.sharpness, 0)
    }
}

final class PairingInviteTests: XCTestCase {
    func testRoundtripEncoding() throws {
        let url = URL(string: "https://example.com/share")!
        let invite = PairingInvite(inviterName: "Sam", inviterInitials: "S", colorHex: "#FF6B9D", shareURL: url)
        let token = try XCTUnwrap(invite.encoded())
        let decoded = try XCTUnwrap(PairingInvite.decode(token))
        XCTAssertEqual(decoded.inviterName, invite.inviterName)
        XCTAssertEqual(decoded.shareURL, invite.shareURL)
    }
}

final class NudgeEngineTests: XCTestCase {
    func testNudgesWhenSilent() {
        let partner = Partner(displayName: "Sam", initials: "S", pairedAt: Date().addingTimeInterval(-86400 * 10))
        let cal = Calendar(identifier: .gregorian)
        let oldHeart = Heart(
            partnerID: partner.id,
            vibe: .heart,
            sentAt: Date().addingTimeInterval(-86400 * 7),
            direction: .sent,
            hapticPatternID: HapticPattern.builtIn.tap.id
        )
        let nudges = NudgeEngine.generate(for: partner, from: [oldHeart], today: .now, calendar: cal)
        XCTAssertFalse(nudges.isEmpty)
    }
}
