import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

@MainActor
@Observable
public final class PulseShare {
    public private(set) var currentBPM: Int?
    public private(set) var isStreaming = false
    public private(set) var lastError: String?

    #if canImport(HealthKit)
    private let healthStore = HKHealthStore()
    private var query: HKAnchoredObjectQuery?
    #endif

    public init() {}

    public func requestAuthorization() async -> Bool {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable(),
              let heartType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return false
        }
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [heartType])
            return true
        } catch {
            lastError = error.localizedDescription
            return false
        }
        #else
        return false
        #endif
    }

    public func start() {
        #if canImport(HealthKit)
        guard !isStreaming, let heartType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        isStreaming = true
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-30), end: nil, options: .strictStartDate)
        let q = HKAnchoredObjectQuery(type: heartType, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, _, _ in
            self?.handle(samples: samples)
        }
        q.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.handle(samples: samples)
        }
        healthStore.execute(q)
        query = q
        #endif
    }

    public func stop() {
        #if canImport(HealthKit)
        if let q = query {
            healthStore.stop(q)
        }
        query = nil
        #endif
        isStreaming = false
        currentBPM = nil
    }

    #if canImport(HealthKit)
    private func handle(samples: [HKSample]?) {
        guard let samples = samples?.compactMap({ $0 as? HKQuantitySample }), !samples.isEmpty else { return }
        let unit = HKUnit.count().unitDivided(by: .minute())
        let latest = samples.max(by: { $0.startDate < $1.startDate })
        if let latest {
            let bpm = Int(latest.quantity.doubleValue(for: unit).rounded())
            Task { @MainActor in
                self.currentBPM = bpm
            }
        }
    }
    #endif

    public static func pattern(forBPM bpm: Int) -> HapticPattern {
        let interval = max(60.0 / Double(bpm), 0.3)
        return HapticPattern(
            id: "pulse.\(bpm)",
            displayName: "Pulse \(bpm)bpm",
            events: [
                HapticPattern.Event(time: 0.0, intensity: 0.95, sharpness: 0.75),
                HapticPattern.Event(time: 0.18, intensity: 0.5, sharpness: 0.4),
                HapticPattern.Event(time: interval, intensity: 0.95, sharpness: 0.75),
                HapticPattern.Event(time: interval + 0.18, intensity: 0.5, sharpness: 0.4)
            ]
        )
    }
}
