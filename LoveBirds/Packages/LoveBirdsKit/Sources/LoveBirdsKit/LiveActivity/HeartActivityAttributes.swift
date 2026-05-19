import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif

public struct HeartActivityAttributes: Hashable, Codable, Sendable {
    public let partnerID: Partner.ID
    public let partnerName: String
    public let initials: String
    public let colorHex: String

    public init(partnerID: Partner.ID, partnerName: String, initials: String, colorHex: String) {
        self.partnerID = partnerID
        self.partnerName = partnerName
        self.initials = initials
        self.colorHex = colorHex
    }

    public struct ContentState: Hashable, Codable, Sendable {
        public let vibe: HeartVibe
        public let sentAt: Date
        public let bpm: Int?
        public let direction: Heart.Direction

        public init(vibe: HeartVibe, sentAt: Date = .now, bpm: Int? = nil, direction: Heart.Direction = .received) {
            self.vibe = vibe
            self.sentAt = sentAt
            self.bpm = bpm
            self.direction = direction
        }
    }
}

#if canImport(ActivityKit)
extension HeartActivityAttributes: ActivityAttributes {}
#endif
