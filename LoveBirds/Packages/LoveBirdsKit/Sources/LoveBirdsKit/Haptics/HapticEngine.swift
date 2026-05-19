import Foundation
import CoreHaptics
#if canImport(WatchKit)
import WatchKit
#endif
#if canImport(UIKit)
import UIKit
#endif

@MainActor
public final class HapticEngine {
    public static let shared = HapticEngine()

    private var engine: CHHapticEngine?
    private var supportsCoreHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    public init() {
        prepare()
    }

    public func prepare() {
        guard supportsCoreHaptics, engine == nil else { return }
        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { [weak self] _ in
                self?.engine = nil
            }
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            try engine?.start()
        } catch {
            AppLogger.haptics.error("Haptic engine init failed: \(error.localizedDescription)")
        }
    }

    public func play(pattern: HapticPattern) {
        if supportsCoreHaptics {
            playCore(pattern: pattern)
        } else {
            playFallback(pattern: pattern)
        }
    }

    private func playCore(pattern: HapticPattern) {
        guard let engine else {
            prepare()
            playFallback(pattern: pattern)
            return
        }
        do {
            let events = pattern.events.map { event -> CHHapticEvent in
                let isContinuous = event.duration > 0
                return CHHapticEvent(
                    eventType: isContinuous ? .hapticContinuous : .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(event.intensity)),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(event.sharpness))
                    ],
                    relativeTime: event.time,
                    duration: max(event.duration, 0.05)
                )
            }
            let chPattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: chPattern)
            try player.start(atTime: 0)
        } catch {
            AppLogger.haptics.error("Play pattern failed: \(error.localizedDescription)")
            playFallback(pattern: pattern)
        }
    }

    private func playFallback(pattern: HapticPattern) {
        #if canImport(WatchKit)
        let kind: WKHapticType = pattern.events.count > 2 ? .notification : .success
        WKInterfaceDevice.current().play(kind)
        #elseif canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: CGFloat(pattern.events.first?.intensity ?? 0.8))
        #endif
    }
}
