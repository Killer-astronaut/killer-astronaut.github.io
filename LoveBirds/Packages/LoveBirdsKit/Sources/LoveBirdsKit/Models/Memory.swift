import Foundation

public struct DayMemory: Identifiable, Hashable, Sendable {
    public let id: Date
    public let date: Date
    public let hearts: [Heart]

    public init(date: Date, hearts: [Heart]) {
        self.id = date
        self.date = date
        self.hearts = hearts
    }

    public var sentCount: Int { hearts.filter { $0.direction == .sent }.count }
    public var receivedCount: Int { hearts.filter { $0.direction == .received }.count }
    public var topVibe: HeartVibe? {
        let counts = Dictionary(grouping: hearts, by: \.vibe).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }
}

public enum MemoryEngine {
    public static func groupByDay(_ hearts: [Heart], calendar: Calendar = .current) -> [DayMemory] {
        let grouped = Dictionary(grouping: hearts) { heart in
            calendar.startOfDay(for: heart.sentAt)
        }
        return grouped
            .map { DayMemory(date: $0.key, hearts: $0.value.sorted(by: { $0.sentAt > $1.sentAt })) }
            .sorted(by: { $0.date > $1.date })
    }

    public static func onThisDay(_ hearts: [Heart], reference: Date = .now, calendar: Calendar = .current) -> [Heart] {
        let target = calendar.dateComponents([.month, .day], from: reference)
        return hearts.filter { heart in
            let comps = calendar.dateComponents([.month, .day], from: heart.sentAt)
            return comps.month == target.month && comps.day == target.day && !calendar.isDate(heart.sentAt, inSameDayAs: reference)
        }
    }
}
