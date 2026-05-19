import Foundation

public struct HapticPattern: Codable, Identifiable, Hashable, Sendable {
    public typealias ID = String

    public let id: ID
    public var displayName: String
    public var events: [Event]

    public struct Event: Codable, Hashable, Sendable {
        public var time: Double
        public var intensity: Double
        public var sharpness: Double
        public var duration: Double

        public init(time: Double, intensity: Double = 0.8, sharpness: Double = 0.6, duration: Double = 0.0) {
            self.time = time
            self.intensity = min(max(intensity, 0), 1)
            self.sharpness = min(max(sharpness, 0), 1)
            self.duration = max(duration, 0)
        }
    }

    public init(id: ID, displayName: String, events: [Event]) {
        self.id = id
        self.displayName = displayName
        self.events = events
    }

    public var totalDuration: Double {
        guard let last = events.last else { return 0 }
        return last.time + max(last.duration, 0.05)
    }
}

public extension HapticPattern {
    enum builtIn {
        public static let tap = HapticPattern(
            id: "builtin.tap",
            displayName: "Tap",
            events: [Event(time: 0.0, intensity: 0.9, sharpness: 0.7)]
        )

        public static let pulse = HapticPattern(
            id: "builtin.pulse",
            displayName: "Pulse",
            events: [
                Event(time: 0.0, intensity: 0.7, sharpness: 0.5),
                Event(time: 0.18, intensity: 1.0, sharpness: 0.7)
            ]
        )

        public static let heartbeat = HapticPattern(
            id: "builtin.heartbeat",
            displayName: "Heartbeat",
            events: [
                Event(time: 0.0, intensity: 0.95, sharpness: 0.8),
                Event(time: 0.18, intensity: 0.5, sharpness: 0.4),
                Event(time: 0.95, intensity: 0.95, sharpness: 0.8),
                Event(time: 1.13, intensity: 0.5, sharpness: 0.4)
            ]
        )

        public static let embrace = HapticPattern(
            id: "builtin.embrace",
            displayName: "Embrace",
            events: [
                Event(time: 0.0, intensity: 0.45, sharpness: 0.2, duration: 0.9),
                Event(time: 0.45, intensity: 0.7, sharpness: 0.3, duration: 0.5)
            ]
        )

        public static let burst = HapticPattern(
            id: "builtin.burst",
            displayName: "Burst",
            events: [
                Event(time: 0.0, intensity: 1.0, sharpness: 0.95),
                Event(time: 0.08, intensity: 0.9, sharpness: 0.9),
                Event(time: 0.16, intensity: 0.8, sharpness: 0.85),
                Event(time: 0.24, intensity: 0.7, sharpness: 0.8)
            ]
        )

        public static let rise = HapticPattern(
            id: "builtin.rise",
            displayName: "Rise",
            events: [
                Event(time: 0.0, intensity: 0.3, sharpness: 0.3, duration: 0.4),
                Event(time: 0.4, intensity: 0.55, sharpness: 0.5, duration: 0.4),
                Event(time: 0.8, intensity: 0.9, sharpness: 0.7)
            ]
        )

        public static let fade = HapticPattern(
            id: "builtin.fade",
            displayName: "Fade",
            events: [
                Event(time: 0.0, intensity: 0.95, sharpness: 0.6, duration: 0.5),
                Event(time: 0.5, intensity: 0.4, sharpness: 0.4, duration: 0.5),
                Event(time: 1.0, intensity: 0.1, sharpness: 0.2, duration: 0.4)
            ]
        )

        public static var all: [HapticPattern] {
            [tap, pulse, heartbeat, embrace, burst, rise, fade]
        }

        public static func by(id: HapticPattern.ID) -> HapticPattern {
            all.first(where: { $0.id == id }) ?? tap
        }
    }
}
