import Foundation
import SwiftUI

public struct Partner: Codable, Identifiable, Hashable, Sendable {
    public typealias ID = UUID

    public let id: ID
    public var displayName: String
    public var initials: String
    public var colorHex: String
    public var pairedAt: Date
    public var importantDates: [ImportantDate]
    public var quietHours: QuietHours?
    public var preferredVibe: HeartVibe
    public var customHapticPatternID: HapticPattern.ID?
    public var sharePulseEnabled: Bool
    public var homeZone: HomeZone?
    public var cloudKitShareURL: URL?

    public init(
        id: ID = UUID(),
        displayName: String,
        initials: String,
        colorHex: String = "#FF6B9D",
        pairedAt: Date = .now,
        importantDates: [ImportantDate] = [],
        quietHours: QuietHours? = nil,
        preferredVibe: HeartVibe = .heart,
        customHapticPatternID: HapticPattern.ID? = nil,
        sharePulseEnabled: Bool = false,
        homeZone: HomeZone? = nil,
        cloudKitShareURL: URL? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.initials = initials
        self.colorHex = colorHex
        self.pairedAt = pairedAt
        self.importantDates = importantDates
        self.quietHours = quietHours
        self.preferredVibe = preferredVibe
        self.customHapticPatternID = customHapticPatternID
        self.sharePulseEnabled = sharePulseEnabled
        self.homeZone = homeZone
        self.cloudKitShareURL = cloudKitShareURL
    }

    public var color: Color {
        Color(hex: colorHex) ?? Color(red: 1.0, green: 0.42, blue: 0.62)
    }
}

public struct ImportantDate: Codable, Identifiable, Hashable, Sendable {
    public var id: UUID
    public var label: String
    public var date: Date
    public var emoji: String

    public init(id: UUID = UUID(), label: String, date: Date, emoji: String = "🎉") {
        self.id = id
        self.label = label
        self.date = date
        self.emoji = emoji
    }
}

public struct QuietHours: Codable, Hashable, Sendable {
    public var start: DateComponents
    public var end: DateComponents
    public var respectFocus: Bool

    public init(start: DateComponents, end: DateComponents, respectFocus: Bool = true) {
        self.start = start
        self.end = end
        self.respectFocus = respectFocus
    }

    public func isActive(at date: Date = .now, calendar: Calendar = .current) -> Bool {
        let now = calendar.dateComponents([.hour, .minute], from: date)
        guard let nowMin = minutes(of: now),
              let startMin = minutes(of: start),
              let endMin = minutes(of: end) else { return false }
        if startMin <= endMin {
            return nowMin >= startMin && nowMin < endMin
        } else {
            return nowMin >= startMin || nowMin < endMin
        }
    }

    private func minutes(of comps: DateComponents) -> Int? {
        guard let h = comps.hour, let m = comps.minute else { return nil }
        return h * 60 + m
    }
}

public struct HomeZone: Codable, Hashable, Sendable {
    public var latitude: Double
    public var longitude: Double
    public var precision: Double

    public init(latitude: Double, longitude: Double, precision: Double = 0.1) {
        self.latitude = (latitude / precision).rounded() * precision
        self.longitude = (longitude / precision).rounded() * precision
        self.precision = precision
    }
}

public extension Partner {
    static let preview = Partner(
        displayName: "Sam",
        initials: "S",
        colorHex: "#FF6B9D",
        importantDates: [
            ImportantDate(label: "Anniversary", date: Date().addingTimeInterval(60 * 60 * 24 * 14), emoji: "💍"),
            ImportantDate(label: "Birthday", date: Date().addingTimeInterval(60 * 60 * 24 * 60), emoji: "🎂")
        ],
        preferredVibe: .heart
    )

    static let previewFamily: [Partner] = [
        preview,
        Partner(displayName: "Mom", initials: "M", colorHex: "#FF8FA3", preferredVibe: .hug),
        Partner(displayName: "Alex", initials: "A", colorHex: "#FFB3C1", preferredVibe: .thinkingOfYou)
    ]
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        guard hexSanitized.count == 6,
              let rgb = UInt64(hexSanitized, radix: 16) else { return nil }
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
