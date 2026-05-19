import Foundation

@MainActor
@Observable
public final class HapticComposer {
    public private(set) var events: [HapticPattern.Event] = []
    public var name: String = "My Pattern"

    public init() {}

    public func loadFrom(_ pattern: HapticPattern) {
        events = pattern.events
        name = pattern.displayName
    }

    public func addTap(at time: Double, intensity: Double, sharpness: Double) {
        events.append(.init(time: max(0, time), intensity: intensity, sharpness: sharpness))
        events.sort { $0.time < $1.time }
    }

    public func remove(at index: Int) {
        guard events.indices.contains(index) else { return }
        events.remove(at: index)
    }

    public func clear() {
        events.removeAll()
    }

    public func build(idPrefix: String = "custom") -> HapticPattern {
        let id = "\(idPrefix).\(UUID().uuidString.prefix(8))"
        return HapticPattern(id: String(id), displayName: name, events: events)
    }
}
