import Foundation

public struct SmartNudge: Identifiable, Hashable, Sendable {
    public enum Tone: String, Sendable {
        case warm, playful, gentle, important
    }

    public let id: UUID
    public let partnerID: Partner.ID
    public let title: String
    public let body: String
    public let suggestedVibe: HeartVibe
    public let tone: Tone
    public let createdAt: Date

    public init(id: UUID = UUID(), partnerID: Partner.ID, title: String, body: String, suggestedVibe: HeartVibe, tone: Tone, createdAt: Date = .now) {
        self.id = id
        self.partnerID = partnerID
        self.title = title
        self.body = body
        self.suggestedVibe = suggestedVibe
        self.tone = tone
        self.createdAt = createdAt
    }
}

public enum NudgeEngine {
    public static func generate(
        for partner: Partner,
        from hearts: [Heart],
        today: Date = .now,
        calendar: Calendar = .current
    ) -> [SmartNudge] {
        var nudges: [SmartNudge] = []

        let partnerHearts = hearts.filter { $0.partnerID == partner.id }
        let lastSent = partnerHearts.filter { $0.direction == .sent }.map(\.sentAt).max()

        if let last = lastSent {
            let days = calendar.dateComponents([.day], from: last, to: today).day ?? 0
            if days >= 3 {
                nudges.append(SmartNudge(
                    partnerID: partner.id,
                    title: "It's been a few days",
                    body: "You haven't tapped \(partner.displayName) in \(days) days. Want to say hi?",
                    suggestedVibe: partner.preferredVibe,
                    tone: .gentle
                ))
            }
        } else if calendar.dateComponents([.day], from: partner.pairedAt, to: today).day ?? 0 >= 1 {
            nudges.append(SmartNudge(
                partnerID: partner.id,
                title: "Send your first heart",
                body: "Try a quick tap so \(partner.displayName) feels you on their wrist.",
                suggestedVibe: .heart,
                tone: .warm
            ))
        }

        for date in partner.importantDates {
            let comps = calendar.dateComponents([.month, .day], from: date.date)
            let today = calendar.dateComponents([.month, .day], from: today)
            if comps.month == today.month && comps.day == today.day {
                nudges.append(SmartNudge(
                    partnerID: partner.id,
                    title: "\(date.emoji) \(date.label) today",
                    body: "A heart now would land just right.",
                    suggestedVibe: .loveYou,
                    tone: .important
                ))
            }
        }

        let memories = MemoryEngine.onThisDay(partnerHearts, reference: today, calendar: calendar)
        if !memories.isEmpty {
            nudges.append(SmartNudge(
                partnerID: partner.id,
                title: "On this day",
                body: "You and \(partner.displayName) exchanged \(memories.count) hearts on this date in the past.",
                suggestedVibe: memories.first?.vibe ?? .heart,
                tone: .playful
            ))
        }

        let lastReceived = partnerHearts.filter { $0.direction == .received }.max(by: { $0.sentAt < $1.sentAt })
        if let last = lastReceived,
           lastSent == nil || lastSent! < last.sentAt {
            nudges.append(SmartNudge(
                partnerID: partner.id,
                title: "Send one back",
                body: "\(partner.displayName) sent you a \(last.vibe.label.lowercased()). Tap them back?",
                suggestedVibe: last.vibe,
                tone: .warm
            ))
        }

        return nudges
    }
}
