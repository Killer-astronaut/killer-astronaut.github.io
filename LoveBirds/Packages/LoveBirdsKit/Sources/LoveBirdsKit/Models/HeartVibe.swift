import Foundation
import SwiftUI

public enum HeartVibe: String, Codable, CaseIterable, Identifiable, Sendable {
    case heart
    case hug
    case kiss
    case coffee
    case goodMorning
    case goodNight
    case thinkingOfYou
    case onMyWay
    case missYou
    case proud
    case loveYou
    case sunshine
    case star
    case rainbow
    case fire
    case heartbeat

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .heart: return "Heart"
        case .hug: return "Hug"
        case .kiss: return "Kiss"
        case .coffee: return "Coffee"
        case .goodMorning: return "Good morning"
        case .goodNight: return "Good night"
        case .thinkingOfYou: return "Thinking of you"
        case .onMyWay: return "On my way"
        case .missYou: return "Miss you"
        case .proud: return "Proud of you"
        case .loveYou: return "Love you"
        case .sunshine: return "Sunshine"
        case .star: return "Star"
        case .rainbow: return "Rainbow"
        case .fire: return "Fire"
        case .heartbeat: return "Heartbeat"
        }
    }

    public var symbol: String {
        switch self {
        case .heart: return "heart.fill"
        case .hug: return "person.2.fill"
        case .kiss: return "mouth.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .goodMorning: return "sun.max.fill"
        case .goodNight: return "moon.stars.fill"
        case .thinkingOfYou: return "sparkles"
        case .onMyWay: return "figure.walk"
        case .missYou: return "envelope.fill"
        case .proud: return "rosette"
        case .loveYou: return "heart.text.square.fill"
        case .sunshine: return "sunrise.fill"
        case .star: return "star.fill"
        case .rainbow: return "rainbow"
        case .fire: return "flame.fill"
        case .heartbeat: return "waveform.path.ecg"
        }
    }

    public var emoji: String {
        switch self {
        case .heart: return "❤️"
        case .hug: return "🤗"
        case .kiss: return "💋"
        case .coffee: return "☕️"
        case .goodMorning: return "🌅"
        case .goodNight: return "🌙"
        case .thinkingOfYou: return "✨"
        case .onMyWay: return "🚶"
        case .missYou: return "💌"
        case .proud: return "🏅"
        case .loveYou: return "💖"
        case .sunshine: return "☀️"
        case .star: return "⭐️"
        case .rainbow: return "🌈"
        case .fire: return "🔥"
        case .heartbeat: return "💓"
        }
    }

    public var defaultHapticPatternID: HapticPattern.ID {
        switch self {
        case .heartbeat: return HapticPattern.builtIn.heartbeat.id
        case .kiss, .loveYou, .heart: return HapticPattern.builtIn.pulse.id
        case .hug: return HapticPattern.builtIn.embrace.id
        case .fire, .star: return HapticPattern.builtIn.burst.id
        case .goodMorning, .sunshine: return HapticPattern.builtIn.rise.id
        case .goodNight: return HapticPattern.builtIn.fade.id
        default: return HapticPattern.builtIn.tap.id
        }
    }

    public var defaultTint: Color {
        switch self {
        case .heart, .loveYou, .heartbeat, .kiss: return Color(red: 1.0, green: 0.42, blue: 0.62)
        case .hug, .missYou: return Color(red: 1.0, green: 0.56, blue: 0.64)
        case .coffee: return Color(red: 0.71, green: 0.52, blue: 0.35)
        case .goodMorning, .sunshine: return Color(red: 1.0, green: 0.78, blue: 0.31)
        case .goodNight: return Color(red: 0.50, green: 0.46, blue: 0.92)
        case .thinkingOfYou, .star: return Color(red: 0.87, green: 0.75, blue: 0.40)
        case .onMyWay: return Color(red: 0.40, green: 0.78, blue: 0.92)
        case .proud: return Color(red: 0.96, green: 0.62, blue: 0.27)
        case .rainbow: return Color(red: 0.87, green: 0.41, blue: 0.78)
        case .fire: return Color(red: 1.0, green: 0.32, blue: 0.22)
        }
    }
}
