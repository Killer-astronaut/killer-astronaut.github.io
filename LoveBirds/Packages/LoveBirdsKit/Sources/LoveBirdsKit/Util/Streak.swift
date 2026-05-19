import Foundation

public enum Streak {
    public static func current(from hearts: [Heart], for partnerID: Partner.ID, calendar: Calendar = .current, today: Date = .now) -> Int {
        let filtered = hearts.filter { $0.partnerID == partnerID }
        guard !filtered.isEmpty else { return 0 }

        let days = Set(filtered.map { calendar.startOfDay(for: $0.sentAt) })
        var streak = 0
        var cursor = calendar.startOfDay(for: today)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor)!

        if days.contains(cursor) {
            streak += 1
            cursor = yesterday
        } else if days.contains(yesterday) {
            cursor = yesterday
        } else {
            return 0
        }

        while days.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        return streak
    }

    public static func longestStreak(from hearts: [Heart], for partnerID: Partner.ID, calendar: Calendar = .current) -> Int {
        let days = Set(hearts.filter { $0.partnerID == partnerID }.map { calendar.startOfDay(for: $0.sentAt) }).sorted()
        guard !days.isEmpty else { return 0 }
        var longest = 1
        var current = 1
        for i in 1..<days.count {
            let prev = days[i - 1]
            let curr = days[i]
            if let next = calendar.date(byAdding: .day, value: 1, to: prev), calendar.isDate(next, inSameDayAs: curr) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }
}
