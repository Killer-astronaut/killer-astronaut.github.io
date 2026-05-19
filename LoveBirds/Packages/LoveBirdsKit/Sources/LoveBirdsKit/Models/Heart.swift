import Foundation

public struct Heart: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let partnerID: Partner.ID
    public let vibe: HeartVibe
    public let sentAt: Date
    public let direction: Direction
    public let hapticPatternID: HapticPattern.ID
    public var deliveredAt: Date?
    public var readAt: Date?
    public var voicePingURL: URL?
    public var pulseBPM: Int?

    public enum Direction: String, Codable, Sendable {
        case sent, received
    }

    public init(
        id: UUID = UUID(),
        partnerID: Partner.ID,
        vibe: HeartVibe,
        sentAt: Date = .now,
        direction: Direction,
        hapticPatternID: HapticPattern.ID,
        deliveredAt: Date? = nil,
        readAt: Date? = nil,
        voicePingURL: URL? = nil,
        pulseBPM: Int? = nil
    ) {
        self.id = id
        self.partnerID = partnerID
        self.vibe = vibe
        self.sentAt = sentAt
        self.direction = direction
        self.hapticPatternID = hapticPatternID
        self.deliveredAt = deliveredAt
        self.readAt = readAt
        self.voicePingURL = voicePingURL
        self.pulseBPM = pulseBPM
    }
}

public extension Heart {
    static func preview(direction: Direction = .sent, vibe: HeartVibe = .heart, minutesAgo: Int = 0) -> Heart {
        Heart(
            partnerID: Partner.preview.id,
            vibe: vibe,
            sentAt: Date().addingTimeInterval(TimeInterval(-minutesAgo * 60)),
            direction: direction,
            hapticPatternID: vibe.defaultHapticPatternID,
            deliveredAt: direction == .sent ? Date() : nil
        )
    }
}
