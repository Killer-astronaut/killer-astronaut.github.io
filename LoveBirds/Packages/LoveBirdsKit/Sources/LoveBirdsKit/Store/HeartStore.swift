import Foundation
import Observation

@MainActor
@Observable
public final class HeartStore {
    public static let shared = HeartStore()

    public private(set) var partners: [Partner] = []
    public private(set) var hearts: [Heart] = []
    public private(set) var customPatterns: [HapticPattern] = []
    public var tipsGiven: Int = 0
    public var lastNudgeDismissedAt: Date?

    public var isOnboarded: Bool {
        !partners.isEmpty
    }

    private let persistence: PersistenceController
    private var hasLoaded = false

    public init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
        load()
    }

    public func load() {
        guard !hasLoaded else { return }
        hasLoaded = true
        if let snapshot = persistence.loadSnapshot() {
            self.partners = snapshot.partners
            self.hearts = snapshot.hearts
            self.customPatterns = snapshot.customPatterns
            self.tipsGiven = snapshot.tipsGiven
        } else {
            seedIfDebug()
        }
    }

    public func patterns() -> [HapticPattern] {
        HapticPattern.builtIn.all + customPatterns
    }

    public func pattern(id: HapticPattern.ID) -> HapticPattern {
        if let custom = customPatterns.first(where: { $0.id == id }) { return custom }
        return HapticPattern.builtIn.by(id: id)
    }

    public func addPartner(_ partner: Partner) {
        partners.append(partner)
        persist()
    }

    public func updatePartner(_ partner: Partner) {
        guard let idx = partners.firstIndex(where: { $0.id == partner.id }) else { return }
        partners[idx] = partner
        persist()
    }

    public func removePartner(id: Partner.ID) {
        partners.removeAll { $0.id == id }
        hearts.removeAll { $0.partnerID == id }
        persist()
    }

    @discardableResult
    public func recordSent(partnerID: Partner.ID, vibe: HeartVibe, hapticPatternID: HapticPattern.ID? = nil, pulseBPM: Int? = nil) -> Heart {
        let partner = partners.first(where: { $0.id == partnerID })
        let patternID = hapticPatternID
            ?? partner?.customHapticPatternID
            ?? vibe.defaultHapticPatternID
        let heart = Heart(
            partnerID: partnerID,
            vibe: vibe,
            direction: .sent,
            hapticPatternID: patternID,
            deliveredAt: Date(),
            pulseBPM: pulseBPM
        )
        hearts.insert(heart, at: 0)
        persist()
        return heart
    }

    public func recordReceived(_ heart: Heart) {
        guard !hearts.contains(where: { $0.id == heart.id }) else { return }
        hearts.insert(heart, at: 0)
        persist()
    }

    public func markRead(_ heartID: Heart.ID) {
        guard let idx = hearts.firstIndex(where: { $0.id == heartID }) else { return }
        hearts[idx].readAt = Date()
        persist()
    }

    public func saveCustomPattern(_ pattern: HapticPattern) {
        if let idx = customPatterns.firstIndex(where: { $0.id == pattern.id }) {
            customPatterns[idx] = pattern
        } else {
            customPatterns.append(pattern)
        }
        persist()
    }

    public func hearts(for partnerID: Partner.ID) -> [Heart] {
        hearts.filter { $0.partnerID == partnerID }
    }

    public func streak(for partnerID: Partner.ID) -> Int {
        Streak.current(from: hearts, for: partnerID)
    }

    public func lastHeart(for partnerID: Partner.ID) -> Heart? {
        hearts.first(where: { $0.partnerID == partnerID })
    }

    public func nudges(for partner: Partner) -> [SmartNudge] {
        NudgeEngine.generate(for: partner, from: hearts)
    }

    public func incrementTipCount() {
        tipsGiven += 1
        persist()
    }

    private func persist() {
        let snapshot = PersistenceController.Snapshot(
            partners: partners,
            hearts: hearts,
            customPatterns: customPatterns,
            tipsGiven: tipsGiven
        )
        persistence.save(snapshot)
    }

    private func seedIfDebug() {
        #if DEBUG
        guard ProcessInfo.processInfo.environment["LOVEBIRDS_SEED"] == "1" else { return }
        let sam = Partner.preview
        partners = [sam]
        hearts = (0..<7).map { i in
            Heart(
                partnerID: sam.id,
                vibe: HeartVibe.allCases.randomElement() ?? .heart,
                sentAt: Date().addingTimeInterval(-Double(i) * 3600 * 8),
                direction: i.isMultiple(of: 2) ? .sent : .received,
                hapticPatternID: HeartVibe.heart.defaultHapticPatternID,
                deliveredAt: Date()
            )
        }
        persist()
        #endif
    }
}
